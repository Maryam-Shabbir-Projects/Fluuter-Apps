import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../../models/design.dart';
import '../../models/element_model.dart';
import '../../widgets/sheets.dart';
import '../../widgets/stage.dart';

Widget _title(String t) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
    );

// ---------------------------------------------------------------------------
// TEXT: language, font size, fonts (English + Urdu + others)
// ---------------------------------------------------------------------------

class TextPanel extends StatefulWidget {
  final void Function(El) onAdd;
  final void Function(El) onAddAndEdit; // adds the item, then opens the keyboard on it
  final void Function(String font) onApplyFont;
  const TextPanel({super.key, required this.onAdd, required this.onAddAndEdit, required this.onApplyFont});
  @override
  State<TextPanel> createState() => _TextPanelState();
}

class _TextPanelState extends State<TextPanel> {
  String lang = 'English';
  String font = 'Anton';
  int size = 130;

  El _text(String t, String f, [Color c = Colors.white]) => El(K.text, text: t, font: f, x: 140, y: 260, w: 1000, size: size.toDouble(), color: c);

  void _setLang(String l) => setState(() {
        lang = l;
        font = langs[l]!.$1;
      });

  @override
  Widget build(BuildContext context) {
    final (mainFont, sample, phrases) = langs[lang]!;
    final fonts = fontsByLang[lang]!;
    return ListView(padding: const EdgeInsets.all(12), children: [
      Wrap(spacing: 8, runSpacing: 4, children: [
        FilledButton.icon(
          onPressed: () => widget.onAddAndEdit(_text(sample, font)),
          icon: const Icon(Icons.keyboard),
          label: const Text('Add text & type'),
        ),
        OutlinedButton.icon(
          onPressed: () => widget.onAddAndEdit(El(K.text, text: sample, font: font, x: 440, y: 300, w: 400, size: size * .6, outline: false, color: Colors.white, bgFill: const Color(0xFFE52D27), radius: 14)),
          icon: const Icon(Icons.label),
          label: const Text('Add label box'),
        ),
      ]),
      const SizedBox(height: 4),
      const Text('Tap any text on the canvas, then tap it again (or "Edit text") to type.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      _title('Language'),
      Wrap(spacing: 8, children: [for (final l in langs.keys) ChoiceChip(label: Text(l), selected: l == lang, onSelected: (_) => _setLang(l))]),
      _title('Font size for new text: $size'),
      Wrap(spacing: 6, children: [
        for (final p in fontSizePresets) ChoiceChip(label: Text('$p'), selected: size == p, onSelected: (_) => setState(() => size = p)),
      ]),
      _title('Colours'),
      Wrap(spacing: 8, children: [
        for (final c in const [Colors.white, Color(0xFFFFE600), Color(0xFFFF2D4F), Color(0xFF00F5D4)])
          ActionChip(label: Text(sample, style: ts(font, 22, color: Colors.black)), backgroundColor: c, onPressed: () => widget.onAdd(_text(sample, font, c))),
      ]),
      _title('Fonts  (tap one to add text)'),
      for (final f in fonts)
        Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: f == font ? Theme.of(context).colorScheme.primaryContainer : null,
          child: ListTile(
            dense: true,
            title: Text(sample, style: ts(f, 28)),
            subtitle: Text(f, style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.add),
            onTap: () {
              setState(() => font = f);
              widget.onAddAndEdit(_text(sample, f));
            },
          ),
        ),
      const Divider(),
      _title('Quick phrases  (in the selected font)'),
      for (final p in phrases)
        ListTile(dense: true, title: Text(p, style: ts(font, 22)), trailing: const Icon(Icons.add), onTap: () => widget.onAdd(_text(p, font))),
      OutlinedButton(onPressed: () => widget.onApplyFont(font), child: Text('Apply "$font" to all text')),
      if (font != mainFont) TextButton(onPressed: () => setState(() => font = mainFont), child: const Text('Back to the default font')),
    ]);
  }
}

// ---------------------------------------------------------------------------
// ICONS (grouped)
// ---------------------------------------------------------------------------

class IconPanel extends StatefulWidget {
  final void Function(El) onAdd;
  final void Function(List<El>) onGroup;
  const IconPanel({super.key, required this.onAdd, required this.onGroup});
  @override
  State<IconPanel> createState() => _IconPanelState();
}

class _IconPanelState extends State<IconPanel> {
  String group = 'All';

  @override
  Widget build(BuildContext context) {
    final entries = group == 'All' ? iconMap.entries : iconGroups[group]!.entries;
    return ListView(padding: const EdgeInsets.all(12), children: [
      const Text('YouTube buttons', style: TextStyle(fontWeight: FontWeight.w700)),
      Wrap(spacing: 8, children: [for (final s in stickers.entries) ActionChip(label: Text(s.key), onPressed: () => widget.onGroup(s.value()))]),
      _title('Icons  (colour them in the bar above the tabs)'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final g in ['All', ...iconGroups.keys])
            Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(g), selected: g == group, onSelected: (_) => setState(() => group = g))),
        ]),
      ),
      const SizedBox(height: 6),
      Wrap(children: [
        for (final i in entries)
          IconButton(iconSize: 32, onPressed: () => widget.onAdd(El(K.icon, icon: i.key, size: 260, x: 500, y: 200)), icon: Icon(i.value)),
      ]),
    ]);
  }
}

// ---------------------------------------------------------------------------
// SHAPES
// ---------------------------------------------------------------------------

class ShapePanel extends StatelessWidget {
  final void Function(El) onAdd;
  const ShapePanel({super.key, required this.onAdd});

  static const _palette = [Color(0xFFE53935), Color(0xFFFFE600), Color(0xFF2F8BFF), Color(0xFF00C853), Color(0xFFFF9800), Color(0xFFAB47BC), Color(0xFFFFFFFF), Color(0xFF00E5FF)];

  El _make(String kind, int i) {
    final (w, h) = shapeSizes[kind] ?? (380.0, 380.0);
    return El(K.shape, shape: kind, x: (1280 - w) / 2, y: (720 - h) / 2, w: w, h: h, color: _palette[i % _palette.length], outline: false);
  }

  @override
  Widget build(BuildContext context) {
    final kinds = shapeKinds.keys.toList();
    return ListView(padding: const EdgeInsets.all(12), children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        ActionChip(label: const Text('Rounded box'), onPressed: () => onAdd(El(K.shape, x: 410, y: 290, w: 460, h: 150, radius: 30, color: const Color(0xFFFFE600)))),
        ActionChip(label: const Text('Circle'), onPressed: () => onAdd(El(K.shape, shape: 'oval', x: 450, y: 170, w: 380, h: 380, color: Colors.white))),
        ActionChip(label: const Text('Dark overlay'), onPressed: () => onAdd(El(K.shape, x: 0, y: 0, w: 1280, h: 720, color: Colors.black, opacity: .5))),
        ActionChip(label: const Text('Line'), onPressed: () => onAdd(El(K.shape, x: 240, y: 340, w: 800, h: 14, radius: 7, color: Colors.white))),
      ]),
      _title('All shapes  (tap to add, then recolour, stretch or rotate)'),
      Wrap(spacing: 6, runSpacing: 8, children: [
        for (var i = 0; i < kinds.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onAdd(kinds[i] == 'rect' ? El(K.shape, x: 410, y: 290, w: 460, h: 150, color: _palette[i % _palette.length]) : _make(kinds[i], i)),
            child: SizedBox(
              width: 76,
              child: Column(children: [
                ShapeTile(kinds[i], color: _palette[i % _palette.length], size: 64),
                Text(shapeKinds[kinds[i]]!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
              ]),
            ),
          ),
      ]),
    ]);
  }
}

// ---------------------------------------------------------------------------
// IMAGES: import (with optional background removal) + computer-drawn expression faces
// ---------------------------------------------------------------------------

class ImagePanel extends StatelessWidget {
  final void Function(El) onAdd;
  final VoidCallback onImport, onImportCutout;
  const ImagePanel({super.key, required this.onAdd, required this.onImport, required this.onImportCutout});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(12), children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(onPressed: onImport, icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('Import image')),
          FilledButton.tonalIcon(onPressed: onImportCutout, icon: const Icon(Icons.auto_fix_high), label: const Text('Import + remove background')),
          OutlinedButton.icon(
            onPressed: () => onAdd(El(K.image, x: 340, y: 60, w: 600, h: 600, radius: 30)),
            icon: const Icon(Icons.crop_original),
            label: const Text('Empty photo frame'),
          ),
        ]),
        const SizedBox(height: 4),
        const Text('Already on the canvas? Tap the photo, then "Remove BG" in the bar above the tabs.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        _title('Expressions  (tap to add, change the colour above the tabs)'),
        Wrap(spacing: 6, runSpacing: 8, children: [
          for (final f in faceKinds.entries)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onAdd(El(K.shape, shape: f.key, x: 440, y: 160, w: 400, h: 400, color: faceColors[f.key] ?? faceDefault, outline: false)),
              child: SizedBox(
                width: 84,
                child: Column(children: [
                  ShapeTile(f.key, size: 72),
                  Text(f.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                ]),
              ),
            ),
        ]),
      ]);
}

// ---------------------------------------------------------------------------
// BACKGROUND: colour, gradient, themes, import from album
// ---------------------------------------------------------------------------

class BackgroundPanel extends StatefulWidget {
  final Doc doc;
  final void Function(List<Color> colors, String? style) onFill;
  final void Function(int index) onEditColor;
  final VoidCallback onPhoto, onClearPhoto, onToggleGradient, onSwap, onClearStyle;
  const BackgroundPanel({
    super.key,
    required this.doc,
    required this.onFill,
    required this.onEditColor,
    required this.onPhoto,
    required this.onClearPhoto,
    required this.onToggleGradient,
    required this.onSwap,
    required this.onClearStyle,
  });
  @override
  State<BackgroundPanel> createState() => _BackgroundPanelState();
}

class _BackgroundPanelState extends State<BackgroundPanel> {
  String theme = 'All';

  Widget _tile(List<Color> colors, String? pattern, VoidCallback f, {String? label, bool circle = false}) => GestureDetector(
        onTap: f,
        child: Container(
          width: circle ? 44 : 112,
          height: circle ? 44 : 63,
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Stack(fit: StackFit.expand, children: [
            BgPreview(colors, pattern),
            if (label != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(color: Colors.black45, padding: const EdgeInsets.symmetric(vertical: 1), child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10))),
              ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final themes = bgThemes.where((t) => theme == 'All' || t.theme == theme).toList();
    return ListView(padding: const EdgeInsets.all(12), children: [
      const Text('Your background', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      if (doc.bgImg != null)
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photo background'),
            subtitle: const Text('Remove it to use colours instead'),
            trailing: TextButton(onPressed: widget.onClearPhoto, child: const Text('Remove')),
          ),
        )
      else
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (var i = 0; i < doc.bg.length; i++)
            ActionChip(
              avatar: CircleAvatar(backgroundColor: doc.bg[i]),
              label: Text(doc.bg.length > 1 ? 'Colour ${i + 1}' : 'Colour'),
              onPressed: () => widget.onEditColor(i),
            ),
          OutlinedButton(onPressed: widget.onToggleGradient, child: Text(doc.bg.length > 1 ? 'Single colour' : 'Make gradient')),
          if (doc.bg.length > 1) OutlinedButton(onPressed: widget.onSwap, child: const Text('Swap')),
          if (doc.bgStyle != null) OutlinedButton(onPressed: widget.onClearStyle, child: const Text('Remove pattern')),
        ]),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: widget.onPhoto, icon: const Icon(Icons.photo_library_outlined), label: const Text('Import background from album')),
      _title('Solid colours'),
      Wrap(children: [for (final c in swatches) _tile([c], null, () => widget.onFill([c], null), circle: true)]),
      _title('Gradients'),
      Wrap(children: [for (final g in gradients) _tile(g, null, () => widget.onFill(g, null))]),
      _title('Themes'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final t in bgThemeNames)
            Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(t), selected: t == theme, onSelected: (_) => setState(() => theme = t))),
        ]),
      ),
      const SizedBox(height: 4),
      Wrap(children: [for (final t in themes) _tile(t.colors, t.pattern, () => widget.onFill(t.colors, t.pattern), label: t.name)]),
    ]);
  }
}
