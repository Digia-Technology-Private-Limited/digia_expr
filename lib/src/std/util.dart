import 'package:digia_expr/digia_expr.dart';
import 'package:digia_expr/src/ast_evaluator.dart';

T? toValue<T>(ASTEvaluator evaluator, Object obj) {
  if (obj is ASTNode) {
    return evaluator.eval(obj) as T?;
  }

  return obj as T?;
}
