import 'package:flutter/material.dart';

/// Calm sage palette with soft sand and clay accents.
class AppTheme {
  AppTheme._();

  static const _sage = Color(0xFF4F7F77);
  static const _sageDark = Color(0xFF86B5AC);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: _sage, brightness: b).copyWith(
      primary: dark ? _sageDark : _sage,
      onPrimary: dark ? const Color(0xFF10201D) : Colors.white,
      secondary: const Color(0xFFC9AB91),
      surface: dark ? const Color(0xFF1A2322) : const Color(0xFFFAFBFA),
      onSurface: dark ? const Color(0xFFE2EBE8) : const Color(0xFF2C3A37),
      outlineVariant: dark ? const Color(0xFF2A3735) : const Color(0xFFE0E7E3),
    );
    final bg = dark ? const Color(0xFF121918) : const Color(0xFFF0F3F1);
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.5),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: scheme.primary, width: 1.5),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: dark ? const Color(0xFF23312F) : const Color(0xFFE4EEEB),
      ),
    );
  }
}

/// Extra semantic colours that are not part of [ColorScheme].
extension AppPalette on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get softFill => isDark ? const Color(0xFF23312F) : const Color(0xFFE4EEEB);
  Color get okColor => isDark ? const Color(0xFF8CC4A3) : const Color(0xFF4F8A6A);
  Color get okFill => isDark ? const Color(0xFF21342A) : const Color(0xFFE1EEE6);
  Color get clayColor => isDark ? const Color(0xFFD9A073) : const Color(0xFFC08657);
  Color get clayFill => isDark ? const Color(0xFF33291F) : const Color(0xFFF5EBE0);
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF335F58), Color(0xFF43736B)]
            : const [Color(0xFF4F7F77), Color(0xFF6B9A92)],
      );
}
