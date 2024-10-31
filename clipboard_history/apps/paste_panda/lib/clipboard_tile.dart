import 'package:clipboard_history/clipboard_history.dart';
import 'package:flutter/material.dart';
import 'package:yaru/icons.dart';

enum ClipboardTilePosition { first, middle, last, single }

class ClipboardTile extends StatelessWidget {
  const ClipboardTile({
    required this.content,
    required this.onDelete,
    this.onCopy,
    this.position = ClipboardTilePosition.middle,
    super.key,
  });

  final ClipboardContent content;
  final ClipboardTilePosition position;
  final void Function() onDelete;
  final void Function()? onCopy;

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    const radius = Radius.circular(8);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: switch (position) {
          ClipboardTilePosition.first =>
            const BorderRadius.only(topLeft: radius, topRight: radius),
          ClipboardTilePosition.middle => BorderRadius.zero,
          ClipboardTilePosition.last =>
            const BorderRadius.only(bottomLeft: radius, bottomRight: radius),
          ClipboardTilePosition.single => const BorderRadius.all(radius),
        },
        border: switch (position) {
          ClipboardTilePosition.first => Border(
              top: border,
              left: border,
              right: border,
              bottom: border,
            ),
          ClipboardTilePosition.middle => Border(
              left: border,
              right: border,
              bottom: border,
            ),
          ClipboardTilePosition.last => Border(
              bottom: border,
              left: border,
              right: border,
            ),
          ClipboardTilePosition.single => Border.fromBorderSide(border),
        },
      ),
      child: ListTile(
        //key: ValueKey(snap.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(content.value),
        subtitle: Text(content.timestamp.toString()),
        leading: onCopy != null
            ? IconButton(icon: Icon(YaruIcons.copy), onPressed: onCopy)
            : null,
        trailing: IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
      ),
    );
  }
}
