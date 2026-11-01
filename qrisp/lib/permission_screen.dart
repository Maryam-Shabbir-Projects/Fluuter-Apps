import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'shell.dart';
import 'widgets.dart';

/// Explains why the camera is needed BEFORE the system prompt appears.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  void _next(BuildContext context) =>
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.photo_camera_outlined, size: 44, color: kPrimary),
                ),
                const SizedBox(height: 18),
                Text('Allow camera access', style: headStyle(34)),
                const SizedBox(height: 18),
                const Text(
                  'Qrisp uses your camera only to read QR codes. Nothing is recorded or uploaded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.6, color: kMuted),
                ),
              ]),
            ),
            AppButton('Allow camera', onTap: () async {
              await Permission.camera.request();
              if (context.mounted) _next(context);
            }),
            const SizedBox(height: 12),
            AppButton('Scan from gallery instead', outlined: true, icon: Icons.image_outlined, onTap: () => _next(context)),
            const SizedBox(height: 28),
          ]),
        ),
      ),
    );
  }
}
