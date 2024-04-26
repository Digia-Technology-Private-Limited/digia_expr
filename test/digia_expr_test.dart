import 'package:digia_expr/digia_expr.dart';
import 'package:digia_expr/src/ast_evaluator.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Expressions: ', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('1. Math functions: sum & mul.', () {
      final code = 'sum(mul(x,4),y)';

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
      final code = 'Hello \${aVar}!';

      final result =
          Expression.eval(code, ExprContext(variables: {'aVar': 'World'}));
      expect(result, 'Hello World!');
    });

    test('4. Access field from an Object', () {
      final code = 'Hello \${person.name}!';

      final result = Expression.eval(
          code,
          ExprContext(variables: {
            'person': ExprClassInstance(
                klass: ExprClass(
                    name: 'Person', fields: {'name': 'Tushar'}, methods: {}))
          }));
      expect(result, 'Hello Tushar!');
    });

    test('5. Execute method of an Object', () {
      const testValue = 10;
      final data = {'count': testValue};

      final code = r"${storage.get('count')}";

      final result = Expression.eval(
          code,
          ExprContext(variables: {
            'storage': ExprClassInstance(
                klass: ExprClass(name: 'LocalStorage', fields: {}, methods: {
              'get': _TestMethod(
                  f: (e, args) => data[e.eval(args.first as ASTNode)])
            }))
          }));
      expect(result, testValue);
    });

    test('6. Access field from a nested Object', () {
      const testValue = 10;
      final code = r'${sum(a.b.c.d(), a.e)}';

      final result = Expression.eval(
          code,
          ExprContext(variables: {
            'a': ExprClassInstance(
                klass: ExprClass(name: 'Test', fields: {
              'b': ExprClassInstance(
                  klass: ExprClass(name: 'Test', fields: {
                'c': ExprClassInstance(
                    klass: ExprClass(
                        name: 'Test',
                        fields: {},
                        methods: {'d': _TestMethod(f: (_, __) => testValue)}))
              }, methods: {})),
              'e': testValue
            }, methods: {}))
          }));
      expect(result, testValue + testValue);
    });
  });
}

class _TestMethod extends ExprCallable {
  final int _arity;
  Object? Function(ASTEvaluator evaluator, List<Object> arguments) f;

  _TestMethod({required this.f, int arity = 0}) : _arity = arity;

  @override
  int arity() => _arity;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    return f(evaluator, arguments);
  }

  @override
  String get name => 'TestMethod';
}
