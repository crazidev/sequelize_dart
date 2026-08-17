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

// qjs_dart_eval(QjsDartRuntime*, const char* js) -> char*
typedef _EvalC = Pointer<Utf8> Function(
  QjsDartRuntimePtr handle,
  Pointer<Utf8> jsCode,
);
typedef _Eval = Pointer<Utf8> Function(
  QjsDartRuntimePtr handle,
  Pointer<Utf8> jsCode,
);

// qjs_dart_pump(QjsDartRuntime*) -> int
typedef _PumpC = Int32 Function(QjsDartRuntimePtr handle);
typedef _Pump = int Function(QjsDartRuntimePtr handle);

// qjs_dart_free_string(char*)
typedef _FreeStringC = Void Function(Pointer<Utf8> str);
typedef _FreeString = void Function(Pointer<Utf8> str);

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic library loading
// ─────────────────────────────────────────────────────────────────────────────

/// Loads the compiled `quickjs_dart` native library.
///
/// The Native Assets build hook (`hook/build.dart`) places the compiled
/// `.dylib` / `.so` / `.dll` at a standard location known to the Dart
/// runtime. When native assets are enabled (`--enable-experiment=native-assets`
/// or Dart 3.7+), `DynamicLibrary.open` resolves the asset name automatically.
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

  // 1. Try standard dynamic library open (works when Native Assets or system path provides it)
  try {
    return DynamicLibrary.open(libName);
  } catch (_) {}

  // 2. Search common build / output locations
  final candidatePaths = [
    '/tmp/$libName',
    libName,
    'native/quickjs/$libName',
    'packages/sequelize_orm_quickjs/native/quickjs/$libName',
    '../packages/sequelize_orm_quickjs/native/quickjs/$libName',
    '../../packages/sequelize_orm_quickjs/native/quickjs/$libName',
  ];

  for (final path in candidatePaths) {
    if (File(path).existsSync()) {
      try {
        return DynamicLibrary.open(File(path).absolute.path);
      } catch (_) {}
    }
  }

  // Final attempt: throws dynamic library error if not found
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
  late final _Eval _eval;
  late final _Pump _pump;
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
    _eval = _lib
        .lookup<NativeFunction<_EvalC>>('qjs_dart_eval')
        .asFunction();
    _pump = _lib
        .lookup<NativeFunction<_PumpC>>('qjs_dart_pump')
        .asFunction();
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

  /// Evaluate [jsCode] in [handle] and return the JSON-encoded result string.
  ///
  /// The returned string must be freed with [freeResultString].
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

  /// Pump the QuickJS microtask queue until it is empty.
  ///
  /// Returns the number of pump iterations required.
  int pump(QjsDartRuntimePtr handle) {
    int iterations = 0;
    int ret;
    do {
      ret = _pump(handle);
      if (ret > 0) iterations++;
    } while (ret > 0);
    return iterations;
  }

  /// Free a result string returned by [evalRaw].
  void freeResultString(Pointer<Utf8> ptr) {
    if (ptr != nullptr) _freeString(ptr);
  }
}
