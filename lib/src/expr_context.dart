import 'package:digia_expr/src/ast.dart';

class ExprContext {
  ExprContext? enclosing;

  Map<String, ASTNode> variables;

  ExprContext({required this.variables, this.enclosing});

  ASTNode? get(String key) {
    if (variables.containsKey(key)) {
      return variables[key];
    }

    return enclosing?.get(key);
  }

  put(String key, ASTNode value) {
    if (variables.containsKey(key)) {
      return variables[key];
    }
  }
}
