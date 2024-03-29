import 'package:digia_expr/digia_expr.dart';

void main() {
  // final code = "'Hello World \${sum(mul(x,4),y)}!'";
  final code = "\${condition(true, sum(x,y), diff(x,y))}";

  final context = ExprContext(variables: {'x': 10, 'y': 2});

  final result = Expression.eval(code, context);
  print('---------ASTEvaluator----------');
  print(result);
}
