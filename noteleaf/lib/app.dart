import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'screens/home.dart';
import 'screens/welcome.dart';

class NoteLeafApp extends StatelessWidget {
  final bool seenWelcome;
  const NoteLeafApp({super.key, required this.seenWelcome});

  ThemeData _theme(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E66), brightness: b).copyWith(surface: dark ? const Color(0xFF16201F) : Colors.white);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0D1413) : const Color(0xFFF2F5F4),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData(brightness: b).textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0, backgroundColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      chipTheme: ChipThemeData(shape: const StadiumBorder(), side: BorderSide(color: scheme.outlineVariant), selectedColor: scheme.primaryContainer),
      sliderTheme: const SliderThemeData(trackHeight: 4),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(64, 48), shape: shape, textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48), shape: shape)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: seenWelcome ? const Home() : const Welcome(),
      );
}
