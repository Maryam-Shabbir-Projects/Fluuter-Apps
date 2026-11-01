import 'package:flutter/material.dart';
import 'package:scankit/core/theme.dart';
import 'package:scankit/screens/home_screen.dart';
import 'package:scankit/screens/welcome_screen.dart';
import 'package:scankit/services/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.i.init();
  runApp(const ScanKitApp());
}

class ScanKitApp extends StatelessWidget {
  const ScanKitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ScanKit',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: Store.i.welcomed ? const HomeScreen() : const WelcomeScreen(),
      );
}
