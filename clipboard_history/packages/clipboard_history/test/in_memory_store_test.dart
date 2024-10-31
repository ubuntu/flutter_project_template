import 'package:clipboard_history/clipboard_history.dart';
import 'package:clipboard_history/src/stores/in_memory_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryStore', () {
    test('add method should add values to the history', () async {
      final store = InMemoryStore();
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
      final store = InMemoryStore();
      await store.init();
      await store.add('first');
      await store.add('second');
      await store.removeAt(0);
      final clipboard = store.clipboard;
      expect(clipboard, hasLength(1));
      expect(clipboard[0].value, 'first');
    });

    test('clear method should clear all values from the store', () async {
      final store = InMemoryStore();
      await store.init();
      await store.add('first');
      await store.add('second');
      await store.clear();
      final clipboard = store.clipboard;
      expect(clipboard, isEmpty);
    });
  });
}
