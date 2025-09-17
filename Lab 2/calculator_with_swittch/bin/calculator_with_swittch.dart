//calculator
import 'dart:io';

void main() {
  print("Enter the first number: ");
  double num1 = double.parse(stdin.readLineSync()!);
  print("Enter the operator (+, -, *, /): ");
  String operator = stdin.readLineSync()!;
  print("Enter the second number: ");
  double num2 = double.parse(stdin.readLineSync()!);
  switch (operator) {
    case '+':
      print("Result: " + (num1 + num2).toString());
      break;
    case '-':
      print("Result: " + (num1 - num2).toString());
      break;
    case '*':
      print("Result: " + (num1 * num2).toString());
      break;
    case '/':
      if (num2 != 0) {
        print("Result: " + (num1 / num2).toString());
      } else {
        print("Error: Division by zero");
      }
      break;
    default:
      print("Invalid operator");
  }
}