import 'package:clipboard_history/src/clipboard_content.dart';

abstract class Store {
  /// The clipboard history.
  List<ClipboardContent> get clipboard;

  /// Initializes the store.
  Future<void> init() async {}

  /// Adds a value to beginning of the stored list.
  Future<void> add(String value);

  /// Removes a value at the given index from the stored list.
  Future<void> removeAt(int index);

  /// Clears the stored list.
  Future<void> clear();
}
