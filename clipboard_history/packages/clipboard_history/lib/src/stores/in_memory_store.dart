import 'package:clipboard_history/clipboard_history.dart';

class InMemoryStore extends Store {
  @override
  final List<ClipboardContent> clipboard = [];

  @override
  Future<void> add(String value) async {
    clipboard.insert(0, ClipboardContent.withTimestamp(value));
  }

  @override
  Future<void> removeAt(int index) async {
    clipboard.removeAt(index);
  }

  @override
  Future<void> clear() async {
    clipboard.clear();
  }
}
