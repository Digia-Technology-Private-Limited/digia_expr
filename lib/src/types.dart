import 'ast_evaluator.dart';
import 'token.dart';

abstract class ExprCallable {
  String get name;
  int arity();
  Object? call(ASTEvaluator evaluator, List<Object> arguments);
}

class ExprCallableImpl extends ExprCallable {
  final int _arity;
  Object? Function(ASTEvaluator evaluator, List<Object> arguments) fn;

  ExprCallableImpl({required this.fn, int arity = 0}) : _arity = arity;

  @override
  int arity() => _arity;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    return fn(evaluator, arguments);
  }

  @override
  String get name => 'ExprCallableImpl';
}

typedef Getter<T> = T Function();

class ExprClass extends ExprCallable {
  final String _name;
  final Map<String, Object?> fields;
  final Map<String, ExprCallable> methods;

  ExprClass({
    required String name,
    required this.fields,
    required this.methods,
  }) : _name = name;

  @override
  int arity() => 0;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    return ExprClassInstance(klass: this);
  }

  @override
  String get name => _name;
}

abstract class ExprInstance {
  Object? getField(String name);
}

class ExprClassInstance implements ExprInstance {
  ExprClass klass;

  ExprClassInstance({
    required this.klass,
  });

  set(Token name, Object value) {
    klass.fields[name.lexeme] = value;
  }

  @override
  Object? getField(String name) {
    if (klass.fields.containsKey(name)) {
      return klass.fields[name];
    }

    if (klass.methods.containsKey(name)) {
      return klass.methods[name];
    }

    throw 'Undefined property ${name}, name';
  }
}
