import 'dart:math' as m;

import 'package:flutter/material.dart';

/// Plain shapes (the "Shapes" tab). 'rect' is drawn with a Container, the rest with [ShapePainter].
const shapeKinds = <String, String>{
  'rect': 'Rectangle',
  'oval': 'Circle / oval',
  'triangle': 'Triangle',
  'diamond': 'Diamond',
  'star': 'Star',
  'star4': 'Sparkle',
  'burst': 'Burst',
  'heart': 'Heart',
  'pentagon': 'Pentagon',
  'hexagon': 'Hexagon',
  'octagon': 'Octagon',
  'cross': 'Plus',
  'arrow_right': 'Arrow right',
  'arrow_left': 'Arrow left',
  'arrow_up': 'Arrow up',
  'arrow_down': 'Arrow down',
  'chevron': 'Chevron',
  'bubble': 'Speech bubble',
  'cloud': 'Cloud',
  'bolt': 'Lightning',
  'moon': 'Moon',
  'drop': 'Drop',
  'ring': 'Ring',
  'parallelogram': 'Slant',
  'trapezoid': 'Trapezoid',
  'half': 'Half circle',
  'banner': 'Ribbon',
  'badge': 'Badge',
};

/// Default (width, height) when a shape is added to the canvas.
const shapeSizes = <String, (double, double)>{
  'arrow_right': (520, 300),
  'arrow_left': (520, 300),
  'chevron': (420, 360),
  'bubble': (520, 380),
  'cloud': (520, 340),
  'parallelogram': (520, 240),
  'trapezoid': (520, 260),
  'half': (520, 260),
  'banner': (560, 220),
  'badge': (440, 440),
};

/// Computer-drawn expression faces (the "Images" tab). Colour = face colour.
const faceKinds = <String, String>{
  'face_happy': 'Happy',
  'face_laugh': 'Laughing',
  'face_wink': 'Wink',
  'face_love': 'In love',
  'face_cool': 'Cool',
  'face_shock': 'Shocked',
  'face_scream': 'Screaming',
  'face_angry': 'Angry',
  'face_sad': 'Sad',
  'face_cry': 'Crying',
  'face_sleepy': 'Sleepy',
  'face_tongue': 'Silly',
  'face_think': 'Thinking',
  'face_devil': 'Devil',
};

/// Face colour each expression starts with.
const faceColors = <String, Color>{
  'face_angry': Color(0xFFE53935),
  'face_scream': Color(0xFF64B5F6),
  'face_sleepy': Color(0xFF90CAF9),
  'face_devil': Color(0xFF9C27B0),
};
const faceDefault = Color(0xFFFFD43B);

bool isFace(String kind) => kind.startsWith('face_');

class ShapePainter extends CustomPainter {
  final String kind;
  final Color color;
  const ShapePainter(this.kind, this.color);

  static Path _poly(double w, double h, List<Offset> pts) {
    final p = Path();
    for (var i = 0; i < pts.length; i++) {
      final o = Offset(pts[i].dx * w, pts[i].dy * h);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  static Path _regular(double w, double h, int n, {double start = -m.pi / 2}) {
    final p = Path();
    for (var i = 0; i < n; i++) {
      final a = start + i * 2 * m.pi / n;
      final o = Offset(w / 2 + w / 2 * m.cos(a), h / 2 + h / 2 * m.sin(a));
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  static Path _starPath(double w, double h, int points, double inner) {
    final p = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? .5 : inner;
      final a = -m.pi / 2 + i * m.pi / points;
      final o = Offset(w / 2 + w * r * m.cos(a), h / 2 + h * r * m.sin(a));
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  /// Path for a plain shape inside a w x h box (null = not a plain shape).
  static Path? pathFor(String kind, double w, double h) {
    switch (kind) {
      case 'oval': {
        return Path()..addOval(Offset.zero & Size(w, h));
      }
      case 'triangle': {
        return _poly(w, h, const [Offset(.5, 0), Offset(1, 1), Offset(0, 1)]);
      }
      case 'diamond': {
        return _poly(w, h, const [Offset(.5, 0), Offset(1, .5), Offset(.5, 1), Offset(0, .5)]);
      }
      case 'star': {
        return _starPath(w, h, 5, .21);
      }
      case 'star4': {
        return _starPath(w, h, 4, .14);
      }
      case 'burst': {
        return _starPath(w, h, 14, .38);
      }
      case 'badge': {
        return _starPath(w, h, 20, .45);
      }
      case 'pentagon': {
        return _regular(w, h, 5);
      }
      case 'hexagon': {
        return _regular(w, h, 6, start: 0);
      }
      case 'octagon': {
        return _regular(w, h, 8, start: -m.pi / 8);
      }
      case 'heart': {
        final p = Path()..moveTo(w / 2, h * .95);
        p.cubicTo(-w * .15, h * .55, w * .05, -h * .1, w / 2, h * .28);
        p.cubicTo(w * .95, -h * .1, w * 1.15, h * .55, w / 2, h * .95);
        return p..close();
      }
      case 'cross': {
        return _poly(w, h, const [
          Offset(.35, 0), Offset(.65, 0), Offset(.65, .35), Offset(1, .35), Offset(1, .65), Offset(.65, .65),
          Offset(.65, 1), Offset(.35, 1), Offset(.35, .65), Offset(0, .65), Offset(0, .35), Offset(.35, .35),
        ]);
      }
      case 'arrow_right': {
        return _poly(w, h, const [Offset(0, .3), Offset(.58, .3), Offset(.58, 0), Offset(1, .5), Offset(.58, 1), Offset(.58, .7), Offset(0, .7)]);
      }
      case 'arrow_left': {
        return _poly(w, h, const [Offset(1, .3), Offset(.42, .3), Offset(.42, 0), Offset(0, .5), Offset(.42, 1), Offset(.42, .7), Offset(1, .7)]);
      }
      case 'arrow_up': {
        return _poly(w, h, const [Offset(.3, 1), Offset(.3, .42), Offset(0, .42), Offset(.5, 0), Offset(1, .42), Offset(.7, .42), Offset(.7, 1)]);
      }
      case 'arrow_down': {
        return _poly(w, h, const [Offset(.3, 0), Offset(.3, .58), Offset(0, .58), Offset(.5, 1), Offset(1, .58), Offset(.7, .58), Offset(.7, 0)]);
      }
      case 'chevron': {
        return _poly(w, h, const [Offset(0, 0), Offset(.55, 0), Offset(1, .5), Offset(.55, 1), Offset(0, 1), Offset(.45, .5)]);
      }
      case 'parallelogram': {
        return _poly(w, h, const [Offset(.22, 0), Offset(1, 0), Offset(.78, 1), Offset(0, 1)]);
      }
      case 'trapezoid': {
        return _poly(w, h, const [Offset(.2, 0), Offset(.8, 0), Offset(1, 1), Offset(0, 1)]);
      }
      case 'half': {
        return Path()
          ..moveTo(0, h)
          ..arcTo(Rect.fromLTWH(0, 0, w, h * 2), m.pi, m.pi, false)
          ..close();
      }
      case 'bubble': {
        final bodyH = h * .78;
        final p = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, bodyH), Radius.circular(bodyH * .3)));
        final tail = Path()
          ..moveTo(w * .22, bodyH - 2)
          ..lineTo(w * .14, h)
          ..lineTo(w * .46, bodyH - 2)
          ..close();
        return Path.combine(PathOperation.union, p, tail);
      }
      case 'cloud': {
        final p = Path();
        p.addOval(Rect.fromLTWH(w * .02, h * .38, w * .36, h * .56));
        p.addOval(Rect.fromLTWH(w * .62, h * .38, w * .36, h * .56));
        p.addOval(Rect.fromLTWH(w * .2, h * .08, w * .4, h * .62));
        p.addOval(Rect.fromLTWH(w * .4, h * .2, w * .36, h * .55));
        p.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .15, h * .52, w * .7, h * .42), Radius.circular(h * .2)));
        return p;
      }
      case 'bolt': {
        return _poly(w, h, const [Offset(.58, 0), Offset(.12, .56), Offset(.46, .56), Offset(.34, 1), Offset(.88, .4), Offset(.54, .4)]);
      }
      case 'moon': {
        final outer = Path()..addOval(Offset.zero & Size(w, h));
        final cut = Path()..addOval(Rect.fromLTWH(w * .3, -h * .08, w * .85, h * 1.0));
        return Path.combine(PathOperation.difference, outer, cut);
      }
      case 'drop': {
        final p = Path()..moveTo(w / 2, 0);
        p.cubicTo(w * .95, h * .45, w * 1.0, h * .62, w * .88, h * .78);
        p.arcToPoint(Offset(w * .12, h * .78), radius: Radius.elliptical(w * .5, h * .27), clockwise: true);
        p.cubicTo(0, h * .62, w * .05, h * .45, w / 2, 0);
        return p..close();
      }
      case 'ring': {
        return Path()
          ..fillType = PathFillType.evenOdd
          ..addOval(Offset.zero & Size(w, h))
          ..addOval(Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64));
      }
      case 'banner': {
        return _poly(w, h, const [Offset(0, .1), Offset(.14, .1), Offset(.14, 0), Offset(.86, 0), Offset(.86, .1), Offset(1, .1), Offset(.92, .5), Offset(1, .9), Offset(.86, .9), Offset(.86, 1), Offset(.14, 1), Offset(.14, .9), Offset(0, .9), Offset(.08, .5)]);
      }
    }
    return null;
  }

  @override
  void paint(Canvas c, Size s) {
    if (isFace(kind)) {
      _paintFace(c, s, kind, color);
      return;
    }
    final p = Paint()..color = color..isAntiAlias = true;
    final path = pathFor(kind, s.width, s.height);
    if (path == null) {
      c.drawRect(Offset.zero & s, p);
    } else {
      c.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(ShapePainter o) => o.kind != kind || o.color != color;
}

// ---------------------------------------------------------------------------
// Expression faces
// ---------------------------------------------------------------------------

const _ink = Color(0xFF2B2B2B);

void _paintFace(Canvas c, Size s, String kind, Color base) {
  final w = s.width, h = s.height, u = m.min(w, h);
  Offset o(double x, double y) => Offset(w * x, h * y);
  final hsl = HSLColor.fromColor(base);
  final rim = hsl.withLightness((hsl.lightness * .62).clamp(0.0, 1.0)).toColor();
  final fill = Paint()..color = base..isAntiAlias = true;
  final ink = Paint()..color = _ink..isAntiAlias = true;
  Paint line(double k, {Color? col}) => Paint()
    ..color = col ?? _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = u * k
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;
  final white = Paint()..color = Colors.white..isAntiAlias = true;

  // head with a darker rim and a soft highlight
  final head = Rect.fromLTWH(u * .02, u * .02, w - u * .04, h - u * .04);
  c.drawOval(head, fill);
  c.drawOval(head.deflate(u * .015), Paint()..color = rim..style = PaintingStyle.stroke..strokeWidth = u * .03..isAntiAlias = true);
  c.drawOval(Rect.fromLTWH(w * .2, h * .08, w * .35, h * .16), Paint()..color = Colors.white.withOpacity(.22)..isAntiAlias = true);

  void eyeDot(double x, double y, {double r = .055}) => c.drawOval(Rect.fromCenter(center: o(x, y), width: u * r * 2, height: u * r * 2.5), ink);
  void bigEye(double x, double y, {double r = .1, double pupil = .045}) {
    c.drawOval(Rect.fromCenter(center: o(x, y), width: u * r * 2, height: u * r * 2.3), white);
    c.drawOval(Rect.fromCenter(center: o(x, y), width: u * r * 2, height: u * r * 2.3), line(.012));
    c.drawCircle(o(x, y), u * pupil, ink);
  }
  void arcEye(double x, double y, {bool up = true}) {
    final r = Rect.fromCenter(center: o(x, y), width: u * .17, height: u * .12);
    c.drawArc(r, up ? m.pi : 0, m.pi, false, line(.03));
  }
  void smile(double cx, double cy, double wd, double ht, {bool frown = false}) {
    final r = Rect.fromCenter(center: o(cx, cy), width: u * wd, height: u * ht * 2);
    c.drawArc(r, frown ? m.pi : 0, m.pi, false, line(.035));
  }
  void brow(Offset a, Offset b) => c.drawLine(a, b, line(.04));
  void tear(double x, double y) {
    final p = Path()..moveTo(w * x, h * y);
    p.cubicTo(w * (x + .05), h * (y + .08), w * (x + .05), h * (y + .13), w * x, h * (y + .13));
    p.cubicTo(w * (x - .05), h * (y + .13), w * (x - .05), h * (y + .08), w * x, h * y);
    c.drawPath(p, Paint()..color = const Color(0xFF4FC3F7)..isAntiAlias = true);
  }
  void heart(Offset ctr, double sz, Color col) {
    final p = Path()..moveTo(ctr.dx, ctr.dy + sz * .45);
    p.cubicTo(ctr.dx - sz * .75, ctr.dy - sz * .05, ctr.dx - sz * .25, ctr.dy - sz * .6, ctr.dx, ctr.dy - sz * .2);
    p.cubicTo(ctr.dx + sz * .25, ctr.dy - sz * .6, ctr.dx + sz * .75, ctr.dy - sz * .05, ctr.dx, ctr.dy + sz * .45);
    c.drawPath(p..close(), Paint()..color = col..isAntiAlias = true);
  }

  switch (kind) {
    case 'face_happy': {
      eyeDot(.34, .38);
      eyeDot(.66, .38);
      smile(.5, .58, .46, .17);
    }
    case 'face_laugh': {
      arcEye(.33, .38);
      arcEye(.67, .38);
      final mouth = Path()..moveTo(w * .22, h * .55)..quadraticBezierTo(w * .5, h * .55, w * .78, h * .55)..quadraticBezierTo(w * .72, h * .88, w * .5, h * .88)..quadraticBezierTo(w * .28, h * .88, w * .22, h * .55);
      c.drawPath(mouth, ink);
      c.drawPath(Path()..moveTo(w * .26, h * .56)..lineTo(w * .74, h * .56)..lineTo(w * .72, h * .63)..lineTo(w * .28, h * .63)..close(), white);
      c.drawOval(Rect.fromCenter(center: o(.5, .8), width: u * .26, height: u * .12), Paint()..color = const Color(0xFFEF5350));
      tear(.14, .46);
      tear(.86, .46);
    }
    case 'face_wink': {
      eyeDot(.34, .38);
      arcEye(.66, .4);
      smile(.5, .58, .46, .17);
    }
    case 'face_love': {
      heart(o(.32, .38), u * .22, const Color(0xFFE91E63));
      heart(o(.68, .38), u * .22, const Color(0xFFE91E63));
      smile(.5, .6, .4, .15);
    }
    case 'face_cool': {
      final glass = Path()
        ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .12, h * .3, w * .34, h * .22), Radius.circular(u * .07)))
        ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .54, h * .3, w * .34, h * .22), Radius.circular(u * .07)));
      c.drawPath(glass, Paint()..color = const Color(0xFF111111));
      c.drawLine(o(.46, .35), o(.54, .35), line(.03));
      c.drawLine(o(.16, .34), o(.26, .34), line(.015, col: Colors.white70));
      c.drawLine(o(.58, .34), o(.68, .34), line(.015, col: Colors.white70));
      smile(.5, .62, .42, .13);
    }
    case 'face_shock': {
      bigEye(.33, .38, r: .1, pupil: .035);
      bigEye(.67, .38, r: .1, pupil: .035);
      brow(o(.22, .2), o(.42, .18));
      brow(o(.58, .18), o(.78, .2));
      c.drawOval(Rect.fromCenter(center: o(.5, .72), width: u * .17, height: u * .24), ink);
    }
    case 'face_scream': {
      bigEye(.32, .36, r: .11, pupil: .03);
      bigEye(.68, .36, r: .11, pupil: .03);
      brow(o(.2, .17), o(.42, .13));
      brow(o(.58, .13), o(.8, .17));
      final mouth = Path()..moveTo(w * .28, h * .6)..quadraticBezierTo(w * .5, h * .5, w * .72, h * .6)..quadraticBezierTo(w * .7, h * .92, w * .5, h * .92)..quadraticBezierTo(w * .3, h * .92, w * .28, h * .6);
      c.drawPath(mouth, ink);
      c.drawOval(Rect.fromCenter(center: o(.5, .84), width: u * .22, height: u * .1), Paint()..color = const Color(0xFFEF5350));
      c.drawRect(Rect.fromLTWH(w * .36, h * .56, w * .28, h * .05), white);
    }
    case 'face_angry': {
      eyeDot(.34, .42, r: .05);
      eyeDot(.66, .42, r: .05);
      brow(o(.2, .26), o(.42, .36));
      brow(o(.8, .26), o(.58, .36));
      smile(.5, .74, .4, .11, frown: true);
    }
    case 'face_sad': {
      eyeDot(.34, .42);
      eyeDot(.66, .42);
      brow(o(.22, .3), o(.42, .24));
      brow(o(.78, .3), o(.58, .24));
      smile(.5, .74, .36, .1, frown: true);
    }
    case 'face_cry': {
      eyeDot(.34, .4);
      eyeDot(.66, .4);
      brow(o(.22, .28), o(.42, .22));
      brow(o(.78, .28), o(.58, .22));
      tear(.3, .5);
      tear(.7, .5);
      smile(.5, .76, .34, .1, frown: true);
    }
    case 'face_sleepy': {
      c.drawArc(Rect.fromCenter(center: o(.33, .4), width: u * .17, height: u * .12), 0, m.pi, false, line(.03));
      c.drawArc(Rect.fromCenter(center: o(.67, .4), width: u * .17, height: u * .12), 0, m.pi, false, line(.03));
      c.drawOval(Rect.fromCenter(center: o(.5, .7), width: u * .12, height: u * .1), ink);
      final tp = TextPainter(text: TextSpan(text: 'Z', style: TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: u * .2)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(w * .74, h * .02));
    }
    case 'face_tongue': {
      eyeDot(.34, .36);
      c.drawCircle(o(.68, .36), u * .09, white);
      c.drawCircle(o(.68, .36), u * .09, line(.012));
      c.drawCircle(o(.7, .37), u * .035, ink);
      smile(.5, .56, .5, .16);
      final t = RRect.fromRectAndRadius(Rect.fromLTWH(w * .43, h * .6, w * .17, h * .26), Radius.circular(u * .08));
      c.drawRRect(t, Paint()..color = const Color(0xFFEF5350));
      c.drawLine(o(.515, .64), o(.515, .74), line(.01, col: const Color(0xFFB71C1C)));
    }
    case 'face_think': {
      eyeDot(.34, .4);
      bigEye(.67, .38, r: .08, pupil: .03);
      brow(o(.58, .22), o(.78, .17));
      c.drawLine(o(.38, .68), o(.64, .64), line(.035));
      c.drawCircle(o(.82, .12), u * .03, ink);
    }
    case 'face_devil': {
      final horn = Paint()..color = rim..isAntiAlias = true;
      c.drawPath(Path()..moveTo(w * .18, h * .16)..lineTo(w * .1, h * -.02)..lineTo(w * .36, h * .07)..close(), horn);
      c.drawPath(Path()..moveTo(w * .82, h * .16)..lineTo(w * .9, h * -.02)..lineTo(w * .64, h * .07)..close(), horn);
      eyeDot(.34, .42, r: .05);
      eyeDot(.66, .42, r: .05);
      brow(o(.2, .28), o(.42, .36));
      brow(o(.8, .28), o(.58, .36));
      final grin = Path()..moveTo(w * .26, h * .6)..quadraticBezierTo(w * .5, h * .9, w * .74, h * .6)..quadraticBezierTo(w * .5, h * .68, w * .26, h * .6);
      c.drawPath(grin, ink);
    }
  }
}

// ---------------------------------------------------------------------------
// Background patterns (drawn over the background colours)
// ---------------------------------------------------------------------------

/// Pattern names used by BgTheme.pattern / Doc.bgStyle. All sizes are relative to the height
/// so a small preview looks like the full canvas.
class BgPatternPainter extends CustomPainter {
  final String style;
  const BgPatternPainter(this.style);

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height, u = h / 720; // 1u = one pixel on the 1280x720 canvas
    final r = m.Random(11);
    final soft = Paint()..color = Colors.white.withOpacity(.14)..isAntiAlias = true;
    switch (style) {
      case 'stars': {
        for (var i = 0; i < 160; i++) {
          final big = r.nextDouble() > .93;
          final p = Paint()..color = Colors.white.withOpacity(.35 + r.nextDouble() * .6);
          c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h), (big ? 3.4 : 1.4 + r.nextDouble() * 1.2) * u, p);
        }
      }
      case 'grid': {
        final p = Paint()..color = Colors.white.withOpacity(.16)..strokeWidth = 2 * u;
        for (var x = 0.0; x <= w; x += 80 * u) {
          c.drawLine(Offset(x, 0), Offset(x, h), p);
        }
        for (var y = 0.0; y <= h; y += 80 * u) {
          c.drawLine(Offset(0, y), Offset(w, y), p);
        }
      }
      case 'dots': {
        for (var y = 0.0, row = 0; y < h + 40 * u; y += 36 * u, row++) {
          for (var x = (row.isEven ? 0.0 : 18 * u); x < w + 40 * u; x += 36 * u) {
            c.drawCircle(Offset(x, y), 6 * u, soft);
          }
        }
      }
      case 'rays': {
        final ctr = Offset(w / 2, h / 2);
        const n = 24;
        for (var i = 0; i < n; i += 2) {
          final a0 = i * 2 * m.pi / n, a1 = (i + 1) * 2 * m.pi / n;
          final big = (w + h) * 2;
          c.drawPath(
            Path()..moveTo(ctr.dx, ctr.dy)..lineTo(ctr.dx + big * m.cos(a0), ctr.dy + big * m.sin(a0))..lineTo(ctr.dx + big * m.cos(a1), ctr.dy + big * m.sin(a1))..close(),
            soft,
          );
        }
      }
      case 'waves': {
        final p = Paint()..color = Colors.white.withOpacity(.18)..style = PaintingStyle.stroke..strokeWidth = 5 * u;
        for (var row = 0; row < 9; row++) {
          final y0 = h * (.12 + row * .11);
          final path = Path()..moveTo(0, y0);
          for (var x = 0.0; x <= w; x += 8 * u) {
            path.lineTo(x, y0 + m.sin(x / (70 * u) + row) * 16 * u);
          }
          c.drawPath(path, p);
        }
      }
      case 'clouds': {
        for (var i = 0; i < 7; i++) {
          final cx = r.nextDouble() * w, cy = h * (.1 + r.nextDouble() * .75), k = (70 + r.nextDouble() * 80) * u;
          for (final d in const [Offset(-.8, .2), Offset(0, -.3), Offset(.8, .2), Offset(0, .3)]) {
            c.drawCircle(Offset(cx + d.dx * k, cy + d.dy * k), k * .75, Paint()..color = Colors.white.withOpacity(.2));
          }
        }
      }
      case 'leaves': {
        for (var i = 0; i < 40; i++) {
          c.save();
          c.translate(r.nextDouble() * w, r.nextDouble() * h);
          c.rotate(r.nextDouble() * m.pi);
          c.drawOval(Rect.fromCenter(center: Offset.zero, width: (50 + r.nextDouble() * 50) * u, height: 22 * u), Paint()..color = Colors.white.withOpacity(.1 + r.nextDouble() * .1));
          c.restore();
        }
      }
      case 'bokeh': {
        for (var i = 0; i < 26; i++) {
          final rad = (20 + r.nextDouble() * 80) * u;
          final col = [Colors.white, const Color(0xFFFF6BCB), const Color(0xFF6BE3FF), const Color(0xFFFFE66B)][r.nextInt(4)];
          c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h), rad, Paint()..color = col.withOpacity(.10 + r.nextDouble() * .16));
        }
      }
      case 'confetti': {
        const cols = [Color(0xFFFFE600), Color(0xFFFF2D4F), Color(0xFF00F5D4), Colors.white, Color(0xFF7B2FF7)];
        for (var i = 0; i < 90; i++) {
          c.save();
          c.translate(r.nextDouble() * w, r.nextDouble() * h);
          c.rotate(r.nextDouble() * m.pi);
          c.drawRect(Rect.fromCenter(center: Offset.zero, width: 24 * u, height: 10 * u), Paint()..color = cols[r.nextInt(cols.length)].withOpacity(.55));
          c.restore();
        }
      }
      case 'stripes': {
        final p = Paint()..color = Colors.white.withOpacity(.1);
        for (var x = -h; x < w + h; x += 120 * u) {
          c.drawPath(Path()..moveTo(x, h)..lineTo(x + 60 * u, h)..lineTo(x + 60 * u + h, 0)..lineTo(x + h, 0)..close(), p);
        }
      }
      case 'islamic': {
        // repeating 8-point star tile
        final p = Paint()..color = Colors.white.withOpacity(.16)..style = PaintingStyle.stroke..strokeWidth = 2.2 * u;
        final cell = 120 * u;
        for (var y = 0.0; y < h + cell; y += cell) {
          for (var x = 0.0; x < w + cell; x += cell) {
            final ctr = Offset(x + cell / 2, y + cell / 2);
            final path = Path();
            for (var i = 0; i < 16; i++) {
              final rad = (i.isEven ? .46 : .27) * cell;
              final a = i * m.pi / 8 - m.pi / 2;
              final pt = Offset(ctr.dx + rad * m.cos(a), ctr.dy + rad * m.sin(a));
              i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
            }
            c.drawPath(path..close(), p);
            c.drawCircle(ctr, cell * .08, p);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(BgPatternPainter o) => o.style != style;
}

/// Gradient / pattern preview tile used in the Background tab.
BoxDecoration bgDecoration(List<Color> colors) => BoxDecoration(
      color: colors.first,
      gradient: colors.length > 1 ? LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
    );

class BgPreview extends StatelessWidget {
  final List<Color> colors;
  final String? pattern;
  const BgPreview(this.colors, this.pattern, {super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: bgDecoration(colors),
        child: pattern == null ? const SizedBox.expand() : SizedBox.expand(child: CustomPaint(painter: BgPatternPainter(pattern!))),
      );
}
