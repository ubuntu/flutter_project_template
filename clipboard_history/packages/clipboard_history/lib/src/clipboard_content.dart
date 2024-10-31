const _separator = ':::SEPARATOR:::';

final class ClipboardContent {
  const ClipboardContent({required this.value, required this.timestamp});

  factory ClipboardContent.withTimestamp(String content) {
    return ClipboardContent(
      value: content,
      timestamp: DateTime.now(),
    );
  }

  factory ClipboardContent.fromString(String content) {
    final parts = content.split(_separator);
    return ClipboardContent(
      value: parts[0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
    );
  }

  final String value;
  final DateTime timestamp;

  @override
  String toString() => '$value$_separator${timestamp.millisecondsSinceEpoch}';
}
