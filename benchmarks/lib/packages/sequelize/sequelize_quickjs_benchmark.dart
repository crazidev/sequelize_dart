import 'package:orm_benchmarks/packages/sequelize/sequelize_benchmark.dart';
import 'package:sequelize_orm/sequelize_orm.dart';
import 'package:sequelize_orm_quickjs/sequelize_orm_quickjs.dart';

class SequelizeOrmQuickjsBenchmark extends SequelizeOrmBenchmark {
  @override
  String get name => 'Sequelize (QuickJS)';

  @override
  Future<void> init() async {
    // Override the bridge to use QuickJS instead of Node.js
    BridgeClient.overrideWith(QuickJsBridgeClient.instance);
    await super.init();
  }

  @override
  Future<void> close() async {
    await super.close();
    // Reset the override so it doesn't affect other benchmarks
    BridgeClient.resetOverride();
  }
}
