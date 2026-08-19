import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class UncommittedTransaction extends AnalysisRule {
  static const LintCode code = LintCode(
    'uncommitted_transaction',
    'Unmanaged transactions must be manually committed or rolled back to avoid leaks.',
    correctionMessage:
        "Add 'await transaction.commit();' or 'await transaction.rollback();'",
  );

  UncommittedTransaction()
    : super(
        name: 'uncommitted_transaction',
        description:
            'Ensures that any variable of type Transaction is eventually committed or rolled back.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final UncommittedTransaction rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // Check if the variable is likely a Transaction
    bool isTransaction = false;

    // Check by explicit type
    final parent = node.parent;
    if (parent is VariableDeclarationList) {
      final type = parent.type;
      if (type != null && type.toString().contains('Transaction')) {
        isTransaction = true;
      }
    }

    // Check by static type of initializer
    final initializer = node.initializer;
    if (!isTransaction && initializer != null) {
      final staticType = initializer.staticType;
      if (staticType != null && staticType.toString().contains('Transaction')) {
        isTransaction = true;
      }
    }

    // Check by initializer call name (heuristic)
    if (!isTransaction && initializer != null) {
      if (_isTransactionCall(initializer)) {
        isTransaction = true;
      }
    }

    if (!isTransaction) return;

    // Found a transaction variable. Now check for commit/rollback calls in the same function.
    final functionBody = node.thisOrAncestorOfType<FunctionBody>();
    if (functionBody == null) return;

    final checker = _TransactionUsageChecker(node.name.lexeme);
    functionBody.accept(checker);

    if (!checker.hasCommitOrRollback) {
      rule.reportAtToken(node.name);
    }
  }

  bool _isTransactionCall(Expression expression) {
    Expression inner = expression;
    if (inner is AwaitExpression) {
      inner = inner.expression;
    }

    if (inner is MethodInvocation) {
      // It's ONLY an unmanaged transaction call if it has NO arguments.
      // Managed transactions pass a callback argument.
      return inner.methodName.name == 'transaction' &&
          inner.argumentList.arguments.isEmpty;
    }
    return false;
  }
}

class _TransactionUsageChecker extends RecursiveAstVisitor<void> {
  final String variableName;
  bool hasCommitOrRollback = false;

  _TransactionUsageChecker(this.variableName);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (hasCommitOrRollback) return;

    final target = node.target;
    if (target is SimpleIdentifier && target.name == variableName) {
      final methodName = node.methodName.name;
      if (methodName == 'commit' || methodName == 'rollback') {
        hasCommitOrRollback = true;
      }
    }
    super.visitMethodInvocation(node);
  }
}
