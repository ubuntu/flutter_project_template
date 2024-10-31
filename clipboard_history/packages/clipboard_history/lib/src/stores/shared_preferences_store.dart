import 'package:clipboard_history/clipboard_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sharedPreferencesKey = 'clipboard';

class SharedPreferencesStore extends Store {
  late final SharedPreferencesWithCache _sharedPreferences;

  @override
  Future<void> init() async {
    _sharedPreferences = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    );
  }

  @override
  List<ClipboardContent> get clipboard =>
      _sharedPreferences.getStringList(_sharedPreferencesKey)?.deserialize() ??
      [];

  @override
  Future<void> add(String value) {
    return _sharedPreferences.setStringList(
      _sharedPreferencesKey,
      [
        ClipboardContent.withTimestamp(value).toString(),
        ..._sharedPreferences.getStringList(_sharedPreferencesKey) ?? [],
      ],
    );
  }

  @override
  Future<void> removeAt(int index) {
    return _sharedPreferences.setStringList(
      _sharedPreferencesKey,
      clipboard.serialize()..removeAt(index),
    );
  }

  @override
  Future<void> clear() {
    return _sharedPreferences.remove(_sharedPreferencesKey);
  }
}

extension on List<ClipboardContent> {
  List<String> serialize() => map((e) => e.toString()).toList();
}

extension on List<String> {
  List<ClipboardContent> deserialize() =>
      map(ClipboardContent.fromString).toList();
}
