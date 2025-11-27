
import 'dart:math';

class BMICalculator {
  final int height; // in cm
  final int weight; // in kg

  double _bmi = 0.0;

  BMICalculator({required this.height, required this.weight});

  // Method to calculate BMI (kg/m^2)
  String calculateBMI() {
    // Convert height from cm to meters (height / 100)
    _bmi = weight / pow(height / 100, 2);
    // Return the result formatted to one decimal place
    return _bmi.toStringAsFixed(1);
  }

  // Method to get the text result (Underweight, Normal, Overweight, etc.)
  String getResult() {
    if (_bmi >= 25) {
      return 'OVERWEIGHT';
    } else if (_bmi > 18.5) {
      return 'NORMAL';
    } else {
      return 'UNDERWEIGHT';
    }
  }

  // Method to get the interpretation (advice)
  String getInterpretation() {
    if (_bmi >= 25) {
      return 'Your BMI is high. You should exercise more and follow a balanced diet.';
    } else if (_bmi > 18.5) {
      return 'Your BMI is within the normal range. Good job!';
    } else {
      return 'Your BMI is low. You should eat a bit more to be healthy.';
    }
  }
}