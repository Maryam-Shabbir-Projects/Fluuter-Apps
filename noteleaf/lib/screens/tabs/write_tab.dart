import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' show LocaleName;
import '../../core/constants.dart';
import '../../models/doc.dart';
import '../../services/importer.dart';
import '../../services/voice.dart';
import '../../widgets/common.dart';
import '../../widgets/style_bar.dart';

class WriteTab extends StatefulWidget {
  final Doc d;
  const WriteTab(this.d, {super.key});
  @override
  State<WriteTab> createState() => _WriteTabState();
}

class _WriteTabState extends State<WriteTab> {
  static const _editorPx = 22.0; // text size on screen for the base size
  final _dict = Dictation();
  List<LocaleName> _locs = [];
  String _loc = 'en_US';
  bool _on = false;
  Doc get d => widget.d;

  String _norm(String s) => s.replaceAll('-', '_');
  List<LocaleName> get _choices => _locs.where((l) => kVoiceLocales.containsKey(_norm(l.localeId))).toList();
  void _startListening() => _dict.start(_loc, (t) => d.ctrl.insert('$t '));

  Future<void> _mic() async {
    if (_on) {
      await _dict.stop();
      setState(() => _on = false);
      return;
    }
    if (_locs.isEmpty) {
      _locs = await _dict.init();
      if (_locs.isEmpty) {
        if (mounted) snack(context, 'Voice typing is not available on this phone');
        return;
      }
      _loc = (_choices.isNotEmpty ? _choices.first : _locs.first).localeId;
    }
    setState(() => _on = true);
    _startListening();
  }

  Future<void> _importFile() async {
    try {
      final r = await Importer.pickText();
      if (r != null) {
        d.importText(r.text);
        if (mounted) snack(context, 'Imported "${r.name}"');
      }
    } catch (e) {
      if (mounted) snack(context, 'Could not import: $e');
    }
  }

  @override
  void dispose() {
    _dict.stop();
    super.dispose();
  }

  Widget _tile(IconData ic, String label, Color color, VoidCallback tap, {bool solid = false}) => Expanded(
        child: GestureDetector(
          onTap: tap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: solid ? color : color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
              boxShadow: solid ? [BoxShadow(color: color.withAlpha(90), blurRadius: 12, offset: const Offset(0, 5))] : null,
            ),
            child: Column(children: [
              Icon(ic, size: 23, color: solid ? Colors.white : color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: solid ? Colors.white : color)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    d.ctrl.ptPx = _editorPx / d.pt; // so a size in points looks in proportion to the base size
    final base = GoogleFonts.getFont(kFonts[d.font], textStyle: TextStyle(fontSize: _editorPx, height: d.lh, color: cs.onSurface));
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 18, offset: const Offset(0, 6))]),
          child: Column(children: [
            Row(children: [
              _tile(Icons.content_paste_rounded, 'Paste', const Color(0xFF2563EB), () async {
                final t = (await Clipboard.getData('text/plain'))?.text;
                if (t != null) d.ctrl.insert(t);
              }),
              const SizedBox(width: 10),
              _tile(Icons.upload_file_rounded, 'Import', const Color(0xFFD97706), _importFile),
              const SizedBox(width: 10),
              _tile(_on ? Icons.stop_rounded : Icons.mic_rounded, _on ? 'Stop' : 'Voice typing', _on ? Colors.red : cs.primary, _mic, solid: _on),
            ]),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: cs.outlineVariant)),
            StyleBar(ctrl: d.ctrl, basePt: d.pt, baseFont: d.font, onChanged: d.touch, showHint: true),
            if (_on)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  const Icon(Icons.graphic_eq, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text('Listening...', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_choices.isNotEmpty)
                    DropdownButton<String>(
                      value: _choices.any((l) => l.localeId == _loc) ? _loc : null,
                      underline: const SizedBox(),
                      items: [for (final l in _choices) DropdownMenuItem(value: l.localeId, child: Text(kVoiceLocales[_norm(l.localeId)]!))],
                      onChanged: (v) async {
                        await _dict.stop();
                        setState(() => _loc = v!);
                        _startListening();
                      },
                    ),
                ]),
              ),
          ]),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            controller: d.ctrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            textDirection: d.td,
            style: base,
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surface,
              contentPadding: const EdgeInsets.all(18),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: cs.primary, width: 1.5)),
              hintText: 'Type, paste, import or speak your notes in any language',
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('${d.words} words · ${d.pages.length} pages', style: Theme.of(c).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ),
    ]);
  }
}
