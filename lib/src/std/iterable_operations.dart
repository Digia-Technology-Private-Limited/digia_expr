import '../ast_evaluator.dart';
import '../types.dart';
import 'util.dart';

abstract class IterableOperations {
  static Map<String, ExprCallable> functions = {
    'contains': _ContainsOp(),
    'elementAt': _ElementAtOp(),
    'firstElement': _FirstElementOp(),
    'lastElement': _LastElementOp(),
    'skip': _SkipOp(),
    'take': _TakeOp(),
    'reversed': _ReversedOp()
  };
}

class _ContainsOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);
    final arg2 = toValue<Object>(evaluator, arguments[1]);

    final contains = arg1?.contains(arg2) ?? false;

    return contains;
  }

  @override
  String get name => 'contains';
}

class _ElementAtOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);
    final arg2 = toValue<int>(evaluator, arguments[1]);

    if (arg2 == null) return null;

    return arg1?.elementAtOrNull(arg2);
  }

  @override
  String get name => 'elementAt';
}

class _FirstElementOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);

    return arg1?.firstOrNull;
  }

  @override
  String get name => 'firstElement';
}

class _LastElementOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);

    return arg1?.lastOrNull;
  }

  @override
  String get name => 'lastElement';
}

class _SkipOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);
    final arg2 = toValue<int>(evaluator, arguments[1]);

    return arg1?.skip(arg2 ?? 0).toList();
  }

  @override
  String get name => 'skip';
}

class _TakeOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);
    final arg2 = toValue<int>(evaluator, arguments[1]);

    return arg1?.take(arg2 ?? 0).toList();
  }

  @override
  String get name => 'take';
}

class _ReversedOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<List>(evaluator, arguments[0]);

    return arg1?.reversed.toList();
  }

  @override
  String get name => 'lastElement';
}
