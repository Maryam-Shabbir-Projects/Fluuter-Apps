import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StarEmblem extends StatelessWidget {
  final double size;
  const StarEmblem({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _StarPainter());
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final c = size.center(Offset.zero);
    final rect = Rect.fromCenter(center: c, width: size.width * .6, height: size.width * .6);
    canvas.drawRect(rect, paint);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();
    canvas.drawCircle(c, size.width * .15, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
