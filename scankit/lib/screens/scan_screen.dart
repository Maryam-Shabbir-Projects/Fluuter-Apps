import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scankit/core/theme.dart';
import 'package:scankit/models/entry.dart';
import 'package:scankit/screens/result_screen.dart';
import 'package:scankit/services/store.dart';

class ScanScreen extends StatefulWidget {
  final bool active;
  const ScanScreen({super.key, required this.active});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.code128, BarcodeFormat.code39, BarcodeFormat.code93, BarcodeFormat.ean13,
      BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE, BarcodeFormat.itf, BarcodeFormat.codabar,
    ],
  );
  bool _busy = false;

  Future<void> _onCapture(BarcodeCapture capture) async {
    if (_busy || !widget.active) return;
    final found = capture.barcodes.where((b) => b.rawValue != null).toList();
    if (found.isEmpty) return;
    _busy = true;
    final s = Store.i;
    if (s.vibrate) HapticFeedback.mediumImpact();
    if (s.beep) SystemSound.play(SystemSoundType.click);
    final entry = Entry(found.first.rawValue!, found.first.format.name, false);
    s.add(entry);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(entry)));
    _busy = false;
  }

  Future<void> _pickFromGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final capture = await _controller.analyzeImage(file.path);
    if (capture != null && capture.barcodes.isNotEmpty) {
      await _onCapture(capture);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No barcode found in image')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          MobileScanner(controller: _controller, onDetect: _onCapture),
          Center(
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: scanLine, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton.filledTonal(tooltip: 'Flash', onPressed: _controller.toggleTorch, icon: const Icon(Icons.flash_on)),
                IconButton.filledTonal(tooltip: 'Gallery', onPressed: _pickFromGallery, icon: const Icon(Icons.image_outlined)),
              ]),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Text(
              'Point the camera at a barcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ]),
      );
}
