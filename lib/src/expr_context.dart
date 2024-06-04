import 'ast.dart';

class ExprContext {
  final String name;
  ExprContext? _enclosing;

  final Map<String, Object?> variables;

  ExprContext({this.name = '', required this.variables, ExprContext? enclosing})
      : _enclosing = enclosing;

  appendEnclosing(ExprContext enclosing) {
    if (_enclosing == null) {
      _enclosing = enclosing;
      return;
    }

    _enclosing!.appendEnclosing(enclosing);
  }

  (bool, Object?) get(String key) {
    if (variables.containsKey(key)) {
      return (true, variables[key]);
    }

    return _enclosing?.get(key) ?? (false, null);
  }

  put(String key, ASTNode value) {
    if (variables.containsKey(key)) {
      return variables[key];
    }
  }
}
