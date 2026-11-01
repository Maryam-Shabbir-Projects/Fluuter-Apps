import 'package:flutter/material.dart';

/// Floating bottom navigation bar.
class Dock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const Dock({super.key, required this.index, required this.onTap});
  static const _items = [(Icons.edit_outlined, 'Write'), (Icons.tune, 'Design'), (Icons.grid_view_rounded, 'Pages'), (Icons.ios_share, 'Export')];

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(36), blurRadius: 22, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: i == index ? cs.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_items[i].$1, size: 22, color: i == index ? cs.primary : cs.onSurfaceVariant),
                    const SizedBox(height: 2),
                    Text(_items[i].$2, style: TextStyle(fontSize: 11, fontWeight: i == index ? FontWeight.w700 : FontWeight.w500, color: i == index ? cs.primary : cs.onSurfaceVariant)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
