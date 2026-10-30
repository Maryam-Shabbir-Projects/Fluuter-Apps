import 'package:flutter/material.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';

const _green = Color(0xFF2F7D4F);
const _greenDeep = Color(0xFF1F5136);
const _offWhite = Color(0xFFFAF8F1);

/// Landing page shown on first launch, before the setup steps.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: .6);
    final accent = dark ? const Color(0xFF8FC9A3) : _green;
    final titleColor = dark ? const Color(0xFFE2EBE8) : _greenDeep;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF121918), Color(0xFF17221E), Color(0xFF1D2F25)]
                : const [_offWhite, Color(0xFFEEF3E3), Color(0xFFD5EAC8)],
            stops: const [0, .45, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.calculate_rounded, color: _offWhite, size: 48),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'CGPA Calculator',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: titleColor, fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your grades and know your result in seconds',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  _Point(Icons.list_alt_rounded, 'Add courses and credit hours', accent),
                  const SizedBox(height: 14),
                  _Point(Icons.show_chart_rounded, 'See your GPA for each semester', accent),
                  const SizedBox(height: 14),
                  _Point(Icons.track_changes_rounded, 'Plan the grades you need next', accent),
                  const SizedBox(height: 34),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: dark ? const Color(0xFF3E8F5F) : _green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Get started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Text('Works offline. No sign-up needed.', style: TextStyle(color: muted, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text, this.accent);
  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ]);
}
