import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/paper_painter.dart';
import '../services/storage.dart';
import 'rich_text.dart';

/// One page: the text range it covers and the styled runs inside it.
class PageSlice {
  final int start, end;
  final List<Run> runs;
  PageSlice(this.start, this.end, this.runs);
  int get words {
    final t = runs.map((r) => r.t).join().trim();
    return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
  }
}

/// A project: styled text + design settings + voice-over. Pages are always derived from the text.
class Doc extends ChangeNotifier {
  final String id;
  String title, size = 'YouTube long 16:9', wm = '';
  String? audio, bgPath, logoPath, folderId; // folderId: null = not in a folder
  // paper: bgMode 0 = ready-made design, 1 = one colour, 2 = gradient, 3 = gallery image
  int bgMode = 0, paper = 0, c1 = 0xFFF6EBCF, c2 = 0xFFE8D3A2, gDir = 1; // gDir: 0 down, 1 diagonal, 2 across, 3 radial
  int textColor = 0, wmColor = 0, font = 0, dir = 0, al = 0; // 0 = automatic colour; dir: 0 auto 1 rtl 2 ltr; al: 0 start 1 centre 2 justify
  double pt = 25, lh = 1.9, mg = 90;
  bool imgLight = false, wmOn = false;
  double wmOp = 0.2, wmPt = 14, wmX = 0.5, wmY = 0.93; // faded text: size in pt, position as page fractions
  double logoX = 0.9, logoY = 0.1, logoSize = 0.12, logoOp = 1;
  ui.Image? bgImage, logoImage;
  final ctrl = RichController();
  List<PageSlice>? _pages;
  final _loaded = <int>{};
  String _last = '';
  Timer? _timer;

  Doc(this.id, this.title) {
    ctrl.addListener(() {
      if (ctrl.text != _last) {
        _last = ctrl.text;
        touch();
      }
    });
  }

  void _scheduleSave() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), save);
  }

  /// Call after any change that affects the pages.
  void touch() {
    _pages = null;
    notifyListeners();
    _scheduleSave();
  }

  void rename(String t) {
    title = t;
    notifyListeners();
    _scheduleSave();
  }

  void setAudio(String? p) {
    audio = p;
    notifyListeners();
    _scheduleSave();
  }

  // ---- sizes ----
  Size get px => kSizes[size]!;
  double get ptPx => px.shortestSide / 540;
  double get fs => pt * ptPx;

  // ---- paper ----
  void setPaper(int i) {
    bgMode = 0;
    paper = i;
    touch();
  }

  void setSolid(int c) {
    bgMode = 1;
    c1 = c;
    touch();
  }

  void setGradient({int? a, int? b, int? direction}) {
    bgMode = 2;
    c1 = a ?? c1;
    c2 = b ?? c2;
    gDir = direction ?? gDir;
    touch();
  }

  Future<void> setBgImage(String path) async {
    bgPath = path;
    bgImage = await _img(path);
    bgMode = 3;
    touch();
  }

  Future<void> setLogo(String? path) async {
    logoPath = path;
    logoImage = await _img(path);
    touch();
  }

  Future<ui.Image?> _img(String? path) async {
    if (path == null || !File(path).existsSync()) return null;
    final codec = await ui.instantiateImageCodec(await File(path).readAsBytes());
    return (await codec.getNextFrame()).image;
  }

  Color _contrast(List<int> cs) {
    final l = cs.map((c) => Color(c).computeLuminance()).reduce((a, b) => a + b) / cs.length;
    return l > 0.45 ? const Color(0xFF111111) : Colors.white;
  }

  /// The paper currently in use (a ready-made one, or built from the chosen colours).
  Paper get active {
    switch (bgMode) {
      case 1:
        return Paper('Colour', [Color(c1), Color(c1)], _contrast([c1]));
      case 2:
        return Paper('Gradient', [Color(c1), Color(c2)], _contrast([c1, c2]), radial: gDir == 3);
      case 3:
        return Paper('Image', const [Colors.white, Colors.white], imgLight ? Colors.white : const Color(0xFF111111));
      default:
        return kPapers[paper];
    }
  }

  /// Text colour: automatic (readable on the paper) unless the user picked one.
  Color get fg => textColor == 0 ? active.fg : Color(textColor);

  // ---- text ----
  void importText(String t) {
    final n = ctrl.text.length;
    final add = n == 0 ? t : '\n\n$t';
    ctrl.replace(n, n, add, List.filled(add.length, const St()));
    touch();
  }

  void replacePage(PageSlice p, RichController rc) {
    ctrl.replace(p.start, p.end, rc.text, rc.st);
    touch();
  }

  TextDirection get td {
    if (dir == 1) return TextDirection.rtl;
    if (dir == 2) return TextDirection.ltr;
    final m = RegExp(r'[A-Za-z\u0590-\u08FF\u0900-\u097F]').firstMatch(ctrl.text);
    final u = m == null ? 0 : m[0]!.codeUnitAt(0);
    return u >= 0x590 && u <= 0x8FF ? TextDirection.rtl : TextDirection.ltr;
  }

  TextStyle get baseStyle => GoogleFonts.getFont(kFonts[font], textStyle: TextStyle(fontSize: fs, height: lh, color: fg));

  TextPainter _painter(List<Run> r, double w) {
    final base = baseStyle;
    return TextPainter(
        text: TextSpan(style: base, children: [for (final x in r) TextSpan(text: x.t, style: x.s.style(base, ptPx))]),
        textDirection: td,
        textAlign: [TextAlign.start, TextAlign.center, TextAlign.justify][al])
      ..layout(maxWidth: w);
  }

  List<Run> _slice(List<Run> r, int s, int e) {
    final o = <Run>[];
    int p = 0;
    for (final x in r) {
      final a = p, b = p + x.t.length;
      p = b;
      if (b <= s || a >= e) continue;
      o.add(Run(x.t.substring((s - a).clamp(0, x.t.length), (e - a).clamp(0, x.t.length)), x.s));
    }
    return o;
  }

  /// Splits the whole text into pages like a word processor: what does not fit moves to the next page.
  List<PageSlice> get pages => _pages ??= _paginate();
  List<PageSlice> _paginate() {
    final all = ctrl.runs;
    if (all.isEmpty) return [PageSlice(0, 0, [])];
    final cw = px.width - 2 * mg, ch = px.height - 2 * mg;
    final tp = _painter(all, cw);
    // Fonts download on first use. Once they have loaded, measure again so pages match the real glyphs.
    final used = {font, ...ctrl.st.map((s) => s.f).where((f) => f >= 0)};
    if (!_loaded.containsAll(used)) {
      _loaded.addAll(used);
      GoogleFonts.pendingFonts().then((_) {
        _pages = null;
        notifyListeners();
      });
    }
    final out = <PageSlice>[];
    int start = 0;
    double y = 0, top = 0;
    for (final l in tp.computeLineMetrics()) {
      if (y - top + l.height > ch && y > top) {
        final off = tp.getPositionForOffset(Offset(td == TextDirection.rtl ? cw - 1 : 1, y + l.height / 2)).offset;
        if (off > start) {
          out.add(PageSlice(start, off, _slice(all, start, off)));
          start = off;
        }
        top = y;
      }
      y += l.height;
    }
    out.add(PageSlice(start, ctrl.text.length, _slice(all, start, ctrl.text.length)));
    return out;
  }

  int get words => ctrl.text.trim().isEmpty ? 0 : ctrl.text.trim().split(RegExp(r'\s+')).length;

  // ---- painting (the same code draws previews, the page editor and exports) ----
  void paintPaperOnly(Canvas c) => paintPaper(c, px, active, image: bgMode == 3 ? bgImage : null, dir: bgMode == 2 && gDir != 3 ? gDir : 1);

  /// Faded text and logo.
  void paintBrand(Canvas c) {
    final d = px;
    if (wmOn && wm.isNotEmpty) {
      final col = (wmColor == 0 ? fg : Color(wmColor)).withAlpha((wmOp * 255).round());
      final tp = TextPainter(
          text: TextSpan(text: wm, style: GoogleFonts.getFont(kFonts[font], textStyle: TextStyle(fontSize: wmPt * ptPx, fontWeight: FontWeight.w700, color: col))),
          textDirection: td)
        ..layout();
      tp.paint(c, Offset(wmX * d.width - tp.width / 2, wmY * d.height - tp.height / 2));
    }
    final img = logoImage;
    if (img != null) {
      final w = logoSize * d.width, h = w * img.height / img.width;
      paintImage(canvas: c, rect: Rect.fromCenter(center: Offset(logoX * d.width, logoY * d.height), width: w, height: h), image: img, opacity: logoOp, fit: BoxFit.contain);
    }
  }

  void paintPage(Canvas c, int i) {
    final d = px;
    paintPaperOnly(c);
    _painter(pages[i].runs, d.width - 2 * mg).paint(c, Offset(mg, mg));
    final num = TextPainter(
        text: TextSpan(text: '${i + 1} / ${pages.length}', style: TextStyle(fontSize: d.shortestSide * 0.025, color: fg.withAlpha(115))),
        textDirection: TextDirection.ltr)
      ..layout();
    num.paint(c, Offset((d.width - num.width) / 2, mg * 0.3 - num.height / 2));
    paintBrand(c);
  }

  Future<ui.Image> render(int i, double scale) {
    final r = ui.PictureRecorder(), c = Canvas(r);
    c.scale(scale);
    paintPage(c, i);
    return r.endRecording().toImage((px.width * scale).round(), (px.height * scale).round());
  }

  // ---- saving ----
  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'size': size, 'font': font, 'dir': dir, 'al': al, 'pt': pt, 'lh': lh, 'mg': mg,
        'bgMode': bgMode, 'paper': paper, 'c1': c1, 'c2': c2, 'gDir': gDir, 'imgLight': imgLight, 'bg': bgPath, 'textColor': textColor,
        'wmOn': wmOn, 'wm': wm, 'wmOp': wmOp, 'wmPt': wmPt, 'wmX': wmX, 'wmY': wmY, 'wmColor': wmColor,
        'logo': logoPath, 'logoX': logoX, 'logoY': logoY, 'logoSize': logoSize, 'logoOp': logoOp, 'audio': audio,
        'runs': [for (final r in ctrl.runs) {'t': r.t, 'b': r.s.b, 'i': r.s.i, 'u': r.s.u, 'c': r.s.c, 'h': r.s.h, 'z': r.s.z, 'f': r.s.f}],
      };

  factory Doc.fromJson(Map j) {
    double dd(String k, double def) => (j[k] as num?)?.toDouble() ?? def;
    int ii(String k, int def) => (j[k] as num?)?.toInt() ?? def;
    final d = Doc(j['id'], j['title'])
      ..size = j['size'] ?? 'YouTube long 16:9' ..font = ii('font', 0) ..dir = ii('dir', 0) ..al = ii('al', 0)
      ..pt = dd('pt', 25) ..lh = dd('lh', 1.9) ..mg = dd('mg', 90)
      ..bgMode = ii('bgMode', 0) ..paper = ii('paper', 0) ..c1 = ii('c1', 0xFFF6EBCF) ..c2 = ii('c2', 0xFFE8D3A2) ..gDir = ii('gDir', 1)
      ..imgLight = j['imgLight'] ?? false ..bgPath = j['bg'] as String? ..textColor = ii('textColor', 0)
      ..wmOn = j['wmOn'] ?? false ..wm = j['wm'] ?? '' ..wmOp = dd('wmOp', 0.2) ..wmPt = dd('wmPt', 14)
      ..wmX = dd('wmX', 0.5) ..wmY = dd('wmY', 0.93) ..wmColor = ii('wmColor', 0)
      ..logoPath = j['logo'] as String? ..logoX = dd('logoX', 0.9) ..logoY = dd('logoY', 0.1) ..logoSize = dd('logoSize', 0.12) ..logoOp = dd('logoOp', 1)
      ..audio = j['audio'] as String?;
    d.ctrl.load([
      for (final r in j['runs'])
        Run(r['t'], St(b: r['b'] ?? false, i: r['i'] ?? false, u: r['u'] ?? false, c: r['c'] ?? 0, h: r['h'] ?? 0, z: (r['z'] as num?)?.toDouble() ?? 0, f: r['f'] ?? -1))
    ]);
    d._last = d.ctrl.text;
    Future.wait([d._img(d.bgPath), d._img(d.logoPath)]).then((l) {
      d.bgImage = l[0];
      d.logoImage = l[1];
      if (l[0] != null || l[1] != null) d.touch();
    });
    return d;
  }

  Future<void> save() => Storage.saveDoc(this);
}
