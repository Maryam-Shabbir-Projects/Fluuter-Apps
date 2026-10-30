import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/welcome_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const ThumblyApp());
}

class ThumblyApp extends StatelessWidget {
  const ThumblyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Thumbly',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const WelcomeScreen(),
      );
}
