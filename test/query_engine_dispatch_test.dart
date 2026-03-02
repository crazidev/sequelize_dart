import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:test/test.dart';

class _SpyQueryEngine extends BridgeQueryEngine {
  bool findAllCalled = false;

  @override
  Future<List<ModelInstanceData>> findAll({
    required String modelName,
    Query? query,
    sequelize,
    model,
    Transaction? transaction,
  }) async {
    findAllCalled = true;
    return <ModelInstanceData>[
      ModelInstanceData(
        data: {
          'model': modelName,
          'query': query?.toJson(),
        },
      ),
    ];
  }
}

void main() {
  group('QueryEngine dispatch', () {
    test('uses bridge engine by default', () {
      final resolved = QueryEngineRegistry.resolve(null);
      expect(resolved, isA<BridgeQueryEngine>());
    });

    test('routes calls to engine registered for sequelize instance', () async {
      final token = Object();
      final spy = _SpyQueryEngine();
      QueryEngineRegistry.registerForSequelize(token, spy);

      final result = await QueryEngine().findAll(
        modelName: 'Users',
        sequelize: token,
      );

      expect(spy.findAllCalled, isTrue);
      expect(result, hasLength(1));
      expect(result.first.data['model'], 'Users');

      QueryEngineRegistry.unregisterForSequelize(token);
    });

    test('falls back to default after unregister', () {
      final token = Object();
      final spy = _SpyQueryEngine();
      QueryEngineRegistry.registerForSequelize(token, spy);
      QueryEngineRegistry.unregisterForSequelize(token);

      final resolved = QueryEngineRegistry.resolve(token);
      expect(resolved, isA<BridgeQueryEngine>());
    });
  });
}
