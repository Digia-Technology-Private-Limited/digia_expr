import 'package:digia_expr/digia_expr.dart';

// Example 1: Custom visitor to collect variable names
class VariableCollectorVisitor extends Visitor<List<String>> {
  final List<String> variables = [];

  @override
  List<String> visitProgram(ASTProgram node) {
    variables.clear();
    for (final expr in node.body) {
      variables.addAll(expr.visit(this));
    }
    return variables;
  }

  @override
  List<String> visitASTVariable(ASTVariable node) {
    return [node.name.lexeme];
  }

  @override
  List<String> visitASTGetExpr(ASTGetExpr node) {
    return node.expr.visit(this);
  }

  @override
  List<String> visitCallExpression(ASTCallExpression node) {
    final List<String> vars = [];
    for (final arg in node.expressions) {
      vars.addAll(arg.visit(this));
    }
    return vars;
  }

  @override
  List<String> visitASTStringExpression(ASTStringExpression node) {
    final List<String> vars = [];
    for (final part in node.parts) {
      vars.addAll(part.visit(this));
    }
    return vars;
  }

  @override
  List<String> visitASTNumberLiteral(ASTNumberLiteral node) => [];

  @override
  List<String> visitASTStringLiteral(ASTStringLiteral node) => [];
}

// Example 2: Custom visitor to collect property access paths
class PropertyPathVisitor extends Visitor<List<String>> {
  @override
  List<String> visitProgram(ASTProgram node) {
    final List<String> allPaths = [];
    for (final expr in node.body) {
      allPaths.addAll(expr.visit(this));
    }
    return allPaths;
  }

  @override
  List<String> visitASTVariable(ASTVariable node) {
    return [node.name.lexeme];
  }

  @override
  List<String> visitASTGetExpr(ASTGetExpr node) {
    final basePaths = node.expr.visit(this);
    return basePaths.map((base) => '$base.${node.name.lexeme}').toList();
  }

  @override
  List<String> visitCallExpression(ASTCallExpression node) {
    final List<String> allPaths = [];
    for (final arg in node.expressions) {
      allPaths.addAll(arg.visit(this));
    }
    return allPaths;
  }

  @override
  List<String> visitASTStringExpression(ASTStringExpression node) {
    final List<String> allPaths = [];
    for (final part in node.parts) {
      allPaths.addAll(part.visit(this));
    }
    return allPaths;
  }

  @override
  List<String> visitASTNumberLiteral(ASTNumberLiteral node) => [];

  @override
  List<String> visitASTStringLiteral(ASTStringLiteral node) => [];
}

void main() {
  print('=== Digia Expression Library - Extensible Visitor Pattern ===\n');

  print('=== Example 1: Expression Evaluation ===');
  final code = "user.name";
  final context = BasicExprContext(variables: {
    'user': {'name': 'John Doe', 'age': 30}
  });

  try {
    final result = Expression.eval(code, context);
    print('Expression: $code');
    print('Result: $result\n');
  } catch (e) {
    print('Error: $e\n');
  }

  print('=== Example 2: Using Custom Visitors ===');

  final expressions = [
    'user.name',
    'config.api.endpoint',
    'appState.user.profile.name',
  ];

  for (final expr in expressions) {
    print('\nExpression: $expr');

    // Parse expression to AST
    final ast = createAST(expr) as ASTProgram;

    // Use custom visitor to collect variable names
    final variableCollector = VariableCollectorVisitor();
    final variables = variableCollector.visitProgram(ast);
    print('  Variables: $variables');

    // Use custom visitor to collect property paths
    final pathCollector = PropertyPathVisitor();
    final paths = pathCollector.visitProgram(ast);
    print('  Paths: $paths');
  }

  print('\n=== Key Features ===');
  print('✓ Extensible Visitor Pattern - Create custom visitors');
  print('✓ AST Access - Use createAST() to parse expressions');
  print('✓ Custom Analysis - Implement any logic by extending Visitor<T>');
  print('✓ Full Control - Build your own expression analyzers');
  print('\nExported components:');
  print('- Visitor<T>: Base visitor class to extend');
  print('- ASTNode and all AST node types');
  print('- createAST(): Parse expressions to AST');
}
