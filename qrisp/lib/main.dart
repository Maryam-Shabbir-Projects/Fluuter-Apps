import 'package:flutter/material.dart';
import 'shell.dart';
import 'store.dart';
import 'welcome_screen.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.I.load();
  runApp(const QrispApp());
}

class QrispApp extends StatelessWidget {
  const QrispApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qrisp',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: AppStore.I.onboarded ? const Shell() : const WelcomeScreen(),
    );
  }
}
