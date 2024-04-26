import '../ast_evaluator.dart';
import '../types.dart';
import 'json_operations.dart';
import 'math_operations.dart';
import 'string_operations.dart';
import 'util.dart';

abstract class StdLibFunctions {
  static Map<String, ExprCallable> functions = {
    ...MathOperations.functions,
    ...StringOperations.functions,
    ...JsonOperations.functions,
    'condition': _ConditionalOp()
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
