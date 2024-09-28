import 'expr_context.dart';

/// A basic implementation of ExprContext that can be used as-is or extended.
class BasicExprContext extends ExprContext {
  @override
  final String name;

  ExprContext? _enclosing;
  final Map<String, Object?> _variables;

  BasicExprContext({
    this.name = '',
    required Map<String, Object?> variables,
    ExprContext? enclosing,
  })  : _variables = Map.from(variables),
        _enclosing = enclosing;

  @override
  ExprContext? get enclosing => _enclosing;

  @override
  ({bool found, Object? value}) getValue(String key) {
    if (_variables.containsKey(key)) {
      return (found: true, value: _variables[key]);
    }
    return _enclosing?.getValue(key) ?? (found: false, value: null);
  }

  @override
  set enclosing(ExprContext? context) {
    _enclosing = context;
  }
}
