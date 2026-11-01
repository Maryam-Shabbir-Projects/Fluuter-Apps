import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';

const kPrimary = Color(0xFF4338CA);
const kInk = Color(0xFF14122B);
const kMuted = Color(0xFF5B5877);
const kBg = Color(0xFFF7F7FB);
const kLine = Color(0xFFE0DEEE);
const kTint = Color(0xFFE8E6FA);
const kLime = Color(0xFFC6F432);
const kDark = Color(0xFF0E0D1F);

// TODO: replace with your real pages and package id before publishing.
const kPrivacyUrl = 'https://YOUR-DOMAIN/privacy';
const kTermsUrl = 'https://YOUR-DOMAIN/terms';
const kStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourcompany.qrisp';

/// Cursive heading style (Dancing Script is open source, free to ship in apps).
TextStyle headStyle(double size, {Color color = kInk}) =>
    GoogleFonts.dancingScript(fontSize: size, fontWeight: FontWeight.w700, color: color, height: 1.1);

const _border = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: kLine, width: 1.5),
);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, primary: kPrimary),
      scaffoldBackgroundColor: kBg,
      appBarTheme: AppBarTheme(
        backgroundColor: kBg,
        foregroundColor: kInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: headStyle(30),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: _border,
        enabledBorder: _border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: kPrimary, width: 2),
        ),
      ),
    );

IconData iconFor(QrKind k) => switch (k) {
      QrKind.website => Icons.link,
      QrKind.text => Icons.text_fields,
      QrKind.wifi => Icons.wifi,
      QrKind.contact => Icons.person_outline,
      QrKind.email => Icons.mail_outline,
      QrKind.phone => Icons.phone_outlined,
    };

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outlined;
  final Color bg;
  final Color fg;
  const AppButton(this.label, {super.key, this.onTap, this.icon, this.outlined = false, this.bg = kPrimary, this.fg = Colors.white});

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ]);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary, shape: shape, side: const BorderSide(color: kPrimary, width: 1.5)),
              child: child)
          : FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg, shape: shape),
              child: child),
    );
  }
}

class KindChip extends StatelessWidget {
  final QrKind kind;
  const KindChip(this.kind, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(iconFor(kind), size: 14, color: kPrimary),
          const SizedBox(width: 6),
          Text(kind.label, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      );
}

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

Future<void> openUri(BuildContext context, String uri) async {
  try {
    final ok = await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) toast(context, 'Could not open this.');
  } catch (_) {
    if (context.mounted) toast(context, 'Could not open this.');
  }
}
