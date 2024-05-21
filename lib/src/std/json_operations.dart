import 'package:json_path/json_path.dart';

import '../../digia_expr.dart';
import '../ast_evaluator.dart';
import 'util.dart';

abstract class JsonOperations {
  static Map<String, ExprCallable> functions = {
    'jsonGet': JsonGetOp(),
    'get': JsonGetOp(),
  };
}

class JsonGetOp implements ExprCallable {
  @override
  int arity() {
    return 2;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final json = toValue(evaluator, arguments[0]);
    final path = toValue<String>(evaluator, arguments[1]);

    final jsonPath = JsonPath('\$.$path');
    final result = jsonPath.readValues(json);
    return result.firstOrNull;
  }

  @override
  String get name => 'jsonGet';
}
