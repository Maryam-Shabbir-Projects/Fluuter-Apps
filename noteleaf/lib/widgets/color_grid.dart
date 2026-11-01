import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Palette of colour dots plus a "custom colour" dot (hex code).
class ColorGrid extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onPick;
  final bool allowCustom;
  const ColorGrid({super.key, required this.selected, required this.onPick, this.allowCustom = true});

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    Widget dot(Color col, bool on, VoidCallback tap, {Widget? child}) => GestureDetector(
          onTap: tap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: col, border: Border.all(width: on ? 3 : 1, color: on ? cs.primary : Colors.black26)),
            child: child,
          ),
        );
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (final k in kPalette) dot(Color(k), selected == k, () => onPick(k)),
      if (allowCustom)
        dot(cs.surface, !kPalette.contains(selected) && selected != 0, () async {
          final v = await customColor(c);
          if (v != null) onPick(v);
        }, child: Icon(Icons.colorize, size: 18, color: cs.onSurface)),
    ]);
  }
}

/// Asks for a hex colour such as 1E88E5.
Future<int?> customColor(BuildContext c) {
  final t = TextEditingController();
  return showDialog<int>(
    context: c,
    builder: (x) => AlertDialog(
      title: const Text('Custom colour'),
      content: TextField(controller: t, autofocus: true, maxLength: 6, decoration: const InputDecoration(prefixText: '#', labelText: 'Hex code, e.g. 1E88E5')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(x, int.tryParse('FF${t.text.trim()}', radix: 16)), child: const Text('Use')),
      ],
    ),
  );
}

/// Bottom sheet to pick a colour. Returns 0 when [noneLabel] is chosen.
Future<int?> pickColorSheet(BuildContext c, {required String title, String? noneLabel, int selected = 0}) => showModalBottomSheet<int>(
      context: c,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ColorGrid(selected: selected, onPick: (v) => Navigator.pop(ctx, v)),
          if (noneLabel != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: () => Navigator.pop(ctx, 0), child: Text(noneLabel)),
          ],
        ]),
      ),
    );
