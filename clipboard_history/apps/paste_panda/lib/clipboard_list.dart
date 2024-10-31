import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paste_panda/clipboard_manager_provider.dart';
import 'package:paste_panda/clipboard_tile.dart';
import 'package:paste_panda/constants.dart';
import 'package:yaru/widgets.dart';

class ClipboardList extends ConsumerWidget {
  const ClipboardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(clipboardManagerProvider).when(
          data: (clipboardContent) {
            final historyLength = clipboardContent.length - 1;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('Clipboard'),
                  floating: true,
                  actions: [
                    Row(
                      children: [
                        Text('Clear clipboard and history'),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            ref.read(clipboardManagerProvider.notifier).clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SliverList.list(
                  children: [
                    SizedBox(height: kMarginMedium),
                    if (clipboardContent.isNotEmpty) ...[
                      Text('Current clipboard content:'),
                      SizedBox(height: kMarginSmall),
                      ClipboardTile(
                        content: clipboardContent.first,
                        position: ClipboardTilePosition.single,
                        onDelete: () {
                          ref
                              .read(clipboardManagerProvider.notifier)
                              .removeActive();
                        },
                      ),
                      SizedBox(height: kMarginMedium),
                      Text('History:'),
                      SizedBox(height: kMarginSmall),
                    ] else ...[
                      Row(
                        children: [
                          Text('The clipboard is empty, waiting for content'),
                          SizedBox(width: kMarginSmall),
                          SizedBox.square(
                            dimension: 22,
                            child: YaruCircularProgressIndicator(
                              strokeWidth: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                SliverList.builder(
                  itemBuilder: (context, index) {
                    final historyIndex = index + 1;
                    return ClipboardTile(
                      content: clipboardContent[historyIndex],
                      position: _determineTilePosition(
                        index: index,
                        length: historyLength,
                      ),
                      onCopy: () {
                        ref.read(clipboardManagerProvider.notifier).setContent(
                              clipboardContent[historyIndex].value,
                              removeIndex: historyIndex,
                            );
                      },
                      onDelete: () {
                        ref
                            .read(clipboardManagerProvider.notifier)
                            .removeAt(historyIndex);
                      },
                      key: ValueKey(clipboardContent[index].toString()),
                    );
                  },
                  itemCount: historyLength,
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Something went terribly wrong. [$error]\n\n$stackTrace',
              ),
            );
          },
          loading: () => const Center(child: YaruCircularProgressIndicator()),
        );
  }
}

ClipboardTilePosition _determineTilePosition({
  required int index,
  required int length,
}) {
  if (length == 1) {
    return ClipboardTilePosition.single;
  }

  if (index == length - 1) {
    return ClipboardTilePosition.last;
  }

  if (index == 0) {
    return ClipboardTilePosition.first;
  } else {
    return ClipboardTilePosition.middle;
  }
}
