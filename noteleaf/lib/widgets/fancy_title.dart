import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cursive style; Urdu and Hindi names fall back to matching fonts.
TextStyle cursiveStyle(double size, {Color color = Colors.white}) => GoogleFonts.getFont('Pacifico', fontSize: size, color: color).copyWith(
      fontFamilyFallback: [GoogleFonts.getFont('Noto Nastaliq Urdu').fontFamily!, GoogleFonts.getFont('Noto Sans Devanagari').fontFamily!],
    );

/// File or folder name in a colourful cursive style (teal, blue, amber).
class FancyTitle extends StatelessWidget {
  final String text;
  final double size;
  const FancyTitle(this.text, {super.key, this.size = 22});
  @override
  Widget build(BuildContext c) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF2563EB), Color(0xFFF5A524)]).createShader(r),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: cursiveStyle(size)),
      );
}
