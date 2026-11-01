import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/paper_painter.dart';

/// Small real preview of a paper design.
class PaperSwatch extends StatelessWidget {
  final Paper p;
  final bool selected;
  const PaperSwatch(this.p, this.selected, {super.key});

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: selected ? 3 : 1, color: selected ? cs.primary : cs.outlineVariant),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(9), child: CustomPaint(painter: _SwatchPainter(p))),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  final Paper p;
  _SwatchPainter(this.p);
  @override
  void paint(Canvas c, Size s) {
    paintPaper(c, s, p);
    final tp = TextPainter(
        text: TextSpan(text: 'Aa', style: TextStyle(color: p.fg, fontSize: s.width * 0.34, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(c, Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}
