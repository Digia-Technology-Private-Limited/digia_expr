import 'package:digia_expr/src/ast.dart';

import 'expr_context.dart';
import 'std/std_functions.dart';

import 'std/types.dart';

abstract class Visitor<T> {
  T visitAst(ASTNode node) =>
      throw UnimplementedError('${node.runtimeType} is not implemented');
  T visitProgram(ASTProgram node);
  T visitCallExpression(ASTCallExpression node);
  T visitASTNumberLiteral(ASTNumberLiteral node);
  T visitASTStringExpression(ASTStringExpression node);
  T visitASTStringLiteral(ASTStringLiteral node);
  T visitASTIdentifer(ASTIdentifer node);
}

class ASTVisitorEvaluator extends Visitor<Object?> {
  final Map<String, ExprCallable> functionHandlers;

  ExprContext? context;

  ASTVisitorEvaluator({
    this.context,
    Map<String, ExprCallable>? functions = const {},
  }) : functionHandlers = {...StdLibFunctions.functions, ...?functions};

  @override
  Object? visitASTIdentifer(ASTIdentifer node) {
    final valueFromContext = context?.get(node.name);
    if (valueFromContext == null) {
      throw 'Value for variable: ${node.name} is not found';
    }
    return valueFromContext.visit(this);
  }

  @override
  Object? visitASTNumberLiteral(ASTNumberLiteral node) {
    return node.value;
  }

  @override
  Object? visitASTStringExpression(ASTStringExpression node) {
    return null;
    // return StringOperations.concatenate(
    //     node.parts.map((e) => e.visit(this)).toList());
  }

  @override
  Object? visitASTStringLiteral(ASTStringLiteral node) {
    return node.value;
  }

  @override
  Object? visitCallExpression(ASTCallExpression node) {
    return null;
    // final fn = functionHandlers[node.fnName];
    // if (fn == null) {
    //   throw 'A Function with name: ${node.fnName} is not found';
    // }
    // return fn.call(node.expressions.map((e) => e.visit(this)).toList());
  }

  @override
  Object? visitProgram(ASTProgram node) {
    return node.body.first.visit(this);
  }
}
