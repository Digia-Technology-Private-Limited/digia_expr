import 'package:digia_expr/src/ast.dart';
import 'package:digia_expr/src/expr_context.dart';
import 'package:digia_expr/src/std/std_functions.dart';
import 'package:digia_expr/src/std/string_operations.dart';
import 'package:digia_expr/src/std/types.dart';

class ASTEvaluator {
  final Map<String, ExprCallable> functionHandlers;
  final ExprContext? context;

  ASTEvaluator({this.context, Map<String, ExprCallable>? functions = const {}})
      : functionHandlers = {...StdLibFunctions.functions, ...?functions};

  Object? eval(ASTNode node) {
    Object? result;

    switch (node) {
      case ASTProgram():
        result = eval(node.body.first);

      case ASTNumberLiteral():
        result = node.value;

      case ASTStringLiteral():
        result = node.value;

      case ASTStringExpression():
        result = ConcatOp().call(this, node.parts);

      case ASTCallExpression():
        final fn = functionHandlers[node.fnName];
        if (fn == null) {
          throw 'A Function with name: ${node.fnName} is not found';
        }
        result = fn.call(this, node.expressions);

      case ASTIdentifer():
        final valueFromContext = context?.get(node.name);
        if (valueFromContext == null) {
          throw 'Value for variable: ${node.name} is not found';
        }
        result = eval(valueFromContext);

      default:
        throw UnimplementedError('${node.runtimeType} is not implemented');
    }

    return result;
  }
}
