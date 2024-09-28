import 'package:digia_expr/digia_expr.dart';
import 'package:digia_expr/src/ast_evaluator.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Expressions: ', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Math functions: sum & mul.', () {
      final code = 'sum(mul(x,4),y)';

      final context = BasicExprContext(variables: {'x': 10, 'y': 2});

      final result = Expression.eval(code, context);
      expect(result, 42);
    });

    test('String concatenation: abc + xyz = abcxyz', () {
      final code = "concat('abc', 'xyz')";

      final result = Expression.eval(code, null);
      expect(result, 'abcxyz');
    });

    group('Test String Interpolation', () {
      test('Single String Interpolation', () {
        final code = r'Hello ${aVar}!';

        final result = Expression.eval(
            code, BasicExprContext(variables: {'aVar': 'World'}));
        expect(result, 'Hello World!');
      });

      test('Multiple String Interpolation Case 1', () {
        final code = r'Hello ${a} & ${b}!';

        final result = Expression.eval(
            code, BasicExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Hello Alpha & Beta!');
      });

      test('Multiple String Interpolation Case 2', () {
        final code = r'${a}';

        final result = Expression.eval(
            code, BasicExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Alpha');
      });

      test('Multiple String Interpolation Case 3', () {
        final code = r'${a}, ${b}';

        final result = Expression.eval(
            code, BasicExprContext(variables: {'a': 'Alpha', 'b': 'Beta'}));
        expect(result, 'Alpha, Beta');
      });
    });
    test('Access field from an Object', () {
      final code = 'Hello \${person.name}!';

      final result = Expression.eval(
          code,
          BasicExprContext(variables: {
            'person': ExprClassInstance(
                klass: ExprClass(
                    name: 'Person', fields: {'name': 'Tushar'}, methods: {}))
          }));
      expect(result, 'Hello Tushar!');
    });

    test('Execute method of an Object', () {
      const testValue = 10;
      final data = {'count': testValue};

      final code = r"${storage.get('count')}";

      final result = Expression.eval(
          code,
          BasicExprContext(variables: {
            'storage': ExprClassInstance(
                klass: ExprClass(name: 'LocalStorage', fields: {}, methods: {
              'get': _TestMethod(
                  f: (e, args) => data[e.eval(args.first as ASTNode)])
            }))
          }));
      expect(result, testValue);
    });

    test('Access field from a nested Object', () {
      const testValue = 10;
      final code = r'${sum(a.b.c.d(), a.e)}';

      final result = Expression.eval(
          code,
          BasicExprContext(variables: {
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

    test('Access JsonObject using Dot Notation', () {
      final code = r'${sum(jsonObject.a.b, jsonObject.a.c)}';

      final result = Expression.eval(
          code,
          BasicExprContext(variables: {
            'jsonObject': {
              'a': {'b': 10, 'c': 2},
            }
          }));
      expect(result, 12);
    });

    test('Test jsonGet', () {
      final testValue = 'https://i.imgur.com/tFUQrOe.png';
      final code = r"${jsonGet(dataSource, 'data.liveLearning.img')}";

      final result = Expression.eval(
          code,
          BasicExprContext(variables: {
            'dataSource': {
              'data': {
                'liveLearning': {'img': testValue}
              },
            }
          }));
      expect(result, testValue);
    });

    test('Test isEqual', () {
      final testValue = true;
      final code = r'${eq(10, 10)}';

      final result = Expression.eval(code, null);
      expect(result, testValue);
    });

    test('Test isNotEqual', () {
      final testValue = true;
      final code = r'${neq(10, 15)}';

      final result = Expression.eval(code, null);
      expect(result, testValue);
    });

    test('Test isoFormat', () {
      final testValue = '2024-06-03T23:42:36Z';
      final output = '3rd June';

      final result = Expression.eval(r"${isoFormat(isoDate, 'Do MMMM')}",
          BasicExprContext(variables: {'isoDate': testValue}));
      expect(result, output);
    });

    test('Test isoFormat leap year', () {
      final testValue = '2024-02-29T00:00:00Z';
      final output = '29th February';

      final result = Expression.eval(r"${isoFormat(isoDate, 'Do MMMM')}",
          BasicExprContext(variables: {'isoDate': testValue}));
      expect(result, output);
    });

    group('Test NumberFormat', () {
      test('Test numberFormat', () {
        expect(Expression.eval(r'${numberFormat(456786)}', null), '4,56,786');
      });

      test('Test custom numberFormat', () {
        expect(
            Expression.eval(r"${numberFormat(123456789, '#,###,000')}", null),
            '123,456,789');
      });

      test('Test custom numberFormat', () {
        expect(Expression.eval(r"${numberFormat(30000, '##,##,###')}", null),
            '30,000');
      });
    });

    group('Test toInt Function', () {
      test('Integer to Int', () {
        expect(Expression.eval(r'${toInt(100)}', null), 100);
      });

      test('Float to Int', () {
        expect(Expression.eval(r'${toInt(100.1)}', null), 100);
      });

      test('String to Int', () {
        expect(Expression.eval(r"${toInt('100.1')}", null), 100);
      });

      test('Hex to Int', () {
        expect(Expression.eval(r"${toInt('0x64')}", null), 100);
      });
    });

    test('Hex to Int', () {
      final code =
          r"${condition(isEqual(a, b), 'Note: NPCI may flag repeat transactions of the same amount as duplicates and might reject them. As a precaution, we will deduct ₹${numberFormat(b)} from your account.', 'Note: You will receive confirmation emails on each steps')}";
      expect(
          Expression.eval(
              code, BasicExprContext(variables: {'a': 1001, 'b': 1001})),
          'Note: NPCI may flag repeat transactions of the same amount as duplicates and might reject them. As a precaution, we will deduct ₹1,001 from your account.');
    });

    test('String Length', () {
      final code = r'${isEqual(strLength(x), length)}';
      expect(
          Expression.eval(code,
              BasicExprContext(variables: {'x': 'hello-world', 'length': 11})),
          true);
    });

    test('QS Encode', () {
      const payload = {
        'key1': 11,
        'key2': 'str',
        'key3': false,
        'key4': 0,
        'key5': {'cKey1': true},
        'key6': [0, 1],
        'key7': [
          {'cKey1': 233},
          {'cKey2': false}
        ]
      };
      expect(
          Expression.eval(r'${qsEncode(payload)}',
              BasicExprContext(variables: {'payload': payload})),
          'key1=11&key2=str&key3=false&key4=0&key5[cKey1]=true&key6=0&key6=1&key7[cKey1]=233&key7[cKey2]=false');
    });

    group('If conditions', () {
      test('Normal if, Without else case, truthy condition', () {
        expect(Expression.eval(r'${if(true, false)}', null), false);
      });

      test('Normal if, Without else case, falsy condition', () {
        expect(Expression.eval(r'${if(false, false)}', null), null);
      });

      test('Normal if, With else case, truthy condition', () {
        expect(Expression.eval(r'${if(true, false, true)}', null), false);
      });

      test('Normal if, With else case, falsy condition', () {
        expect(Expression.eval(r'${if(false, false, true)}', null), true);
      });

      test('Multi if, Without else case, 1st condition - truthy evaluation',
          () {
        expect(Expression.eval(r"${if(true, 'a', true, 'b')}", null), 'a');
      });

      test('Multi if, Without else case, 1st condition - false evaluation', () {
        expect(Expression.eval(r"${if(false, 'a', true, 'b')}", null), 'b');
      });

      test('Multi if, Without else case, all false evaluation', () {
        expect(Expression.eval(r"${if(false, 'a', false, 'b')}", null), null);
      });

      test('Multi if, With else case, all false evaluation', () {
        expect(
            Expression.eval(r"${if(false, 'a', false, 'b', 'c')}", null), 'c');
      });
    });

    group('Logical Ops', () {
      test('greater than - false', () {
        expect(Expression.eval(r'${gt(1, 2)}', null), false);
      });
      test('greater than - true', () {
        expect(Expression.eval(r'${gt(2.1, 1.2)}', null), true);
      });

      test('greater than or equal - false', () {
        expect(Expression.eval(r'${gte(1.2, 2.1)}', null), false);
      });
      test('greater than or equal - true', () {
        expect(Expression.eval(r'${gte(2.1, 2.1)}', null), true);
      });

      test('less than - false', () {
        expect(Expression.eval(r'${lt(1, 2)}', null), true);
      });
      test('less than - true', () {
        expect(Expression.eval(r'${lt(2.1, 1.2)}', null), false);
      });

      test('less than or equal - false', () {
        expect(Expression.eval(r'${lte(1.2, 2.1)}', null), true);
      });
      test('less than or equal - true', () {
        expect(Expression.eval(r'${lte(2.1, 2.1)}', null), true);
      });

      test('not - true to false', () {
        expect(Expression.eval(r'${not(true)}', null), false);
      });

      test('not - false to true', () {
        expect(Expression.eval(r'${not(false)}', null), true);
      });

      test('Logical OR - false || true', () {
        expect(Expression.eval(r'${or(false, true)}', null), true);
      });

      test('Logical OR - false || false', () {
        expect(Expression.eval(r'${or(false, false)}', null), false);
      });

      test('fallback value - PASS: null ?? a', () {
        expect(Expression.eval(r"${or(if(false, false), 'a')}", null), 'a');
      });

      test('fallback value - PASS: a ?? a', () {
        expect(Expression.eval(r"${or('b', 'a')}", null), 'b');
      });

      test('Logical AND - false && true', () {
        expect(Expression.eval(r'${and(false, true)}', null), false);
      });

      test('Logical AND - true && true', () {
        expect(Expression.eval(r'${and(true, true)}', null), true);
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
