import '../ast_evaluator.dart';
import '../types.dart';
import 'util.dart';

abstract class MathOperations {
  static Map<String, ExprCallable> functions = {
    'sum': _SumOp(),
    'mul': _MulOp(),
    'multiply': _MulOp(),
    'diff': _DiffOp(),
    'difference': _DiffOp(),
    'divide': _DivideOp()
  };
}

class _SumOp implements ExprCallable {
  @override
  int arity() {
    return 255;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    final num numValue =
        arguments.map((e) => toValue<num>(evaluator, e)).fold(0, (acc, e) {
      acc = acc + (e ?? 0);
      return acc;
    });

    return numValue;
  }

  @override
  String get name => 'sum';
}

class _MulOp implements ExprCallable {
  @override
  int arity() {
    return 255;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    final num numValue =
        arguments.map((e) => toValue<num>(evaluator, e)).fold(1, (acc, e) {
      acc = acc * (e ?? 1);
      return acc;
    });

    return numValue;
  }

  @override
  String get name => 'multiply';
}

class _DiffOp implements ExprCallable {
  @override
  int arity() {
    return 2;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final operand1 = toValue<num>(evaluator, arguments[0]);
    final operand2 = toValue<num>(evaluator, arguments[1]);

    if (operand1 == null || operand2 == null) {
      return 'Incorrect call to diff. Operands are null: $operand1, $operand2';
    }

    return operand1 - operand2;
  }

  @override
  String get name => 'diff';
}

class _DivideOp implements ExprCallable {
  @override
  int arity() {
    return 2;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final operand1 = toValue<num>(evaluator, arguments[0]);
    final operand2 = toValue<num>(evaluator, arguments[1]);

    if (operand1 == null || operand2 == null) {
      return 'Incorrect call to divide. Operands are null: $operand1, $operand2';
    }

    return operand1 / operand2;
  }

  @override
  String get name => 'divide';
}
