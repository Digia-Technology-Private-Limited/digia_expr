import 'package:digia_expr/src/ast.dart';
import 'package:digia_expr/src/expr_context.dart';
import 'package:digia_expr/src/std/std_functions.dart';
import 'package:digia_expr/src/std/string_operations.dart';

import 'types.dart';

class ASTEvaluator {
  ExprContext? _context;

  ASTEvaluator({ExprContext? context}) {
    final enclosing = ExprContext(variables: {...StdLibFunctions.functions});
    if (context == null) {
      _context = enclosing;
    } else {
      _context = context..enclosing = enclosing;
    }
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
        final valueFromContext = _context?.get(node.name.lexeme);
        if (valueFromContext == null) {
          throw 'Value for variable: ${node.name} is not found';
        }

        result = (valueFromContext is ASTNode)
            ? eval(valueFromContext)
            : valueFromContext;

      case ASTGetExpr():
        final object = eval(node.expr);
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
