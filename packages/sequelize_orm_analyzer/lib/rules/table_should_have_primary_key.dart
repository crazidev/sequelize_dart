import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class TableShouldHavePrimaryKey extends AnalysisRule {
  static const LintCode code = LintCode(
    'table_should_have_primary_key',
    'Table class is missing a @PrimaryKey annotation on any field.',
    correctionMessage: "Add '@PrimaryKey()' to at least one field.",
  );

  static const LintCode codeOnIdField = LintCode(
    'table_should_have_primary_key',
    "Field 'id' should be annotated with @PrimaryKey.",
    correctionMessage: "Add '@PrimaryKey()' above the 'id' field.",
  );

  TableShouldHavePrimaryKey()
      : super(
          name: 'table_should_have_primary_key',
          description:
              'Ensures that any class with @Table annotation has at least one field annotated with @PrimaryKey.',
        );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final TableShouldHavePrimaryKey rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final hasTable = node.metadata.any(
      (annotation) => annotation.name.name == 'Table',
    );

    if (!hasTable) return;

    final fields = node.members.whereType<FieldDeclaration>().toList();

    final hasPrimaryKey = fields.any(
      (field) => field.metadata.any(
        (annotation) => annotation.name.name == 'PrimaryKey',
      ),
    );

    if (hasPrimaryKey) return;

    // If an 'id' field exists, report on it with the targeted code
    final idField = _findFieldNamed(fields, 'id');
    if (idField != null) {
      rule.reportAtToken(idField.fields.variables.first.name);
    } else {
      // Fallback: report on the class name
      rule.reportAtToken(node.name);
    }
  }

  FieldDeclaration? _findFieldNamed(
    List<FieldDeclaration> fields,
    String name,
  ) {
    for (final field in fields) {
      for (final variable in field.fields.variables) {
        if (variable.name.lexeme == name) return field;
      }
    }
    return null;
  }
}

/// Quick fix that inserts `@PrimaryKey()` above the `id` field.
class AddPrimaryKeyToIdFieldFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'sequelize_orm_analyzer.fix.addPrimaryKey',
    DartFixKindPriority.standard,
    "Add '@PrimaryKey()' to 'id' field",
  );

  AddPrimaryKeyToIdFieldFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind? get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final decl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (decl == null) return;

    final fields = decl.members.whereType<FieldDeclaration>().toList();

    FieldDeclaration? idField;
    for (final field in fields) {
      for (final variable in field.fields.variables) {
        if (variable.name.lexeme == 'id') {
          idField = field;
          break;
        }
      }
      if (idField != null) break;
    }

    if (idField == null) return;

    // Use getLinePrefix to get the leading whitespace of the field's line
    final indent = utils.getLinePrefix(idField.offset);

    await builder.addDartFileEdit(
      file,
      (editBuilder) {
        editBuilder.addSimpleInsertion(
          idField!.offset,
          '@PrimaryKey()\n$indent',
        );
      },
      createEditsForImports: false,
    );
  }
}
