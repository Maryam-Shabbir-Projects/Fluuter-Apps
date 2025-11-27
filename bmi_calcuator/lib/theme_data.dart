import 'package:flutter/material.dart';
import 'constants.dart'; // Import your colors

final ThemeData kDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: kPrimaryColor, 
  colorScheme: const ColorScheme.dark().copyWith(
    primary: kPrimaryColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
  ),
);