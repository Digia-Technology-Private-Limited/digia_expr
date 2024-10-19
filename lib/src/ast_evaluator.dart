import 'ast.dart';
import 'base_expr_context.dart';
import 'expr_context.dart';
import 'std/json_operations.dart';
import 'std/std_functions.dart';
import 'std/string_operations.dart';

import 'types.dart';

class ASTEvaluator {
  late ExprContext _context;

  ASTEvaluator({ExprContext? context}) {
    final std = BasicExprContext(variables: StdLibFunctions.functions);
    if (context != null) {
      context.addContextAtTail(std);
      _context = context;
      return;
    }
    _context = std;
  }

  Object? eval(ASTNode node) {
    Object? result;

    switch (node) {
      case ASTProgram():
        result = eval(node.body.first);

      case ASTNumberLiteral():
        result = node.value;

      case ASTBooleanLiteral():
        result = node.value;

      case ASTStringLiteral():
        result = node.value;

      case ASTStringExpression():
        result = ConcatOp().call(this, node.parts);

      case ASTCallExpression():
        final callee = eval(node.fnName);
        if (callee is! ExprCallable) {
          throw 'Invalid Function: ${node.fnName.toString()}';
        }

        result = callee.call(this, node.expressions);

      case ASTVariable():
        final record = _context.getValue(node.name.lexeme);
        if (!record.found) {
          throw '${node.name.lexeme} is not defined';
        }

        if (record.value == null) return null;

        result = (record.value is ASTNode)
            ? eval(record.value as ASTNode)
            : record.value;

      case ASTGetExpr():
        final object = eval(node.expr);

        if (object == null) return null;

        if (object is Map) {
          result = JsonGetOp().call(this, [object, node.name.lexeme]);
          break;
        }

        if (object is! ExprInstance) {
          throw 'Only class instances have properties';
        }

        result = object.getField(node.name.lexeme);

      default:
        throw UnimplementedError('${node.runtimeType} is not implemented');
    }

    return result;
  }
}
