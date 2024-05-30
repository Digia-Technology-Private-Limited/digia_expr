import 'package:intl/intl.dart';

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
    'isNull': _IsNullOp(),
    'isNotNull': _IsNotNullOp(),
    'numberFormat': _NumberFormatOp(),
    'toInt': _ToIntOp()
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

class _NumberFormatOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length > arity()) {
      return 'Incorrect argument size';
    }

    final number = toValue<num>(evaluator, arguments[0]);
    final arg1 = arguments.length > 1 ? arguments[1] : null;
    final format = arg1 != null ? toValue<String>(evaluator, arg1) : '#,##,000';

    return NumberFormat(format).format(number);
  }

  @override
  String get name => 'numberFormat';
}

class _IsNullOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length > arity()) {
      return 'Incorrect argument size';
    }

    return arguments.firstOrNull == null;
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

    return arguments.firstOrNull != null;
  }

  @override
  String get name => 'isNotNull';
}

class _ToIntOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arity() != arguments.length) {
      return 'Incorrect argument size';
    }

    final value = toValue(evaluator, arguments[0]);

    if (value is String) {
      if (value.startsWith('0x') == true) {
        return int.tryParse(value.substring(2), radix: 16)?.toInt();
      }

      return double.tryParse(value)?.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  @override
  String get name => 'toInt';
}
