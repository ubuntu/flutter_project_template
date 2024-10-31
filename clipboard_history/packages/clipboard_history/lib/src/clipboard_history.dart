import 'dart:async';

import 'package:clipboard_history/clipboard_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A store that holds the clipboard history.
/// The store polls the clipboard for changes and adds them to the history.
///
/// This currently only works when the window is in focus (when on wayland) due
/// to this bug:
/// https://github.com/flutter/flutter/issues/155741
class ClipboardHistory extends ChangeNotifier {
  ClipboardHistory(Store store) : _store = store;
  ClipboardHistory.inMemory() : this(InMemoryStore());
  ClipboardHistory.sharedPreferences() : this(SharedPreferencesStore());

  /// The store that holds the clipboard history.
  final Store _store;

  /// The interval in milliseconds to poll the clipboard for changes.
  int pollInterval = 500;

  Timer? _timer;

  /// Initializes the store and starts polling the clipboard for changes.
  Future<void> init() {
    if (_timer != null) {
      return Future.value();
    }
    return _store.init().then((_) {
      _timer = Timer.periodic(Duration(milliseconds: pollInterval), (_) {
        _poll();
      });
    });
  }

  /// Polls the clipboard for changes and adds them to the store.
  /// Returns true if a new value was added and false otherwise.
  Future<void> _poll() async {
    final currentValue = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (currentValue != null &&
        currentValue != _store.clipboard.firstOrNull?.value &&
        currentValue != '') {
      await _store.add(currentValue);
      notifyListeners();
    }
  }

  List<ClipboardContent> getValues() {
    return _store.clipboard;
  }

  /// Removes the active clipboard content and sets the clipboard to the next
  /// active content, if any.
  void removeActive() {
    _store.removeAt(0);
    Clipboard.setData(
      ClipboardData(text: _store.clipboard.firstOrNull?.value ?? ''),
    );
    notifyListeners();
  }

  /// Adds a new value to the top of the clipboard history and sets it as the
  /// active clipboard content.
  void add(String value) {
    _store.add(value);
    Clipboard.setData(ClipboardData(text: value));
    notifyListeners();
  }

  void removeAt(int index) {
    _store.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _store.clear();
    Clipboard.setData(ClipboardData(text: ''));
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
