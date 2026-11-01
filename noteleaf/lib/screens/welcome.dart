import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/storage.dart';
import '../widgets/logo.dart';
import 'home.dart';

/// First-run tour. Also reachable later from the menu on the home screen.
class Welcome extends StatefulWidget {
  final bool fromMenu;
  const Welcome({super.key, this.fromMenu = false});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _pc = PageController();
  int _i = 0;
  static const _slides = [
    (Icons.keyboard_voice_rounded, 'Write in any language', 'Type, paste, import a Word or text file, or just speak. Urdu, Hindi, Arabic, English and more.'),
    (Icons.palette_rounded, 'Make every page beautiful', 'Many font styles, colours and gradients. Use your own photo as paper, add a logo and faded channel name.'),
    (Icons.movie_creation_rounded, 'Export with your voice', 'Save pages as images or a video. Add your voice and the pages follow it automatically.'),
  ];

  Future<void> _done() async {
    if (widget.fromMenu) {
      Navigator.pop(context);
      return;
    }
    await Storage.markSeen();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
  }

  Widget _paper(ColorScheme cs, double angle, Color color, {bool lines = true}) => Transform.rotate(
        angle: angle,
        child: Container(
          width: 128,
          height: 168,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 18, offset: const Offset(0, 8))]),
          child: lines
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final w in [1.0, 0.85, 1.0, 0.6, 0.9])
                    Container(height: 6, width: 96 * w, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: cs.primary.withAlpha(70), borderRadius: BorderRadius.circular(3))),
                ])
              : null,
        ),
      );

  Widget _art(ColorScheme cs, IconData icon) => SizedBox(
        width: 280,
        height: 250,
        child: Stack(alignment: Alignment.center, children: [
          Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer.withAlpha(150))),
          Positioned(left: 36, top: 30, child: _paper(cs, -0.18, const Color(0xFFFFE9B8), lines: false)),
          Positioned(right: 34, top: 36, child: _paper(cs, 0.16, const Color(0xFFCDE9E5), lines: false)),
          _paper(cs, 0, Colors.white),
          Positioned(
            right: 52,
            bottom: 18,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary, boxShadow: [BoxShadow(color: cs.primary.withAlpha(90), blurRadius: 18, offset: const Offset(0, 8))]),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme, tt = Theme.of(c).textTheme;
    final last = _i == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(children: [
              const LeafLogo(size: 34),
              const SizedBox(width: 10),
              Text(kAppName, style: tt.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(onPressed: _done, child: const Text('Skip')),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) {
                final s = _slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _art(cs, s.$1),
                    const SizedBox(height: 28),
                    Text(s.$2, textAlign: TextAlign.center, style: tt.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(s.$3, textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(fontSize: 13.5, color: cs.onSurfaceVariant, height: 1.5)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var k = 0; k < _slides.length; k++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: k == _i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: k == _i ? cs.primary : cs.outlineVariant),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => last ? _done() : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                child: Text(last ? 'Get started' : 'Continue', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
