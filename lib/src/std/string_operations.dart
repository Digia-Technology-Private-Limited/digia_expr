import 'package:digia_expr/src/ast_evaluator.dart';
import 'package:digia_expr/src/std/util.dart';

import 'types.dart';

abstract class StringOperations {
  static Map<String, ExprCallable> functions = {
    'concat': ConcatOp(),
    'concatenate': ConcatOp(),
  };
}

class ConcatOp implements ExprCallable {
  @override
  int arity() {
    return 255;
  }

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    final StringBuffer sb = StringBuffer();
    for (final arg in arguments) {
      final o = toValue<String>(evaluator, arg);
      sb.write(o.toString());
    }
    return sb.toString();
  }

  @override
  String get name => 'concatenate';
}
