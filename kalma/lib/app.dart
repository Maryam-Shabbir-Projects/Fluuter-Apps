import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/landing/landing_screen.dart';

class KalmaApp extends StatelessWidget {
  const KalmaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Six Kalmas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LandingScreen(),
      );
}
