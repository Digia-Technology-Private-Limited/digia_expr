import '../../digia_expr.dart';
import '../ast_evaluator.dart';
import 'util.dart';

abstract class StringOperations {
  static Map<String, ExprCallable> functions = {
    'concat': ConcatOp(),
    'concatenate': ConcatOp(),
    'strLength': LengthOp(),
  };
}

class LengthOp implements ExprCallable {
  @override
  int arity() => 1;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length != arity()) {
      throw 'Incorrect argument size';
    }

    return toValue<String>(evaluator, arguments.first)?.length;
  }

  @override
  String get name => 'length';
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
  String get name => 'strLength';
}
