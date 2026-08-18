import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as dart_crypto;
import 'package:ffi/ffi.dart';
import 'package:sequelize_orm_quickjs/src/quickjs_bindings.dart';

/// High-level wrapper around the embedded QuickJS JavaScript engine.
///
/// Manages a single JS runtime context, provides Promise/async execution,
/// and registers host polyfills for `net.Socket`, `crypto`, and timers so
/// that the bundled Sequelize bridge can run without Node.js.
///
/// Usage:
/// ```dart
/// final rt = await QuickJsRuntime.create();
/// rt.loadBundle(myBundleJs);
/// final result = await rt.callAsync('findAll', {'modelName': 'Post', ...});
/// rt.dispose();
/// ```
class QuickJsRuntime {
  final QuickJsBindings _bindings;
  late final QjsDartRuntimePtr _handle;
  bool _disposed = false;

  /// Pending Dart Completers for JS Promises, keyed by promise-id.
  final Map<int, Completer<dynamic>> _pendingPromises = {};
  int _promiseIdCounter = 0;

  /// Active Dart TCP socket contexts, keyed by socket-id.
  final Map<int, _DartSocketContext> _sockets = {};

  /// Active Dart Timers, keyed by timer-id.
  final Map<int, Timer> _timers = {};

  /// Callback for notifications dispatched from JavaScript (e.g. SQL logging).
  void Function(Map<String, dynamic>)? onNotification;

  /// Native function pointer kept alive for the lifetime of this runtime.
  Pointer<NativeFunction<DartBridgeCallbackC>>? _nativeCb;

  QuickJsRuntime._(this._bindings);

  /// Mapping of active runtimes by handle address to support multi-runtime isolation.
  static final Map<int, QuickJsRuntime> _runtimesByHandle = {};

  /// Create and initialise a new QuickJS runtime with all polyfills installed.
  static Future<QuickJsRuntime> create() async {
    final rt = QuickJsRuntime._(QuickJsBindings.instance);
    rt._handle = rt._bindings.createRuntime();
    if (rt._handle == nullptr) {
      throw StateError(
        'Failed to create QuickJS runtime — native library may not be loaded',
      );
    }
    rt._installCallback();
    rt._installJsPolyfillLayer();
    return rt;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Dart ↔ JS bridge callback
  // ────────────────────────────────────────────────────────────────────────

  void _installCallback() {
    _runtimesByHandle[_handle.address] = this;
    _nativeCb = Pointer.fromFunction<DartBridgeCallbackC>(
      _dispatchFromJs,
    );
    _bindings.setCallback(_nativeCb!);
    _bindings.setRuntimeCallback(_handle, _nativeCb!);
  }

  /// Static dispatcher called from C when `_ffiNotify(name, argsJson)` is
  /// invoked inside the QuickJS context. Routes to the appropriate Dart handler.
  static Pointer<Utf8> _dispatchFromJs(
    Pointer<Utf8> namePtr,
    Pointer<Utf8> argsPtr,
  ) {
    final name = namePtr.toDartString();
    final argsJson = argsPtr.toDartString();

    final rt = _runtimesByHandle.values.isNotEmpty
        ? _runtimesByHandle.values.first
        : null;
    if (rt == null) return nullptr;

    return rt._handleBridgeCall(name, argsJson);
  }

  Pointer<Utf8> _handleBridgeCall(String name, String argsJson) {
    try {
      Map<String, dynamic> args = {};
      try {
        final decoded = jsonDecode(argsJson);
        if (decoded is Map) args = Map<String, dynamic>.from(decoded);
      } catch (_) {}

      switch (name) {
        case '_dart_promise_resolve':
          final id = (args['id'] as num).toInt();
          _pendingPromises.remove(id)?.complete(args['value']);

        case '_dart_promise_reject':
          final id = (args['id'] as num).toInt();
          final error = args['error'] as String? ?? 'Unknown error';
          _pendingPromises.remove(id)?.completeError(Exception(error));

        case '_dart_socket_connect':
          _handleSocketConnect(args);

        case '_dart_socket_write':
          final socketId = (args['id'] as num).toInt();
          final b64 = args['data'] as String;
          _sockets[socketId]?.write(base64Decode(b64));

        case '_dart_socket_destroy':
          final socketId = (args['id'] as num).toInt();
          _sockets.remove(socketId)?.destroy();

        case '_dart_random_bytes':
          final count = (args['count'] as num).toInt();
          final bytes = _secureRandomBytes(count);
          final result = jsonEncode(base64Encode(bytes));
          return result.toNativeUtf8();

        case '_dart_hash':
          final algorithm = args['algorithm'] as String;
          final data = args['data'];
          final hex = _computeHash(algorithm, data);
          return jsonEncode(hex).toNativeUtf8();

        case '_dart_subtle_hmac':
          final algorithm = (args['algorithm'] as String?) ?? 'sha256';
          final key = args['key'];
          final data = args['data'];
          final bytes = _computeHmac(algorithm, key, data);
          return jsonEncode(base64Encode(bytes)).toNativeUtf8();

        case '_dart_subtle_pbkdf2':
          final password = args['password'];
          final salt = args['salt'];
          final iterations = (args['iterations'] as num?)?.toInt() ?? 4096;
          final lengthBytes = (args['lengthBytes'] as num?)?.toInt() ?? 32;
          final bytes = _pbkdf2(password, salt, iterations, lengthBytes);
          return jsonEncode(base64Encode(bytes)).toNativeUtf8();

        case '_dart_notification':
          onNotification?.call(args);
          return nullptr;

        case '_dart_timer_set':
          final timerId = (args['id'] as num).toInt();
          final ms = (args['ms'] as num?)?.toInt() ?? 0;
          final repeat = args['repeat'] as bool? ?? false;
          if (repeat) {
            _timers[timerId] = Timer.periodic(
              Duration(milliseconds: ms),
              (_) => _onTimerTrigger(timerId),
            );
          } else {
            _timers[timerId] = Timer(
              Duration(milliseconds: ms),
              () => _onTimerTrigger(timerId),
            );
          }

        case '_dart_timer_clear':
          if (args['id'] != null && args['id'] is num) {
            final timerId = (args['id'] as num).toInt();
            _timers.remove(timerId)?.cancel();
          }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[QuickJsRuntime] Bridge call "$name" error: $e');
    }

    return nullptr;
  }

  void _handleSocketConnect(Map<String, dynamic> args) {
    final socketId = (args['id'] as num).toInt();
    final host = args['host'] as String;
    final port = (args['port'] as num).toInt();
    final useTls = args['tls'] as bool? ?? false;

    _DartSocketContext.connect(
      socketId: socketId,
      host: host,
      port: port,
      useTls: useTls,
      onData: (data) => _onSocketData(socketId, data),
      onClose: () => _onSocketClose(socketId),
      onError: (e) => _onSocketError(socketId, e.toString()),
    ).then((ctx) {
      _sockets[socketId] = ctx;
      _bindings.emitSocketEvent(_handle, socketId, 'connect');
      _bindings.pumpAll(_handle);
    }).catchError((e) {
      _bindings.emitSocketError(_handle, socketId, e.toString());
      _bindings.pumpAll(_handle);
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // JS polyfill layer
  // ────────────────────────────────────────────────────────────────────────

  void _installJsPolyfillLayer() {
    // language=javascript
    const polyfill = r"""
(function() {
  'use strict';

  globalThis.global = globalThis;
  globalThis.window = globalThis;
  globalThis.self = globalThis;

  // ── EventEmitter ─────────────────────────────────────────────────────────
  class EventEmitter {
    constructor() { this._events = Object.create(null); }
    on(event, fn) {
      const e = this._events[event];
      if (!e) this._events[event] = fn;
      else if (typeof e === 'function') this._events[event] = [e, fn];
      else e.push(fn);
      return this;
    }
    addListener(event, fn) { return this.on(event, fn); }
    once(event, fn) {
      const wrapper = (...args) => { this.off(event, wrapper); fn.apply(this, args); };
      wrapper._orig = fn;
      return this.on(event, wrapper);
    }
    off(event, fn) {
      const e = this._events[event];
      if (!e) return this;
      if (e === fn || e._orig === fn) {
        delete this._events[event];
      } else if (Array.isArray(e)) {
        this._events[event] = e.filter(f => f !== fn && f._orig !== fn);
        if (this._events[event].length === 1) this._events[event] = this._events[event][0];
      }
      return this;
    }
    removeListener(event, fn) { return this.off(event, fn); }
    emit(event, ...args) {
      const e = this._events[event];
      if (!e) return false;
      if (typeof e === 'function') {
        e.apply(this, args);
      } else {
        const copy = e.slice();
        for (let i = 0; i < copy.length; i++) copy[i].apply(this, args);
      }
      return true;
    }
    removeAllListeners(event) {
      if (event) delete this._events[event];
      else this._events = Object.create(null);
      return this;
    }
    listenerCount(event) {
      const e = this._events[event];
      if (!e) return 0;
      return typeof e === 'function' ? 1 : e.length;
    }
    listeners(event) {
      const e = this._events[event];
      if (!e) return [];
      return typeof e === 'function' ? [e] : e.slice();
    }
    rawListeners(event) { return this.listeners(event); }
    setMaxListeners() { return this; }
    getMaxListeners() { return 10; }
  }

  // ── TextEncoder / TextDecoder singletons ──────────────────────────────────
  if (typeof TextEncoder === 'undefined') {
    globalThis.TextEncoder = class {
      encode(str) {
        if (!str) return new Uint8Array(0);
        const utf8 = unescape(encodeURIComponent(str));
        const arr = new Uint8Array(utf8.length);
        for (let i = 0; i < utf8.length; i++) arr[i] = utf8.charCodeAt(i);
        return arr;
      }
    };
  }
  if (typeof TextDecoder === 'undefined') {
    globalThis.TextDecoder = class {
      decode(arr) {
        if (!arr || arr.length === 0) return '';
        let str = '';
        const len = arr.length;
        for (let i = 0; i < len; i++) str += String.fromCharCode(arr[i]);
        try {
          return decodeURIComponent(escape(str));
        } catch (_) {
          return str;
        }
      }
    };
  }
  const _sharedTextEncoder = new TextEncoder();
  const _sharedTextDecoder = new TextDecoder();

  // ── base64 <-> bytes helpers ─────────────────────────────────────────────
  const _B64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  function _bytesToBase64(view) {
    const arr = view instanceof Uint8Array ? view : new Uint8Array(view);
    const len = arr.length;
    if (len === 0) return '';
    let res = '';
    let i = 0;
    for (; i + 2 < len; i += 3) {
      const n = (arr[i] << 16) | (arr[i + 1] << 8) | arr[i + 2];
      res += _B64_CHARS[(n >> 18) & 63] + _B64_CHARS[(n >> 12) & 63] + _B64_CHARS[(n >> 6) & 63] + _B64_CHARS[n & 63];
    }
    if (i < len) {
      if (len - i === 1) {
        const n = arr[i] << 16;
        res += _B64_CHARS[(n >> 18) & 63] + _B64_CHARS[(n >> 12) & 63] + '==';
      } else {
        const n = (arr[i] << 16) | (arr[i + 1] << 8);
        res += _B64_CHARS[(n >> 18) & 63] + _B64_CHARS[(n >> 12) & 63] + _B64_CHARS[(n >> 6) & 63] + '=';
      }
    }
    return res;
  }

  const _B64_LOOKUP = new Uint8Array(256);
  for (let i = 0; i < _B64_CHARS.length; i++) {
    _B64_LOOKUP[_B64_CHARS.charCodeAt(i)] = i;
  }
  function _base64ToBytes(b64) {
    if (!b64 || typeof b64 !== 'string') return new Uint8Array(0);
    const len = b64.length;
    let validLen = len;
    while (validLen > 0 && b64[validLen - 1] === '=') validLen--;
    const outLen = Math.floor((validLen * 3) / 4);
    const out = new Uint8Array(outLen);
    let outIdx = 0;
    let i = 0;
    while (i < validLen) {
      const c0 = _B64_LOOKUP[b64.charCodeAt(i++)];
      const c1 = i < validLen ? _B64_LOOKUP[b64.charCodeAt(i++)] : 0;
      const c2 = i < validLen ? _B64_LOOKUP[b64.charCodeAt(i++)] : 0;
      const c3 = i < validLen ? _B64_LOOKUP[b64.charCodeAt(i++)] : 0;
      const n = (c0 << 18) | (c1 << 12) | (c2 << 6) | c3;
      if (outIdx < outLen) out[outIdx++] = (n >> 16) & 255;
      if (outIdx < outLen) out[outIdx++] = (n >> 8) & 255;
      if (outIdx < outLen) out[outIdx++] = n & 255;
    }
    return out;
  }
  globalThis.btoa = _bytesToBase64;
  globalThis.atob = function(str) {
    return _sharedTextDecoder.decode(_base64ToBytes(str));
  };

  // ── Timers polyfills ────────────────────────────────────────────────────
  let _timerIdGen = 0;
  const _timerCallbacks = {};

  globalThis._dart_trigger_timer = function(id) {
    const entry = _timerCallbacks[id];
    if (!entry) return;
    if (!entry.repeat) delete _timerCallbacks[id];
    try {
      if (typeof entry.fn === 'function') {
        entry.fn(...entry.args);
      } else if (typeof entry.fn === 'string') {
        eval(entry.fn);
      }
    } catch (e) {
      console.error('Timer error:', e);
    }
  };

  globalThis.setTimeout = function(fn, ms, ...args) {
    const id = ++_timerIdGen;
    const delay = Math.max(Number(ms) || 0, 0);
    _timerCallbacks[id] = { fn, args, repeat: false };
    _ffiNotify('_dart_timer_set', JSON.stringify({ id, ms: delay, repeat: false }));
    return id;
  };

  globalThis.clearTimeout = function(id) {
    delete _timerCallbacks[id];
    _ffiNotify('_dart_timer_clear', JSON.stringify({ id: Number(id) }));
  };

  globalThis.setInterval = function(fn, ms, ...args) {
    const id = ++_timerIdGen;
    const delay = Math.max(Number(ms) || 0, 0);
    _timerCallbacks[id] = { fn, args, repeat: true };
    _ffiNotify('_dart_timer_set', JSON.stringify({ id, ms: delay, repeat: true }));
    return id;
  };

  globalThis.clearInterval = function(id) {
    delete _timerCallbacks[id];
    _ffiNotify('_dart_timer_clear', JSON.stringify({ id: Number(id) }));
  };

  globalThis.setImmediate = function(fn, ...args) {
    return globalThis.setTimeout(fn, 0, ...args);
  };

  globalThis.clearImmediate = function(id) {
    globalThis.clearTimeout(id);
  };

  globalThis.queueMicrotask = function(fn) {
    Promise.resolve().then(fn);
  };

  // ── URL and URLSearchParams polyfills ────────────────────────────────────
  if (typeof URL === 'undefined') {
    class URLSearchParams {
      constructor(init) {
        this._params = {};
        if (typeof init === 'string') {
          if (init.startsWith('?')) init = init.slice(1);
          init.split('&').filter(Boolean).forEach(pair => {
            const idx = pair.indexOf('=');
            const k = idx >= 0 ? decodeURIComponent(pair.slice(0, idx)) : decodeURIComponent(pair);
            const v = idx >= 0 ? decodeURIComponent(pair.slice(idx + 1)) : '';
            this.append(k, v);
          });
        }
      }
      get(k) { return this._params[k] ? this._params[k][0] : null; }
      getAll(k) { return this._params[k] || []; }
      set(k, v) { this._params[k] = [String(v)]; }
      append(k, v) { (this._params[k] = this._params[k] || []).push(String(v)); }
      has(k) { return !!this._params[k]; }
      delete(k) { delete this._params[k]; }
      keys() { return Object.keys(this._params)[Symbol.iterator](); }
      *values() {
        for (const k of Object.keys(this._params)) {
          for (const v of this._params[k]) yield v;
        }
      }
      *entries() {
        for (const k of Object.keys(this._params)) {
          for (const v of this._params[k]) yield [k, v];
        }
      }
      [Symbol.iterator]() { return this.entries(); }
      forEach(cb) {
        for (const [k, v] of this.entries()) cb(v, k, this);
      }
      toString() {
        const parts = [];
        for (const k of Object.keys(this._params)) {
          for (const v of this._params[k]) {
            parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(v)}`);
          }
        }
        return parts.join('&');
      }
    }

    class _URL {
      constructor(url, base) {
        if (base && !url.includes('://')) {
          url = base.replace(/\/+$/, '') + '/' + url.replace(/^\/+/, '');
        }
        this.href = url;
        const match = url.match(/^([a-zA-Z][a-zA-Z0-9+.-]*:)\/\/([^@/]+@)?([^:/]+)(:\d+)?(\/[^?#]*)?(\?[^#]*)?(#.*)?$/);
        if (match) {
          this.protocol = match[1] || '';
          const auth = match[2] ? match[2].slice(0, -1).split(':') : [];
          this.username = auth[0] || '';
          this.password = auth[1] || '';
          this.hostname = match[3] || '';
          this.port = match[4] ? match[4].slice(1) : '';
          this.host = this.port ? `${this.hostname}:${this.port}` : this.hostname;
          this.pathname = match[5] || '/';
          this.search = match[6] || '';
          this.hash = match[7] || '';
          this.searchParams = new URLSearchParams(this.search);
          this.origin = `${this.protocol}//${this.host}`;
        } else {
          this.protocol = '';
          this.username = '';
          this.password = '';
          this.hostname = '';
          this.port = '';
          this.host = '';
          this.pathname = url;
          this.search = '';
          this.hash = '';
          this.searchParams = new URLSearchParams('');
          this.origin = '';
        }
      }
      toString() { return this.href; }
      toJSON() { return this.href; }
    }
    globalThis.URL = _URL;
    globalThis.URLSearchParams = URLSearchParams;
  }

  // ── Buffer polyfill ───────────────────────────────────────────────────────
  if (typeof Buffer === 'undefined') {
    class _Buffer extends Uint8Array {
      static from(data, encodingOrOffset, length) {
        if (typeof data === 'string') {
          const enc = encodingOrOffset || 'utf8';
          if (enc === 'hex') {
            const arr = new _Buffer(Math.floor(data.length / 2));
            for (let i = 0; i < arr.length; i++) {
              arr[i] = parseInt(data.substr(i * 2, 2), 16) || 0;
            }
            return arr;
          }
          if (enc === 'base64') {
            const bytes = _base64ToBytes(data);
            const arr = new _Buffer(bytes.length);
            arr.set(bytes);
            return arr;
          }
          const bytes = _sharedTextEncoder.encode(data);
          const buf = new _Buffer(bytes.length);
          buf.set(bytes);
          return buf;
        }
        if (data instanceof ArrayBuffer) {
          const offset = encodingOrOffset || 0;
          const len = length !== undefined ? length : (data.byteLength - offset);
          return new _Buffer(data, offset, len);
        }
        if (data instanceof Uint8Array || Array.isArray(data)) {
          const buf = new _Buffer(data.length);
          buf.set(data);
          return buf;
        }
        return new _Buffer(data);
      }
      static alloc(size, fill = 0) {
        const buf = new _Buffer(size);
        if (fill !== 0) buf.fill(fill);
        return buf;
      }
      static allocUnsafe(size) { return new _Buffer(size); }
      static allocUnsafeSlow(size) { return new _Buffer(size); }
      static concat(bufs, totalLength) {
        if (!Array.isArray(bufs) || bufs.length === 0) return new _Buffer(0);
        const len = totalLength !== undefined ? totalLength : bufs.reduce((s, b) => s + b.length, 0);
        const out = new _Buffer(len);
        let offset = 0;
        for (const b of bufs) {
          if (offset >= len) break;
          const copyLen = Math.min(b.length, len - offset);
          out.set(b.subarray(0, copyLen), offset);
          offset += copyLen;
        }
        return out;
      }
      static isBuffer(v) {
        return v instanceof _Buffer || v instanceof Uint8Array;
      }
      static byteLength(string, encoding = 'utf8') {
        if (typeof string !== 'string') return string ? string.length : 0;
        if (encoding === 'hex') return Math.floor(string.length / 2);
        return _sharedTextEncoder.encode(string).length;
      }
      copy(target, targetStart = 0, sourceStart = 0, sourceEnd) {
        const end = sourceEnd !== undefined ? sourceEnd : this.length;
        const toCopy = this.subarray(sourceStart, end);
        target.set(toCopy, targetStart);
        return toCopy.length;
      }
      slice(start = 0, end) {
        const sub = this.subarray(start, end !== undefined ? end : this.length);
        const buf = new _Buffer(sub.length);
        buf.set(sub);
        return buf;
      }
      write(string, offset, length, encoding) {
        if (typeof string !== 'string') return 0;
        let off = 0, len = undefined;
        if (typeof offset === 'number') {
          off = offset;
          if (typeof length === 'number') len = length;
        }
        const bytes = _sharedTextEncoder.encode(string);
        const writeLen = len !== undefined ? Math.min(len, bytes.length) : bytes.length;
        const available = Math.max(0, Math.min(writeLen, this.length - off));
        this.set(bytes.subarray(0, available), off);
        return available;
      }
      readUInt8(offset = 0) { return this[offset] || 0; }
      readInt8(offset = 0) { const v = this[offset] || 0; return v > 127 ? v - 256 : v; }
      readUInt16BE(offset = 0) { return ((this[offset] || 0) << 8) + (this[offset + 1] || 0); }
      readInt16BE(offset = 0) { const v = this.readUInt16BE(offset); return v > 32767 ? v - 65536 : v; }
      readUInt32BE(offset = 0) { return ((this[offset] || 0) * 0x1000000) + (((this[offset + 1] || 0) << 16) | ((this[offset + 2] || 0) << 8) | (this[offset + 3] || 0)); }
      readInt32BE(offset = 0) { const v = this.readUInt32BE(offset); return v > 0x7FFFFFFF ? v - 0x100000000 : v; }
      readUInt16LE(offset = 0) { return (this[offset] || 0) | ((this[offset + 1] || 0) << 8); }
      readInt16LE(offset = 0) { const v = this.readUInt16LE(offset); return v > 32767 ? v - 65536 : v; }
      readUInt32LE(offset = 0) { return ((this[offset] || 0) | ((this[offset + 1] || 0) << 8) | ((this[offset + 2] || 0) << 16)) + ((this[offset + 3] || 0) * 0x1000000); }
      readInt32LE(offset = 0) { const v = this.readUInt32LE(offset); return v > 0x7FFFFFFF ? v - 0x100000000 : v; }
      writeUInt8(val, offset = 0) { this[offset] = val & 255; return offset + 1; }
      writeInt8(val, offset = 0) { this[offset] = val & 255; return offset + 1; }
      writeUInt16BE(val, offset = 0) { this[offset] = (val >>> 8) & 255; this[offset + 1] = val & 255; return offset + 2; }
      writeInt16BE(val, offset = 0) { return this.writeUInt16BE(val, offset); }
      writeUInt32BE(val, offset = 0) { this[offset] = (val >>> 24) & 255; this[offset + 1] = (val >>> 16) & 255; this[offset + 2] = (val >>> 8) & 255; this[offset + 3] = val & 255; return offset + 4; }
      writeInt32BE(val, offset = 0) { return this.writeUInt32BE(val, offset); }
      writeUInt16LE(val, offset = 0) { this[offset] = val & 255; this[offset + 1] = (val >>> 8) & 255; return offset + 2; }
      writeInt16LE(val, offset = 0) { return this.writeUInt16LE(val, offset); }
      writeUInt32LE(val, offset = 0) { this[offset] = val & 255; this[offset + 1] = (val >>> 8) & 255; this[offset + 2] = (val >>> 16) & 255; this[offset + 3] = (val >>> 24) & 255; return offset + 4; }
      writeInt32LE(val, offset = 0) { return this.writeUInt32LE(val, offset); }
      toString(encoding, start, end) {
        let enc = 'utf8';
        let s = 0;
        let e = this.length;
        if (typeof encoding === 'number') {
          s = encoding;
          e = typeof start === 'number' ? start : this.length;
        } else {
          if (typeof encoding === 'string' && encoding) enc = encoding.toLowerCase().replace('-', '');
          if (typeof start === 'number') s = start;
          if (typeof end === 'number') e = end;
        }
        const sub = this.subarray(s, e);
        if (enc === 'hex') {
          return Array.from(sub).map(b => b.toString(16).padStart(2, '0')).join('');
        }
        if (enc === 'base64') {
          return _bytesToBase64(sub);
        }
        return _sharedTextDecoder.decode(sub);
      }
      equals(other) {
        if (!other || this.length !== other.length) return false;
        for (let i = 0; i < this.length; i++) {
          if (this[i] !== other[i]) return false;
        }
        return true;
      }
    }
    _Buffer.Buffer = _Buffer;
    globalThis.Buffer = _Buffer;
  }

  // ── Dart-backed net.Socket ────────────────────────────────────────────────
  const _socketMap = {};

  globalThis._dart_emit_socket = function(id, event, arg) {
    const sock = _socketMap[id];
    if (sock) {
      if (event === 'connect') sock.connecting = false;
      sock.emit(event, arg);
    }
  };

  globalThis._dart_socket_data = function(id, data) {
    const sock = _socketMap[id];
    if (!sock) return;
    try {
      if (typeof data === 'string') {
        sock.emit('data', Buffer.from(data, 'base64'));
      } else if (data instanceof ArrayBuffer) {
        sock.emit('data', Buffer.from(data));
      } else if (data instanceof Uint8Array) {
        sock.emit('data', Buffer.from(data.buffer, data.byteOffset, data.byteLength));
      } else {
        sock.emit('data', Buffer.from(data));
      }
    } catch(e) {
      console.error('[_dart_socket_data error]:', e?.message || e);
    }
  };

  class DartSocket extends EventEmitter {
    constructor() {
      super();
      this._id = ++DartSocket._idGen;
      this.writable = true;
      this.readable = true;
      this.remoteAddress = null;
      this.remotePort = null;
      this.connecting = false;
      this._destroyed = false;
      _socketMap[this._id] = this;
    }
    connect(...args) {
      let options = {};
      let cb = null;
      if (typeof args[0] === 'object' && args[0] !== null) {
        options = Object.assign({}, args[0]);
        if (typeof args[1] === 'function') cb = args[1];
      } else if (typeof args[0] === 'number' || typeof args[0] === 'string') {
        options.port = Number(args[0]);
        if (typeof args[1] === 'string') {
          options.host = args[1];
          if (typeof args[2] === 'function') cb = args[2];
        } else if (typeof args[1] === 'function') {
          cb = args[1];
        }
      }
      this.remoteAddress = options.host || 'localhost';
      this.remotePort = Number(options.port) || 5432;
      this.connecting = true;
      if (typeof cb === 'function') {
        this.once('connect', cb);
      }
      _ffiNotify('_dart_socket_connect', JSON.stringify({
        id: this._id,
        host: String(this.remoteAddress),
        port: Number(this.remotePort),
        tls: false,
      }));
      return this;
    }
    write(data, encoding, cb) {
      const buf = Buffer.isBuffer(data)
        ? data
        : Buffer.from(data, typeof encoding === 'string' ? encoding : 'utf8');
      _ffiNotify('_dart_socket_write', JSON.stringify({ id: this._id, data: _bytesToBase64(buf) }));
      if (typeof encoding === 'function') encoding();
      else if (typeof cb === 'function') cb();
      return true;
    }
    end(data, encoding, cb) {
      if (data) this.write(data, encoding, cb);
      this.destroy();
    }
    destroy(err) {
      if (this._destroyed) return;
      this._destroyed = true;
      delete _socketMap[this._id];
      _ffiNotify('_dart_socket_destroy', JSON.stringify({ id: this._id }));
      if (err) this.emit('error', err);
      this.emit('close', !!err);
    }
    pause() { return this; }
    resume() { return this; }
    setTimeout() { return this; }
    setNoDelay() { return this; }
    setKeepAlive() { return this; }
    ref() { return this; }
    unref() { return this; }
  }
  DartSocket._idGen = 0;

  class TlsSocket extends DartSocket {
    connect(...args) {
      let options = {};
      let cb = null;
      if (typeof args[0] === 'object' && args[0] !== null) {
        options = Object.assign({}, args[0]);
        if (typeof args[1] === 'function') cb = args[1];
      }
      this.remoteAddress = options.host || 'localhost';
      this.remotePort = Number(options.port) || 5432;
      this.connecting = true;
      if (typeof cb === 'function') {
        this.once('connect', cb);
      }
      _ffiNotify('_dart_socket_connect', JSON.stringify({
        id: this._id,
        host: String(this.remoteAddress),
        port: Number(this.remotePort),
        tls: true,
      }));
      return this;
    }
  }

  globalThis.net = {
    Socket: DartSocket,
    createConnection: (...args) => new DartSocket().connect(...args),
    connect: (...args) => new DartSocket().connect(...args),
    isIP: (s) => (typeof s === 'string' && /^\d+\.\d+\.\d+\.\d+$/.test(s)) ? 4 : 0,
    isIPv4: (s) => (typeof s === 'string' && /^\d+\.\d+\.\d+\.\d+$/.test(s)),
    isIPv6: () => false,
  };

  globalThis.tls = {
    TLSSocket: TlsSocket,
    connect: (options, cb) => new TlsSocket().connect(options, cb),
  };

  // ── Native C Crypto Integration with Fallback ────────────────────────────
  const _nativeCrypto = globalThis._native_crypto;

  globalThis.crypto = globalThis.crypto || {};
  globalThis.crypto.randomBytes = function(n) {
    if (_nativeCrypto && typeof _nativeCrypto.randomBytes === 'function') {
      const u8 = _nativeCrypto.randomBytes(n);
      return Buffer.from(u8.buffer || u8);
    }
    const jsonResult = _ffiNotify('_dart_random_bytes', JSON.stringify({ count: n }));
    return Buffer.from(JSON.parse(jsonResult), 'base64');
  };

  globalThis.crypto.randomUUID = function() {
    const bytes = globalThis.crypto.randomBytes(16);
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    const hex = Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
    return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) + '-' + hex.slice(16, 20) + '-' + hex.slice(20);
  };

  globalThis.crypto.getRandomValues = function(typedArray) {
    if (!typedArray || !typedArray.length) return typedArray;
    const bytes = globalThis.crypto.randomBytes(typedArray.length);
    typedArray.set(bytes);
    return typedArray;
  };

  globalThis.crypto.createHash = function(algorithm) {
    const chunks = [];
    const algo = (algorithm || 'sha256').toLowerCase().replace('-', '');
    return {
      update(chunk, enc) {
        if (typeof chunk === 'string') {
          chunks.push(Buffer.from(chunk, enc || 'utf8'));
        } else {
          chunks.push(chunk instanceof Uint8Array ? chunk : Buffer.from(chunk));
        }
        return this;
      },
      digest(enc) {
        const allData = Buffer.concat(chunks);
        if (algo === 'sha256' && _nativeCrypto && typeof _nativeCrypto.sha256Digest === 'function') {
          const hex = _nativeCrypto.sha256Digest(allData, 'hex');
          if (enc === 'hex') return hex;
          if (enc === 'base64') return _bytesToBase64(Buffer.from(hex, 'hex'));
          return Buffer.from(hex, 'hex');
        }
        const jsonResult = _ffiNotify('_dart_hash', JSON.stringify({
          algorithm,
          data: _bytesToBase64(allData),
        }));
        const hex = JSON.parse(jsonResult);
        if (enc === 'hex') return hex;
        return Buffer.from(hex, 'hex');
      },
    };
  };

  globalThis.crypto.createHmac = function(algorithm, key) {
    const chunks = [];
    const keyBytes = typeof key === 'string' ? Buffer.from(key, 'utf8') : (key instanceof Uint8Array ? key : Buffer.from(key));
    const algo = (algorithm || 'sha256').toLowerCase().replace('-', '');
    return {
      update(chunk, enc) {
        if (typeof chunk === 'string') {
          chunks.push(Buffer.from(chunk, enc || 'utf8'));
        } else {
          chunks.push(chunk instanceof Uint8Array ? chunk : Buffer.from(chunk));
        }
        return this;
      },
      digest(enc) {
        const fullData = Buffer.concat(chunks);
        if (algo === 'sha256' && _nativeCrypto && typeof _nativeCrypto.hmacSha256 === 'function') {
          const ab = _nativeCrypto.hmacSha256(keyBytes, fullData);
          const b = Buffer.from(ab);
          if (enc === 'hex') return b.toString('hex');
          if (enc === 'base64') return b.toString('base64');
          return b;
        }
        const res = _ffiNotify('_dart_subtle_hmac', JSON.stringify({
          algorithm: algo,
          key: _bytesToBase64(keyBytes),
          data: _bytesToBase64(fullData),
        }));
        const buf = res ? Buffer.from(JSON.parse(res), 'base64') : Buffer.alloc(0);
        if (enc === 'hex') return buf.toString('hex');
        if (enc === 'base64') return buf.toString('base64');
        return buf;
      },
    };
  };

  globalThis.crypto.pbkdf2Sync = function(password, salt, iterations, keylen, digest) {
    const passwordBytes = typeof password === 'string' ? _sharedTextEncoder.encode(password) : (password instanceof Uint8Array ? password : new Uint8Array(password));
    const saltBytes = typeof salt === 'string' ? _sharedTextEncoder.encode(salt) : (salt instanceof Uint8Array ? salt : new Uint8Array(salt));
    const iter = Number(iterations) || 1000;
    const len = Number(keylen) || 32;
    if (_nativeCrypto && typeof _nativeCrypto.pbkdf2Sync === 'function') {
      const ab = _nativeCrypto.pbkdf2Sync(passwordBytes.buffer || passwordBytes, saltBytes.buffer || saltBytes, iter, len);
      return Buffer.from(ab);
    }
    const res = _ffiNotify('_dart_subtle_pbkdf2', JSON.stringify({
      password: _bytesToBase64(passwordBytes),
      salt: _bytesToBase64(saltBytes),
      iterations: iter,
      lengthBytes: len,
    }));
    return res ? Buffer.from(JSON.parse(res), 'base64') : Buffer.alloc(0);
  };

  // ── WebCrypto subtle shim (for Postgres SCRAM-SHA-256 SASL auth) ────────
  const subtle = {
    async digest(algorithm, data) {
      const algoName = typeof algorithm === 'string' ? algorithm : (algorithm?.name || 'SHA-256');
      const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
      if (algoName.toLowerCase().replace('-', '') === 'sha256' && _nativeCrypto && typeof _nativeCrypto.sha256Digest === 'function') {
        const hex = _nativeCrypto.sha256Digest(bytes, 'hex');
        const buf = Buffer.from(hex, 'hex');
        return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
      }
      const res = _ffiNotify('_dart_hash', JSON.stringify({
        algorithm: algoName,
        data: _bytesToBase64(bytes),
      }));
      const hex = res ? JSON.parse(res) : '';
      const buf = Buffer.from(hex, 'hex');
      return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
    },
    async importKey(format, keyData, algorithm, extractable, keyUsages) {
      const bytes = keyData instanceof Uint8Array ? keyData : new Uint8Array(keyData);
      return { raw: bytes, algorithm, extractable, keyUsages };
    },
    async sign(algorithm, key, data) {
      const keyBytes = key.raw || key;
      const dataBytes = data instanceof Uint8Array ? data : new Uint8Array(data);
      const algoName = typeof algorithm === 'string' ? algorithm : (algorithm?.name || 'SHA-256');
      if (algoName.toLowerCase().replace('-', '') === 'sha256' && _nativeCrypto && typeof _nativeCrypto.hmacSha256 === 'function') {
        const ab = _nativeCrypto.hmacSha256(keyBytes, dataBytes);
        const buf = Buffer.from(ab);
        return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
      }
      const res = _ffiNotify('_dart_subtle_hmac', JSON.stringify({
        algorithm: algoName,
        key: _bytesToBase64(keyBytes),
        data: _bytesToBase64(dataBytes),
      }));
      const buf = res ? Buffer.from(JSON.parse(res), 'base64') : Buffer.alloc(0);
      return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
    },
    async deriveBits(params, key, length) {
      const passwordBytes = key.raw || key;
      const saltBytes = params.salt instanceof Uint8Array ? params.salt : new Uint8Array(params.salt);
      const iterations = Number(params.iterations) || 4096;
      const lengthBytes = Math.floor(Number(length) / 8) || 32;
      if (_nativeCrypto && typeof _nativeCrypto.pbkdf2Sync === 'function') {
        const ab = _nativeCrypto.pbkdf2Sync(passwordBytes, saltBytes, iterations, lengthBytes);
        const buf = Buffer.from(ab);
        return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
      }
      const res = _ffiNotify('_dart_subtle_pbkdf2', JSON.stringify({
        password: _bytesToBase64(passwordBytes),
        salt: _bytesToBase64(saltBytes),
        iterations: iterations,
        lengthBytes: lengthBytes,
      }));
      const buf = res ? Buffer.from(JSON.parse(res), 'base64') : Buffer.alloc(0);
      return buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
    },
  };
  globalThis.crypto.subtle = subtle;
  globalThis.crypto.webcrypto = globalThis.crypto;

  // ── process shim ─────────────────────────────────────────────────────────
  if (typeof process === 'undefined') {
    globalThis.process = {
      env: {},
      version: 'v18.20.0',
      versions: { node: '18.20.0' },
      platform: 'linux',
      argv: ['/usr/bin/node', '/index.js'],
      nextTick: (fn, ...args) => Promise.resolve().then(() => fn(...args)),
      on: () => {},
      removeListener: () => {},
      stdout: { isTTY: false, fd: 1, write: (s) => console.log(s) },
      stderr: { isTTY: false, fd: 2, write: (s) => console.error(s) },
      stdin: { isTTY: false, fd: 0, on: () => {} },
      hrtime: Object.assign((time) => {
        const now = Date.now();
        if (time) return [Math.floor(now / 1000) - time[0], 0];
        return [Math.floor(now / 1000), 0];
      }, { bigint: () => BigInt(Date.now()) * BigInt(1e6) }),
      cwd: () => '/tmp',
      exit: () => {},
    };
  }

  // ── tty polyfill ──────────────────────────────────────────────────────────
  const _tty = {
    isatty: (fd) => false,
    ReadStream: class extends EventEmitter { constructor() { super(); this.isTTY = false; } },
    WriteStream: class extends EventEmitter { constructor() { super(); this.isTTY = false; } },
  };
  _tty.default = _tty;

  // ── Native SQLite Module Shim ─────────────────────────────────────────────
  const _sqlite = globalThis._native_sqlite;
  class SqliteDatabase extends EventEmitter {
    constructor(filename, mode, callback) {
      super();
      if (typeof mode === 'function') {
        callback = mode;
        mode = 6;
      }
      this.filename = filename;
      this._handle = null;
      try {
        if (_sqlite && typeof _sqlite.open === 'function') {
          this._handle = _sqlite.open(filename || ':memory:');
          this.open = true;
        }
        if (callback) queueMicrotask(() => callback(null));
      } catch (err) {
        if (callback) queueMicrotask(() => callback(err));
      }
    }
    close(callback) {
      if (this._handle !== null && this._handle !== undefined && _sqlite) {
        try {
          _sqlite.close(this._handle);
          this._handle = null;
          this.open = false;
          if (callback) queueMicrotask(() => callback(null));
        } catch (err) {
          if (callback) queueMicrotask(() => callback(err));
        }
      } else if (callback) {
        queueMicrotask(() => callback(null));
      }
    }
    all(sql, params, callback) {
      if (typeof params === 'function') {
        callback = params;
        params = [];
      }
      try {
        const rows = _sqlite ? _sqlite.query(this._handle, sql, params || []) : [];
        if (callback) queueMicrotask(() => callback.call(this, null, rows));
      } catch (err) {
        if (callback) queueMicrotask(() => callback.call(this, err));
      }
      return this;
    }
    get(sql, params, callback) {
      if (typeof params === 'function') {
        callback = params;
        params = [];
      }
      try {
        let row;
        if (_sqlite && typeof _sqlite.get === 'function') {
          row = _sqlite.get(this._handle, sql, params || []);
          if (row === null) row = undefined;
        } else {
          const rows = _sqlite ? _sqlite.query(this._handle, sql, params || []) : [];
          row = rows && rows.length > 0 ? rows[0] : undefined;
        }
        if (callback) queueMicrotask(() => callback.call(this, null, row));
      } catch (err) {
        if (callback) queueMicrotask(() => callback.call(this, err));
      }
      return this;
    }
    run(sql, params, callback) {
      if (typeof params === 'function') {
        callback = params;
        params = [];
      }
      try {
        const res = _sqlite ? _sqlite.run(this._handle, sql, params || []) : { lastID: 0, changes: 0 };
        const ctx = { lastID: res.lastID, changes: res.changes };
        if (callback) queueMicrotask(() => callback.call(ctx, null));
      } catch (err) {
        if (callback) queueMicrotask(() => callback.call(this, err));
      }
      return this;
    }
    exec(sql, callback) {
      try {
        if (_sqlite) _sqlite.exec(this._handle, sql);
        if (callback) queueMicrotask(() => callback.call(this, null));
      } catch (err) {
        if (callback) queueMicrotask(() => callback.call(this, err));
      }
      return this;
    }
  }

  const _sqlite3 = {
    Database: SqliteDatabase,
    OPEN_READONLY: 1,
    OPEN_READWRITE: 2,
    OPEN_CREATE: 4,
    OPEN_FULLMUTEX: 0x00010000,
    OPEN_URI: 0x00000040,
    OPEN_SHAREDCACHE: 0x00020000,
    OPEN_PRIVATECACHE: 0x00040000,
    verbose: () => _sqlite3,
    default: null,
  };
  _sqlite3.default = _sqlite3;

  // ── util polyfill ────────────────────────────────────────────────────────
  const _customInspect = Symbol.for('nodejs.util.inspect.custom');
  const _inspect = function(obj, options) {
    if (obj === null) return 'null';
    if (obj === undefined) return 'undefined';
    if (typeof obj === 'object' && typeof obj[_customInspect] === 'function') {
      try { return obj[_customInspect](2, options || {}); } catch(_) {}
    }
    try { return JSON.stringify(obj); } catch(_) { return String(obj); }
  };
  _inspect.custom = _customInspect;

  const _util = {
    inspect: _inspect,
    promisify: (fn) => (...args) => new Promise((resolve, reject) => fn(...args, (err, res) => err ? reject(err) : resolve(res))),
    inherits: (ctor, superCtor) => { if (superCtor) { ctor.super_ = superCtor; Object.setPrototypeOf(ctor.prototype, superCtor.prototype); } },
    types: { isUint8Array: (v) => v instanceof Uint8Array },
    format: (...args) => args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '),
    deprecate: (fn) => fn,
    TextEncoder: globalThis.TextEncoder,
    TextDecoder: globalThis.TextDecoder,
  };
  _util.default = _util;

  // ── string_decoder polyfill ───────────────────────────────────────────────
  class _StringDecoder {
    constructor(enc) { this.enc = enc || 'utf8'; }
    write(buf) { return _sharedTextDecoder.decode(buf); }
    end(buf) { return buf ? _sharedTextDecoder.decode(buf) : ''; }
  }

  // ── path polyfill ─────────────────────────────────────────────────────────
  const _path = {
    join: (...parts) => parts.filter(Boolean).join('/'),
    resolve: (...parts) => parts.filter(Boolean).join('/'),
    dirname: (p) => p.split('/').slice(0, -1).join('/') || '.',
    basename: (p) => p.split('/').pop() || '',
    extname: (p) => { const b = p.split('/').pop() || ''; const idx = b.lastIndexOf('.'); return idx >= 0 ? b.slice(idx) : ''; },
    sep: '/',
    delimiter: ':',
  };
  _path.posix = _path;
  _path.win32 = _path;
  _path.default = _path;

  // ── async_hooks polyfill ──────────────────────────────────────────────────
  class _AsyncLocalStorage {
    constructor() { this._store = undefined; }
    getStore() { return this._store; }
    run(store, callback, ...args) {
      const prev = this._store;
      this._store = store;
      try {
        return callback(...args);
      } finally {
        this._store = prev;
      }
    }
    enterWith(store) { this._store = store; }
    exit(callback, ...args) {
      const prev = this._store;
      this._store = undefined;
      try {
        return callback(...args);
      } finally {
        this._store = prev;
      }
    }
  }

  const _asyncHooks = {
    AsyncLocalStorage: _AsyncLocalStorage,
    AsyncResource: class {
      constructor(name) { this.name = name; }
      runInAsyncScope(fn, thisArg, ...args) { return fn.apply(thisArg, args); }
      emitDestroy() {}
      asyncId() { return 1; }
      triggerAsyncId() { return 1; }
    },
    createHook: () => ({ enable: () => {}, disable: () => {} }),
    executionAsyncId: () => 1,
    triggerAsyncId: () => 1,
    default: { AsyncLocalStorage: _AsyncLocalStorage },
  };

  // ── require() shim with Cache Dictionary ──────────────────────────────────
  const _moduleCache = Object.create(null);
  const _modules = {
    crypto: Object.assign(globalThis.crypto, { default: globalThis.crypto }),
    events: Object.assign(EventEmitter, { EventEmitter, default: EventEmitter }),
    buffer: Object.assign(globalThis.Buffer, { Buffer: globalThis.Buffer, default: globalThis.Buffer }),
    net: Object.assign(globalThis.net, { default: globalThis.net }),
    tls: Object.assign(globalThis.tls, { default: globalThis.tls }),
    sqlite3: _sqlite3,
    url: Object.assign(globalThis.URL, { URL: globalThis.URL, URLSearchParams: globalThis.URLSearchParams, default: globalThis.URL }),
    util: _util,
    string_decoder: { StringDecoder: _StringDecoder, default: { StringDecoder: _StringDecoder } },
    path: _path,
    async_hooks: _asyncHooks,
    fs: {
      readFileSync: () => '',
      existsSync: () => false,
      promises: { readFile: async () => '', access: async () => {} },
      default: { readFileSync: () => '', existsSync: () => false },
    },
    os: {
      platform: () => 'linux',
      type: () => 'Linux',
      release: () => '5.15.0',
      tmpdir: () => '/tmp',
      homedir: () => '/root',
      cpus: () => [{ model: 'QuickJS Virtual CPU', speed: 2000 }],
      endianness: () => 'LE',
      default: { platform: () => 'linux' },
    },
    timers: {
      setTimeout: globalThis.setTimeout,
      clearTimeout: globalThis.clearTimeout,
      setInterval: globalThis.setInterval,
      clearInterval: globalThis.clearInterval,
      setImmediate: globalThis.setImmediate,
      clearImmediate: globalThis.clearImmediate,
    },
    stream: {
      Readable: EventEmitter,
      Writable: EventEmitter,
      Transform: EventEmitter,
      Duplex: DartSocket,
      PassThrough: EventEmitter,
      pipeline: (...args) => { const cb = args[args.length - 1]; if (typeof cb === 'function') cb(null); },
      default: { Readable: EventEmitter, Writable: EventEmitter },
    },
    assert: Object.assign((val, msg) => { if (!val) throw new Error(msg || 'Assertion failed'); }, {
      ok: (val, msg) => { if (!val) throw new Error(msg || 'Assertion failed'); },
      strictEqual: (a, b, msg) => { if (a !== b) throw new Error(msg || `${a} !== ${b}`); },
    }),
    zlib: {
      gzipSync: (b) => b,
      gunzipSync: (b) => b,
      deflateSync: (b) => b,
      inflateSync: (b) => b,
      default: {},
    },
    dns: {
      lookup: (host, cb) => cb(null, '127.0.0.1', 4),
      promises: { lookup: async () => ({ address: '127.0.0.1', family: 4 }) },
      default: {},
    },
    tty: _tty,
    process: globalThis.process,
  };

  globalThis._js_require = function(mod) {
    if (!mod || typeof mod !== 'string') {
      throw new Error(`Cannot find module '${mod}'`);
    }
    const normalized = mod.startsWith('node:') ? mod.slice(5) : mod;
    if (_moduleCache[normalized]) return _moduleCache[normalized];
    if (_modules[normalized]) {
      _moduleCache[normalized] = _modules[normalized];
      return _modules[normalized];
    }
    const base = normalized.split('/')[0];
    if (_modules[base]) {
      _moduleCache[normalized] = _modules[base];
      return _modules[base];
    }
    throw new Error(`Cannot find module '${mod}'`);
  };

  // ── Direct Async Request Dispatcher Shim ─────────────────────────────────
  globalThis._dart_handleRequest = async function(promiseId, params) {
    try {
      let result;
      const fnName = params.functionName || params.method;
      if (typeof globalThis.handleRequest === 'function') {
        const req = params.requestJson ? JSON.parse(params.requestJson) : params;
        result = await globalThis.handleRequest(req.method, req.params);
      } else if (typeof globalThis[fnName] === 'function') {
        result = await globalThis[fnName](params);
      } else if (typeof processRequest === 'function') {
        const req = params.requestJson ? JSON.parse(params.requestJson) : params;
        result = await new Promise((resolve) => {
          processRequest(req, (res) => resolve(res));
        });
      } else {
        throw new Error('Function not found: ' + fnName);
      }
      _ffiNotify('_dart_promise_resolve', JSON.stringify({id: promiseId, value: result}));
    } catch(e) {
      _ffiNotify('_dart_promise_reject', JSON.stringify({id: promiseId, error: String(e?.message || e)}));
    }
  };

})();
""";

    eval(polyfill);
  }

  /// Load and evaluate a JavaScript bundle (e.g. `bridge_server_quickjs.bundle.js`).
  String loadBundle(String bundleJs) {
    return eval(bundleJs);
  }

  /// Evaluate a raw JavaScript string in the QuickJS context.
  String eval(String jsCode) {
    if (_disposed) throw StateError('QuickJsRuntime is disposed');
    return _bindings.eval(_handle, jsCode);
  }

  /// Execute an asynchronous JS function by name with given parameters.
  ///
  /// Dispatches directly into native `qjs_dart_call_async` without generating
  /// dynamic JS code.
  Future<dynamic> callAsync(
    String functionName,
    Map<String, dynamic> params,
  ) {
    if (_disposed) throw StateError('QuickJsRuntime is disposed');
    final id = _promiseIdCounter++;
    final completer = Completer<dynamic>();
    _pendingPromises[id] = completer;

    final argsJson = jsonEncode({
      'functionName': functionName,
      ...params,
    });

    final res = _bindings.callAsync(_handle, id, argsJson);
    if (res < 0) {
      // Fallback if _dart_handleRequest was not registered
      eval(
        '(async () => {'
        '  try {'
        '    const result = await $functionName($argsJson);'
        '    _ffiNotify("_dart_promise_resolve", JSON.stringify({id:$id,value:result}));'
        '  } catch(e) {'
        '    _ffiNotify("_dart_promise_reject", JSON.stringify({id:$id,error:String(e.message||e)}));'
        '  }'
        '})();',
      );
    }

    _bindings.pumpAll(_handle);
    return completer.future;
  }

  /// Trigger garbage collection in the embedded QuickJS runtime.
  void gc() {
    if (_disposed) return;
    _bindings.runGc(_handle);
  }

  /// Set the memory limit in bytes for this QuickJS runtime.
  void setMemoryLimit(int bytes) {
    if (_disposed) return;
    _bindings.setMemoryLimit(_handle, bytes);
  }

  /// Set the GC threshold in bytes for this QuickJS runtime.
  void setGcThreshold(int bytes) {
    if (_disposed) return;
    _bindings.setGcThreshold(_handle, bytes);
  }

  /// Dispose the runtime and release all native QuickJS resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _runtimesByHandle.remove(_handle.address);
    for (final ctx in _sockets.values) {
      ctx.destroy();
    }
    _sockets.clear();
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _pendingPromises.clear();
    _bindings.freeRuntime(_handle);
  }

  void _onTimerTrigger(int timerId) {
    if (_disposed) return;
    _bindings.triggerTimer(_handle, timerId);
    _bindings.pumpAll(_handle);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Socket event helpers with Direct Binary Transport
  // ────────────────────────────────────────────────────────────────────────

  void _onSocketData(int socketId, Uint8List data) {
    if (_disposed) return;
    final ptr = calloc<Uint8>(data.length);
    final list = ptr.asTypedList(data.length);
    list.setAll(0, data);

    _bindings.emitSocketData(_handle, socketId, ptr, data.length);
    calloc.free(ptr);
    _bindings.pumpAll(_handle);
  }

  void _onSocketClose(int socketId) {
    if (_disposed) return;
    _sockets.remove(socketId);
    _bindings.emitSocketEvent(_handle, socketId, 'close');
    _bindings.pumpAll(_handle);
  }

  void _onSocketError(int socketId, String error) {
    if (_disposed) return;
    _sockets.remove(socketId);
    _bindings.emitSocketError(_handle, socketId, error);
    _bindings.pumpAll(_handle);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Crypto helpers (Dart fallback)
  // ────────────────────────────────────────────────────────────────────────

  static Uint8List _toUint8List(dynamic data) {
    if (data is List) return Uint8List.fromList(data.cast<int>());
    if (data is String) return base64Decode(data);
    return Uint8List(0);
  }

  static Uint8List _computeHmac(String algorithm, dynamic key, dynamic data) {
    final keyBytes = _toUint8List(key);
    final dataBytes = _toUint8List(data);
    final dart_crypto.Hash hash;
    switch (algorithm.toLowerCase().replaceAll('-', '')) {
      case 'sha256':
        hash = dart_crypto.sha256;
        break;
      case 'sha1':
        hash = dart_crypto.sha1;
        break;
      case 'md5':
        hash = dart_crypto.md5;
        break;
      default:
        hash = dart_crypto.sha256;
    }
    final hmac = dart_crypto.Hmac(hash, keyBytes);
    return Uint8List.fromList(hmac.convert(dataBytes).bytes);
  }

  static Uint8List _pbkdf2(
    dynamic password,
    dynamic salt,
    int iterations,
    int lengthBytes,
  ) {
    final passwordBytes = _toUint8List(password);
    final saltBytes = _toUint8List(salt);
    final hmac = dart_crypto.Hmac(dart_crypto.sha256, passwordBytes);
    final blocks = (lengthBytes / 32).ceil();
    final out = Uint8List(blocks * 32);

    for (var i = 1; i <= blocks; i++) {
      final saltWithIndex = Uint8List(saltBytes.length + 4);
      saltWithIndex.setRange(0, saltBytes.length, saltBytes);
      saltWithIndex[saltBytes.length] = (i >> 24) & 255;
      saltWithIndex[saltBytes.length + 1] = (i >> 16) & 255;
      saltWithIndex[saltBytes.length + 2] = (i >> 8) & 255;
      saltWithIndex[saltBytes.length + 3] = i & 255;

      var u = Uint8List.fromList(hmac.convert(saltWithIndex).bytes);
      final blockResult = Uint8List.fromList(u);

      for (var iter = 1; iter < iterations; iter++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < 32; k++) {
          blockResult[k] ^= u[k];
        }
      }
      out.setRange((i - 1) * 32, (i - 1) * 32 + 32, blockResult);
    }

    return Uint8List.sublistView(out, 0, lengthBytes);
  }

  static Uint8List _secureRandomBytes(int count) {
    final bytes = Uint8List(count);
    final rng = Random.secure();
    for (var i = 0; i < count; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }

  static String _computeHash(String algorithm, dynamic data) {
    final bytes = _toUint8List(data);

    switch (algorithm.toLowerCase().replaceAll('-', '')) {
      case 'sha256':
        return dart_crypto.sha256.convert(bytes).toString();
      case 'sha1':
        return dart_crypto.sha1.convert(bytes).toString();
      case 'md5':
        return dart_crypto.md5.convert(bytes).toString();
      default:
        return dart_crypto.sha256.convert(bytes).toString();
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Internal: Dart-side TCP socket context
// ──────────────────────────────────────────────────────────────────────────

class _DartSocketContext {
  final int socketId;
  final Socket _socket;
  StreamSubscription<Uint8List>? _sub;

  _DartSocketContext._({
    required this.socketId,
    required Socket socket,
  }) : _socket = socket;

  static Future<_DartSocketContext> connect({
    required int socketId,
    required String host,
    required int port,
    required bool useTls,
    required void Function(Uint8List) onData,
    required void Function() onClose,
    required void Function(Object) onError,
  }) async {
    final Socket socket;
    if (useTls) {
      socket = await SecureSocket.connect(
        host,
        port,
        onBadCertificate: (_) => true,
      );
    } else {
      socket = await Socket.connect(host, port);
    }

    final ctx = _DartSocketContext._(socketId: socketId, socket: socket);
    ctx._sub = socket.listen(
      onData,
      onDone: onClose,
      onError: onError,
      cancelOnError: false,
    );
    return ctx;
  }

  void write(Uint8List bytes) {
    _socket.add(bytes);
  }

  void destroy() {
    _sub?.cancel();
    _socket.destroy();
  }
}
