import 'package:digia_expr/digia_expr.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('(10 * 4) + 2', () {
      final code = "sum(mul(x,4),y)";

      final context = ExprContext(variables: {'x': 10, 'y': 2});

      final result = Expression.eval(code, context);
      expect(result, 42);
    });

    test('abc + xyz', () {
      final code = "concat('abc', 'xyz')";

      final result = Expression.eval(code, null);
      expect(result, 'abcxyz');
    });
  });
}
