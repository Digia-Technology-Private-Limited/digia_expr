import 'ast_evaluator.dart';
import 'constants.dart';
import 'create_ast.dart';
import 'expr_context.dart';

class Expression {
  static Object? eval(String source, ExprContext? context) {
    final trimmed = source.trim();

    if (isExpression(trimmed)) {
      final root = createAST(trimmed.substring(2, trimmed.length - 1));

      return ASTEvaluator(context: context).eval(root);
    }

    // Case of String interpolation
    if (hasExpression(trimmed)) {
      final root = createAST(_wrapWithQuotes(trimmed));
      final result = ASTEvaluator(context: context).eval(root) as String?;
      return result;
    }

    final root = createAST(trimmed);
    return ASTEvaluator(context: context).eval(root);
  }

  static bool hasExpression(String s) {
    return RegExp(expressionSyntaxRegex).hasMatch(s.trim());
  }

  static bool isExpression(String s) {
    final string = s.trim();
    return string.startsWith(r'${') &&
        string.endsWith('}') &&
        RegExp(expressionSyntaxRegex).allMatches(s).length == 1;
  }
}

String _wrapWithQuotes(String string) {
  if (string.startsWith('\'') && string.endsWith('\'')) {
    return string;
  }
  return '"$string"';
}
