import '../ast_evaluator.dart';
import '../types.dart';
import 'util.dart';

abstract class LogicalOperations {
  static Map<String, ExprCallable> functions = {
    'isEqual': _IsEqualOp(),
    'isNotEqual': _IsNotEqualOp(),
    'isNull': _IsNullOp(),
    'isNotNull': _IsNotNullOp(),
    'condition': _IfOp(),
    'if': _IfOp(),
    'eq': _IsEqualOp(),
    'neq': _IsNotEqualOp(),
    'gt': _GreatThanOp(),
    'gte': _GreatThanOrEqualOp(),
    'lt': _LessThanOp(),
    'lte': _LessThanOrEqualOp(),
    'not': _NotOp(),
    'or': _OrOp(),
    'and': _AndOp(),
  };
}

class _IfOp implements ExprCallable {
  @override
  int arity() => 255;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < 2) {
      return ArgumentError('Can not resolve for less than 2 arguments');
    }

    final defaultCase = arguments.length % 2 == 1 ? arguments.last : null;
    final lengthToIterateOver = arguments.length - (arguments.length % 2);

    for (var i = 0; i < lengthToIterateOver; i += 2) {
      final condition = toValue<bool>(evaluator, arguments[i]);
      if (condition == true) {
        return toValue<Object>(evaluator, arguments[i + 1]);
      }
    }

    if (defaultCase == null) return null;
    return toValue<Object>(evaluator, defaultCase);
  }

  @override
  String get name => 'if';
}

class _IsEqualOp implements ExprCallable {
  @override
  int arity() {
    return 2;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final arg1 = toValue<Object>(evaluator, arguments[0]);
    final arg2 = toValue<Object>(evaluator, arguments[1]);

    return arg1 == arg2;
  }

  @override
  String get name => 'isEqual';
}

class _IsNotEqualOp implements ExprCallable {
  @override
  int arity() {
    return 2;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final arg1 = toValue<Object>(evaluator, arguments[0]);
    final arg2 = toValue<Object>(evaluator, arguments[1]);

    return arg1 != arg2;
  }

  @override
  String get name => 'isNotEqual';
}

class _IsNullOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length > arity()) {
      return 'Incorrect argument size';
    }

    return arguments.firstOrNull == null ||
        toValue(evaluator, arguments.firstOrNull!) == null;
  }

  @override
  String get name => 'isNull';
}

class _IsNotNullOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length > arity()) {
      return 'Incorrect argument size';
    }

    return arguments.firstOrNull != null &&
        toValue(evaluator, arguments.firstOrNull!) != null;
  }

  @override
  String get name => 'isNotNull';
}

class _GreatThanOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<num>(evaluator, arguments[0]);
    final arg2 = toValue<num>(evaluator, arguments[1]);

    if (arg1 == null || arg2 == null) return false;

    return arg1 > arg2;
  }

  @override
  String get name => 'gt';
}

class _GreatThanOrEqualOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<num>(evaluator, arguments[0]);
    final arg2 = toValue<num>(evaluator, arguments[1]);

    if (arg1 == null || arg2 == null) return false;

    return arg1 >= arg2;
  }

  @override
  String get name => 'gte';
}

class _LessThanOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<num>(evaluator, arguments[0]);
    final arg2 = toValue<num>(evaluator, arguments[1]);

    if (arg1 == null || arg2 == null) return false;

    return arg1 < arg2;
  }

  @override
  String get name => 'lt';
}

class _LessThanOrEqualOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<num>(evaluator, arguments[0]);
    final arg2 = toValue<num>(evaluator, arguments[1]);

    if (arg1 == null || arg2 == null) return false;

    return arg1 <= arg2;
  }

  @override
  String get name => 'lte';
}

class _NotOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<Object>(evaluator, arguments[0]);

    if (arg1 == null) return null;

    if (arg1 is bool) return !arg1;

    return null;
  }

  @override
  String get name => 'not';
}

class _OrOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<Object>(evaluator, arguments[0]);
    final arg2 = toValue<Object>(evaluator, arguments[1]);

    if (arg1 is bool && arg2 is bool) {
      return arg1 || arg2;
    }

    if (arg1 == null) return arg2;

    return arg1;
  }

  @override
  String get name => 'or';
}

class _AndOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      return ArgumentError.value(arguments);
    }

    final arg1 = toValue<Object>(evaluator, arguments[0]);
    final arg2 = toValue<Object>(evaluator, arguments[1]);

    if (arg1 is bool && arg2 is bool) {
      return arg1 && arg2;
    }

    return null;
  }

  @override
  String get name => 'or';
}
