import 'package:intl/intl.dart';
import 'package:qs_dart/qs_dart.dart';

import '../ast_evaluator.dart';
import '../types.dart';
import 'date_time_operations.dart';
import 'iterable_operations.dart';
import 'json_operations.dart';
import 'logical_operations.dart';
import 'math_operations.dart';
import 'string_operations.dart';
import 'util.dart';

abstract class StdLibFunctions {
  static Map<String, ExprCallable> functions = {
    ...LogicalOperations.functions,
    ...MathOperations.functions,
    ...StringOperations.functions,
    ...JsonOperations.functions,
    ...DateTimeOperations.functions,
    ...IterableOperations.functions,
    'numberFormat': _NumberFormatOp(),
    'toInt': _ToIntOp(),
    'qsEncode': _QsEncodeOp(),
    'isEmpty': _IsEmptyOp(),
    'length': _LengthOp(),
    // For Backward Compatibility
    'strLength': _LengthOp(),
  };
}

class _IsEmptyOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      throw 'Incorrect argument size';
    }

    final arg = toValue(evaluator, arguments.first);

    if (arg is num) return arg == 0;

    if (arg is bool) return arg;

    if (arg is String) return arg.isEmpty;

    if (arg is List) return arg.isEmpty;

    if (arg is Map) return arg.isEmpty;

    return arg == null;
  }

  @override
  String get name => 'isEmpty';
}

class _LengthOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      throw 'Incorrect argument size';
    }

    final arg = toValue(evaluator, arguments.first);
    if (arg == null) return null;

    if (arg is String) return arg.length;

    if (arg is List) return arg.length;

    if (arg is Map) return arg.length;

    return null;
  }

  @override
  String get name => 'length';
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
    final format =
        arg1 != null ? toValue<String>(evaluator, arg1) : '##,##,###';

    return NumberFormat(format).format(number);
  }

  @override
  String get name => 'numberFormat';
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

class _QsEncodeOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arity() != arguments.length) {
      return 'Incorrect argument size';
    }

    final value = toValue<Object>(evaluator, arguments[0]);

    final output = QS.encode(
        value, EncodeOptions(encode: false, listFormat: ListFormat.repeat));

    return output;
  }

  @override
  String get name => 'qsEncode';
}
