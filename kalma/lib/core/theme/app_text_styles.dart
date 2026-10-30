import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle arabic(double size, Color color, {double height = 2}) =>
      GoogleFonts.amiri(fontSize: size, color: color, height: height);

  static TextStyle urdu(double size, Color color, {FontWeight? weight}) =>
      GoogleFonts.notoNastaliqUrdu(
          fontSize: size, color: color, fontWeight: weight, height: 1.9);

  static TextStyle title(double size, Color color) =>
      GoogleFonts.amiri(fontSize: size, color: color);

  static TextStyle body(double size, Color color,
          {FontWeight? weight, double? height, double? letterSpacing}) =>
      GoogleFonts.inter(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing);
}
