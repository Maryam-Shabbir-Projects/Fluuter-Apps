import 'package:flutter/material.dart';

enum K { text, icon, shape, image }

int _seq = 0;
double _d(Object? v) => (v as num).toDouble();

/// One item placed on the 1280x720 canvas (text, icon, shape or photo).
class El {
  final int id;
  K k;
  double x, y, w, h, rot, size, radius, opacity;
  double sy; // icons only: vertical stretch (1 = square)
  String shape; // shapes only: rect, oval, triangle, diamond, star
  Color color, stroke;
  Color? bgFill; // text only: coloured box behind the text (null = none)
  String text, font;
  String? icon; // key in iconMap
  String? path; // file name inside the app media folder
  bool outline, flipX, flipY;

  El(this.k,
      {int? id,
      this.x = 0,
      this.y = 0,
      this.w = 300,
      this.h = 300,
      this.rot = 0,
      this.size = 100,
      this.radius = 0,
      this.opacity = 1,
      this.color = Colors.white,
      this.stroke = Colors.black,
      this.text = '',
      this.font = 'Anton',
      this.icon,
      this.path,
      this.outline = true,
      this.flipX = false,
      this.flipY = false,
      this.sy = 1,
      this.shape = 'rect',
      this.bgFill})
      : id = id ?? ++_seq;

  El copy({bool fresh = false}) => El(k,
      id: fresh ? null : id,
      x: fresh ? x + 30 : x,
      y: fresh ? y + 30 : y,
      w: w, h: h, rot: rot, size: size, radius: radius, opacity: opacity,
      color: color, stroke: stroke, text: text, font: font,
      icon: icon, path: path, outline: outline, flipX: flipX, flipY: flipY, sy: sy, shape: shape, bgFill: bgFill);

  // ignore_for_file: deprecated_member_use
  Map<String, dynamic> toJson() => {
        'k': k.name, 'x': x, 'y': y, 'w': w, 'h': h, 'rot': rot, 'size': size,
        'r': radius, 'o': opacity, 'c': color.value, 's': stroke.value,
        'text': text, 'font': font, 'icon': icon, 'path': path, 'ol': outline,
        'fx': flipX, 'fy': flipY, 'bf': bgFill?.value, 'sy': sy, 'sh': shape,
      };

  factory El.fromJson(Map<String, dynamic> j) => El(K.values.byName(j['k'] as String),
      x: _d(j['x']), y: _d(j['y']), w: _d(j['w']), h: _d(j['h']), rot: _d(j['rot']),
      size: _d(j['size']), radius: _d(j['r']), opacity: _d(j['o']),
      color: Color(j['c'] as int), stroke: Color(j['s'] as int),
      text: j['text'] as String? ?? '', font: j['font'] as String? ?? 'Anton',
      icon: j['icon'] as String?, path: j['path'] as String?, outline: j['ol'] as bool? ?? true,
      flipX: j['fx'] as bool? ?? false, flipY: j['fy'] as bool? ?? false,
      sy: j['sy'] == null ? 1 : _d(j['sy']), shape: j['sh'] as String? ?? 'rect',
      bgFill: j['bf'] == null ? null : Color(j['bf'] as int));
}
