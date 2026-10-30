import 'package:flutter/material.dart';

const kBlue = Color(0xFF2F5BFF);
const kMaroon = Color(0xFF800000);

ThemeData buildTheme(Brightness b) =>
    ThemeData(useMaterial3: true, colorSchemeSeed: kBlue, brightness: b);
