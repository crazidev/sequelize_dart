import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:sequelize_orm_analyzer/rules/table_must_be_abstract.dart';
import 'package:sequelize_orm_analyzer/rules/table_should_have_primary_key.dart';
import 'package:sequelize_orm_analyzer/rules/uncommitted_transaction.dart';

final plugin = SequelizePlugin();

class SequelizePlugin extends Plugin {
  @override
  String get name => 'Sequelize ORM Dart plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(TableMustBeAbstract());
    registry.registerLintRule(TableShouldHavePrimaryKey());
    registry.registerLintRule(UncommittedTransaction());
    registry.registerFixForRule(
      TableMustBeAbstract.code,
      AddAbstractToTableClassFix.new,
    );
    registry.registerFixForRule(
      TableShouldHavePrimaryKey.code,
      AddPrimaryKeyToIdFieldFix.new,
    );
  }
}
