import 'dart:convert';

/// MongoDB query formatter utility for pretty-printing structured mongo logs.
///
/// Expected input format:
/// `[mongo:<operation>] {"collection":"Users","pipeline":[...]}`
class MongoDbFormatter {
  /// Formats a mongo log line for readability.
  ///
  /// If the input is not a mongo log line, returns it unchanged.
  static String format(String message) {
    final match = RegExp(r'^\[mongo:([^\]]+)\]\s*(.*)$').firstMatch(message);
    if (match == null) {
      return message;
    }

    final operation = match.group(1)?.trim() ?? 'query';
    final rawPayload = (match.group(2) ?? '').trim();
    if (rawPayload.isEmpty) {
      return '[mongo:$operation]';
    }

    final prettyPayload = _prettyJson(rawPayload);
    return '[mongo:$operation]\n$prettyPayload';
  }

  /// Formats and prints a mongo log line.
  static void printFormatted(String message) {
    print(format(message));
  }

  static String _prettyJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return rawJson;
    }
  }
}
