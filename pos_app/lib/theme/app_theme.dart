import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF1976D2); // Blue
  static const Color primaryColorLight = Color(0xFF63A4FF);
  static const Color primaryColorDark = Color(0xFF004BA0);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFFA726); // Orange

  // Background colors
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5);
  static const Color drawerBackgroundColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Accent colors
  static const Color accentColor = Color(0xFF00BCD4); // Cyan

  // Button colors
  static const Color buttonColor = primaryColor;
  static const Color buttonTextColor = Colors.white;

  // Border radius
  static const double borderRadius = 8.0;

  // Shadows
  static const List<BoxShadow> boxShadow = [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    color: textPrimaryColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
  );

  // ThemeData for the app
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      drawerTheme: const DrawerThemeData(
        backgroundColor: drawerBackgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 2,
        titleTextStyle: headline6,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: headline1,
        titleLarge: headline6,
        bodyLarge: bodyText1,
        bodyMedium: bodyText2,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColorLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor),
        ),
        labelStyle: const TextStyle(color: primaryColorDark),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(primaryColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(primaryColor),
        trackColor: MaterialStateProperty.all(primaryColorLight),
      ),
    );
  }
}
