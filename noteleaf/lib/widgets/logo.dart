import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// The NoteLeaf mark: a note page with a leaf. Same artwork as the launcher icon.
class LeafLogo extends StatelessWidget {
  final double size;
  const LeafLogo({super.key, this.size = 48});
  @override
  Widget build(BuildContext c) => CustomPaint(size: Size(size, size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(w * 0.24)),
      Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(w, h), const [Color(0xFF12948A), Color(0xFF0A5C56)]),
    );
    c.drawRRect(RRect.fromLTRBR(w * .24, h * .18, w * .70, h * .80, Radius.circular(w * .06)), Paint()..color = Colors.white);
    final lp = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = w * .035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = h * (.34 + i * .12);
      c.drawLine(Offset(w * .31, y), Offset(w * (i == 2 ? .50 : .63), y), lp);
    }
    final leaf = Path()
      ..moveTo(w * .58, h * .86)
      ..quadraticBezierTo(w * .58, h * .52, w * .86, h * .46)
      ..quadraticBezierTo(w * .90, h * .80, w * .58, h * .86)
      ..close();
    c.drawPath(leaf, Paint()..color = const Color(0xFFF5A524));
    c.drawLine(Offset(w * .60, h * .84), Offset(w * .80, h * .55),
        Paint()..color = Colors.white.withAlpha(190)..strokeWidth = w * .02..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_) => false;
}
