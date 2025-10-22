import 'ast.dart';
import 'create_ast.dart';
import 'expression.dart';
import 'visitor.dart';

/// Information about a variable access in an expression
class VariableAccessInfo {
  /// The variable name
  final String name;

  /// The type of container (map, list, or direct)
  final VariableContainerType containerType;

  /// The path to access the variable (e.g., 'user.profile.name')
  final String accessPath;

  /// Whether the variable is accessed through function calls
  final bool accessedThroughFunction;

  /// Function names involved in accessing this variable
  final List<String> functionCalls;

  /// List of sub-paths accessed for this variable (e.g., for appState: ['user.name', 'test'])
  final List<String> subPaths;

  VariableAccessInfo({
    required this.name,
    required this.containerType,
    required this.accessPath,
    this.accessedThroughFunction = false,
    this.functionCalls = const [],
    this.subPaths = const [],
  });

  /// Creates a copy with updated sub-paths
  VariableAccessInfo copyWith({
    String? name,
    VariableContainerType? containerType,
    String? accessPath,
    bool? accessedThroughFunction,
    List<String>? functionCalls,
    List<String>? subPaths,
  }) {
    return VariableAccessInfo(
      name: name ?? this.name,
      containerType: containerType ?? this.containerType,
      accessPath: accessPath ?? this.accessPath,
      accessedThroughFunction:
          accessedThroughFunction ?? this.accessedThroughFunction,
      functionCalls: functionCalls ?? this.functionCalls,
      subPaths: subPaths ?? this.subPaths,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'containerType': containerType.toString(),
      'accessPath': accessPath,
      'accessedThroughFunction': accessedThroughFunction,
      'functionCalls': functionCalls,
      'subPaths': subPaths,
    };
  }

  @override
  String toString() {
    return 'VariableAccessInfo(name: $name, containerType: $containerType, accessPath: $accessPath, accessedThroughFunction: $accessedThroughFunction, functionCalls: $functionCalls, subPaths: $subPaths)';
  }
}

/// Types of containers a variable can be accessed from
enum VariableContainerType {
  direct,

  json,

  unknown
}

/// Analyzes expressions to determine variable access patterns
class ExpressionAnalyzer extends Visitor<List<VariableAccessInfo>> {
  final List<VariableAccessInfo> _accessInfo = [];

  ExpressionAnalyzer();

  /// Extracts sub-path from an access path (everything after the root variable)
  static String? _extractSubPath(String variableName, String accessPath) {
    final pathParts = accessPath.split('.');
    return pathParts.length > 1 ? pathParts.sublist(1).join('.') : null;
  }

  /// Analyzes an expression and returns information about variable access patterns
  static Map<String, VariableAccessInfo> analyze(String expression) {
    final analyzer = ExpressionAnalyzer();

    // Handle string interpolation expressions
    String processedExpression = expression.trim();

    // Check if it's a string interpolation expression
    if (Expression.hasExpression(processedExpression)) {
      // For string interpolation, we need to parse it differently
      return analyzer._analyzeStringInterpolation(processedExpression);
    }

    if (processedExpression.startsWith(r'${') &&
        processedExpression.endsWith('}')) {
      processedExpression =
          processedExpression.substring(2, processedExpression.length - 1);
    }

    final ast = createAST(processedExpression);
    final results = analyzer._analyzeNode(ast);

    // Convert to map with variable names as keys and merge sub-paths
    final Map<String, VariableAccessInfo> resultMap = {};
    for (final info in results) {
      if (resultMap.containsKey(info.name)) {
        // Merge sub-paths for the same variable
        final existing = resultMap[info.name]!;
        final mergedSubPaths =
            <String>{...existing.subPaths, ...info.subPaths}.toList();
        resultMap[info.name] = existing.copyWith(subPaths: mergedSubPaths);
      } else {
        resultMap[info.name] = info;
      }
    }

    return resultMap;
  }

  /// Internal method to analyze a node and return variable access info
  List<VariableAccessInfo> _analyzeNode(ASTNode node) {
    switch (node) {
      case ASTProgram():
        return visitProgram(node);
      case ASTVariable():
        return visitASTVariable(node);
      case ASTGetExpr():
        return visitASTGetExpr(node);
      case ASTCallExpression():
        return visitCallExpression(node);
      case ASTStringExpression():
        return visitASTStringExpression(node);
      case ASTNumberLiteral():
        return visitASTNumberLiteral(node);
      case ASTStringLiteral():
        return visitASTStringLiteral(node);
      case ASTBooleanLiteral():
        return [];
      default:
        throw UnimplementedError('${node.runtimeType} is not implemented');
    }
  }

  /// Analyzes string interpolation expressions
  Map<String, VariableAccessInfo> _analyzeStringInterpolation(
      String expression) {
    final Map<String, VariableAccessInfo> resultMap = {};

    // Extract expressions from string interpolation using regex
    final RegExp expressionRegex = RegExp(r'\$\{([^}]+)\}');
    final matches = expressionRegex.allMatches(expression);

    for (final match in matches) {
      final innerExpression = match.group(1);
      if (innerExpression != null) {
        try {
          final ast = createAST(innerExpression);
          final results = _analyzeNode(ast);

          for (final info in results) {
            if (resultMap.containsKey(info.name)) {
              // Merge sub-paths for the same variable
              final existing = resultMap[info.name]!;
              final mergedSubPaths =
                  <String>{...existing.subPaths, ...info.subPaths}.toList();
              resultMap[info.name] =
                  existing.copyWith(subPaths: mergedSubPaths);
            } else {
              resultMap[info.name] = info;
            }
          }
        } catch (e) {
          // Skip invalid expressions
          continue;
        }
      }
    }

    return resultMap;
  }

  @override
  List<VariableAccessInfo> visitProgram(ASTProgram node) {
    _accessInfo.clear();
    for (final child in node.body) {
      _accessInfo.addAll(_analyzeNode(child));
    }
    return _accessInfo;
  }

  @override
  List<VariableAccessInfo> visitASTVariable(ASTVariable node) {
    final varName = node.name.lexeme;
    final subPath = _extractSubPath(varName, varName);

    return [
      VariableAccessInfo(
        name: varName,
        containerType: VariableContainerType.direct,
        accessPath: varName,
        subPaths: subPath != null ? [subPath] : [],
      )
    ];
  }

  @override
  List<VariableAccessInfo> visitASTGetExpr(ASTGetExpr node) {
    final List<VariableAccessInfo> results = [];

    // Get info from the base expression
    final baseResults = _analyzeNode(node.expr);

    // Build the full access path and infer container type
    for (final baseResult in baseResults) {
      final fullPath = '${baseResult.accessPath}.${node.name.lexeme}';
      final subPath = _extractSubPath(baseResult.name, fullPath);

      results.add(VariableAccessInfo(
        name: baseResult.name,
        containerType: VariableContainerType.json,
        accessPath: fullPath,
        accessedThroughFunction: baseResult.accessedThroughFunction,
        functionCalls: baseResult.functionCalls,
        subPaths: subPath != null ? [subPath] : [],
      ));
    }

    return results;
  }

  @override
  List<VariableAccessInfo> visitCallExpression(ASTCallExpression node) {
    final List<VariableAccessInfo> results = [];

    // Get function name
    String functionName = '';
    if (node.fnName is ASTVariable) {
      functionName = (node.fnName as ASTVariable).name.lexeme;
    }

    // Process arguments to find variable accesses
    for (final arg in node.expressions) {
      final argResults = _analyzeNode(arg);
      for (final argResult in argResults) {
        results.add(VariableAccessInfo(
          name: argResult.name,
          containerType: argResult.containerType,
          accessPath: argResult.accessPath,
          accessedThroughFunction: true,
          functionCalls: [...argResult.functionCalls, functionName],
          subPaths: argResult.subPaths,
        ));
      }
    }

    return results;
  }

  @override
  List<VariableAccessInfo> visitASTStringExpression(ASTStringExpression node) {
    final List<VariableAccessInfo> results = [];

    for (final part in node.parts) {
      results.addAll(_analyzeNode(part));
    }

    return results;
  }

  @override
  List<VariableAccessInfo> visitASTNumberLiteral(ASTNumberLiteral node) {
    return [];
  }

  @override
  List<VariableAccessInfo> visitASTStringLiteral(ASTStringLiteral node) {
    return [];
  }
}
