// Native Assets build hook for sequelize_orm_quickjs.
//
// Compiles the vendored QuickJS C sources (in native/quickjs/) into a
// platform-native shared library (libquickjs_dart.dylib / .so / .dll) that
// is loaded at runtime by dart:ffi via QuickJsBindings.

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final cBuilder = CBuilder.library(
      name: 'quickjs_dart',
      assetName: 'lib/src/quickjs_bindings.dart',
      sources: [
        'native/quickjs/quickjs.c',
        'native/quickjs/cutils.c',
        'native/quickjs/dtoa.c',
        'native/quickjs/libregexp.c',
        'native/quickjs/libunicode.c',
        'native/quickjs/quickjs_dart_bridge.c',
      ],
      includes: [
        'native/quickjs',
      ],
      flags: [
        '-DCONFIG_BIGNUM',
        '-D_GNU_SOURCE',
        '-DCONFIG_VERSION="2024-01-13"',
        '-O2',
        '-fwrapv',
        '-lsqlite3',
      ],
    );

    await cBuilder.run(
      input: input,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => print(record.message)),
    );
  });
}
