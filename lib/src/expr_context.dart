/// An abstract class representing the context for expression evaluation.
/// This context provides access to variables and supports hierarchical scoping.
abstract class ExprContext {
  /// The name of this context, useful for debugging and logging.
  String get name;

  /// The enclosing context, if any. Used for hierarchical variable lookup.
  ExprContext? get enclosing;

  set enclosing(ExprContext? context);

  /// Retrieves a value from the context.
  ///
  /// Returns a tuple where:
  /// - The first element is a boolean indicating if the key was found.
  /// - The second element is the value associated with the key, or null if not found.
  ///
  /// This method should search in the current context first, then in enclosing contexts.
  ({bool found, Object? value}) getValue(String key);

  /// Adds a context to the tail of the current context chain.
  ///
  /// If this context doesn't have an enclosing context, the new context becomes
  /// the enclosing context. Otherwise, it's added to the end of the chain.
  ///
  /// @param context The ExprContext to add to the tail of the chain.
  void addContextAtTail(ExprContext context) {
    if (enclosing == null) {
      enclosing = context;
    } else {
      enclosing!.addContextAtTail(context);
    }
  }
}
