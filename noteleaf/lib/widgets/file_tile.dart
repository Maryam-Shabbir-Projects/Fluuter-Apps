import 'dart:math';
import 'package:flutter/material.dart';
import '../models/doc.dart';
import 'page_preview.dart';

/// A file in a list: small page thumbnail and the name only.
class FileTile extends StatelessWidget {
  final Doc d;
  final VoidCallback onOpen, onRename, onMove, onDelete;
  const FileTile({super.key, required this.d, required this.onOpen, required this.onRename, required this.onMove, required this.onDelete});

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final w = d.px.width, h = d.px.height, s = min(64 / w, 46 / h);
    PopupMenuItem<String> item(String v, IconData ic, String t, {Color? color}) =>
        PopupMenuItem(value: v, child: Row(children: [Icon(ic, size: 20, color: color), const SizedBox(width: 12), Text(t, style: TextStyle(color: color))]));
    return Container(
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 14, offset: const Offset(0, 4))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(children: [
            SizedBox(
              width: 64,
              height: 46,
              child: Center(
                child: ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: w * s, height: h * s, child: CustomPaint(painter: PagePainter(d, 0, s)))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'rename' ? onRename() : (v == 'move' ? onMove() : onDelete()),
              itemBuilder: (_) => [
                item('rename', Icons.edit_outlined, 'Rename'),
                item('move', Icons.drive_file_move_outline, 'Move to folder'),
                item('del', Icons.delete_outline, 'Delete', color: Colors.red),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
