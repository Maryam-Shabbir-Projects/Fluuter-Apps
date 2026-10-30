import 'dart:io';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/catalog.dart';
import '../models/design.dart';
import '../models/element_model.dart';
import '../services/storage_service.dart';
import 'shapes.dart';

export 'shapes.dart';

/// Line height per font: Nastaliq scripts need a lot of vertical room.
double _lineHeight(String font) => switch (font) {
      'Noto Nastaliq Urdu' => 1.9,
      'Gulzar' => 1.8,
      'Mirza' => 1.5,
      'Aref Ruqaa' || 'Lateef' || 'Amiri' || 'Noto Naskh Arabic' || 'Rakkas' => 1.35,
      _ => 1.05,
    };

TextStyle ts(String font, double size, {Color? color, Paint? paint}) {
  try {
    return GoogleFonts.getFont(font, fontSize: size, height: _lineHeight(font), color: paint == null ? color : null, foreground: paint);
  } catch (_) {
    // font name unknown to the google_fonts package: fall back instead of crashing
    return TextStyle(fontSize: size, height: _lineHeight(font), color: paint == null ? color : null, foreground: paint);
  }
}

const _ring = [Offset(1, 0), Offset(-1, 0), Offset(0, 1), Offset(0, -1), Offset(.7, .7), Offset(-.7, .7), Offset(.7, -.7), Offset(-.7, -.7)];

Widget buildElement(El e) {
  switch (e.k) {
    case K.text:
      const a = TextAlign.center;
      final t = SizedBox(
        width: e.w,
        child: Stack(children: [
          if (e.outline)
            Text(e.text, textAlign: a,
                style: ts(e.font, e.size, paint: Paint()..style = PaintingStyle.stroke..strokeWidth = e.size * .14..strokeJoin = StrokeJoin.round..color = e.stroke)),
          Text(e.text, textAlign: a, style: ts(e.font, e.size, color: e.color)),
        ]),
      );
      if (e.bgFill == null) return t;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: e.size * .25, vertical: e.size * .1),
        decoration: BoxDecoration(color: e.bgFill, borderRadius: BorderRadius.circular(e.radius)),
        child: t,
      );
    case K.icon:
      final ic = Icon(iconMap[e.icon] ?? Icons.help_outline, size: e.size, color: e.color,
          shadows: e.outline ? [for (final o in _ring) Shadow(color: e.stroke, offset: o * (e.size * .035))] : null);
      if ((e.sy - 1).abs() < .001) return ic;
      return SizedBox(width: e.size, height: e.size * e.sy, child: FittedBox(fit: BoxFit.fill, child: ic));
    case K.shape:
      if (e.shape != 'rect') return CustomPaint(size: Size(e.w, e.h), painter: ShapePainter(e.shape, e.color));
      return Container(width: e.w, height: e.h, decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(e.radius)));
    case K.image:
      return ClipRRect(
        borderRadius: BorderRadius.circular(e.radius),
        child: e.path == null
            ? Container(width: e.w, height: e.h, color: Colors.blueGrey, child: Icon(Icons.person, size: e.h * .5, color: Colors.white70))
            : Image.file(File(StorageService.instance.media(e.path!)), width: e.w, height: e.h, fit: BoxFit.cover),
      );
  }
}


/// Size an element really occupies on the canvas (text is measured, the rest is known).
Size elSize(El e) {
  switch (e.k) {
    case K.icon:
      return Size(e.size, e.size * e.sy);
    case K.shape:
    case K.image:
      return Size(e.w, e.h);
    case K.text:
      final tp = TextPainter(text: TextSpan(text: e.text.isEmpty ? ' ' : e.text, style: ts(e.font, e.size)), textAlign: TextAlign.center, textDirection: TextDirection.ltr)
        ..layout(maxWidth: e.w);
      final h = tp.height;
      tp.dispose();
      if (e.bgFill == null) return Size(e.w, h);
      return Size(e.w + e.size * .5, h + e.size * .2);
  }
}

/// Which handles an element shows: (hx, hy) with -1/0/1 = left/none/right, top/none/bottom.
List<(int, int)> handlesFor(El e, {bool edges = true}) {
  final c = [(-1, -1), (1, -1), (-1, 1), (1, 1)];
  if (!edges) return c;
  if (e.k == K.text) return [...c, (-1, 0), (1, 0)];
  return [...c, (0, -1), (0, 1), (-1, 0), (1, 0)];
}

/// The design surface (doc.w x doc.h, 1280x720 by default). Interactive when callbacks are supplied.
///
/// One finger drags an item, two fingers pinch-resize and rotate it.
/// [viewScale] = on-screen width / doc.w, used to convert finger movement into canvas units.
class Stage extends StatelessWidget {
  final Doc doc;
  final int? selected;
  final double viewScale;
  final ValueChanged<int>? onTap;
  final ValueChanged<int>? onGestureStart;

  /// delta in canvas units; scale and rotation (radians) are cumulative since the gesture began.
  final void Function(int id, Offset delta, double scale, double rotation)? onGestureUpdate;
  final VoidCallback? onClear;

  /// Drag handles on the selected item. [delta] is in canvas units (not yet rotated into the item's frame).
  final void Function(int id, int hx, int hy)? onHandleStart;
  final void Function(int id, Offset delta)? onHandleUpdate;
  const Stage({super.key, required this.doc, this.selected, this.viewScale = 1, this.onTap, this.onGestureStart, this.onGestureUpdate, this.onClear, this.onHandleStart, this.onHandleUpdate});


  Widget _item(El e, double bw) {
    final sel = onHandleStart != null && e.id == selected;
    final hp = sel ? 18 / viewScale : 0.0; // handle zone, ~36 screen px wide
    final r = hp * .42; // visible handle radius
    final sz = sel ? elSize(e) : Size.zero;
    final showEdges = sel && (e.k == K.text ? sz.width * viewScale > 60 : (sz.width * viewScale > 60 && sz.height * viewScale > 60));
    Widget handle(int hx, int hy) => Align(
          alignment: Alignment(hx.toDouble(), hy.toDouble()),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (_) => onHandleStart!(e.id, hx, hy),
            onScaleUpdate: (u) => onHandleUpdate?.call(e.id, u.focalPointDelta / viewScale),
            child: SizedBox(
              width: hp * 2, height: hp * 2,
              child: Center(
                child: Container(
                  width: r * 2, height: r * 2,
                  decoration: BoxDecoration(color: Colors.white, shape: hx != 0 && hy != 0 ? BoxShape.circle : BoxShape.rectangle, borderRadius: hx != 0 && hy != 0 ? null : BorderRadius.circular(r * .5), border: Border.all(color: const Color(0xFF2F8BFF), width: r * .22)),
                ),
              ),
            ),
          ),
        );
    return Positioned(
      left: e.x - hp, top: e.y - hp,
      child: Transform.rotate(
        angle: e.rot * m.pi / 180,
        child: Stack(clipBehavior: Clip.none, children: [
          Opacity(
            opacity: e.opacity,
            child: Padding(
              padding: EdgeInsets.all(hp),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () => onTap!(e.id),
                onScaleStart: onGestureStart == null ? null : (_) => onGestureStart!(e.id),
                onScaleUpdate: onGestureUpdate == null ? null : (u) => onGestureUpdate!(e.id, u.focalPointDelta / viewScale, u.scale, u.rotation),
                child: Container(
                  foregroundDecoration: e.id == selected ? BoxDecoration(border: Border.all(color: const Color(0xFF2F8BFF), width: bw)) : null,
                  child: Transform.flip(flipX: e.flipX, flipY: e.flipY, child: buildElement(e)),
                ),
              ),
            ),
          ),
          if (sel)
            for (final h in handlesFor(e, edges: showEdges).reversed)
              Positioned.fill(child: handle(h.$1, h.$2)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bw = (3 / viewScale).clamp(3.0, 16.0);
    return GestureDetector(
      onTap: onClear,
      child: Container(
        width: doc.w, height: doc.h, clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: doc.bg.first,
          gradient: doc.bg.length > 1 ? LinearGradient(colors: doc.bg, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          image: doc.bgImg == null ? null : DecorationImage(image: FileImage(File(StorageService.instance.media(doc.bgImg!))), fit: BoxFit.cover),
        ),
        child: Stack(children: [
          if (doc.bgImg == null && doc.bgStyle != null) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: BgPatternPainter(doc.bgStyle!)))),
          for (final e in doc.els) _item(e, bw),
        ]),
      ),
    );
  }
}

/// Non-interactive thumbnail preview that scales the stage to its parent.
class StageView extends StatelessWidget {
  final Doc doc;
  final BoxFit fit;
  const StageView(this.doc, {super.key, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) => FittedBox(fit: fit, child: IgnorePointer(child: Stage(doc: doc)));
}
