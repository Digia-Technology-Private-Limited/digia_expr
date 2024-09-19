class ExprContext {
  final String name;
  ExprContext? _enclosing;

  final Map<String, Object?> _variables;

  ExprContext({
    this.name = '',
    required Map<String, Object?> variables,
    ExprContext? enclosing,
  })  : _enclosing = enclosing,
        _variables = variables;

  appendEnclosing(ExprContext enclosing) {
    if (_enclosing == null) {
      _enclosing = enclosing;
      return;
    }

    _enclosing!.appendEnclosing(enclosing);
  }

  (bool, Object?) get(String key) {
    if (_variables.containsKey(key)) {
      return (true, _variables[key]);
    }

    return _enclosing?.get(key) ?? (false, null);
  }

  ExprContext copyWithNewVariables({Map<String, Object?>? newVariables}) {
    return ExprContext(
      name: name,
      variables: Map.from(_variables)..addAll(newVariables ?? {}),
      enclosing: _enclosing,
    );
  }
}
