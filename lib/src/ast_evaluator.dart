import 'ast.dart';
import 'expr_context.dart';
import 'std/json_operations.dart';
import 'std/std_functions.dart';
import 'std/string_operations.dart';

import 'types.dart';

class ASTEvaluator {
  ExprContext? _context;

  ASTEvaluator({ExprContext? context}) {
    final enclosing = ExprContext(variables: {...StdLibFunctions.functions});
    _context = enclosing..enclosing = context;
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
        if (_context == null) {
          throw 'No Environment Context provided';
        }
        final (variableFound, valueOfVariable) =
            _context!.get(node.name.lexeme);
        if (!variableFound) {
          throw '${node.name.lexeme} is not defined';
        }

        if (valueOfVariable == null) return null;

        result = (valueOfVariable is ASTNode)
            ? eval(valueOfVariable)
            : valueOfVariable;

      case ASTGetExpr():
        final object = eval(node.expr);
        if (object is Map<String, dynamic>) {
          result = JsonGetOp().call(this, [object, node.name.lexeme]);
          break;
        }

        if (object is! ExprClassInstance) {
          throw 'Only class instances have properties';
        }

        result = object.get(node.name);

      default:
        throw UnimplementedError('${node.runtimeType} is not implemented');
    }

    return result;
  }
}
