import 'dart:io';
void main(){
  int count = 0;
  int input;
  do{
    print("enter a number : ");
    input = int.parse(stdin.readLineSync()!);
    if(input !=0) count++;
  } while (input !=0);
  print("count is : ");
  print(count);
}