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

    group('3. Test String Interpolation', () {
      test('1. Single String Interpolation', () {
        final code = r'Hello ${aVar}!';

        final result =
            Expression.eval(code, ExprContext(variables: {'aVar': 'World'}));
        expect(result, 'Hello World!');
      });

      test('2. Multiple String Interpolation Case 1', () {
        final code = r'Hello ${a} & ${b}!';

        final result = Expression.eval(
            code, ExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Hello Alpha & Beta!');
      });

      test('3. Multiple String Interpolation Case 2', () {
        final code = r'${a}';

        final result = Expression.eval(
            code, ExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Alpha');
      });

      test('4. Multiple String Interpolation Case 3', () {
        final code = r'${a}, ${b}';

        final result = Expression.eval(
            code, ExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Alpha, Beta');
      });
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

    test('6. Access JsonObject using Dot Notation', () {
      final code = r'${sum(jsonObject.a.b, jsonObject.a.c)}';

      final result = Expression.eval(
          code,
          ExprContext(variables: {
            'jsonObject': {
              'a': {'b': 10, 'c': 2},
            }
          }));
      expect(result, 12);
    });

    test('6. Test jsonGet', () {
      final testValue = 'https://i.imgur.com/tFUQrOe.png';
      final code = r"${jsonGet(dataSource, 'data.liveLearning.img')}";

      final result = Expression.eval(
          code,
          ExprContext(variables: {
            'dataSource': {
              'data': {
                'liveLearning': {'img': testValue}
              },
            }
          }));
      expect(result, testValue);
    });

    test('7. Test isEqual', () {
      final testValue = true;
      final code = r"${isEqual(10, 10)}";

      final result = Expression.eval(code, null);
      expect(result, testValue);
    });

    test('8. Test isNotEqual', () {
      final testValue = true;
      final code = r"${isNotEqual(10, 15)}";

      final result = Expression.eval(code, null);
      expect(result, testValue);
    });

    test('8. Test isoFormat', () {
      final testValue = '2024-01-29T00:00:00Z';
      final output = '29th January';

      final result = Expression.eval(r"${isoFormat(isoDate, 'Do MMMM')}",
          ExprContext(variables: {'isoDate': testValue}));
      expect(result, output);
    });

    test('9. Test isoFormat leap year', () {
      final testValue = '2024-02-29T00:00:00Z';
      final output = '31st Jan';

      final result = Expression.eval(r"${isoFormat(isoDate, 'Do MMM')}",
          ExprContext(variables: {'isoDate': testValue}));
      expect(result, output);
    });

    group('Test NumberFormat', () {
      test('1. Test numberFormat', () {
        expect(Expression.eval(r'${numberFormat(456786)}', null), '4,56,786');
      });

      test('2. Test custom numberFormat', () {
        expect(
            Expression.eval(r"${numberFormat(123456789, '#,###,000')}", null),
            '123,456,789');
      });
    });

    group('Test toInt Function', () {
      test('1. Integer to Int', () {
        expect(Expression.eval(r'${toInt(100)}', null), 100);
      });

      test('2. Float to Int', () {
        expect(Expression.eval(r'${toInt(100.1)}', null), 100);
      });

      test('3. String to Int', () {
        expect(Expression.eval(r"${toInt('100.1')}", null), 100);
      });

      test('4. Hex to Int', () {
        expect(Expression.eval(r"${toInt('0x64')}", null), 100);
      });
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
