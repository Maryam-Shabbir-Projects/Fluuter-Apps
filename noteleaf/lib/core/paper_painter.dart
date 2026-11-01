import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'constants.dart';

/// Draws a paper (gradient + optional pattern, or a custom image) filling [s].
/// [dir] for linear gradients: 0 top to bottom, 1 diagonal, 2 left to right.
void paintPaper(Canvas c, Size s, Paper p, {ui.Image? image, int dir = 1}) {
  final r = Offset.zero & s;
  if (image != null) {
    paintImage(canvas: c, rect: r, image: image, fit: BoxFit.cover);
    return;
  }
  final from = dir == 0 ? r.topCenter : (dir == 2 ? r.centerLeft : r.topLeft);
  final to = dir == 0 ? r.bottomCenter : (dir == 2 ? r.centerRight : r.bottomRight);
  c.drawRect(
    r,
    Paint()..shader = p.radial ? ui.Gradient.radial(r.center, s.longestSide * 0.7, p.bg) : ui.Gradient.linear(from, to, p.bg),
  );
  final u = s.shortestSide / 16;
  final w = (s.shortestSide / 540).clamp(1.0, 3.0);
  final line = Paint()
    ..color = p.fg.withAlpha(45)
    ..strokeWidth = w
    ..style = PaintingStyle.stroke;
  switch (p.pat) {
    case PaperPattern.lines:
      for (var y = u * 2; y < s.height; y += u) {
        c.drawLine(Offset(0, y), Offset(s.width, y), line);
      }
    case PaperPattern.grid:
      for (var y = u; y < s.height; y += u) {
        c.drawLine(Offset(0, y), Offset(s.width, y), line);
      }
      for (var x = u; x < s.width; x += u) {
        c.drawLine(Offset(x, 0), Offset(x, s.height), line);
      }
    case PaperPattern.dots:
      final dot = Paint()..color = p.fg.withAlpha(70);
      for (var y = u; y < s.height; y += u) {
        for (var x = u; x < s.width; x += u) {
          c.drawCircle(Offset(x, y), w * 1.3, dot);
        }
      }
    case PaperPattern.frame:
      final f = Paint()
        ..color = p.fg.withAlpha(110)
        ..strokeWidth = w * 1.5
        ..style = PaintingStyle.stroke;
      c.drawRect(r.deflate(u * 0.45), f);
      c.drawRect(r.deflate(u * 0.7), line);
    case PaperPattern.none:
      break;
  }
}
