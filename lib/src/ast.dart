import 'package:digia_expr/src/std/types.dart';
import 'package:digia_expr/src/visitor.dart';

enum AstNodeType {
  program,
  function,
  numberLiteral,
  stringExpression,
  stringLiteral,
  identifer,
  subExpression
}

abstract class ASTNode {
  AstNodeType get type;

  T visit<T>(Visitor<T> visitor) => visitor.visitAst(this);
}

class ASTProgram extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.program;

  List<ASTNode> body;

  ASTProgram({
    required this.body,
  });

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitProgram(this);
}

class ASTCallExpression extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.function;

  String fnName;
  List<ASTNode> expressions;

  ASTCallExpression({
    required this.fnName,
    required this.expressions,
  });

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitCallExpression(this);
}

class ASTNumberLiteral extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.numberLiteral;

  bool get isFloat => value is double;

  final num? _value;

  final Getter<num?>? _getter;

  ASTNumberLiteral({num? value, Getter<num?>? getter})
      : _value = value,
        _getter = getter;

  num? get value => _value ?? _getter?.call();

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitASTNumberLiteral(this);
}

class ASTStringExpression extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.stringExpression;

  List<ASTNode> parts;

  ASTStringExpression({required this.parts});

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitASTStringExpression(this);
}

class ASTStringLiteral extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.stringLiteral;

  final String? _value;

  final Getter<String>? _getter;

  ASTStringLiteral({String? value, Getter<String>? getter})
      : _value = value,
        _getter = getter;

  String? get value => _value ?? _getter?.call();

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitASTStringLiteral(this);
}

class ASTIdentifer extends ASTNode {
  @override
  AstNodeType get type => AstNodeType.identifer;

  String name;

  ASTIdentifer({required this.name});

  @override
  T visit<T>(Visitor<T> visitor) => visitor.visitASTIdentifer(this);
}
