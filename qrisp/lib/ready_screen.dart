import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'widgets.dart';

class ReadyScreen extends StatefulWidget {
  final String raw;
  const ReadyScreen({super.key, required this.raw});
  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  static const _colors = [kInk, kPrimary, Color(0xFF0F766E), Color(0xFFB42318)];
  Color _color = kInk;
  bool _dots = false;
  int _ec = QrErrorCorrectLevel.M;
  ui.Image? _logo;

  QrPainter _qr() => QrPainter(
        data: widget.raw,
        version: QrVersions.auto,
        errorCorrectionLevel: _ec,
        eyeStyle: QrEyeStyle(eyeShape: _dots ? QrEyeShape.circle : QrEyeShape.square, color: _color),
        dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: _dots ? QrDataModuleShape.circle : QrDataModuleShape.square, color: _color),
      );

  /// Draws the exact same picture as the preview: solid white background,
  /// quiet zone, QR, then the logo. Used for Save and Share so they always scan.
  Future<Uint8List?> _png() async {
    const size = 1024.0;
    final rec = ui.PictureRecorder();
    _QrArt(_qr(), _logo).paint(Canvas(rec), const Size(size, size));
    final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
    final d = await img.toByteData(format: ui.ImageByteFormat.png);
    return d?.buffer.asUint8List();
  }

  Future<void> _pickLogo() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (f == null) return;
    final img = await decodeImageFromList(await f.readAsBytes());
    setState(() {
      _logo = img;
      _ec = QrErrorCorrectLevel.H; // logos need strong error correction
    });
  }

  Future<void> _save() async {
    try {
      final b = await _png();
      if (b == null) return;
      if (!await Gal.hasAccess()) await Gal.requestAccess();
      await Gal.putImageBytes(b, album: 'Qrisp');
      if (mounted) toast(context, 'Saved to your gallery');
    } catch (_) {
      if (mounted) toast(context, 'Could not save the image.');
    }
  }

  Future<void> _share() async {
    final b = await _png();
    if (b == null) return;
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/qrisp_${DateTime.now().millisecondsSinceEpoch}.png');
    await f.writeAsBytes(b);
    await Share.shareXFiles([XFile(f.path, mimeType: 'image/png')]);
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kMuted)),
      );

  @override
  Widget build(BuildContext context) {
    final p = parseQr(widget.raw);
    return Scaffold(
      appBar: AppBar(title: const Text('Your QR code')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kLine),
            ),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(size: const Size(240, 240), painter: _QrArt(_qr(), _logo)),
              ),
              const SizedBox(height: 14),
              Text('${p.kind.label}: ${p.title}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
          _label('Colour'),
          Row(children: [
            for (final c in _colors)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Semantics(
                  button: true,
                  label: 'Colour',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: _color == c ? kPrimary : kLine, width: _color == c ? 3 : 1),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
          _label('Shape'),
          Wrap(spacing: 10, children: [
            ChoiceChip(label: const Text('Square'), selected: !_dots, onSelected: (_) => setState(() => _dots = false)),
            ChoiceChip(label: const Text('Dots'), selected: _dots, onSelected: (_) => setState(() => _dots = true)),
          ]),
          _label('Error correction'),
          Wrap(spacing: 10, children: [
            for (final o in const {'Low': QrErrorCorrectLevel.L, 'Medium': QrErrorCorrectLevel.M, 'High': QrErrorCorrectLevel.H}.entries)
              ChoiceChip(
                label: Text(o.key),
                selected: _ec == o.value,
                onSelected: (_) => setState(() => _ec = o.value),
              ),
          ]),
          const SizedBox(height: 18),
          AppButton(_logo == null ? 'Add logo in the centre' : 'Remove logo',
              outlined: true,
              icon: Icons.image_outlined,
              onTap: _logo == null ? _pickLogo : () => setState(() => _logo = null)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: AppButton('Save', outlined: true, icon: Icons.download, onTap: _save)),
            const SizedBox(width: 10),
            Expanded(child: AppButton('Share', icon: Icons.share_outlined, onTap: _share)),
          ]),
          const SizedBox(height: 14),
          const Text('Tip: always test your code with another phone before printing it.',
              style: TextStyle(fontSize: 12, color: kMuted)),
        ]),
      ),
    );
  }
}

/// QR on an opaque white square. The logo sits on a white rounded plate
/// (about 25% of the width) so it is clearly visible but the code still scans.
class _QrArt extends CustomPainter {
  final QrPainter qr;
  final ui.Image? logo;
  _QrArt(this.qr, this.logo);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final pad = s * 0.12; // quiet zone: scanners need a white border
    canvas.save();
    canvas.translate(pad, pad);
    qr.paint(canvas, Size(s - 2 * pad, s - 2 * pad));
    canvas.restore();
    final l = logo;
    if (l != null) {
      final box = s * 0.25;
      final r = Rect.fromCenter(center: Offset(s / 2, s / 2), width: box, height: box);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(box * 0.18)), Paint()..color = Colors.white);
      paintImage(canvas: canvas, rect: r.deflate(box * 0.08), image: l, fit: BoxFit.contain, filterQuality: FilterQuality.high);
    }
  }

  @override
  bool shouldRepaint(covariant _QrArt old) => true;
}
