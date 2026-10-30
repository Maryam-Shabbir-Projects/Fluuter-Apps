import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';
import 'package:cgpa_calculator/data/storage_repository.dart';
import 'package:cgpa_calculator/features/home/home_shell.dart';
import 'package:cgpa_calculator/features/onboarding/onboarding_screen.dart';
import 'package:cgpa_calculator/features/welcome/welcome_screen.dart';
import 'package:cgpa_calculator/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await StorageRepository.create();
  final state = AppState(repo);
  await state.load();
  runApp(ChangeNotifierProvider.value(value: state, child: const CgpaApp()));
}

class CgpaApp extends StatefulWidget {
  const CgpaApp({super.key});

  @override
  State<CgpaApp> createState() => _CgpaAppState();
}

class _CgpaAppState extends State<CgpaApp> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final onboarded = context.select<AppState, bool>((s) => s.onboarded);
    if (onboarded) _started = false; // so a later reset shows the landing page again
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: onboarded
          ? const HomeShell()
          : _started
              ? OnboardingScreen(onBack: () => setState(() => _started = false))
              : WelcomeScreen(onStart: () => setState(() => _started = true)),
    );
  }
}
