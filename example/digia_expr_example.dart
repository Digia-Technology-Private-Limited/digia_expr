import 'package:digia_expr/digia_expr.dart';

void main() {
  // final code = "'Hello World \${sum(mul(x,4),y)}!'";
  final code = "condition(condition(true, false, true), 'Hey', 'Hello')";

  final context = BasicExprContext(variables: {'x': 10, 'y': 2});

  final result = Expression.eval(code, context);
  print('---------ASTEvaluator----------');
  print(result);
}
