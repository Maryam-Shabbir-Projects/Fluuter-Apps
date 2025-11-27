import 'package:flutter/material.dart';
import 'inputpage.dart';

void main() {
  runApp(const BMICalculator());
}

// --------------------------------------------------
// BMICalculator (Main App Class)
// --------------------------------------------------
class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black, // make screen black
      ),
      home: const InputPage(title: 'BMI Calcultor'),
    );
  }
}



