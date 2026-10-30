import 'package:flutter/material.dart';

import 'element_model.dart';

/// Canvas content: elements + background (1 colour = solid, 2+ = gradient).
class Doc {
  List<El> els;
  List<Color> bg;
  String? bgImg; // file name inside the app media folder
  String? bgStyle; // themed pattern drawn over the colours (stars, grid, rays ...), null = none
  double w, h; // frame size in canvas units (default 1280x720)

  Doc(this.els, [this.bg = const [Colors.white], this.bgImg, this.bgStyle, this.w = 1280, this.h = 720]);

  Doc copy() => Doc(els.map((e) => e.copy()).toList(), List.of(bg), bgImg, bgStyle, w, h);

  // ignore: deprecated_member_use
  Map<String, dynamic> toJson() => {'bg': bg.map((c) => c.value).toList(), 'bgImg': bgImg, 'bgStyle': bgStyle, 'w': w, 'h': h, 'els': els.map((e) => e.toJson()).toList()};

  factory Doc.fromJson(Map<String, dynamic> j) => Doc(
        (j['els'] as List).map((e) => El.fromJson(e as Map<String, dynamic>)).toList(),
        (j['bg'] as List).map((v) => Color(v as int)).toList(),
        j['bgImg'] as String?,
        j['bgStyle'] as String?,
        (j['w'] as num?)?.toDouble() ?? 1280,
        (j['h'] as num?)?.toDouble() ?? 720,
      );
}

/// A canvas size the user can start a design in.
class FramePreset {
  final String name;
  final double w, h;
  const FramePreset(this.name, this.w, this.h);
  double get ratio => w / h;
  String get label => '${w.toInt()} × ${h.toInt()}';
}

const kFrames = [
  FramePreset('YouTube thumbnail', 1280, 720),
  FramePreset('Square post', 1080, 1080),
  FramePreset('Portrait post', 1080, 1350),
  FramePreset('Story / Reel', 1080, 1920),
  FramePreset('Wide banner', 1500, 500),
];

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

/// A user's saved (or about to be saved) thumbnail project.
class Design {
  final String id;
  String name;
  DateTime updated;
  Doc doc;

  Design({String? id, required this.name, required this.doc, DateTime? updated})
      : id = id ?? newId(),
        updated = updated ?? DateTime.now();

  Map<String, dynamic> toJson() => {'v': 1, 'id': id, 'name': name, 'updated': updated.toIso8601String(), 'doc': doc.toJson()};

  factory Design.fromJson(Map<String, dynamic> j) => Design(
        id: j['id'] as String,
        name: j['name'] as String,
        updated: DateTime.parse(j['updated'] as String),
        doc: Doc.fromJson(j['doc'] as Map<String, dynamic>),
      );
}
