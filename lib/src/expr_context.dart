import 'ast.dart';

class ExprContext {
  ExprContext? enclosing;

  Map<String, Object?> variables;

  ExprContext({required this.variables, this.enclosing});

  Object? get(String key) {
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
