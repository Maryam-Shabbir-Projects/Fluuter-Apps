import 'package:flutter/material.dart';
import 'package:scankit/core/theme.dart';
import 'package:scankit/screens/home_screen.dart';
import 'package:scankit/services/store.dart';
import 'package:scankit/widgets/icon_badge.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _feature(IconData icon, String title, String subtitle) => Card(
        elevation: 0,
        child: ListTile(
          leading: IconBadge(icon),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
        ),
      );

  void _start(BuildContext context) {
    Store.i.setFlag('welcomed', true);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 20),
              Text('Welcome to ScanKit', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Scan and create barcodes in seconds.'),
              const SizedBox(height: 28),
              _feature(Icons.qr_code_scanner, 'Scan any barcode', 'EAN, UPC, Code 128, Code 39 and more'),
              _feature(Icons.add_box_outlined, 'Create barcodes', 'Generate, save and share'),
              _feature(Icons.history, 'Keep history', 'Everything stays on your device'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(onPressed: () => _start(context), child: const Text('Get started')),
              ),
            ]),
          ),
        ),
      );
}
