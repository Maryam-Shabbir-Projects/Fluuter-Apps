import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

/// Style of one character: bold, italic, underline, colour, highlight, size in points (0 = base size), font index.
class St {
  final bool b, i, u;
  final int c, h, f;
  final double z;
  const St({this.b = false, this.i = false, this.u = false, this.c = 0, this.h = 0, this.z = 0, this.f = -1});
  St copy({bool? b, bool? i, bool? u, int? c, int? h, double? z, int? f}) =>
      St(b: b ?? this.b, i: i ?? this.i, u: u ?? this.u, c: c ?? this.c, h: h ?? this.h, z: z ?? this.z, f: f ?? this.f);
  @override
  bool operator ==(Object o) => o is St && o.b == b && o.i == i && o.u == u && o.c == c && o.h == h && o.z == z && o.f == f;
  @override
  int get hashCode => Object.hash(b, i, u, c, h, z, f);

  /// [ptPx] is how many pixels one point is on the surface being drawn.
  TextStyle style(TextStyle base, double ptPx) {
    final t = base.copyWith(
      fontSize: z == 0 ? base.fontSize : z * ptPx,
      fontWeight: b ? FontWeight.w700 : null,
      fontStyle: i ? FontStyle.italic : null,
      color: c == 0 ? null : Color(c),
      backgroundColor: h == 0 ? null : Color(h),
      decoration: u ? TextDecoration.underline : null,
    );
    return f < 0 ? t : GoogleFonts.getFont(kFonts[f], textStyle: t);
  }
}

class Run {
  final String t;
  final St s;
  Run(this.t, this.s);
}

/// Text field controller that keeps one [St] per character and paints them.
///
/// With nothing selected, changing font, size, bold, colour... sets a "typing style":
/// the text you type next uses it, like a word processor. It is dropped when the caret moves elsewhere.
class RichController extends TextEditingController {
  List<St> st = [];
  String _old = '';
  St? _typing;
  int _caret = -1;
  double ptPx = 1; // pixels per point on this screen; set by the owner before building

  RichController() {
    addListener(_sync);
  }

  bool get hasTypingStyle => _typing != null;

  void _sync() {
    if (text == _old) {
      // Selection-only change: forget the typing style when the caret moves somewhere else.
      if (_typing != null && !(selection.isValid && selection.isCollapsed && selection.start == _caret)) _typing = null;
      return;
    }
    final a = _old, b = text;
    int p = 0;
    while (p < a.length && p < b.length && a[p] == b[p]) {
      p++;
    }
    int q = 0;
    while (q < a.length - p && q < b.length - p && a[a.length - 1 - q] == b[b.length - 1 - q]) {
      q++;
    }
    final cur = _typing ?? (p > 0 ? st[p - 1] : const St());
    st.replaceRange(p, a.length - q, List.filled(b.length - q - p, cur));
    _old = b;
    if (_typing != null) _caret = selection.isValid ? selection.start : b.length;
  }

  void load(List<Run> runs) {
    _typing = null;
    st = [for (final r in runs) ...List.filled(r.t.length, r.s)];
    _old = runs.map((r) => r.t).join();
    value = TextEditingValue(text: _old);
  }

  /// Replaces text[s..e) with [t] and gives it [styles] (one per character).
  void replace(int s, int e, String t, List<St> styles) {
    _typing = null;
    final n = [...st.sublist(0, s), ...styles, ...st.sublist(e)];
    _old = text.replaceRange(s, e, t);
    st = n;
    value = TextEditingValue(text: _old, selection: TextSelection.collapsed(offset: s + t.length));
  }

  void insert(String t) {
    final s = selection;
    final a = s.isValid ? s.start : text.length, b = s.isValid ? s.end : text.length;
    value = TextEditingValue(text: text.replaceRange(a, b, t), selection: TextSelection.collapsed(offset: a + t.length));
  }

  bool get _hasRange => selection.isValid && !selection.isCollapsed;

  /// The style shown in the toolbar: the typing style, the selection's first character, or the character before the caret.
  St styleAtCaret() {
    final s = selection;
    if (_typing != null && !_hasRange) return _typing!;
    if (st.isEmpty) return const St();
    final i = s.isValid ? (s.isCollapsed ? s.start - 1 : s.start) : st.length - 1;
    return i < 0 ? const St() : st[i.clamp(0, st.length - 1)];
  }

  /// Whether [has] is true for everything selected (or at the caret when nothing is selected).
  bool isOn(bool Function(St) has) => _hasRange ? st.sublist(selection.start, selection.end).every(has) : has(styleAtCaret());

  /// Applies [f] to the selection, or sets the typing style when nothing is selected.
  void apply(St Function(St) f) {
    final s = selection;
    if (!_hasRange) {
      _typing = f(styleAtCaret());
      _caret = s.isValid ? s.start : text.length;
      notifyListeners();
      return;
    }
    for (var i = s.start; i < s.end; i++) {
      st[i] = f(st[i]);
    }
    notifyListeners();
  }

  /// Turns a style on, or off if it is already on for everything selected (or at the caret).
  void toggle(bool Function(St) has, St Function(St, bool) set) {
    final on = isOn(has);
    apply((x) => set(x, !on));
  }

  /// Size in points at the caret/selection, else [fallback].
  double sizeAtSel(double fallback) {
    final z = styleAtCaret().z;
    return z == 0 ? fallback : z;
  }

  int fontAtSel(int fallback) {
    final f = styleAtCaret().f;
    return f < 0 ? fallback : f;
  }

  List<Run> get runs {
    if (st.length != text.length) return [Run(text, const St())];
    final o = <Run>[];
    int i = 0;
    while (i < text.length) {
      int j = i + 1;
      while (j < text.length && st[j] == st[i]) {
        j++;
      }
      o.add(Run(text.substring(i, j), st[i]));
      i = j;
    }
    return o;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (st.length != text.length) return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    return TextSpan(style: style, children: [for (final r in runs) TextSpan(text: r.t, style: r.s.style(style!, ptPx))]);
  }
}
