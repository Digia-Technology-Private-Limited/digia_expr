import '../../digia_expr.dart';
import '../ast_evaluator.dart';

T? toValue<T>(ASTEvaluator evaluator, Object obj) {
  if (obj is ASTNode) {
    final result = evaluator.eval(obj);
    return result as T?;
  }

  return obj as T?;
}
