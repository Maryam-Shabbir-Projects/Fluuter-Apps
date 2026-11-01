import 'package:flutter/material.dart';

/// Row of icon + label options in one rounded track. The chosen option is lifted.
class ToggleGroup extends StatelessWidget {
  final List<(IconData, String)> items;
  final int selected;
  final ValueChanged<int> onChanged;
  const ToggleGroup({super.key, required this.items, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: cs.onSurface.withAlpha(14), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                decoration: BoxDecoration(
                  color: i == selected ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: i == selected ? [BoxShadow(color: Colors.black.withAlpha(28), blurRadius: 6, offset: const Offset(0, 2))] : null,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(items[i].$1, size: 20, color: i == selected ? cs.primary : cs.onSurfaceVariant),
                  const SizedBox(height: 3),
                  Text(items[i].$2, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500, color: i == selected ? cs.primary : cs.onSurfaceVariant)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}
