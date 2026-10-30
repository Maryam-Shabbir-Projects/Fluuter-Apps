import 'package:flutter/material.dart';

import '../models/element_model.dart';
import 'shapes.dart' show isFace;

/// Colour / size / flip / layer controls for the selected element.
class QuickBar extends StatelessWidget {
  final El el;
  final void Function(VoidCallback) change; // records undo + rebuilds
  final VoidCallback onEditText, onFront, onDuplicate, onDelete, onDone;
  final VoidCallback onPickPhoto, onRemoveBg, onColor, onOutlineColor, onTextBg, onAdjust;
  final VoidCallback onSize, onReplaceIcon, onReplaceShape, onBoxBehind, onFont;
  final void Function(int where) onLayer; // 0 = to back, 1 = backward, 2 = forward, 3 = to front
  const QuickBar({
    super.key,
    required this.el,
    required this.change,
    required this.onEditText,
    required this.onFront,
    required this.onDuplicate,
    required this.onDelete,
    required this.onDone,
    required this.onPickPhoto,
    required this.onRemoveBg,
    required this.onColor,
    required this.onOutlineColor,
    required this.onTextBg,
    required this.onAdjust,
    required this.onSize,
    required this.onReplaceIcon,
    required this.onReplaceShape,
    required this.onBoxBehind,
    required this.onFont,
    required this.onLayer,
  });

  void _scale(double f) => change(() {
        if (el.k == K.text || el.k == K.icon) {
          el.size *= f;
          if (el.k == K.text) el.w *= f;
        } else {
          el.w *= f;
          el.h *= f;
        }
      });

  Widget _dot(Color? c) => Container(
        width: 20, height: 20,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1.5)),
        child: c == null ? const Icon(Icons.block, size: 14, color: Colors.grey) : null,
      );

  @override
  Widget build(BuildContext context) {
    final e = el;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [
        if (e.k == K.text) TextButton.icon(onPressed: onEditText, icon: const Icon(Icons.keyboard), label: const Text('Edit text')),
        if (e.k == K.text || e.k == K.icon)
          TextButton.icon(onPressed: onSize, icon: const Icon(Icons.format_size), label: Text('Size ${e.size.round()}')),
        if (e.k == K.icon) TextButton.icon(onPressed: onReplaceIcon, icon: const Icon(Icons.swap_horiz), label: const Text('Replace icon')),
        if (e.k == K.shape) TextButton.icon(onPressed: onReplaceShape, icon: const Icon(Icons.swap_horiz), label: Text(isFace(el.shape) ? 'Change face' : 'Replace shape')),
        if (e.k == K.text || e.k == K.icon) TextButton.icon(onPressed: onBoxBehind, icon: const Icon(Icons.crop_square), label: const Text('Box behind')),
        if (e.k == K.image) ...[
          if (e.path != null) TextButton.icon(onPressed: onRemoveBg, icon: const Icon(Icons.auto_fix_high), label: const Text('Remove BG')),
          TextButton.icon(onPressed: onPickPhoto, icon: const Icon(Icons.photo_library_outlined), label: Text(e.path == null ? 'Choose photo' : 'Replace')),
        ] else
          TextButton.icon(onPressed: onColor, icon: _dot(e.color), label: Text(e.k == K.shape ? 'Fill colour' : 'Colour')),
        if (e.k == K.text || e.k == K.icon) ...[
          TextButton(onPressed: () => change(() => e.outline = !e.outline), child: Text(e.outline ? 'Outline: on' : 'Outline: off')),
          TextButton.icon(onPressed: onOutlineColor, icon: _dot(e.stroke), label: const Text('Outline colour')),
        ],
        if (e.k == K.text) ...[
          TextButton.icon(onPressed: onTextBg, icon: _dot(e.bgFill), label: const Text('Text background')),
          TextButton.icon(onPressed: onFont, icon: const Icon(Icons.font_download_outlined), label: Text(e.font)),
        ],
        TextButton.icon(onPressed: onAdjust, icon: const Icon(Icons.tune), label: const Text('Adjust')),
        IconButton(tooltip: 'Smaller', onPressed: () => _scale(.85), icon: const Icon(Icons.remove_circle_outline)),
        IconButton(tooltip: 'Bigger', onPressed: () => _scale(1.15), icon: const Icon(Icons.add_circle_outline)),
        IconButton(tooltip: 'Flip left ↔ right', onPressed: () => change(() => e.flipX = !e.flipX), icon: const Icon(Icons.flip)),
        IconButton(tooltip: 'Flip upside down', onPressed: () => change(() => e.flipY = !e.flipY), icon: const RotatedBox(quarterTurns: 1, child: Icon(Icons.flip))),
        IconButton(tooltip: 'Rotate 90°', onPressed: () => change(() => e.rot = (e.rot + 90) % 360), icon: const Icon(Icons.rotate_90_degrees_cw)),
        PopupMenuButton<int>(
          tooltip: 'Layer order',
          icon: const Icon(Icons.layers),
          onSelected: onLayer,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 3, child: Text('Bring to front')),
            PopupMenuItem(value: 2, child: Text('Move forward')),
            PopupMenuItem(value: 1, child: Text('Move backward')),
            PopupMenuItem(value: 0, child: Text('Send to back')),
          ],
        ),
        IconButton(tooltip: 'Duplicate', onPressed: onDuplicate, icon: const Icon(Icons.copy)),
        IconButton(tooltip: 'Delete', onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
        TextButton(onPressed: onDone, child: const Text('Done')),
      ]),
    );
  }
}
