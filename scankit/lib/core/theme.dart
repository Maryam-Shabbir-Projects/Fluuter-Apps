import 'package:flutter/material.dart';

const teal = Color(0xFF0B6E63);
const scanLine = Color(0xFF5EE0CF);

ThemeData buildTheme(Brightness b) => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: teal, brightness: b),
      useMaterial3: true,
    );
