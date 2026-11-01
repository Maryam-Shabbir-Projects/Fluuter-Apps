import 'package:flutter/material.dart';
import '../models/doc.dart';

/// Live preview of page [i], drawn with the same code that exports it.
class PagePreview extends StatelessWidget {
  final Doc d;
  final int i;
  const PagePreview(this.d, this.i, {super.key});
  @override
  Widget build(BuildContext c) => AspectRatio(
        aspectRatio: d.px.width / d.px.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LayoutBuilder(builder: (_, k) => CustomPaint(painter: PagePainter(d, i, k.maxWidth / d.px.width), size: Size.infinite)),
        ),
      );
}

/// Preview where tapping or dragging reports a position (as fractions of the page).
class PlaceablePreview extends StatelessWidget {
  final Doc d;
  final void Function(double x, double y) onMove;
  const PlaceablePreview(this.d, this.onMove, {super.key});
  @override
  Widget build(BuildContext c) => AspectRatio(
        aspectRatio: d.px.width / d.px.height,
        child: LayoutBuilder(builder: (_, k) {
          void go(Offset p) => onMove((p.dx / k.maxWidth).clamp(0.0, 1.0), (p.dy / k.maxHeight).clamp(0.0, 1.0));
          return GestureDetector(
            onTapDown: (e) => go(e.localPosition),
            onPanStart: (e) => go(e.localPosition),
            onPanUpdate: (e) => go(e.localPosition),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(c).colorScheme.primary, width: 2)),
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: CustomPaint(painter: PagePainter(d, 0, k.maxWidth / d.px.width), size: Size.infinite)),
            ),
          );
        }),
      );
}

class PagePainter extends CustomPainter {
  final Doc d;
  final int i;
  final double s;
  PagePainter(this.d, this.i, this.s);
  @override
  void paint(Canvas c, Size size) {
    c.clipRect(Offset.zero & size);
    c.scale(s);
    if (i < d.pages.length) d.paintPage(c, i);
  }

  @override
  bool shouldRepaint(_) => true;
}

/// Paper (and, with [brand], the faded text and logo) in page coordinates. Used behind and above the page editor.
class LayerPainter extends CustomPainter {
  final Doc d;
  final bool brand;
  LayerPainter(this.d, this.brand);
  @override
  void paint(Canvas c, Size size) => brand ? d.paintBrand(c) : d.paintPaperOnly(c);
  @override
  bool shouldRepaint(_) => true;
}
