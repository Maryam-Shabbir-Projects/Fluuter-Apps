import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_screen.dart';
import 'shell.dart';
import 'store.dart';
import 'widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _feat(IconData i, String t, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFF24224A), borderRadius: BorderRadius.circular(12)),
            child: Icon(i, color: kLime, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              Text(s, style: const TextStyle(color: Color(0xFFB9B6D6), fontSize: 13)),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Spacer(),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(color: kLime, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.qr_code_2, size: 48, color: kDark),
            ),
            const SizedBox(height: 22),
            Text('Qrisp', style: headStyle(64, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Scan and create QR codes in a snap.',
                style: TextStyle(color: Color(0xFFB9B6D6), fontSize: 17, height: 1.5)),
            const SizedBox(height: 28),
            _feat(Icons.qr_code_scanner, 'Fast scanning', 'Point your camera and go'),
            _feat(Icons.add_box_outlined, 'Create your own', 'Links, Wi-Fi, contacts and more'),
            _feat(Icons.verified_user_outlined, 'Private by design', 'No account. Scans stay on your phone.'),
            const Spacer(),
            AppButton('Get started', bg: kLime, fg: kDark, onTap: () async {
              await AppStore.I.set('onboarded', true);
              if (!context.mounted) return;
              final granted = await Permission.camera.isGranted;
              if (!context.mounted) return;
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => granted ? const Shell() : const PermissionScreen()));
            }),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(onPressed: () => openUri(context, kTermsUrl), child: const Text('Terms')),
              const Text('and', style: TextStyle(color: Color(0xFFB9B6D6), fontSize: 12)),
              TextButton(onPressed: () => openUri(context, kPrivacyUrl), child: const Text('Privacy Policy')),
            ]),
          ]),
        ),
      ),
    );
  }
}
