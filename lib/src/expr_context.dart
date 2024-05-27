import 'ast.dart';

class ExprContext {
  ExprContext? enclosing;

  Map<String, Object?> variables;

  ExprContext({required this.variables, this.enclosing});

  (bool, Object?) get(String key) {
    if (variables.containsKey(key)) {
      return (true, variables[key]);
    }

    return enclosing?.get(key) ?? (false, null);
  }

  put(String key, ASTNode value) {
    if (variables.containsKey(key)) {
      return variables[key];
    }
  }
}
