import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models.dart';
import 'result_screen.dart';
import 'store.dart';
import 'widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _c = MobileScannerController();
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _handle(String? raw) async {
    if (raw == null || raw.isEmpty || _busy) return;
    _busy = true;
    final s = AppStore.I;
    if (s.vibrate) HapticFeedback.mediumImpact();
    if (s.beep) SystemSound.play(SystemSoundType.click);
    s.add(raw, created: false);
    await _c.stop();
    if (!mounted) return;
    final parsed = parseQr(raw);
    if (s.autoOpen && parsed.kind == QrKind.website) {
      await openUri(context, raw);
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(raw: raw)));
    }
    if (!mounted) return;
    _busy = false;
    await _c.start();
  }

  Future<void> _gallery() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f == null) return;
    final cap = await _c.analyzeImage(f.path);
    final raw = cap?.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      if (mounted) toast(context, 'No QR code found in that image.');
    } else {
      await _handle(raw);
    }
  }

  Widget _round(IconData i, String label, VoidCallback onTap) => Semantics(
        label: label,
        button: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Color(0xFF2A2850), shape: BoxShape.circle),
            child: Icon(i, color: Colors.white, size: 22),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDark,
      child: Stack(fit: StackFit.expand, children: [
        MobileScanner(
          controller: _c,
          onDetect: (cap) => _handle(cap.barcodes.firstOrNull?.rawValue),
          errorBuilder: (context, error, child) => _NoCamera(onGallery: _gallery),
        ),
        const IgnorePointer(child: Center(child: SizedBox(width: 260, height: 260, child: CustomPaint(painter: _FramePainter())))),
        SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _c,
                  builder: (_, st, __) => _round(
                    st.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    'Flash',
                    () => _c.toggleTorch(),
                  ),
                ),
                _round(Icons.image_outlined, 'Scan from gallery', _gallery),
              ]),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(children: [
                Text('Scan anything', style: headStyle(34, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Point at a QR code or barcode',
                    style: TextStyle(color: Color(0xFFB9B6D6), fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _NoCamera extends StatelessWidget {
  final VoidCallback onGallery;
  const _NoCamera({required this.onGallery});
  @override
  Widget build(BuildContext context) => Container(
        color: kDark,
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text('Camera is not available',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Allow camera access in settings, or scan a QR code from a photo.',
              textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB9B6D6), height: 1.5)),
          const SizedBox(height: 24),
          AppButton('Open settings', bg: kLime, fg: kDark, onTap: openAppSettings),
          const SizedBox(height: 12),
          AppButton('Scan from gallery', outlined: true, icon: Icons.image_outlined, onTap: onGallery),
        ]),
      );
}

class _FramePainter extends CustomPainter {
  const _FramePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = kLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const l = 44.0;
    final w = size.width, h = size.height;
    canvas.drawPath(Path()..moveTo(0, l)..lineTo(0, 0)..lineTo(l, 0), p);
    canvas.drawPath(Path()..moveTo(w - l, 0)..lineTo(w, 0)..lineTo(w, l), p);
    canvas.drawPath(Path()..moveTo(0, h - l)..lineTo(0, h)..lineTo(l, h), p);
    canvas.drawPath(Path()..moveTo(w - l, h)..lineTo(w, h)..lineTo(w, h - l), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
