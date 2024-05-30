import 'package:moment_dart/moment_dart.dart';

import '../../digia_expr.dart';
import '../ast_evaluator.dart';
import 'util.dart';

abstract class DateTimeOperations {
  static Map<String, ExprCallable> functions = {'isoFormat': _IsoFormatOp()};
}

class _IsoFormatOp implements ExprCallable {
  @override
  int arity() => 2;

  @override
  Object? call(ASTEvaluator evaluator, List<Object> arguments) {
    if (arguments.length < arity()) {
      return 'Incorrect argument size';
    }

    final isoStringDate = toValue<String>(evaluator, arguments[0]);
    final path = toValue<String>(evaluator, arguments[1]);

    return _isoFormat(isoStringDate, path);
  }

  @override
  String get name => 'isoFormat';
}

String? _isoFormat(String? isoString, String? format) {
  if (isoString == null || format == null) {
    return null;
  }

  return Moment.parse(isoString).format(format);
}
