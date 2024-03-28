import 'ast.dart';
import 'parser.dart';
import 'scanner.dart';

ASTNode createAST(String source) {
  final tokens = Scanner(source: source).scanTokens();
  final ast = Parser(tokens: tokens).parse();
  return ast;
}
