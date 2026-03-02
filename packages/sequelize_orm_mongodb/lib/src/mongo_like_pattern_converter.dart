class MongoLikePatternConverter {
  const MongoLikePatternConverter();

  /// Converts a SQL LIKE pattern to a MongoDB regex string.
  ///
  /// Rules:
  /// - `%` -> `.*`
  /// - `_` -> `.`
  /// - `\x` escapes the next character as a literal
  /// - all other regex-special characters are escaped
  ///
  /// When [anchorStart] and [anchorEnd] are true (default), full-string
  /// matching semantics are preserved (`^...$`).
  static String convertLikeToRegex(
    String pattern, {
    bool anchorStart = true,
    bool anchorEnd = true,
  }) {
    final buffer = StringBuffer();
    var index = 0;
    while (index < pattern.length) {
      final char = pattern[index];
      if (char == r'\' && index + 1 < pattern.length) {
        index += 1;
        buffer.write(RegExp.escape(pattern[index]));
      } else if (char == '%') {
        buffer.write('.*');
      } else if (char == '_') {
        buffer.write('.');
      } else {
        buffer.write(RegExp.escape(char));
      }
      index += 1;
    }

    final prefix = anchorStart ? '^' : '';
    final suffix = anchorEnd ? r'$' : '';
    return '$prefix${buffer.toString()}$suffix';
  }

  static Map<String, dynamic> likeOperator(
    String pattern, {
    bool caseInsensitive = false,
  }) {
    return {
      r'$regex': convertLikeToRegex(pattern),
      if (caseInsensitive) r'$options': 'i',
    };
  }

  static Map<String, dynamic> notLikeOperator(
    String pattern, {
    bool caseInsensitive = false,
  }) {
    return {
      r'$not': {
        r'$regex': convertLikeToRegex(pattern),
        if (caseInsensitive) r'$options': 'i',
      },
    };
  }
}
