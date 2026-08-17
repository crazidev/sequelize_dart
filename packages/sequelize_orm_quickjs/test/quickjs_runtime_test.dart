import 'package:sequelize_orm_quickjs/sequelize_orm_quickjs.dart';
import 'package:test/test.dart';

void main() {
  group('QuickJsRuntime', () {
    late QuickJsRuntime runtime;

    setUp(() async {
      runtime = await QuickJsRuntime.create();
    });

    tearDown(() {
      runtime.dispose();
    });

    test('eval simple synchronous arithmetic', () {
      final result = runtime.eval('1 + 1');
      expect(result, equals('2'));
    });

    test('eval string and json manipulation', () {
      final result = runtime.eval('JSON.stringify({ hello: "world", count: 42 })');
      expect(result, equals('{"hello":"world","count":42}'));
    });

    test('polyfilled crypto.randomBytes works', () {
      final result = runtime.eval('Array.from(crypto.randomBytes(4)).length');
      expect(result, equals('4'));
    });

    test('polyfilled crypto.createHash works', () {
      final hash = runtime.eval('crypto.createHash("sha256").update("hello").digest("hex")');
      // sha256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
      expect(hash, equals('2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824'));
    });

    test('polyfilled Buffer works', () {
      final result = runtime.eval('Buffer.from("abc").toString()');
      expect(result, contains('abc'));
    });

    test('callAsync resolves JS Promise to Dart value', () async {
      runtime.eval(r'''
        globalThis.testAsyncAdd = async function(params) {
          const a = params.a || 0;
          const b = params.b || 0;
          return { sum: a + b, message: "ok" };
        };
      ''');

      final result = await runtime.callAsync('testAsyncAdd', {'a': 15, 'b': 27});
      expect(result, isA<Map>());
      expect(result['sum'], equals(42));
      expect(result['message'], equals('ok'));
    });

    test('callAsync rejects when JS throws error', () async {
      runtime.eval(r'''
        globalThis.testFailingAsync = async function(params) {
          throw new Error("Intentional async test error");
        };
      ''');

      expect(
        () => runtime.callAsync('testFailingAsync', {}),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'error message',
          contains('Intentional async test error'),
        )),
      );
    });
  });
}
