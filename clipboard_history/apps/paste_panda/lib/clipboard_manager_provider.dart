import 'package:clipboard_history/clipboard_history.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'clipboard_manager_provider.g.dart';

@riverpod
class ClipboardManager extends _$ClipboardManager {
  late final _clipboard = getService<ClipboardHistory>();
  void Function()? _listener;

  @override
  Future<List<ClipboardContent>> build() async {
    await _clipboard.init();
    if (_listener == null) {
      _listener = _silentUpdate;
      _clipboard.addListener(_listener!);
    }
    return _clipboard.getValues();
  }

  /// This method updates the state without going into the loading state first.
  void _silentUpdate() {
    state = AsyncData(_clipboard.getValues());
  }

  /// This sets the current content of the clipboard.
  Future<void> setContent(String value, {int? removeIndex}) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (removeIndex != null) {
      _clipboard.removeAt(removeIndex);
    }
    _clipboard.add(value);
  }

  void removeActive() {
    _clipboard.removeActive();
  }

  void removeAt(int index) {
    _clipboard.removeAt(index);
  }

  void clear() {
    _clipboard.clear();
  }
}
