/// Low-level Dart FFI bindings to the compiled QuickJS native library.
///
/// These bindings directly map to the C functions in `quickjs_dart_bridge.c`.
/// You should not use these directly; use [QuickJsRuntime] instead.
library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Native function signatures
// ─────────────────────────────────────────────────────────────────────────────

// Opaque C struct pointer — QjsDartRuntime*
final class QjsDartRuntimeOpaque extends Opaque {}

typedef QjsDartRuntimePtr = Pointer<QjsDartRuntimeOpaque>;

// qjs_dart_create_runtime() -> QjsDartRuntime*
typedef _CreateRuntimeC = QjsDartRuntimePtr Function();
typedef _CreateRuntime = QjsDartRuntimePtr Function();

// qjs_dart_free_runtime(QjsDartRuntime*)
typedef _FreeRuntimeC = Void Function(QjsDartRuntimePtr);
typedef _FreeRuntime = void Function(QjsDartRuntimePtr);

// DartBridgeCallback type: const char* (*)(const char* name, const char* args)
typedef DartBridgeCallbackC = Pointer<Utf8> Function(
  Pointer<Utf8> name,
  Pointer<Utf8> argsJson,
);
typedef DartBridgeCallbackNative = Pointer<Utf8> Function(
  Pointer<Utf8> name,
  Pointer<Utf8> argsJson,
);

// qjs_dart_set_callback(DartBridgeCallback)
typedef _SetCallbackC = Void Function(
  Pointer<NativeFunction<DartBridgeCallbackC>>,
);
typedef _SetCallback = void Function(
  Pointer<NativeFunction<DartBridgeCallbackC>>,
);

// qjs_dart_set_runtime_callback(QjsDartRuntime*, DartBridgeCallback)
typedef _SetRuntimeCallbackC = Void Function(
  QjsDartRuntimePtr handle,
  Pointer<NativeFunction<DartBridgeCallbackC>>,
);
typedef _SetRuntimeCallback = void Function(
  QjsDartRuntimePtr handle,
  Pointer<NativeFunction<DartBridgeCallbackC>>,
);

typedef DartBridgeBinaryCallbackC = Void Function(
  QjsDartRuntimePtr handle,
  Int32 promiseId,
  Pointer<Uint8> bytes,
  Int32 length,
);

typedef _SetRuntimeBinaryCallbackC = Void Function(
  QjsDartRuntimePtr handle,
  Pointer<NativeFunction<DartBridgeBinaryCallbackC>>,
);
typedef _SetRuntimeBinaryCallback = void Function(
  QjsDartRuntimePtr handle,
  Pointer<NativeFunction<DartBridgeBinaryCallbackC>>,
);

// qjs_dart_eval(QjsDartRuntime*, const char* js) -> char*
typedef _EvalC = Pointer<Utf8> Function(
  QjsDartRuntimePtr handle,
  Pointer<Utf8> jsCode,
);
typedef _Eval = Pointer<Utf8> Function(
  QjsDartRuntimePtr handle,
  Pointer<Utf8> jsCode,
);

// qjs_dart_call_async(QjsDartRuntime*, int promise_id, const char* json_args) -> int
typedef _CallAsyncC = Int32 Function(
  QjsDartRuntimePtr handle,
  Int32 promiseId,
  Pointer<Utf8> jsonArgs,
);
typedef _CallAsync = int Function(
  QjsDartRuntimePtr handle,
  int promiseId,
  Pointer<Utf8> jsonArgs,
);

// qjs_dart_trigger_timer(QjsDartRuntime*, int timer_id) -> int
typedef _TriggerTimerC = Int32 Function(
  QjsDartRuntimePtr handle,
  Int32 timerId,
);
typedef _TriggerTimer = int Function(
  QjsDartRuntimePtr handle,
  int timerId,
);

// qjs_dart_emit_socket_data(QjsDartRuntime*, int socket_id, const uint8_t* bytes, size_t len) -> int
typedef _EmitSocketDataC = Int32 Function(
  QjsDartRuntimePtr handle,
  Int32 socketId,
  Pointer<Uint8> bytes,
  IntPtr len,
);
typedef _EmitSocketData = int Function(
  QjsDartRuntimePtr handle,
  int socketId,
  Pointer<Uint8> bytes,
  int len,
);

// qjs_dart_emit_socket_event(QjsDartRuntime*, int socket_id, const char* event_name) -> int
typedef _EmitSocketEventC = Int32 Function(
  QjsDartRuntimePtr handle,
  Int32 socketId,
  Pointer<Utf8> eventName,
);
typedef _EmitSocketEvent = int Function(
  QjsDartRuntimePtr handle,
  int socketId,
  Pointer<Utf8> eventName,
);

// qjs_dart_emit_socket_error(QjsDartRuntime*, int socket_id, const char* error_msg) -> int
typedef _EmitSocketErrorC = Int32 Function(
  QjsDartRuntimePtr handle,
  Int32 socketId,
  Pointer<Utf8> errorMsg,
);
typedef _EmitSocketError = int Function(
  QjsDartRuntimePtr handle,
  int socketId,
  Pointer<Utf8> errorMsg,
);

// qjs_dart_pump(QjsDartRuntime*) -> int
typedef _PumpC = Int32 Function(QjsDartRuntimePtr handle);
typedef _Pump = int Function(QjsDartRuntimePtr handle);

// qjs_dart_pump_all(QjsDartRuntime*) -> int
typedef _PumpAllC = Int32 Function(QjsDartRuntimePtr handle);
typedef _PumpAll = int Function(QjsDartRuntimePtr handle);

// qjs_dart_set_memory_limit(QjsDartRuntime*, size_t limit)
typedef _SetMemoryLimitC = Void Function(
    QjsDartRuntimePtr handle, IntPtr limit);
typedef _SetMemoryLimit = void Function(QjsDartRuntimePtr handle, int limit);

// qjs_dart_set_gc_threshold(QjsDartRuntime*, size_t threshold)
typedef _SetGcThresholdC = Void Function(
    QjsDartRuntimePtr handle, IntPtr threshold);
typedef _SetGcThreshold = void Function(
    QjsDartRuntimePtr handle, int threshold);

// qjs_dart_run_gc(QjsDartRuntime*)
typedef _RunGcC = Void Function(QjsDartRuntimePtr handle);
typedef _RunGc = void Function(QjsDartRuntimePtr handle);

// qjs_dart_free_string(char*)
typedef _FreeStringC = Void Function(Pointer<Utf8> str);
typedef _FreeString = void Function(Pointer<Utf8> str);

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic library loading
// ─────────────────────────────────────────────────────────────────────────────

/// Loads the compiled `quickjs_dart` native library.
DynamicLibrary _loadLibrary() {
  const assetName = 'quickjs_dart';
  final libName = Platform.isMacOS
      ? 'lib$assetName.dylib'
      : Platform.isWindows
          ? '$assetName.dll'
          : 'lib$assetName.so';

  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }

  // 1. Check environment variable override
  final envLib = Platform.environment['QUICKJS_DART_LIB'] ??
      Platform.environment['LIBQUICKJS_PATH'];
  if (envLib != null && envLib.isNotEmpty) {
    final envFile = File(envLib);
    if (envFile.existsSync()) {
      try {
        return DynamicLibrary.open(envFile.absolute.path);
      } catch (_) {}
    }
  }

  // 2. Try standard dynamic library open
  try {
    return DynamicLibrary.open(libName);
  } catch (_) {}

  // 3. Collect candidate search paths across bundle, script, CWD, and build locations
  final candidatePaths = <String>[];

  try {
    final exeFile = File(Platform.resolvedExecutable);
    final exeDir = exeFile.parent;
    final exeParent = exeDir.parent;

    candidatePaths.add('${exeParent.path}/lib/$libName');
    candidatePaths.add('${exeParent.path}/$libName');
    candidatePaths.add('${exeParent.path}/Frameworks/$libName');
    candidatePaths.add('${exeDir.path}/$libName');
    candidatePaths.add('${exeDir.path}/lib/$libName');
    candidatePaths.add('${exeDir.path}/Frameworks/$libName');
  } catch (_) {}

  try {
    if (Platform.script.scheme == 'file') {
      final scriptDir = File.fromUri(Platform.script).parent;
      candidatePaths.add('${scriptDir.path}/$libName');
      candidatePaths.add('${scriptDir.path}/lib/$libName');
      candidatePaths.add('${scriptDir.path}/../lib/$libName');
      candidatePaths.add('${scriptDir.path}/../native/quickjs/$libName');
      candidatePaths.add('${scriptDir.path}/../../native/quickjs/$libName');
      candidatePaths.add('${scriptDir.path}/../../../native/quickjs/$libName');
      candidatePaths.add(
          '${scriptDir.path}/../../packages/sequelize_orm_quickjs/native/quickjs/$libName');
      candidatePaths.add(
          '${scriptDir.path}/../../../packages/sequelize_orm_quickjs/native/quickjs/$libName');
    }
  } catch (_) {}

  final cwd = Directory.current.path;
  candidatePaths.addAll([
    '/tmp/$libName',
    libName,
    '$cwd/$libName',
    '$cwd/lib/$libName',
    '$cwd/native/quickjs/$libName',
    '$cwd/packages/sequelize_orm_quickjs/native/quickjs/$libName',
    '$cwd/../packages/sequelize_orm_quickjs/native/quickjs/$libName',
    '$cwd/../../packages/sequelize_orm_quickjs/native/quickjs/$libName',
    '$cwd/build/cli/macos_x64/bundle/lib/$libName',
    '$cwd/build/cli/macos_arm64/bundle/lib/$libName',
    '$cwd/build/cli/linux_x64/bundle/lib/$libName',
    '$cwd/build/cli/linux_arm64/bundle/lib/$libName',
    '$cwd/build/cli/windows_x64/bundle/lib/$libName',
    '$cwd/benchmarks/build/cli/macos_x64/bundle/lib/$libName',
    '$cwd/benchmarks/build/cli/macos_arm64/bundle/lib/$libName',
    '$cwd/benchmarks/build/cli/linux_x64/bundle/lib/$libName',
    '$cwd/benchmarks/build/cli/linux_arm64/bundle/lib/$libName',
    '$cwd/benchmarks/build/cli/windows_x64/bundle/lib/$libName',
  ]);

  for (final path in candidatePaths) {
    final file = File(path);
    if (file.existsSync()) {
      try {
        return DynamicLibrary.open(file.absolute.path);
      } catch (_) {}
    }
  }

  return DynamicLibrary.open(libName);
}

// ─────────────────────────────────────────────────────────────────────────────
// Bindings class
// ─────────────────────────────────────────────────────────────────────────────

/// Low-level FFI bindings to `quickjs_dart_bridge.c`.
class QuickJsBindings {
  final DynamicLibrary _lib;

  late final _CreateRuntime _createRuntime;
  late final _FreeRuntime _freeRuntime;
  late final _SetCallback _setCallback;
  late final _SetRuntimeCallback _setRuntimeCallback;
  late final _SetRuntimeBinaryCallback _setRuntimeBinaryCallback;
  late final _Eval _eval;
  late final _CallAsync _callAsync;
  late final _TriggerTimer _triggerTimer;
  late final _EmitSocketData _emitSocketData;
  late final _EmitSocketEvent _emitSocketEvent;
  late final _EmitSocketError _emitSocketError;
  late final _Pump _pump;
  late final _PumpAll _pumpAll;
  late final _SetMemoryLimit _setMemoryLimit;
  late final _SetGcThreshold _setGcThreshold;
  late final _RunGc _runGc;
  late final _FreeString _freeString;

  QuickJsBindings._(this._lib) {
    _createRuntime = _lib
        .lookup<NativeFunction<_CreateRuntimeC>>('qjs_dart_create_runtime')
        .asFunction();
    _freeRuntime = _lib
        .lookup<NativeFunction<_FreeRuntimeC>>('qjs_dart_free_runtime')
        .asFunction();
    _setCallback = _lib
        .lookup<NativeFunction<_SetCallbackC>>('qjs_dart_set_callback')
        .asFunction();
    _setRuntimeCallback = _lib
        .lookup<NativeFunction<_SetRuntimeCallbackC>>(
            'qjs_dart_set_runtime_callback')
        .asFunction();
    _setRuntimeBinaryCallback = _lib
        .lookup<NativeFunction<_SetRuntimeBinaryCallbackC>>(
            'qjs_dart_set_runtime_binary_callback')
        .asFunction();
    _eval = _lib.lookup<NativeFunction<_EvalC>>('qjs_dart_eval').asFunction();
    _callAsync = _lib
        .lookup<NativeFunction<_CallAsyncC>>('qjs_dart_call_async')
        .asFunction();
    _triggerTimer = _lib
        .lookup<NativeFunction<_TriggerTimerC>>('qjs_dart_trigger_timer')
        .asFunction();
    _emitSocketData = _lib
        .lookup<NativeFunction<_EmitSocketDataC>>('qjs_dart_emit_socket_data')
        .asFunction();
    _emitSocketEvent = _lib
        .lookup<NativeFunction<_EmitSocketEventC>>('qjs_dart_emit_socket_event')
        .asFunction();
    _emitSocketError = _lib
        .lookup<NativeFunction<_EmitSocketErrorC>>('qjs_dart_emit_socket_error')
        .asFunction();
    _pump = _lib.lookup<NativeFunction<_PumpC>>('qjs_dart_pump').asFunction();
    _pumpAll = _lib
        .lookup<NativeFunction<_PumpAllC>>('qjs_dart_pump_all')
        .asFunction();
    _setMemoryLimit = _lib
        .lookup<NativeFunction<_SetMemoryLimitC>>('qjs_dart_set_memory_limit')
        .asFunction();
    _setGcThreshold = _lib
        .lookup<NativeFunction<_SetGcThresholdC>>('qjs_dart_set_gc_threshold')
        .asFunction();
    _runGc =
        _lib.lookup<NativeFunction<_RunGcC>>('qjs_dart_run_gc').asFunction();
    _freeString = _lib
        .lookup<NativeFunction<_FreeStringC>>('qjs_dart_free_string')
        .asFunction();
  }

  static QuickJsBindings? _instance;

  /// Singleton access to the native bindings.
  static QuickJsBindings get instance {
    _instance ??= QuickJsBindings._(_loadLibrary());
    return _instance!;
  }

  // ── Wrapped API ──────────────────────────────────────────────────────────

  /// Create a new QuickJS runtime.
  QjsDartRuntimePtr createRuntime() => _createRuntime();

  /// Free a runtime created with [createRuntime].
  void freeRuntime(QjsDartRuntimePtr handle) => _freeRuntime(handle);

  /// Set the global Dart callback dispatcher.
  void setCallback(Pointer<NativeFunction<DartBridgeCallbackC>> cb) {
    _setCallback(cb);
  }

  /// Set the runtime-specific Dart callback dispatcher.
  void setRuntimeCallback(
    QjsDartRuntimePtr handle,
    Pointer<NativeFunction<DartBridgeCallbackC>> cb,
  ) {
    _setRuntimeCallback(handle, cb);
  }

  /// Set the runtime-specific binary FFI callback dispatcher (Option B).
  void setRuntimeBinaryCallback(
    QjsDartRuntimePtr handle,
    Pointer<NativeFunction<DartBridgeBinaryCallbackC>> cb,
  ) {
    _setRuntimeBinaryCallback(handle, cb);
  }

  /// Evaluate [jsCode] in [handle] and return the JSON-encoded result string.
  Pointer<Utf8> evalRaw(QjsDartRuntimePtr handle, Pointer<Utf8> jsCode) {
    return _eval(handle, jsCode);
  }

  /// Evaluate [jsCode] in [handle] and return the result as a Dart string.
  String eval(QjsDartRuntimePtr handle, String jsCode) {
    final codePtr = jsCode.toNativeUtf8();
    final resultPtr = _eval(handle, codePtr);
    calloc.free(codePtr);
    if (resultPtr == nullptr) return 'null';
    final result = resultPtr.toDartString();
    _freeString(resultPtr);
    return result;
  }

  /// Directly dispatch an async call into `_dart_handleRequest` with JSON arguments without eval.
  int callAsync(QjsDartRuntimePtr handle, int promiseId, String jsonArgs) {
    final argsPtr = jsonArgs.toNativeUtf8();
    final res = _callAsync(handle, promiseId, argsPtr);
    calloc.free(argsPtr);
    return res;
  }

  /// Directly trigger a JavaScript timer callback by [timerId] without eval.
  int triggerTimer(QjsDartRuntimePtr handle, int timerId) {
    return _triggerTimer(handle, timerId);
  }

  /// Directly push binary bytes into JavaScript context without base64 encoding.
  int emitSocketData(
    QjsDartRuntimePtr handle,
    int socketId,
    Pointer<Uint8> bytes,
    int len,
  ) {
    return _emitSocketData(handle, socketId, bytes, len);
  }

  /// Directly emit a socket event (e.g. 'connect', 'close').
  int emitSocketEvent(
      QjsDartRuntimePtr handle, int socketId, String eventName) {
    final namePtr = eventName.toNativeUtf8();
    final res = _emitSocketEvent(handle, socketId, namePtr);
    calloc.free(namePtr);
    return res;
  }

  /// Directly emit a socket error with [errorMsg].
  int emitSocketError(QjsDartRuntimePtr handle, int socketId, String errorMsg) {
    final msgPtr = errorMsg.toNativeUtf8();
    final res = _emitSocketError(handle, socketId, msgPtr);
    calloc.free(msgPtr);
    return res;
  }

  /// Pump the QuickJS microtask queue in native C until it is empty.
  ///
  /// Returns the number of pump iterations executed in a single FFI crossing.
  int pumpAll(QjsDartRuntimePtr handle) {
    return _pumpAll(handle);
  }

  /// Single step pump for backward compatibility.
  int pump(QjsDartRuntimePtr handle) {
    return _pump(handle);
  }

  /// Set the memory limit for the QuickJS runtime in bytes.
  void setMemoryLimit(QjsDartRuntimePtr handle, int bytes) {
    _setMemoryLimit(handle, bytes);
  }

  /// Set the GC threshold for the QuickJS runtime in bytes.
  void setGcThreshold(QjsDartRuntimePtr handle, int bytes) {
    _setGcThreshold(handle, bytes);
  }

  /// Trigger garbage collection in QuickJS.
  void runGc(QjsDartRuntimePtr handle) {
    _runGc(handle);
  }

  /// Free a result string returned by [evalRaw].
  void freeResultString(Pointer<Utf8> ptr) {
    if (ptr != nullptr) _freeString(ptr);
  }
}
