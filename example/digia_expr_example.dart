import 'package:digia_expr/digia_expr.dart';

void main() {
  final code = "'Hello World \${sum(mul(x,4),y)}!'";
  // final code = "multiply(4,2)";

  final context = ExprContext(variables: {
    'x': ASTNumberLiteral(
      getter: () => 10,
    ),
    'y': ASTNumberLiteral(value: 2)
  });

  final result1 = Expression.eval(code, context);
  print('---------ASTEvaluator----------');
  print(result1);
}
