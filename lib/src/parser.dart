import 'package:digia_expr/src/ast.dart';
import 'package:digia_expr/src/constants.dart';
import 'package:digia_expr/src/create_ast.dart';

import 'token.dart';

class Parser {
  final List<Token> tokens;

  Parser({required this.tokens});

  late ASTProgram ast;

  int _current = 0;

  Token? _peek() => _current + 1 < tokens.length ? tokens[_current + 1] : null;
  bool _isAtEnd() =>
      _current > tokens.length; // Last token will be TokenType.eof
  _advance({int by = 1}) => _current = _current + by;
  Token _next() => tokens[++_current];
  _consume(TokenType tokenType, String errorMessage) {
    if (tokens[_current].type == tokenType) {
      _advance();
      return;
    }
    throw errorMessage;
  }

  List<ASTNode> _createStringExpression(String input) {
    final RegExp exp = RegExp(stringExpressionRegex);
    List<ASTNode> parts = [];
    int lastIndex = 0;

    for (RegExpMatch match in exp.allMatches(input)) {
      String expression = input.substring(match.start, match.end);
      parts.add(
          ASTStringLiteral(value: input.substring(lastIndex, match.start)));
      parts.add(createAST(expression.substring(2, expression.length - 1)));
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      parts.add(ASTStringLiteral(value: input.substring(lastIndex)));
    }

    return parts;
  }

  ASTNode parse() {
    ast = ASTProgram(body: []);

    var token = tokens[_current];

    ASTNode walk() {
      switch (token.type) {
        case TokenType.integer:
          _advance();
          return ASTNumberLiteral(value: int.tryParse(token.lexeme));

        case TokenType.yes:
        case TokenType.no:
          _advance();
          return ASTBooleanLiteral(token: token);

        case TokenType.string:
          if (RegExp(stringExpressionRegex).hasMatch(token.lexeme)) {
            final parts = _createStringExpression(token.lexeme);
            _advance();
            return ASTStringExpression(parts: parts);
          } else {
            _advance();
            return ASTStringLiteral(value: token.lexeme);
          }

        case TokenType.semicolon:
          _advance();
          return ASTStringLiteral(value: token.lexeme);

        case TokenType.eof:
          _advance();
          return ASTStringLiteral(value: token.lexeme);

        case TokenType.variable:
          // if Neither x.y nor x(), then 'x' is a Variable.
          if (_peek()?.type != TokenType.leftParen &&
              _peek()?.type != TokenType.dot) {
            _advance();
            return ASTVariable(name: token);
          }

          // While loop for the chain.
          // a.b.c, Or,
          // a.b.c(), Or,
          // a.b().c
          ASTNode expr = ASTVariable(name: token);
          while (_peek()?.type == TokenType.leftParen ||
              _peek()?.type == TokenType.dot) {
            if (_peek()?.type == TokenType.leftParen) {
              _advance();

              final node = ASTCallExpression(fnName: expr, expressions: []);
              token = _next();
              while (token.type != TokenType.rightParen) {
                node.expressions.add(walk());
                token = tokens[_current];
                if (token.type != TokenType.rightParen) {
                  _consume(
                      TokenType.comma, "Expected , after a function argument");
                }
                token = tokens[_current];
              }
              _consume(
                  TokenType.rightParen, "Missing ) at the end of function");
              expr = node;
            } else if (_peek()?.type == TokenType.dot) {
              _advance();
              expr = ASTGetExpr(name: _next(), expr: expr);
            } else {
              break;
            }
          }
          return expr;

        default:
          throw "Unexpected token: ${token.type}";
      }
    }

    ast.body.add(walk());

    return ast;
  }
}
