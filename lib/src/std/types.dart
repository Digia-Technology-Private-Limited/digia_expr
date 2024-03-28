import 'package:digia_expr/src/ast_evaluator.dart';

abstract class ExprCallable {
  String get name;
  int arity();
  Object? call(ASTEvaluator evaluator, List<Object> arguments);
}

typedef Getter<T> = T Function();
