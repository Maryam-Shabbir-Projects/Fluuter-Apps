import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/doc.dart';
import '../../services/importer.dart';
import '../../widgets/color_grid.dart';
import '../../widgets/common.dart';
import '../../widgets/page_preview.dart';
import '../../widgets/paper_swatch.dart';
import '../../widgets/style_bar.dart';
import '../../widgets/toggle_group.dart';

class DesignTab extends StatefulWidget {
  final Doc d;
  const DesignTab(this.d, {super.key});
  @override
  State<DesignTab> createState() => _DesignState();
}

class _DesignState extends State<DesignTab> {
  static const _sections = [(Icons.crop_landscape, 'Page'), (Icons.wallpaper, 'Paper'), (Icons.text_fields, 'Text'), (Icons.branding_watermark_outlined, 'Brand')];
  int sec = 0, paperTab = 0, target = 0; // target: 0 faded text, 1 logo
  Doc get d => widget.d;

  @override
  void initState() {
    super.initState();
    paperTab = d.bgMode;
  }

  // ---------- small building blocks ----------
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)));

  Widget _slider(String label, double v, double lo, double hi, void Function(double) f, {String Function(double)? fmt, int? divisions}) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      Row(children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(150), borderRadius: BorderRadius.circular(10)),
          child: Text(fmt != null ? fmt(v) : v.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cs.onPrimaryContainer)),
        ),
      ]),
      Slider(value: v.clamp(lo, hi), min: lo, max: hi, divisions: divisions, onChanged: (x) { f(x); d.touch(); }),
    ]);
  }

  Widget _upload(IconData ic, String title, String sub, VoidCallback tap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: tap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(60), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.primary.withAlpha(90))),
        child: Column(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer), child: Icon(ic, color: cs.onPrimaryContainer)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Future<void> _gallery(BuildContext c, bool logo) async {
    try {
      final p = logo ? await Importer.pickLogo() : await Importer.pickPaperImage();
      if (p == null) return;
      if (logo) {
        await d.setLogo(p);
      } else {
        await d.setBgImage(p);
      }
    } catch (e) {
      if (c.mounted) snack(c, 'Could not open the gallery: $e');
    }
  }

  Widget _sizeCard(String k) {
    final cs = Theme.of(context).colorScheme, s = kSizes[k]!, on = d.size == k, lab = kSizeLabels[k]!;
    const mx = 36.0;
    final w = s.width >= s.height ? mx : mx * s.width / s.height, h = s.height >= s.width ? mx : mx * s.height / s.width;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () { d.size = k; d.touch(); },
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: on ? cs.primaryContainer.withAlpha(110) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: on ? 2 : 1, color: on ? cs.primary : cs.outlineVariant),
        ),
        child: Column(children: [
          SizedBox(height: mx, child: Center(child: Container(width: w, height: h, decoration: BoxDecoration(color: on ? cs.primary : cs.outline, borderRadius: BorderRadius.circular(4))))),
          const SizedBox(height: 8),
          Text(lab.$1, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: on ? cs.primary : null)),
          Text(lab.$2, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Widget _autoColor(int value, void Function(int) set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Colour'),
        Row(children: [ChoiceChip(label: const Text('Automatic'), selected: value == 0, onSelected: (_) => set(0))]),
        const SizedBox(height: 10),
        ColorGrid(selected: value, onPick: set),
      ]);

  // ---------- sections ----------
  List<Widget> _page() => [
        Panel(title: 'Page size', icon: Icons.crop_landscape, child: Wrap(spacing: 10, runSpacing: 10, children: [for (final k in kSizes.keys) _sizeCard(k)])),
        Panel(title: 'Spacing', icon: Icons.format_line_spacing, child: Column(children: [
          _slider('Line spacing', d.lh, 1.0, 3.0, (v) => d.lh = (v * 20).round() / 20, fmt: (v) => v.toStringAsFixed(2)),
          _slider('Margin', d.mg, 20, 200, (v) => d.mg = v.roundToDouble(), fmt: (v) => '${v.round()} px'),
        ])),
        Panel(
          title: 'Text direction',
          icon: Icons.swap_horiz,
          child: ToggleGroup(
            items: const [(Icons.auto_awesome, 'Auto'), (Icons.format_textdirection_r_to_l, 'Right to left'), (Icons.format_textdirection_l_to_r, 'Left to right')],
            selected: d.dir,
            onChanged: (v) { d.dir = v; d.touch(); },
          ),
        ),
        Panel(
          title: 'Alignment',
          icon: Icons.format_align_center,
          child: ToggleGroup(
            items: const [(Icons.format_align_left, 'Start'), (Icons.format_align_center, 'Centre'), (Icons.format_align_justify, 'Justify')],
            selected: d.al,
            onChanged: (v) { d.al = v; d.touch(); },
          ),
        ),
      ];

  List<Widget> _paper(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    Widget gradDot(int a, int b, bool on, VoidCallback tap) => GestureDetector(
          onTap: tap,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(a), Color(b)]),
              border: Border.all(width: on ? 3 : 1, color: on ? cs.primary : cs.outlineVariant),
            ),
          ),
        );
    final Widget body;
    switch (paperTab) {
      case 0:
        body = Wrap(spacing: 12, runSpacing: 12, children: [
          for (var i = 0; i < kPapers.length; i++)
            GestureDetector(
              onTap: () => d.setPaper(i),
              child: Column(children: [PaperSwatch(kPapers[i], d.bgMode == 0 && d.paper == i), const SizedBox(height: 5), Text(kPapers[i].name, style: const TextStyle(fontSize: 11))]),
            ),
        ]);
      case 1:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Pick a colour'), ColorGrid(selected: d.bgMode == 1 ? d.c1 : 0, onPick: d.setSolid)]);
      case 2:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Ready-made'),
          Wrap(spacing: 12, runSpacing: 12, children: [for (final g in kGradients) gradDot(g[0], g[1], d.bgMode == 2 && d.c1 == g[0] && d.c2 == g[1], () => d.setGradient(a: g[0], b: g[1]))]),
          const SizedBox(height: 18),
          _label('Make your own'),
          Text('From', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          ColorGrid(selected: d.c1, onPick: (v) => d.setGradient(a: v)),
          const SizedBox(height: 14),
          Text('To', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          ColorGrid(selected: d.c2, onPick: (v) => d.setGradient(b: v)),
          const SizedBox(height: 18),
          _label('Direction'),
          ToggleGroup(items: const [(Icons.south, 'Down'), (Icons.south_east, 'Diagonal'), (Icons.east, 'Across'), (Icons.blur_circular, 'Radial')], selected: d.gDir, onChanged: (v) => d.setGradient(direction: v)),
        ]);
      default:
        body = d.bgMode == 3 && d.bgImage != null
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 90, height: 60, child: RawImage(image: d.bgImage, fit: BoxFit.cover))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.tonalIcon(onPressed: () => _gallery(c, false), icon: const Icon(Icons.photo_library_outlined, size: 18), label: const Text('Change'))),
                  IconButton(tooltip: 'Remove photo', icon: const Icon(Icons.delete_outline), onPressed: () => d.setPaper(d.paper)),
                ]),
                const SizedBox(height: 18),
                _label('Text colour on the photo'),
                ToggleGroup(items: const [(Icons.dark_mode_outlined, 'Dark text'), (Icons.light_mode_outlined, 'Light text')], selected: d.imgLight ? 1 : 0, onChanged: (v) { d.imgLight = v == 1; d.touch(); }),
              ])
            : _upload(Icons.photo_library_outlined, 'Choose from gallery', 'Use any photo as the page background', () => _gallery(c, false));
    }
    return [
      Panel(
        title: 'Paper and background',
        icon: Icons.wallpaper,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ToggleGroup(
            items: const [(Icons.grid_view_rounded, 'Designs'), (Icons.palette_outlined, 'Colour'), (Icons.gradient, 'Gradient'), (Icons.photo_library_outlined, 'Photo')],
            selected: paperTab,
            onChanged: (v) => setState(() => paperTab = v),
          ),
          const SizedBox(height: 18),
          body,
        ]),
      ),
    ];
  }

  List<Widget> _text(BuildContext c) => [
        Panel(title: 'Font', icon: Icons.font_download_outlined, child: Column(children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Base font style'),
            subtitle: Text(kFonts[d.font]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final i = await pickFont(c, current: d.font);
              if (i != null) { d.font = i; d.touch(); }
            },
          ),
          _slider('Base font size', d.pt, 8, 100, (v) => d.pt = v.roundToDouble(), fmt: (v) => '${v.round()} pt', divisions: 92),
        ])),
        Panel(title: 'Text colour', icon: Icons.format_color_text, child: _autoColor(d.textColor, (v) { d.textColor = v; d.touch(); })),
      ];

  List<Widget> _brand(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return [
      Panel(
        title: 'Place on page',
        icon: Icons.open_with,
        child: Column(children: [
          ToggleGroup(items: const [(Icons.title, 'Faded text'), (Icons.image_outlined, 'Logo')], selected: target, onChanged: (v) => setState(() => target = v)),
          const SizedBox(height: 12),
          InfoBanner([(Icons.touch_app_outlined, 'Tap or drag on the preview above to place the ${target == 0 ? 'faded text' : 'logo'} anywhere.')]),
        ]),
      ),
      Panel(
        title: 'Faded text',
        icon: Icons.title,
        trailing: Switch(value: d.wmOn, onChanged: (v) { d.wmOn = v; d.touch(); }),
        child: d.wmOn
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextFormField(
                  initialValue: d.wm,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.edit_outlined), labelText: 'Channel name or text', filled: true, fillColor: cs.onSurface.withAlpha(10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  onChanged: (v) { d.wm = v; d.touch(); },
                ),
                const SizedBox(height: 12),
                _slider('Size', d.wmPt, 6, 100, (v) => d.wmPt = v.roundToDouble(), fmt: (v) => '${v.round()} pt'),
                _slider('Opacity', d.wmOp, 0.03, 0.8, (v) => d.wmOp = v, fmt: (v) => '${(v * 100).round()}%'),
                const SizedBox(height: 4),
                _autoColor(d.wmColor, (v) { d.wmColor = v; d.touch(); }),
              ])
            : Text('Turn on to show your channel name faintly on every page.', style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
      ),
      Panel(
        title: 'Logo',
        icon: Icons.image_outlined,
        child: d.logoImage == null
            ? _upload(Icons.add_photo_alternate_outlined, 'Import logo from gallery', 'PNG with a clear background works best', () => _gallery(c, true))
            : Column(children: [
                Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: cs.onSurface.withAlpha(12), borderRadius: BorderRadius.circular(14)),
                    child: RawImage(image: d.logoImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.tonalIcon(onPressed: () => _gallery(c, true), icon: const Icon(Icons.swap_horiz, size: 18), label: const Text('Change'))),
                  IconButton(tooltip: 'Remove logo', icon: const Icon(Icons.delete_outline), onPressed: () => d.setLogo(null)),
                ]),
                const SizedBox(height: 10),
                _slider('Size', d.logoSize, 0.04, 0.6, (v) => d.logoSize = v, fmt: (v) => '${(v * 100).round()}%'),
                _slider('Opacity', d.logoOp, 0.1, 1.0, (v) => d.logoOp = v, fmt: (v) => '${(v * 100).round()}%'),
              ]),
      ),
    ];
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final body = switch (sec) { 0 => _page(), 1 => _paper(c), 2 => _text(c), _ => _brand(c) };
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Center(
            child: sec == 3
                ? PlaceablePreview(d, (x, y) {
                    if (target == 0) {
                      d.wmX = x;
                      d.wmY = y;
                      d.wmOn = true;
                    } else if (d.logoImage != null) {
                      d.logoX = x;
                      d.logoY = y;
                    }
                    d.touch();
                  })
                : PagePreview(d, 0),
          ),
        ),
      ),
      SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (var i = 0; i < _sections.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(_sections[i].$1, size: 18, color: sec == i ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                label: Text(_sections[i].$2),
                selected: sec == i,
                onSelected: (_) => setState(() => sec = i),
              ),
            ),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: body)),
    ]);
  }
}
