import 'token.dart';

class Scanner {
  final String source;

  Scanner({
    required this.source,
  });

  // Private vars
  int _currIdx = 0;
  int _line = 1;
  final List<Token> _tokens = [];

  // Constants;
  final _digitRegex = RegExp(r'[0-9]');

  // Private Util functions
  _advance({int by = 1}) => _currIdx = _currIdx + by;
  String? _curr() => _isAtEnd() ? null : source[_currIdx];
  String? _next() {
    _advance();
    if (_isAtEnd()) return null;
    return _curr();
  }

  bool _isAtEnd() => _currIdx >= source.length;
  String? _peek() =>
      _currIdx + 1 >= source.length ? null : source[_currIdx + 1];
  String? _peekNext() =>
      _currIdx + 2 > source.length ? null : source[_currIdx + 2];
  _addToken(TokenType type, String value) =>
      _tokens.add(Token(type: type, lexeme: value, line: _line));

  List<Token> scanTokens() {
    final Map<String, void Function(String)> charMap = {
      '(': (char) {
        _addToken(TokenType.leftParen, char);
        _advance();
      },
      ')': (char) {
        _addToken(TokenType.rightParen, char);
        _advance();
      },
      ',': (char) {
        _addToken(TokenType.comma, char);
        _advance();
      },
      '.': (char) {
        _addToken(TokenType.dot, char);
        _advance();
      },
      ';': (char) {
        _addToken(TokenType.semicolon, char);
        _advance();
      },
      '\n': (char) {
        _line++;
        _addToken(TokenType.newLine, char);
        _advance();
      },
    };

    while (!_isAtEnd()) {
      var char = _curr()!;

      if (charMap.containsKey(char)) {
        charMap[char]!.call(char);
        continue;
      }

      if (RegExp(r'\s').hasMatch(char)) {
        _scanWhiteSpace();
        continue;
      }

      // Scan a String token
      if (char == '"' || char == '\'') {
        _scanString();
        continue;
      }

      // Scan a Integer or Float token

      if (_digitRegex.hasMatch(char)) {
        _scanNumber();
        continue;
      }

      if (RegExp(r'[a-z]').hasMatch(char)) {
        _scanIdentifier();
        continue;
      }

      throw UnsupportedError('Unknown token $char');
    }

    _addToken(TokenType.eof, '');

    return _tokens;
  }

  void _scanWhiteSpace() => _advance();

  void _scanString() {
    int leftQuotePos = _currIdx;
    int rightQuotePos = _currIdx;
    String? previousChar = _curr();
    String? char = _next();

    // Match opening quote & allow Escaped Characters
    while (
        char != source[leftQuotePos] && previousChar != '\\' && !_isAtEnd()) {
      previousChar = char;
      char = _next();
      rightQuotePos = _currIdx;

      if (_isAtEnd()) {
        throw 'Unterminated String';
      }
    }
    // Skip the Closing Quote
    _advance();
    _addToken(
        TokenType.string, source.substring(leftQuotePos + 1, rightQuotePos));
  }

  void _scanNumber() {
    var numTokenType = TokenType.integer;
    int numStartPos = _currIdx;
    int numEndPos = _currIdx;
    String? char = _curr();

    while (char != null && _digitRegex.hasMatch(char)) {
      if (_peek() == '.') {
        if (_digitRegex.hasMatch(_peekNext() ?? '')) {
          numTokenType = TokenType.float;
          _advance(by: 2);
        } else {
          throw 'Invalid Number format';
        }
      }
      char = _next();
      numEndPos = _currIdx;
    }

    _addToken(numTokenType, source.substring(numStartPos, numEndPos));
  }

  void _scanIdentifier() {
    String? char = _curr();
    int nameStartPos = _currIdx;
    int nameEndPos = _currIdx;
    while (char != null && RegExp(r'[a-zA-Z0-9_]').hasMatch(char)) {
      char = _next();
      nameEndPos = _currIdx;
    }
    final string = source.substring(nameStartPos, nameEndPos);
    switch (string) {
      case 'true':
      case 'True':
        _addToken(TokenType.yes, 'true');
        break;

      case 'false':
      case 'False':
        _addToken(TokenType.no, 'true');
        break;

      default:
        _addToken(TokenType.variable, string);
    }
  }
}
