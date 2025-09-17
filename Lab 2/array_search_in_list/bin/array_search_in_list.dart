//check number
import 'dart:io';
void main(){
  List<int> numbers = [10, 20, 30 ,40, 50];
  print("enter a number : ");
  int target = int.parse(stdin.readLineSync()!);
  if (numbers.contains(target)){
    print("number found");
  }
  else{
    print("number not found");
  }
}