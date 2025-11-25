import 'package:flutter/material.dart';
import 'inputpage.dart';
void main() {
  runApp(const BMICalculator());
}

// ----------------------------------------
// MAIN UI WIDGET
// ----------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InputPage(title: "BMI Calculator");
  }
}

// ----------------------------------------
// ALL CLASSES ARE BELOW
// ----------------------------------------

// 1️⃣ BMICalculator Class
class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        primaryColor: Colors.red,
      ),
      home: const InputPage(title: 'BMI Calculator'),
      //theme:ThemeData.dark(),
    );
  }
}

// 2️⃣ InputPage Class

