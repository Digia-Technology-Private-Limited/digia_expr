import 'ast.dart';

class ExprContext {
  ExprContext? enclosing;

  Map<String, Object?> variables;

  ExprContext({required this.variables, this.enclosing});

  setEnclosing(ExprContext? enclosing) {
    if (this.enclosing == null) {
      this.enclosing = enclosing;
      return;
    }

    enclosing?.setEnclosing(enclosing);
  }

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
