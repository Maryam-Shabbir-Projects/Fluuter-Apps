// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/element_model.dart';
import 'shapes.dart';
import 'stage.dart' show ts;

const _more = <Color>[
  Color(0xFFFF2D4F), Color(0xFFFF6B00), Color(0xFF00F5D4), Color(0xFF7B2FF7), Color(0xFF0B132B),
  Color(0xFF1A1A1A), Color(0xFF8B0000), Color(0xFFFFD1DC), Color(0xFF90EE90), Color(0xFF9E9E9E),
];

String _hex(Color c) => (c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

/// Full colour picker (hue / saturation / brightness / hex / swatches).
/// [onChanged] fires continuously while the user drags, so the canvas updates live.
Future<void> showColorSheet(
  BuildContext context, {
  required String title,
  required Color? initial,
  required ValueChanged<Color?> onChanged,
  bool allowNone = false,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent, // keep the canvas visible
      showDragHandle: true,
      builder: (_) => _ColorSheet(title: title, initial: initial, onChanged: onChanged, allowNone: allowNone),
    );

class _ColorSheet extends StatefulWidget {
  final String title;
  final Color? initial;
  final ValueChanged<Color?> onChanged;
  final bool allowNone;
  const _ColorSheet({required this.title, required this.initial, required this.onChanged, required this.allowNone});
  @override
  State<_ColorSheet> createState() => _ColorSheetState();
}

class _ColorSheetState extends State<_ColorSheet> {
  late HSVColor hsv = HSVColor.fromColor(widget.initial ?? Colors.white);
  late final hex = TextEditingController(text: _hex(hsv.toColor()));

  @override
  void dispose() {
    hex.dispose();
    super.dispose();
  }

  void _set(HSVColor h, {bool fromHex = false}) {
    setState(() {
      hsv = h;
      if (!fromHex) hex.text = _hex(h.toColor());
    });
    widget.onChanged(h.toColor());
  }

  Widget _slider(String label, double v, double max, ValueChanged<double> f) => Row(children: [
        SizedBox(width: 92, child: Text(label)),
        Expanded(child: Slider(value: v.clamp(0.0, max), max: max, onChanged: f)),
      ]);

  @override
  Widget build(BuildContext context) {
    final c = hsv.toColor();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            if (widget.allowNone)
              TextButton(
                onPressed: () {
                  widget.onChanged(null);
                  Navigator.pop(context);
                },
                child: const Text('None'),
              ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.grey))),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: hex,
                maxLength: 6,
                decoration: const InputDecoration(prefixText: '#', labelText: 'Hex colour', counterText: '', isDense: true, border: OutlineInputBorder()),
                onChanged: (v) {
                  final n = v.length == 6 ? int.tryParse(v, radix: 16) : null;
                  if (n != null) _set(HSVColor.fromColor(Color(0xFF000000 | n)), fromHex: true);
                },
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const SizedBox(width: 92, child: Text('Colour')),
            Expanded(
              child: Stack(alignment: Alignment.center, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(colors: [for (var i = 0; i <= 6; i++) HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor()]),
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 10, activeTrackColor: Colors.transparent, inactiveTrackColor: Colors.transparent),
                  child: Slider(value: hsv.hue.clamp(0.0, 360.0), max: 360, onChanged: (v) => _set(hsv.withHue(v))),
                ),
              ]),
            ),
          ]),
          _slider('Strength', hsv.saturation, 1, (v) => _set(hsv.withSaturation(v))),
          _slider('Brightness', hsv.value, 1, (v) => _set(hsv.withValue(v))),
          Wrap(children: [
            for (final s in [...swatches, ..._more])
              GestureDetector(
                onTap: () => _set(HSVColor.fromColor(s)),
                child: Container(width: 34, height: 34, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: s, shape: BoxShape.circle, border: Border.all(color: Colors.grey))),
              ),
          ]),
        ]),
      ),
    );
  }
}

/// Opacity / corners / width / height / rotation sliders for the selected element.
Future<void> showAdjustSheet(BuildContext context, El e, void Function(VoidCallback) live) => showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => _AdjustSheet(e: e, live: live),
    );

class _AdjustSheet extends StatefulWidget {
  final El e;
  final void Function(VoidCallback) live;
  const _AdjustSheet({required this.e, required this.live});
  @override
  State<_AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<_AdjustSheet> {
  El get e => widget.e;

  void _set(VoidCallback f) {
    widget.live(f);
    setState(() {});
  }

  Widget _row(String label, double v, double min, double max, ValueChanged<double> f) => Row(children: [
        SizedBox(width: 84, child: Text(label)),
        Expanded(child: Slider(value: v.clamp(min, max), min: min, max: max, onChanged: (x) => _set(() => f(x)))),
      ]);

  @override
  Widget build(BuildContext context) {
    final box = e.k == K.shape || e.k == K.image;
    var rot = e.rot % 360;
    if (rot > 180) rot -= 360;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Expanded(child: Text('Adjust', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ]),
        _row('Opacity', e.opacity, .05, 1, (v) => e.opacity = v),
        if (box) _row('Corners', e.radius, 0, math.max(1, math.min(e.w, e.h) / 2), (v) => e.radius = v),
        if (e.k == K.text && e.bgFill != null) _row('Corners', e.radius, 0, 80, (v) => e.radius = v),
        if (box) _row('Width', e.w, 20, 1600, (v) => e.w = v),
        if (box) _row('Height', e.h, 20, 1600, (v) => e.h = v),
        if (e.k == K.text) _row('Box width', e.w, 40, 1600, (v) => e.w = v),
        if (e.k == K.icon) _row('Width', e.size, 12, 1000, (v) {
              final h = e.size * e.sy;
              e.size = v;
              e.sy = h / v; // keep the height while the width changes
            }),
        if (e.k == K.icon) _row('Height', e.size * e.sy, 12, 1000, (v) => e.sy = v / e.size),
        _row('Rotation', rot, -180, 180, (v) => e.rot = v),
      ]),
    );
  }
}

const _sizePresets = [12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 64, 80, 100, 130, 160, 200, 260, 320, 400];

/// Font size (text) / icon size with exact numbers: - / + buttons, typed value, presets and slider.
Future<void> showSizeSheet(BuildContext context, El e, void Function(VoidCallback) live) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => _SizeSheet(e: e, live: live),
    );

class _SizeSheet extends StatefulWidget {
  final El e;
  final void Function(VoidCallback) live;
  const _SizeSheet({required this.e, required this.live});
  @override
  State<_SizeSheet> createState() => _SizeSheetState();
}

class _SizeSheetState extends State<_SizeSheet> {
  El get e => widget.e;
  late final c = TextEditingController(text: e.size.round().toString());

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _setSize(double v, {bool fromField = false}) {
    v = v.clamp(6.0, 1200.0).roundToDouble();
    widget.live(() => e.size = v);
    setState(() {
      if (!fromField) c.text = v.round().toString();
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(e.k == K.text ? 'Font size' : 'Icon size', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            IconButton.filledTonal(onPressed: () => _setSize(e.size - 1), icon: const Icon(Icons.remove)),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: TextField(
                controller: c,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), suffixText: 'pt'),
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null && n >= 1) _setSize(n, fromField: true);
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(onPressed: () => _setSize(e.size + 1), icon: const Icon(Icons.add)),
            Expanded(child: Slider(value: e.size.clamp(6.0, 400.0), min: 6, max: 400, onChanged: _setSize)),
          ]),
          Wrap(spacing: 6, runSpacing: 0, children: [
            for (final p in _sizePresets) ChoiceChip(label: Text('$p'), selected: e.size.round() == p, onSelected: (_) => _setSize(p.toDouble())),
          ]),
        ]),
      );
}

/// Icons grouped by topic; picking one swaps the selected icon (colour, size and position are kept).
Future<void> showIconPicker(BuildContext context, {required String? current, required ValueChanged<String> onPick}) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .6,
        maxChildSize: .9,
        builder: (_, scroll) => ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), children: [
          const Text('Replace icon', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          for (final g in iconGroups.entries) ...[
            Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text(g.key, style: const TextStyle(fontWeight: FontWeight.w600))),
            Wrap(children: [
              for (final i in g.value.entries)
                IconButton(
                  iconSize: 32,
                  isSelected: i.key == current,
                  onPressed: () {
                    onPick(i.key);
                    Navigator.pop(ctx);
                  },
                  icon: Icon(i.value),
                ),
            ]),
          ],
        ]),
      ),
    );

/// Small picture of a shape or expression face, used in the pickers and the Shapes / Images tabs.
class ShapeTile extends StatelessWidget {
  final String kind;
  final Color? color;
  final double size;
  const ShapeTile(this.kind, {super.key, this.color, this.size = 56});
  @override
  Widget build(BuildContext context) {
    final c = color ?? faceColors[kind] ?? (isFace(kind) ? faceDefault : Theme.of(context).colorScheme.primary);
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(size * .08),
        child: kind == 'rect'
            ? Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(size * .06)))
            : CustomPaint(painter: ShapePainter(kind, c)),
      ),
    );
  }
}

/// Pick a different shape for the selected shape (colour, size and position are kept).
Future<void> showShapePicker(BuildContext context, {required String current, required ValueChanged<String> onPick}) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        maxChildSize: .9,
        builder: (_, scroll) => ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
          const Text('Replace shape', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in [...shapeKinds.keys, ...faceKinds.keys])
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  onPick(k);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: k == current ? Theme.of(ctx).colorScheme.primary : Colors.grey.shade400, width: k == current ? 2 : 1),
                  ),
                  child: Tooltip(message: shapeKinds[k] ?? faceKinds[k] ?? k, child: ShapeTile(k, size: 60)),
                ),
              ),
          ]),
        ]),
      ),
    );

/// Font chooser: English and Urdu (and other) fonts, each shown in its own style.
Future<void> showFontPicker(BuildContext context, {required String current, required ValueChanged<String> onPick}) {
  final sections = <String, (List<String>, String)>{
    'English': (englishFonts, 'Your Text 123'),
    'اردو  Urdu': (urduFonts, 'آپ کا متن'),
    'Other languages': (['Yatra One', 'Noto Sans Arabic', 'Noto Sans Bengali', 'Noto Sans SC', 'Noto Sans JP', 'Noto Sans KR'], 'Aa आ ع 文 あ 한'),
  };
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .65,
      maxChildSize: .92,
      builder: (_, scroll) => ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(8, 0, 8, 16), children: [
        const Padding(padding: EdgeInsets.only(left: 8), child: Text('Choose font', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
        for (final sec in sections.entries) ...[
          Padding(padding: const EdgeInsets.fromLTRB(8, 12, 8, 2), child: Text(sec.key, style: const TextStyle(fontWeight: FontWeight.w600))),
          for (final f in sec.value.$1)
            ListTile(
              dense: true,
              selected: f == current,
              title: Text(sec.value.$2, style: ts(f, 26)),
              subtitle: Text(f, style: const TextStyle(fontSize: 11)),
              trailing: f == current ? const Icon(Icons.check) : null,
              onTap: () {
                onPick(f);
                Navigator.pop(ctx);
              },
            ),
        ],
      ]),
    ),
  );
}
