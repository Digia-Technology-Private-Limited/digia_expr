enum TokenType {
  // Single-character tokens.
  leftParen,
  rightParen,
  comma,
  dot,
  semicolon,
  newLine,
  //Literals.
  variable,
  string,
  integer,
  float,
  //Keywords.
  no,
  yes,
  eof
}

class Token {
  final TokenType type;
  final String lexeme;
  final int line;

  Token({required this.type, required this.lexeme, required this.line});

  @override
  String toString() {
    return '{ type: $type, lexeme: $lexeme, line: $line }';
  }
}
