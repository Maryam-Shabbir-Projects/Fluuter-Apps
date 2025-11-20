import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';  // Import welcome screen
import 'utils/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: taskProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const WelcomeScreen(),  // Start with WelcomeScreen
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
