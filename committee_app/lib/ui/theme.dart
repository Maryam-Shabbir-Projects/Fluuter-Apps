import 'package:flutter/material.dart';

final AppTheme = ThemeData(
  useMaterial3: true, // ✅ Enables Material 3 styling
  colorSchemeSeed: Colors.indigo, // Replaces primarySwatch
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.grey[50],
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // replaces headline6
    bodyMedium: TextStyle(fontSize: 14), // replaces bodyText2
  ),
);
