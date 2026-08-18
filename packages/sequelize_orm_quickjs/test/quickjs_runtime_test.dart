import 'dart:convert';
import 'dart:io';
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
      final result =
          runtime.eval('JSON.stringify({ hello: "world", count: 42 })');
      expect(result, equals('{"hello":"world","count":42}'));
    });

    test('polyfilled crypto.randomBytes works with high entropy', () {
      final result = runtime.eval(
        'JSON.stringify(Array.from(crypto.randomBytes(16)))',
      );
      final bytes = (jsonDecode(result) as List).cast<int>();
      expect(bytes.length, equals(16));
      expect(bytes.any((b) => b != 0), isTrue);
    });

    test('polyfilled crypto.createHash works for SHA-256 and MD5', () {
      final sha256 = runtime
          .eval('crypto.createHash("sha256").update("hello").digest("hex")');
      // sha256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
      expect(
        sha256,
        equals(
          '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
        ),
      );

      final md5 = runtime
          .eval('crypto.createHash("md5").update("hello").digest("hex")');
      // md5("hello") = 5d41402abc4b2a76b9719d911017c592
      expect(md5, equals('5d41402abc4b2a76b9719d911017c592'));
    });

    test('polyfilled crypto.createHmac works for HMAC-SHA256', () {
      final hmac = runtime.eval(
        'crypto.createHmac("sha256", "secret_key").update("hello world").digest("hex")',
      );
      // HMAC-SHA256("secret_key", "hello world") = cf1a418afaafc798df48fd804a2abf6970283afd8c40b41f818ad9b6ca4f8ca8
      expect(
        hmac,
        equals(
          'cf1a418afaafc798df48fd804a2abf6970283afd8c40b41f818ad9b6ca4f8ca8',
        ),
      );
    });

    test('polyfilled crypto.pbkdf2Sync works for PBKDF2-HMAC-SHA256', () {
      final keyHex = runtime.eval(
        'crypto.pbkdf2Sync("password", "salt", 1000, 32, "sha256").toString("hex")',
      );
      // PBKDF2-HMAC-SHA256("password", "salt", 1000, 32) = 632c2812e46d4604102ba7618e9d6d7d2f8128f6266b4a03264d2a0460b7dcb3
      expect(
        keyHex,
        equals(
          '632c2812e46d4604102ba7618e9d6d7d2f8128f6266b4a03264d2a0460b7dcb3',
        ),
      );
    });

    test('polyfilled Buffer works correctly', () {
      final result = runtime.eval('Buffer.from("abc").toString()');
      expect(result, contains('abc'));

      final base64 =
          runtime.eval('Buffer.from("hello world").toString("base64")');
      expect(base64, equals('aGVsbG8gd29ybGQ='));

      final fromBase64 = runtime
          .eval('Buffer.from("aGVsbG8gd29ybGQ=", "base64").toString("utf8")');
      expect(fromBase64, equals('hello world'));
    });

    test('callAsync resolves JS Promise to Dart value', () async {
      runtime.eval(r'''
        globalThis.testAsyncAdd = async function(params) {
          const a = params.a || 0;
          const b = params.b || 0;
          return { sum: a + b, message: "ok" };
        };
      ''');

      final result =
          await runtime.callAsync('testAsyncAdd', {'a': 15, 'b': 27});
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

    test('native SQLite prepared statement caching and single-row query work',
        () {
      runtime.eval(r'''
        const dbId = _native_sqlite.open(":memory:");
        _native_sqlite.exec(dbId, "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, score REAL);");
        _native_sqlite.run(dbId, "INSERT INTO users (name, score) VALUES (?, ?);", ["Alice", 95.5]);
        _native_sqlite.run(dbId, "INSERT INTO users (name, score) VALUES (?, ?);", ["Bob", 88.0]);
        _native_sqlite.run(dbId, "INSERT INTO users (name, score) VALUES (?, ?);", ["Charlie", 72.3]);

        // Test single row get
        const row1 = _native_sqlite.get(dbId, "SELECT id, name, score FROM users WHERE name = ?;", ["Alice"]);

        // Test all rows query (which reuses cached prepared statement)
        const allRows = _native_sqlite.all(dbId, "SELECT id, name, score FROM users ORDER BY id ASC;", []);

        _native_sqlite.close(dbId);

        globalThis.sqliteTestResult = {
          row1,
          allRows,
        };
      ''');

      final jsonResult =
          runtime.eval('JSON.stringify(globalThis.sqliteTestResult)');
      final data = jsonDecode(jsonResult) as Map<String, dynamic>;

      expect(data['row1']['name'], equals('Alice'));
      expect(data['row1']['score'], equals(95.5));

      final allRows = (data['allRows'] as List).cast<Map<String, dynamic>>();
      expect(allRows.length, equals(3));
      expect(allRows[0]['name'], equals('Alice'));
      expect(allRows[1]['name'], equals('Bob'));
      expect(allRows[2]['name'], equals('Charlie'));
    });

    test('GC and memory management methods execute safely', () {
      expect(() => runtime.setMemoryLimit(128 * 1024 * 1024), returnsNormally);
      expect(() => runtime.setGcThreshold(1024 * 1024), returnsNormally);
      expect(() => runtime.gc(), returnsNormally);
    });

    test('Multiple concurrent QuickJsRuntime instances maintain isolated state',
        () async {
      final runtime2 = await QuickJsRuntime.create();
      try {
        runtime.eval('globalThis.instanceName = "RUNTIME_ONE";');
        runtime2.eval('globalThis.instanceName = "RUNTIME_TWO";');

        expect(runtime.eval('globalThis.instanceName'), equals('RUNTIME_ONE'));
        expect(runtime2.eval('globalThis.instanceName'), equals('RUNTIME_TWO'));
      } finally {
        runtime2.dispose();
      }
    });

    test('load bridge_server_quickjs bundle without top-level error', () {
      final bundleFile = File(
          '../sequelize_orm/lib/src/bridge/bridge_server_quickjs.bundle.js');
      expect(bundleFile.existsSync(), isTrue);
      final bundleJs = bundleFile.readAsStringSync();
      final res = runtime.loadBundle(bundleJs);
      // If eval fails, eval returns the stack trace string
      expect(res, isNot(contains('at ')));
      final handleReqType = runtime.eval('typeof globalThis.handleRequest');
      expect(handleReqType, equals('function'));
    });
  });
}
