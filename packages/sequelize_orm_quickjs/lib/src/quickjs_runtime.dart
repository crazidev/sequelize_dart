import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as dartCrypto;
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
///
/// ## Performance notes
///
/// All binary payloads that cross the Dart <-> JS boundary (socket bytes,
/// hash/HMAC/PBKDF2 inputs and outputs, random bytes) are exchanged as
/// **base64 strings**, never as JSON arrays of integers. A JSON int array is
/// both far larger on the wire (each byte becomes 1-3 decimal digits plus a
/// comma, vs. 4/3 bytes for base64) and far more expensive for the embedded
/// JS engine to *parse*: `[12,54,3,...]` requires lexing one token per byte,
/// while `'aGVsbG8='` is a single string-literal token. Keep this convention
/// when adding new bridge calls — always base64-encode binary data before
/// calling `_ffiNotify`, and base64-decode on the way back.
class QuickJsRuntime {
  final QuickJsBindings _bindings;
  late final QjsDartRuntimePtr _handle;
  bool _disposed = false;

  /// Pending Dart Completers for JS Promises, keyed by promise-id.
  ///
  /// Holds the already-decoded result value (Map/List/String/num/bool/null)
  /// — see [callAsync] for why the result only crosses the bridge
  /// JSON-encoded once instead of twice.
  final Map<int, Completer<dynamic>> _pendingPromises = {};
  int _promiseIdCounter = 0;

  /// Active Dart TCP socket contexts, keyed by socket-id.
  final Map<int, _DartSocketContext> _sockets = {};

  /// Active Dart Timers, keyed by timer-id.
  final Map<int, Timer> _timers = {};

  /// Callback for notifications dispatched from JavaScript (e.g. SQL logging).
  void Function(Map<String, dynamic>)? onNotification;

  /// Native function pointer we must keep alive for the lifetime of the runtime.
  Pointer<NativeFunction<DartBridgeCallbackC>>? _nativeCb;

  QuickJsRuntime._(this._bindings);

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
    // Use a top-level static function converted to a C pointer.
    // We keep the pointer alive as a field to prevent GC.
    _nativeCb = Pointer.fromFunction<DartBridgeCallbackC>(
      _dispatchFromJs,
      // No exceptional return needed — Pointer.fromFunction handles Pointer
      // return types without an exceptionalReturn argument.
    );
    _bindings.setCallback(_nativeCb!);
  }

  /// Static dispatcher called from C when `_ffiNotify(name, argsJson)` is
  /// invoked inside the QuickJS context. Routes to the appropriate Dart handler.
  static Pointer<Utf8> _dispatchFromJs(
    Pointer<Utf8> namePtr,
    Pointer<Utf8> argsPtr,
  ) {
    final name = namePtr.toDartString();
    final argsJson = argsPtr.toDartString();

    // Get the currently active runtime (registered below in _installCallback).
    final rt = _activeRuntime;
    if (rt == null) return nullptr;

    return rt._handleBridgeCall(name, argsJson);
  }

  Pointer<Utf8> _handleBridgeCall(String name, String argsJson) {
    final sw = Stopwatch()..start();
    try {
      Map<String, dynamic> args = {};
      try {
        final decoded = jsonDecode(argsJson);
        if (decoded is Map) args = Map<String, dynamic>.from(decoded);
      } catch (_) {}

      switch (name) {
        case '_dart_promise_resolve':
          final id = (args['id'] as num).toInt();
          // 'value' is already the decoded JSON value (Map/List/String/
          // num/bool/null) — see callAsync for why this crosses the
          // bridge JSON-encoded exactly once, not twice.
          _pendingPromises.remove(id)?.complete(args['value']);

        case '_dart_promise_reject':
          final id = (args['id'] as num).toInt();
          final error = args['error'] as String? ?? 'Unknown error';
          _pendingPromises.remove(id)?.completeError(Exception(error));

        case '_dart_socket_connect':
          _handleSocketConnect(args);

        case '_dart_socket_write':
          // 'data' arrives as a base64 string (see class-level perf notes).
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
      // Best-effort — log but don't crash the JS context.
      // ignore: avoid_print
      print('[QuickJsRuntime] Bridge call "$name" error: $e');
    }

    sw.stop();
    if (sw.elapsedMilliseconds > 2) {
      // ignore: avoid_print
      print(
          '[QuickJsRuntime] _handleBridgeCall("$name") took ${sw.elapsedMilliseconds} ms');
    }

    return nullptr;
  }

  void _handleSocketConnect(Map<String, dynamic> args) {
    final socketId = (args['id'] as num).toInt();
    final host = args['host'] as String;
    final port = (args['port'] as num).toInt();
    final useTls = args['tls'] as bool? ?? false;

    // Connect asynchronously; deliver events back to JS via eval.
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
      _evalAsync("_dart_emit_socket($socketId, 'connect');");
      _bindings.pump(_handle);
    }).catchError((e) {
      _evalAsync(
        "_dart_emit_socket($socketId, 'error', new Error(${_jsString(e.toString())}));",
      );
      _bindings.pump(_handle);
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // Active runtime registry (needed for static callback dispatch)
  // ────────────────────────────────────────────────────────────────────────

  // NOTE: This is intentionally a simple static reference. In real use
  // there will typically be one QuickJsRuntime per Dart isolate. For
  // multi-instance scenarios, promote this to a Map<int, QuickJsRuntime>.
  static QuickJsRuntime? _activeRuntime;

  // ────────────────────────────────────────────────────────────────────────
  // JS polyfill layer
  // ────────────────────────────────────────────────────────────────────────

  void _installJsPolyfillLayer() {
    _activeRuntime = this;

    // language=javascript
    const polyfill = r"""
(function() {
  'use strict';

  globalThis.global = globalThis;
  globalThis.window = globalThis;
  globalThis.self = globalThis;

  // ── EventEmitter ─────────────────────────────────────────────────────────
  class EventEmitter {
    constructor() { this._events = {}; }
    on(event, fn) {
      (this._events[event] = this._events[event] || []).push(fn);
      return this;
    }
    addListener(event, fn) { return this.on(event, fn); }
    once(event, fn) {
      const wrapper = (...args) => { this.off(event, wrapper); fn(...args); };
      return this.on(event, wrapper);
    }
    off(event, fn) {
      if (this._events[event])
        this._events[event] = this._events[event].filter(f => f !== fn);
      return this;
    }
    removeListener(event, fn) { return this.off(event, fn); }
    emit(event, ...args) {
      (this._events[event] || []).slice().forEach(fn => fn(...args));
    }
    removeAllListeners(event) {
      if (event) delete this._events[event];
      else this._events = {};
      return this;
    }
    listenerCount(event) {
      return (this._events[event] || []).length;
    }
    listeners(event) {
      return (this._events[event] || []).slice();
    }
    rawListeners(event) {
      return (this._events[event] || []).slice();
    }
    setMaxListeners() { return this; }
    getMaxListeners() { return 10; }
  }
  // ── TextEncoder / TextDecoder polyfills ──────────────────────────────────
  if (typeof TextEncoder === 'undefined') {
    globalThis.TextEncoder = class {
      encode(str) {
        if (!str) return new Uint8Array(0);
        const utf8 = unescape(encodeURIComponent(str));
        const arr = new Uint8Array(utf8.length);
        for (let i = 0; i < utf8.length; i++) {
          arr[i] = utf8.charCodeAt(i);
        }
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
        for (let i = 0; i < len; i++) {
          str += String.fromCharCode(arr[i]);
        }
        try {
          return decodeURIComponent(escape(str));
        } catch (_) {
          return str;
        }
      }
    };
  }

  // ── base64 <-> bytes helpers ─────────────────────────────────────────────
  // Every binary payload crossing the Dart bridge (_ffiNotify) goes through
  // these. Avoid string concatenation in a loop for large buffers (can be
  // quadratic on some engines) — build an array of chunks and join once.
  const _B64_CHUNK = 0x2000;
  function _bytesToBase64(view) {
    const arr = view instanceof Uint8Array ? view : new Uint8Array(view);
    if (arr.length === 0) return '';
    const parts = new Array(Math.ceil(arr.length / _B64_CHUNK));
    let pi = 0;
    for (let i = 0; i < arr.length; i += _B64_CHUNK) {
      parts[pi++] = String.fromCharCode.apply(null, arr.subarray(i, i + _B64_CHUNK));
    }
    return btoa(parts.join(''));
  }
  function _base64ToBytes(b64) {
    if (!b64) return new Uint8Array(0);
    const bin = atob(b64);
    const len = bin.length;
    const out = new Uint8Array(len);
    for (let i = 0; i < len; i++) out[i] = bin.charCodeAt(i);
    return out;
  }

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

  // ── Complete Buffer polyfill ───────────────────────────────────────────────
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
          const te = new TextEncoder();
          const bytes = te.encode(data);
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
      static allocUnsafe(size) {
        return new _Buffer(size);
      }
      static allocUnsafeSlow(size) {
        return new _Buffer(size);
      }
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
        return new TextEncoder().encode(string).length;
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
        let off = 0;
        let len = undefined;
        let enc = 'utf8';
        if (typeof offset === 'number') {
          off = offset;
          if (typeof length === 'number') {
            len = length;
            if (typeof encoding === 'string') enc = encoding;
          } else if (typeof length === 'string') {
            enc = length;
          }
        } else if (typeof offset === 'string') {
          enc = offset;
        }
        const bytes = new TextEncoder().encode(string);
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
        return new TextDecoder().decode(sub);
      }
      equals(other) {
        if (!other || this.length !== other.length) return false;
        for (let i = 0; i < this.length; i++) {
          if (this[i] !== other[i]) return false;
        }
        return true;
      }
    }
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

  // `b64` is a base64-encoded payload (see class-level perf notes) — decode
  // straight into a Buffer, no JSON.parse of an integer array required.
  globalThis._dart_socket_data = function(id, b64) {
    const sock = _socketMap[id];
    if (!sock) return;
    try {
      sock.emit('data', Buffer.from(b64, 'base64'));
    } catch(e) {
      console.error('[_dart_socket_data error]:', e?.message || e, '\n[Stack]:', e?.stack);
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
    get destroyed() { return this._destroyed; }
    get pending() { return this.connecting; }
    get readyState() {
      if (this.connecting) return 'opening';
      if (this._destroyed) return 'closed';
      return 'open';
    }
  }
  DartSocket._idGen = 0;

  class TlsSocket extends DartSocket {
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
        tls: true,
      }));
      return this;
    }
    get encrypted() { return true; }
    get authorized() { return true; }
  }

  globalThis.net = {
    Socket: DartSocket,
    createConnection: (options, cb) => new DartSocket().connect(options, cb),
    connect: (options, cb) => new DartSocket().connect(options, cb),
  };

  globalThis.tls = {
    TLSSocket: TlsSocket,
    connect: (options, cb) => new TlsSocket().connect(options, cb),
  };

  // ── btoa / atob polyfills ───────────────────────────────────────────────
  // Array + single join('') instead of repeated += string concatenation —
  // avoids potential quadratic-time growth on large buffers.
  const _b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  if (typeof globalThis.btoa === 'undefined') {
    globalThis.btoa = function(str) {
      const len = str.length;
      if (len === 0) return '';
      const parts = new Array(Math.ceil(len / 3));
      let pi = 0;
      for (let i = 0; i < len; i += 3) {
        const a = str.charCodeAt(i);
        const b = i + 1 < len ? str.charCodeAt(i + 1) : 0;
        const c = i + 2 < len ? str.charCodeAt(i + 2) : 0;
        const n = (a << 16) | (b << 8) | c;
        let chunk = _b64chars[(n >> 18) & 63] + _b64chars[(n >> 12) & 63];
        chunk += (i + 1 < len) ? _b64chars[(n >> 6) & 63] : '=';
        chunk += (i + 2 < len) ? _b64chars[n & 63] : '=';
        parts[pi++] = chunk;
      }
      return parts.join('');
    };
  }
  if (typeof globalThis.atob === 'undefined') {
    globalThis.atob = function(str) {
      const clean = str.replace(/[^A-Za-z0-9+/]/g, '');
      const len = clean.length;
      if (len === 0) return '';
      const parts = new Array(Math.ceil(len / 4));
      let pi = 0;
      for (let i = 0; i < len; i += 4) {
        const a = _b64chars.indexOf(clean[i]);
        const b = _b64chars.indexOf(clean[i + 1]);
        const c = clean[i + 2] ? _b64chars.indexOf(clean[i + 2]) : 0;
        const d = clean[i + 3] ? _b64chars.indexOf(clean[i + 3]) : 0;
        const n = (a << 18) | (b << 12) | (c << 6) | d;
        let chunk = String.fromCharCode((n >> 16) & 255);
        if (clean[i + 2]) chunk += String.fromCharCode((n >> 8) & 255);
        if (clean[i + 3]) chunk += String.fromCharCode(n & 255);
        parts[pi++] = chunk;
      }
      return parts.join('');
    };
  }

  // ── Dart-backed crypto ────────────────────────────────────────────────────
  globalThis.crypto = globalThis.crypto || {};
  globalThis.crypto.randomUUID = function() {
    const bytes = crypto.randomBytes(16);
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    const hex = Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
    return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) + '-' + hex.slice(16, 20) + '-' + hex.slice(20);
  };
  globalThis.crypto.getRandomValues = function(typedArray) {
    if (!typedArray || !typedArray.length) return typedArray;
    const jsonResult = _ffiNotify('_dart_random_bytes', JSON.stringify({ count: typedArray.length }));
    const bytes = _base64ToBytes(JSON.parse(jsonResult));
    typedArray.set(bytes);
    return typedArray;
  };
  globalThis.crypto.randomBytes = function(n) {
    const jsonResult = _ffiNotify('_dart_random_bytes', JSON.stringify({ count: n }));
    return Buffer.from(JSON.parse(jsonResult), 'base64');
  };
  globalThis.crypto.createHash = function(algorithm) {
    const chunks = [];
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
        const res = _ffiNotify('_dart_subtle_hmac', JSON.stringify({
          algorithm: algorithm || 'sha256',
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

  // ── WebCrypto subtle shim (for Postgres SCRAM-SHA-256 SASL auth) ────────
  const subtle = {
    async digest(algorithm, data) {
      const algoName = typeof algorithm === 'string' ? algorithm : (algorithm?.name || 'SHA-256');
      const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
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
      stdout: { isTTY: false, write: (s) => console.log(s) },
      stderr: { isTTY: false, write: (s) => console.error(s) },
      stdin: { on: () => {} },
      hrtime: Object.assign((time) => {
        const now = Date.now();
        if (time) return [Math.floor(now / 1000) - time[0], 0];
        return [Math.floor(now / 1000), 0];
      }, { bigint: () => BigInt(Date.now()) * BigInt(1e6) }),
      cwd: () => '/tmp',
      exit: () => {},
    };
  }
  const _process = globalThis.process;

  // ── require() shim ────────────────────────────────────────────────────────
  const _path = {
    join: (...parts) => parts.filter(Boolean).join('/').replace(/\/+/g, '/'),
    dirname: (p) => (p ? p.replace(/\/[^/]*$/, '') : '') || '.',
    resolve: (...parts) => parts.join('/'),
    extname: (p) => { const m = p ? p.match(/\.[^.]*$/) : null; return m ? m[0] : ''; },
    basename: (p, ext) => {
      const base = p ? p.split('/').pop() : '';
      return ext && base.endsWith(ext) ? base.slice(0, -ext.length) : base;
    },
    sep: '/',
    delimiter: ':',
  };
  _path.posix = _path;
  _path.win32 = _path;
  const _assert = function(value, message) {
    if (!value) throw new Error(message || 'Assertion failed');
  };
  _assert.ok = _assert;
  _assert.strictEqual = (a, b, msg) => { if (a !== b) throw new Error(msg || `${a} !== ${b}`); };
  _assert.deepStrictEqual = (a, b, msg) => { if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(msg || 'Not deep equal'); };
  _assert.default = _assert;

  const _util = {
    format: (...args) => args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '),
    inherits: (ctor, superCtor) => { ctor.prototype = Object.create(superCtor.prototype); },
    promisify: (fn) => (...args) => new Promise((res, rej) => fn(...args, (err, val) => err ? rej(err) : res(val))),
    callbackify: (fn) => (...args) => {
      const cb = args.pop();
      fn(...args).then(val => cb(null, val), err => cb(err));
    },
    inspect: Object.assign((obj) => typeof obj === 'string' ? obj : JSON.stringify(obj), {
      custom: Symbol.for('nodejs.util.inspect.custom'),
      defaultOptions: {},
    }),
    types: {
      isDate: (v) => v instanceof Date,
      isPromise: (v) => v instanceof Promise,
    },
    deprecate: (fn) => fn,
    default: null,
  };
  _util.default = _util;

  const _crypto = Object.assign(globalThis.crypto, { default: globalThis.crypto });
  const _events = Object.assign(EventEmitter, { EventEmitter, default: EventEmitter });
  const _buffer = Object.assign(globalThis.Buffer, { Buffer: globalThis.Buffer, default: globalThis.Buffer });

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
        const rows = _sqlite ? _sqlite.query(this._handle, sql, params || []) : [];
        const row = rows && rows.length > 0 ? rows[0] : undefined;
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
      const self = { lastID: 0, changes: 0 };
      try {
        const res = _sqlite ? _sqlite.run(this._handle, sql, params || []) : { lastID: 0, changes: 0 };
        self.lastID = res.lastID;
        self.changes = res.changes;
        if (callback) queueMicrotask(() => callback.call(self, null));
      } catch (err) {
        if (callback) queueMicrotask(() => callback.call(self, err));
      }
      return this;
    }
    exec(sql, callback) {
      try {
        if (_sqlite) _sqlite.exec(this._handle, sql);
        if (callback) queueMicrotask(() => callback(null));
      } catch (err) {
        if (callback) queueMicrotask(() => callback(err));
      }
      return this;
    }
    serialize(callback) {
      if (callback) callback();
    }
    parallelize(callback) {
      if (callback) callback();
    }
    configure() {}
    interrupt() {}
  }

  const _sqlite3Module = {
    Database: SqliteDatabase,
    OPEN_READONLY: 1,
    OPEN_READWRITE: 2,
    OPEN_CREATE: 4,
    verbose: () => _sqlite3Module,
    default: null,
  };
  _sqlite3Module.default = _sqlite3Module;

  const _fsPromises = {
    access: async (path) => true,
    stat: async (path) => ({ isDirectory: () => false, isFile: () => true }),
    lstat: async (path) => ({ isDirectory: () => false, isFile: () => true }),
    mkdir: async (path, options) => undefined,
    readFile: async (path) => '',
    writeFile: async (path, data) => undefined,
    readdir: async (path) => [],
    unlink: async (path) => undefined,
    default: null,
  };
  _fsPromises.default = _fsPromises;

  const _fs = {
    promises: _fsPromises,
    access: (p, cb) => cb(null),
    accessSync: (p) => {},
    mkdir: (p, opts, cb) => { if (typeof opts === 'function') opts(null); else cb(null); },
    mkdirSync: (p) => {},
    readFile: (p, e, cb) => { if (typeof e === 'function') e(new Error('fs not available')); else cb(new Error('fs not available')); },
    writeFile: (p, d, e, cb) => { if (typeof e === 'function') e(new Error('fs not available')); else cb(new Error('fs not available')); },
    stat: (p, cb) => cb(null, { isDirectory: () => false, isFile: () => true }),
    statSync: () => ({ isDirectory: () => false, isFile: () => true }),
    lstat: (p, cb) => cb(null, { isDirectory: () => false, isFile: () => true }),
    lstatSync: () => ({ isDirectory: () => false, isFile: () => true }),
    readdir: (p, cb) => cb(null, []),
    readdirSync: () => [],
    existsSync: () => true,
    default: null,
  };
  _fs.default = _fs;

  const _modules = {
    process: _process,
    'node:process': _process,
    'process/browser': _process,
    net: globalThis.net,
    'node:net': globalThis.net,
    tls: globalThis.tls,
    'node:tls': globalThis.tls,
    crypto: _crypto,
    'node:crypto': _crypto,
    events: _events,
    'node:events': _events,
    buffer: _buffer,
    'node:buffer': _buffer,
    path: _path,
    'node:path': _path,
    'path/posix': _path,
    'path/win32': _path,
    assert: _assert,
    'node:assert': _assert,
    'node:assert/strict': _assert,
    util: _util,
    'node:util': _util,
    'node:util/types': _util.types,
    os: {
      platform: () => 'linux',
      EOL: '\n',
      tmpdir: () => '/tmp',
      cpus: () => [{ model: 'QuickJS Virtual CPU', speed: 2000, times: { user: 0, nice: 0, sys: 0, idle: 0, irq: 0 } }],
      homedir: () => '/tmp',
      hostname: () => 'localhost',
      release: () => '1.0.0',
      type: () => 'Linux',
      arch: () => 'x64',
      totalmem: () => 1024 * 1024 * 1024,
      freemem: () => 512 * 1024 * 1024,
    },
    stream: {
      Transform: EventEmitter,
      Readable: EventEmitter,
      Writable: EventEmitter,
      PassThrough: EventEmitter,
      pipeline: () => {},
    },
    string_decoder: {
      StringDecoder: class {
        write(b) { return new TextDecoder().decode(b); }
        end() { return ''; }
      },
    },
    sqlite3: _sqlite3Module,
    'node:sqlite3': _sqlite3Module,
    dns: {
      lookup: (host, opts, cb) => {
        if (typeof opts === 'function') { cb = opts; }
        cb(null, host, 4);
      },
    },
    child_process: { spawn: () => null, exec: () => null },
    worker_threads: { isMainThread: true, parentPort: null, workerData: null },
    fs: _fs,
    'node:fs': _fs,
    'fs/promises': _fsPromises,
    'node:fs/promises': _fsPromises,
    tty: { isatty: () => false },
    v8: { getHeapStatistics: () => ({}) },
    perf_hooks: { performance: { now: () => Date.now() } },
    async_hooks: { AsyncLocalStorage: class { run(store, fn, ...args) { return fn(...args); } getStore() { return undefined; } } },
    zlib: {},
    http: {},
    https: {},
    url: { URL: class { constructor(u) { this.href = u; } } },
  };

  globalThis.require = function(mod) {
    if (typeof mod === 'string' && mod.startsWith('node:')) {
      mod = mod.slice(5);
    }
    if (_modules[mod]) return _modules[mod];
    // Dynamic subpath: try stripping to base module name.
    const base = mod.split('/')[0];
    if (_modules[base]) return _modules[base];
    throw new Error(`[sequelize-quickjs] Module "${mod}" is not polyfilled.`);
  };
  globalThis._js_require = globalThis.require;
  globalThis.require.resolve = () => '';
  globalThis.module = { exports: {} };
  globalThis.exports = globalThis.module.exports;
  globalThis.__dirname = '/';
  globalThis.__filename = '/index.js';
})();
function require(mod) {
  return globalThis.require(mod);
}
var module = globalThis.module;
var exports = globalThis.exports;
var __dirname = globalThis.__dirname;
var __filename = globalThis.__filename;
""";

    eval(polyfill);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────

  /// Evaluate a JavaScript string and return the result as a Dart string.
  ///
  /// The result is JSON-encoded by QuickJS then decoded by Dart.
  String eval(String code) {
    return _bindings.eval(_handle, code);
  }

  /// Load a full JavaScript bundle into the runtime context.
  ///
  /// Call once after [create] with the Sequelize bridge bundle JS.
  void loadBundle(String bundleJs) {
    final res = eval(bundleJs);
    if (res != 'undefined') {
      // ignore: avoid_print
      print('[QuickJS Bundle Load Result]: $res');
    }
  }

  /// Call a global async JS function and await its Promise result.
  ///
  /// The function must be of the form:
  /// ```js
  /// async function myHandler(params) { return someValue; }
  /// ```
  ///
  /// Returns the decoded result when the Promise resolves.
  ///
  /// ## Why the result crosses the bridge JSON-encoded only once
  ///
  /// The result travels back as `{"id":<id>,"value":<result>}`, with
  /// `result` nested directly as JSON rather than pre-stringified into a
  /// string field. That means exactly one `JSON.stringify` on the JS side
  /// and one `jsonDecode` on the Dart side for the whole envelope.
  ///
  /// An earlier version did `JSON.stringify({id, value: JSON.stringify(result)})`
  /// — stringifying `result`, then stringifying the wrapper *around* that
  /// already-stringified text. Every quote character in the result got
  /// escaped a second time (inflating payload size), and the Dart side had
  /// to `jsonDecode` twice to unwrap it. For a query returning a few
  /// thousand rows that's a real, measurable tax paid on every call — keep
  /// nesting JSON values directly rather than stringifying-then-embedding
  /// when adding new bridge calls.
  Future<dynamic> callAsync(
    String functionName,
    Map<String, dynamic> params,
  ) {
    final id = _promiseIdCounter++;
    final completer = Completer<dynamic>();
    _pendingPromises[id] = completer;

    final paramsJson = jsonEncode(params);
    eval(
      '(async () => {'
      '  try {'
      '    const result = await $functionName($paramsJson);'
      '    _ffiNotify("_dart_promise_resolve", JSON.stringify({id:$id,value:result}));'
      '  } catch(e) {'
      '    _ffiNotify("_dart_promise_reject", JSON.stringify({id:$id,error:String(e.message||e)}));'
      '  }'
      '})();',
    );

    // Pump the microtask queue to let the Promise chain start executing.
    _bindings.pump(_handle);

    return completer.future;
  }

  /// Dispose the runtime and release all native QuickJS resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_activeRuntime == this) _activeRuntime = null;
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
    _evalAsync('_dart_trigger_timer($timerId);');
    _bindings.pump(_handle);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Socket event helpers
  // ────────────────────────────────────────────────────────────────────────

  void _onSocketData(int socketId, Uint8List data) {
    final sw = Stopwatch()..start();
    // Base64, embedded directly as a JS string literal — no JSON int-array
    // encoding/parsing, and no character escaping needed (base64's alphabet
    // is A-Za-z0-9+/=, none of which need quoting inside a single-quoted
    // JS string).
    final b64 = base64Encode(data);
    final encodeTime = sw.elapsedMilliseconds;
    sw.reset();
    sw.start();

    _evalAsync("_dart_socket_data($socketId, '$b64');");
    final evalTime = sw.elapsedMilliseconds;
    sw.reset();
    sw.start();

    _bindings.pump(_handle);
    final pumpTime = sw.elapsedMilliseconds;

    if (encodeTime > 1 || evalTime > 1 || pumpTime > 1) {
      // ignore: avoid_print
      print(
          '[QuickJsRuntime] _onSocketData [${data.length} bytes]: base64Encode=$encodeTime ms, _evalAsync=$evalTime ms, pump=$pumpTime ms');
    }
  }

  void _onSocketClose(int socketId) {
    _sockets.remove(socketId);
    _evalAsync("_dart_emit_socket($socketId, 'close');");
    _bindings.pump(_handle);
  }

  void _onSocketError(int socketId, String error) {
    _sockets.remove(socketId);
    _evalAsync(
      "_dart_emit_socket($socketId, 'error', new Error(${_jsString(error)}));",
    );
    _bindings.pump(_handle);
  }

  void _evalAsync(String code) {
    if (_disposed) return;
    try {
      eval(code);
    } catch (_) {}
  }

  // ────────────────────────────────────────────────────────────────────────
  // Crypto helpers
  // ────────────────────────────────────────────────────────────────────────

  /// Decode a value coming from the JS bridge into raw bytes.
  ///
  /// By convention (see class-level perf notes) the JS side always sends
  /// binary payloads as base64 strings, never as JSON int arrays — decoding
  /// a base64 string is O(n) with no JSON tokenization overhead, unlike the
  /// previous `List<int>` protocol which required parsing one JSON number
  /// per byte on both ends.
  static Uint8List _toUint8List(dynamic data) {
    if (data is List) return Uint8List.fromList(data.cast<int>());
    if (data is String) return base64Decode(data);
    return Uint8List(0);
  }

  static Uint8List _computeHmac(String algorithm, dynamic key, dynamic data) {
    final keyBytes = _toUint8List(key);
    final dataBytes = _toUint8List(data);
    final dartCrypto.Hash hash;
    switch (algorithm.toLowerCase().replaceAll('-', '')) {
      case 'sha256':
        hash = dartCrypto.sha256;
        break;
      case 'sha1':
        hash = dartCrypto.sha1;
        break;
      case 'md5':
        hash = dartCrypto.md5;
        break;
      default:
        hash = dartCrypto.sha256;
    }
    final hmac = dartCrypto.Hmac(hash, keyBytes);
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
    final hmac = dartCrypto.Hmac(dartCrypto.sha256, passwordBytes);
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

    switch (algorithm.toLowerCase()) {
      case 'sha256':
        return dartCrypto.sha256.convert(bytes).toString();
      case 'sha1':
        return dartCrypto.sha1.convert(bytes).toString();
      case 'md5':
        return dartCrypto.md5.convert(bytes).toString();
      default:
        return dartCrypto.sha256.convert(bytes).toString();
    }
  }

  static String _jsString(String s) {
    final escaped = s
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
    return "'$escaped'";
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
        onBadCertificate: (_) => true, // Accept self-signed certs for dev
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
