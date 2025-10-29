import 'package:digia_expr/digia_expr.dart';

void main() {
  print('=== Digia Expression Library - Extensible Visitor Pattern ===\n');

  print('=== Example 1: Expression Evaluation ===');
  final code = "user.name";
  final context = BasicExprContext(variables: {
    'user': {'name': 'John Doe', 'age': 30}
  });

  try {
    final result = Expression.eval(code, context);
    print('Expression: $code');
    print('Result: $result\n');
  } catch (e) {
    print('Error: $e\n');
  }
}
