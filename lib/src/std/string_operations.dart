import 'package:digia_expr/digia_expr.dart';
import 'package:digia_expr/src/ast_evaluator.dart';

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
      final o =
          arg is ASTNode ? evaluator.eval(arg)?.toString() : arg.toString();
      sb.write(o.toString());
    }
    return sb.toString();
  }

  @override
  String get name => 'concatenate';
}
