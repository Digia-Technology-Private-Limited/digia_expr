import '../ast_evaluator.dart';
import '../types.dart';
import 'date_time_operations.dart';
import 'json_operations.dart';
import 'math_operations.dart';
import 'string_operations.dart';
import 'util.dart';

abstract class StdLibFunctions {
  static Map<String, ExprCallable> functions = {
    ...MathOperations.functions,
    ...StringOperations.functions,
    ...JsonOperations.functions,
    ...DateTimeOperations.functions,
    'condition': _ConditionalOp(),
    'isEqual': _IsEqualOp(),
    'isNotEqual': _IsNotEqualOp(),
  };
}

class _ConditionalOp implements ExprCallable {
  @override
  int arity() {
    return 3;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object?> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final result = toValue<bool>(evaluator, arguments[0]!);

    if (result == true) {
      return arguments[1] == null
          ? null
          : toValue<Object>(evaluator, arguments[1]!);
    }

    return arguments[2] == null
        ? null
        : toValue<Object>(evaluator, arguments[2]!);
  }

  @override
  String get name => 'conditional';
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
