import 'package:digia_expr/digia_expr.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Expressions: ', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('1. Math functions: sum & mul.', () {
      final code = "sum(mul(x,4),y)";

      final context = ExprContext(variables: {'x': 10, 'y': 2});

      final result = Expression.eval(code, context);
      expect(result, 42);
    });

    test('2. String concatenation: abc + xyz = abcxyz', () {
      final code = "concat('abc', 'xyz')";

      final result = Expression.eval(code, null);
      expect(result, 'abcxyz');
    });

    test('3. Variable Substitution & String Interpolation', () {
      final code = "Hello \${aVar}!";

      final result =
          Expression.eval(code, ExprContext(variables: {'aVar': 'World'}));
      expect(result, 'Hello World!');
    });
  });
}
