import 'package:clipboard_history/src/stores/shared_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesStore', () {
    test('add method should add values to the history', () async {
      final store = SharedPreferencesStore();
      await store.init();
      await store.add('first');
      await Future.delayed(Duration(milliseconds: 100));
      await store.add('second');
      final clipboard = store.clipboard;
      expect(clipboard, hasLength(2));
      expect(clipboard[0].value, 'second');
      expect(clipboard[1].value, 'first');
      expect(clipboard[0].timestamp.isAfter(clipboard[1].timestamp), isTrue);
    });

    test('removeAt method should remove value at specified index', () async {
      final store = SharedPreferencesStore();
      await store.init();
      await store.add('first');
      await store.add('second');
      await store.removeAt(0);
      final clipboard = store.clipboard;
      expect(clipboard, hasLength(1));
      expect(clipboard[0].value, 'first');
    });

    test('clear method should clear all values from the store', () async {
      final store = SharedPreferencesStore();
      await store.init();
      await store.add('first');
      await store.add('second');
      await store.clear();
      final clipboard = store.clipboard;
      expect(clipboard, isEmpty);
    });
  });
}
