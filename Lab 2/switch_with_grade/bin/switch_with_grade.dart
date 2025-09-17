import 'dart:io';

void main() {
  print("Enter a grade (A-F): ");
  String grade = stdin.readLineSync()!.toUpperCase();
  switch (grade) {
    case 'A':
      print("Excellent");
      break;
    case 'B':
      print("Good");
      break;
    case 'C':
      print("Average");
      break;
    case 'D':
      print("Poor");
      break;
    case 'F':
      print("Fail");
      break;
    default:
      print("Invalid grade");
  }
}