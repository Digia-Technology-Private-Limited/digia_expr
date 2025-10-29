# Digia Expressions

A powerful and flexible expression evaluator for Dart, designed to dynamically process expressions with support for variables, custom functions, and string interpolation. Built on an extensible visitor pattern architecture.

> **Note**: This package is developed for internal use within [Digia UI](https://pub.dev/packages/digia_ui) and is not intended for general public consumption.

## Key Features

- **Evaluate expressions**: Mathematical, logical, and property access expressions
- **Extensible Visitor Pattern**: Create custom analyzers by extending `Visitor<T>`
- **AST Access**: Full access to the Abstract Syntax Tree for custom processing

## Architecture

The library exposes its internals, allowing you to:

1. **Parse expressions to AST** using `createAST()`
2. **Extend the Visitor pattern** to create custom analyzers
3. **Access all AST node types** for complete control

## Usage

### Basic Expression Evaluation

```dart
import 'package:digia_expr/digia_expr.dart';

void main() {
  final context = BasicExprContext(variables: {
    'user': {'name': 'John Doe', 'age': 30}
  });
  
  final result = Expression.eval('user.name', context);
  print(result); // Output: John Doe
}
```

### Extending the Visitor Pattern

Create custom visitors to analyze expressions:

```dart
import 'package:digia_expr/digia_expr.dart';

// Custom visitor to collect variable names
class VariableCollectorVisitor extends Visitor<List<String>> {
  @override
  List<String> visitProgram(ASTProgram node) {
    final List<String> vars = [];
    for (final expr in node.body) {
      // Implement traversal logic
    }
    return vars;
  }
  
  @override
  List<String> visitASTVariable(ASTVariable node) {
    return [node.name.lexeme];
  }
  
  // Implement other visit methods...
}

void main() {
  final ast = createAST('user.name') as ASTProgram;
  final collector = VariableCollectorVisitor();
  final variables = collector.visitProgram(ast);
  print(variables); // Output: [user]
}
```
## Exported Components

When you import `package:digia_expr/digia_expr.dart`, you get access to:

- **Visitor<T>**: Abstract base class for creating custom visitors
- **AST Nodes**: All AST node types (ASTProgram, ASTVariable, ASTGetExpr, etc.)
- **createAST()**: Parse expressions into AST
- **Expression**: Main evaluation class
- **BasicExprContext**: Basic context for expression evaluation
- **StdLibFunctions**: Standard library functions

## Example Use Cases

1. **Static Analysis**: Analyze expressions to extract variable dependencies
2. **Code Generation**: Transform expressions into different formats
3. **Validation**: Check expressions before evaluation
4. **Custom Evaluators**: Build domain-specific expression evaluators
5. **Dependency Tracking**: Track what data an expression accesses

See `example/digia_expr_example.dart` for complete working examples.
