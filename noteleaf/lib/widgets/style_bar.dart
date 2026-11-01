import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../models/rich_text.dart';
import 'color_grid.dart';

/// Formatting tools. With text selected they change the selection; with nothing selected they set the
/// style for the text you type next (font, size in points, bold, italic, underline, colour, highlight).
class StyleBar extends StatelessWidget {
  final RichController ctrl;
  final double basePt;
  final int baseFont;
  final VoidCallback onChanged;
  final bool showHint;
  const StyleBar({super.key, required this.ctrl, required this.basePt, required this.baseFont, required this.onChanged, this.showHint = false});

  void _a(St Function(St) f) {
    ctrl.apply(f);
    onChanged();
  }

  String _fmt(double v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

  Widget _toggle(ColorScheme cs, IconData ic, String tip, bool Function(St) has, St Function(St, bool) set) {
    final on = ctrl.isOn(has);
    return Tooltip(
      message: tip,
      child: GestureDetector(
        onTap: () {
          ctrl.toggle(has, set);
          onChanged();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 42,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: on ? cs.primary : cs.onSurface.withAlpha(12), borderRadius: BorderRadius.circular(13)),
          child: Icon(ic, size: 21, color: on ? cs.onPrimary : cs.onSurface),
        ),
      ),
    );
  }

  Widget _colorTile(ColorScheme cs, IconData ic, String tip, int current, Future<void> Function() tap) => Tooltip(
        message: tip,
        child: GestureDetector(
          onTap: tap,
          child: Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: cs.onSurface.withAlpha(12), borderRadius: BorderRadius.circular(13)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(ic, size: 20),
              const SizedBox(height: 2),
              Container(width: 20, height: 4, decoration: BoxDecoration(color: current == 0 ? cs.onSurface.withAlpha(90) : Color(current), borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.black12, width: 0.5))),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) {
        final sty = ctrl.styleAtCaret();
        final cur = ctrl.sizeAtSel(basePt);
        final smaller = kPts.lastWhere((p) => p < cur - 0.01, orElse: () => kPts.first);
        final bigger = kPts.firstWhere((p) => p > cur + 0.01, orElse: () => kPts.last);
        final fi = ctrl.fontAtSel(baseFont);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              GestureDetector(
                onTap: () async {
                  final i = await pickFont(c, current: fi);
                  if (i != null) _a((x) => x.copy(f: i));
                },
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.only(left: 8, right: 6),
                  decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(110), borderRadius: BorderRadius.circular(13)),
                  child: Row(children: [
                    Text('Aa', style: GoogleFonts.getFont(kFonts[fi], fontSize: 22, color: cs.primary)),
                    const SizedBox(width: 8),
                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 104), child: Text(kFonts[fi], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                    const Icon(Icons.expand_more, size: 20),
                  ]),
                ),
              ),
              Container(
                height: 42,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: cs.onSurface.withAlpha(12), borderRadius: BorderRadius.circular(13)),
                child: Row(children: [
                  IconButton(tooltip: 'Smaller', visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, size: 18), onPressed: () => _a((x) => x.copy(z: smaller))),
                  PopupMenuButton<double>(
                    tooltip: 'Font size in points',
                    onSelected: (v) => _a((x) => x.copy(z: v)),
                    itemBuilder: (_) => [for (final p in kPts) PopupMenuItem(value: p, child: Text('${_fmt(p)} pt'))],
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_fmt(cur), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      const Padding(padding: EdgeInsets.only(left: 2, bottom: 3), child: Text('pt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                  IconButton(tooltip: 'Bigger', visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 18), onPressed: () => _a((x) => x.copy(z: bigger))),
                ]),
              ),
              _toggle(cs, Icons.format_bold, 'Bold', (x) => x.b, (x, v) => x.copy(b: v)),
              _toggle(cs, Icons.format_italic, 'Italic', (x) => x.i, (x, v) => x.copy(i: v)),
              _toggle(cs, Icons.format_underlined, 'Underline', (x) => x.u, (x, v) => x.copy(u: v)),
              _colorTile(cs, Icons.format_color_text, 'Text colour', sty.c, () async {
                final v = await pickColorSheet(c, title: 'Text colour', noneLabel: 'Default colour', selected: sty.c);
                if (v != null) _a((x) => x.copy(c: v));
              }),
              _colorTile(cs, Icons.border_color_outlined, 'Highlight', sty.h, () async {
                final v = await pickColorSheet(c, title: 'Highlight colour', noneLabel: 'No highlight', selected: sty.h);
                if (v != null) _a((x) => x.copy(h: v));
              }),
            ]),
          ),
          if (showHint && ctrl.hasTypingStyle)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(90), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit_note, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text('Next text: ${kFonts[fi]} · ${_fmt(cur)} pt${sty.b ? ' · Bold' : ''}${sty.i ? ' · Italic' : ''}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer)),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}

/// Bottom sheet that shows every font in its own style, grouped by language.
Future<int?> pickFont(BuildContext c, {int? current}) => showModalBottomSheet<int>(
      context: c,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, sc) {
          final items = <Object>[];
          String? g;
          for (var i = 0; i < kFontList.length; i++) {
            if (kFontList[i].$2 != g) {
              g = kFontList[i].$2;
              items.add(g);
            }
            items.add(i);
          }
          const sample = {'Urdu / Arabic': 'ابج  اردو نوٹس', 'Hindi': 'अआ  हिंदी नोट्स'};
          return ListView.builder(
            controller: sc,
            itemCount: items.length,
            itemBuilder: (_, k) {
              final it = items[k];
              if (it is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: Text(it.toUpperCase(), style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1, color: Theme.of(ctx).colorScheme.primary)),
                );
              }
              final i = it as int;
              return ListTile(
                selected: i == current,
                title: Text(sample[kFontList[i].$2] ?? 'Aa  Hello, notes', style: GoogleFonts.getFont(kFonts[i], fontSize: 24)),
                subtitle: Text(kFonts[i]),
                trailing: i == current ? const Icon(Icons.check_circle) : null,
                onTap: () => Navigator.pop(ctx, i),
              );
            },
          );
        },
      ),
    );
