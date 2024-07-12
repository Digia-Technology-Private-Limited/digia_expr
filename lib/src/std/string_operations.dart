import '../../digia_expr.dart';
import '../ast_evaluator.dart';
import 'util.dart';

abstract class StringOperations {
  static Map<String, ExprCallable> functions = {
    'concat': ConcatOp(),
    'concatenate': ConcatOp(),
    'substring': _SubStringOp(),
  };
}

class _SubStringOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return ArgumentError('Can not resolve for less than 2 arguments');
    }

    final string = toValue<String>(evaluator, arguments[0]);

    final start = toValue<int>(evaluator, arguments[1]);
    final end = toValue<int>(evaluator, arguments.elementAtOrNull(2));

    if (start == null) return string;

    return string?.substring(start, end);
  }

  @override
  String get name => 'substring';
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
