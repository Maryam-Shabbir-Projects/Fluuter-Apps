import 'package:flutter/material.dart';
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import '../../models/doc.dart';
import '../../services/exporter.dart';
import '../../services/importer.dart';
import '../../services/voice.dart';
import '../../widgets/common.dart';
import '../../widgets/toggle_group.dart';

class ExportTab extends StatefulWidget {
  final Doc d;
  const ExportTab(this.d, {super.key});
  @override
  State<ExportTab> createState() => _ExportState();
}

class _ExportState extends State<ExportTab> {
  final _rec = VoiceRecorder();
  bool video = false, hd = true, sync = true, busy = false, recording = false, allPages = true, ok = true;
  double sec = 4, prog = 0;
  RangeValues? range;
  String msg = '';
  Doc get d => widget.d;
  int get n => d.pages.length;

  RangeValues get rv {
    final r = range ?? RangeValues(1, n.toDouble());
    final a = r.start.clamp(1.0, n.toDouble()), b = r.end.clamp(a, n.toDouble());
    return RangeValues(a, b);
  }

  int get count => allPages || n < 2 ? n : rv.end.round() - rv.start.round() + 1;

  Future<void> _record() async {
    if (recording) {
      final p = await _rec.stop();
      setState(() => recording = false);
      if (p != null) d.setAudio(p);
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    if (await _rec.start('${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a')) {
      setState(() => recording = true);
    } else {
      setState(() { msg = 'Microphone permission was denied'; ok = false; });
    }
  }

  Future<void> _importAudio() async {
    try {
      final p = await Importer.pickAudio();
      if (p != null) d.setAudio(p);
    } catch (e) {
      setState(() { msg = 'Could not import: $e'; ok = false; });
    }
  }

  Future<void> _run() async {
    setState(() { busy = true; prog = 0; msg = ''; });
    try {
      msg = await Exporter.run(d,
          video: video, hd: hd, sec: sec, sync: sync, from: allPages ? 1 : rv.start.round(), to: allPages ? 0 : rv.end.round(), onProgress: (v) => setState(() => prog = v));
      ok = true;
    } catch (e) {
      msg = 'Export failed: $e';
      ok = false;
    }
    if (mounted) setState(() => busy = false);
  }

  // ---------- pieces ----------
  Widget _summary(ColorScheme cs) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F8F82), Color(0xFF0A5C56)]),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.ios_share_rounded, color: Colors.white)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ready to export', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('$n pages · ${d.px.width.round()} × ${d.px.height.round()} px', style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12.5)),
            ]),
          ),
        ]),
      );

  Widget _option(ColorScheme cs, IconData ic, String title, String sub, bool on, VoidCallback tap) => Expanded(
        child: GestureDetector(
          onTap: tap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: on ? cs.primaryContainer.withAlpha(110) : cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: on ? 2 : 1, color: on ? cs.primary : cs.outlineVariant),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: on ? cs.primary : cs.onSurface.withAlpha(14), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: on ? cs.onPrimary : cs.onSurface)),
                const Spacer(),
                Icon(on ? Icons.check_circle_rounded : Icons.circle_outlined, color: on ? cs.primary : cs.outline, size: 22),
              ]),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(sub, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ]),
          ),
        ),
      );

  Widget _valueTag(ColorScheme cs, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(150), borderRadius: BorderRadius.circular(10)),
        child: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cs.onPrimaryContainer)),
      );

  Widget _pagesPanel(ColorScheme cs) => Panel(
        title: 'Pages',
        icon: Icons.auto_stories_outlined,
        trailing: _valueTag(cs, '$count of $n'),
        child: Column(children: [
          if (n > 1) ToggleGroup(items: const [(Icons.select_all, 'All pages'), (Icons.linear_scale, 'Choose range')], selected: allPages ? 0 : 1, onChanged: (v) => setState(() => allPages = v == 0)),
          if (!allPages && n > 1) ...[
            const SizedBox(height: 14),
            Row(children: [Text('From ${rv.start.round()}', style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), Text('to ${rv.end.round()}', style: const TextStyle(fontWeight: FontWeight.w600))]),
            RangeSlider(values: rv, min: 1, max: n.toDouble(), divisions: n - 1, labels: RangeLabels('${rv.start.round()}', '${rv.end.round()}'), onChanged: (v) => setState(() => range = v)),
          ] else if (n <= 1)
            Text('Your file has one page.', style: TextStyle(color: cs.onSurfaceVariant)),
        ]),
      );

  Widget _videoPanel(ColorScheme cs) => Panel(
        title: 'Video',
        icon: Icons.movie_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quality', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ToggleGroup(items: const [(Icons.hd_outlined, 'Full size'), (Icons.speed, 'Smaller, faster')], selected: hd ? 0 : 1, onChanged: (v) => setState(() => hd = v == 0)),
          if (!(d.audio != null && sync)) ...[
            const SizedBox(height: 16),
            Row(children: [Text('Time for each page', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)), const Spacer(), _valueTag(cs, '${sec.round()} sec')]),
            Slider(value: sec, min: 1, max: 20, divisions: 19, onChanged: (v) => setState(() => sec = v)),
          ],
        ]),
      );

  Widget _voiceTile(ColorScheme cs, IconData ic, String label, Color color, VoidCallback? tap, {bool solid = false}) => Expanded(
        child: GestureDetector(
          onTap: tap,
          child: Opacity(
            opacity: tap == null ? 0.45 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: solid ? color : color.withAlpha(30), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Icon(ic, size: 26, color: solid ? Colors.white : color),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: solid ? Colors.white : color)),
              ]),
            ),
          ),
        ),
      );

  Widget _voicePanel(ColorScheme cs) => Panel(
        title: 'Voice-over',
        icon: Icons.graphic_eq,
        child: d.audio == null
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Add your voice and the pages follow it automatically.', style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(children: [
                  _voiceTile(cs, recording ? Icons.stop_rounded : Icons.mic_rounded, recording ? 'Stop recording' : 'Record voice', recording ? Colors.red : cs.primary, _record, solid: recording),
                  const SizedBox(width: 10),
                  _voiceTile(cs, Icons.audio_file_rounded, 'Add audio file', const Color(0xFFD97706), recording ? null : _importAudio),
                ]),
              ])
            : Column(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(90), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Container(width: 38, height: 38, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(11)), child: Icon(Icons.graphic_eq, color: cs.onPrimary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(pth.basename(d.audio!), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                    IconButton(tooltip: 'Remove voice', icon: const Icon(Icons.close_rounded), onPressed: () => d.setAudio(null)),
                  ]),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sync pages to voice', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Each page gets time in proportion to its words'),
                  value: sync,
                  onChanged: (v) => setState(() => sync = v),
                ),
              ]),
      );

  Widget _bottom(ColorScheme cs) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(color: cs.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 16, offset: const Offset(0, -4))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (busy) ...[
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: prog, minHeight: 8))),
              const SizedBox(width: 12),
              Text('${(prog * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
          ],
          if (msg.isNotEmpty && !busy) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: (ok ? const Color(0xFF1B7F4B) : const Color(0xFFD93025)).withAlpha(26), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, size: 20, color: ok ? const Color(0xFF1B7F4B) : const Color(0xFFD93025)),
                const SizedBox(width: 10),
                Expanded(child: Text(msg, style: const TextStyle(fontSize: 12.5, height: 1.35))),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              onPressed: busy || recording ? null : _run,
              icon: Icon(video ? Icons.movie_creation_rounded : Icons.photo_library_rounded),
              label: Text(busy ? 'Exporting...' : (video ? 'Export video' : 'Export $count ${count == 1 ? 'image' : 'images'}'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
          _summary(cs),
          const SizedBox(height: 14),
          Row(children: [
            _option(cs, Icons.image_rounded, 'Images', 'One PNG per page', !video, () => setState(() => video = false)),
            const SizedBox(width: 12),
            _option(cs, Icons.movie_rounded, 'Video', 'MP4 with voice-over', video, () => setState(() => video = true)),
          ]),
          const SizedBox(height: 14),
          _pagesPanel(cs),
          if (video) ...[_videoPanel(cs), _voicePanel(cs)],
        ]),
      ),
      _bottom(cs),
    ]);
  }
}
