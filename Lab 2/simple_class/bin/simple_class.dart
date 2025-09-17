class Student{
  String name;
  int age;
  Student(this.name , this.age);
}
void main(){
  Student student = Student("Maryam" , 20);
  print("name of student : ");
  print(student.name);
  print("age of student : ");
  print(student.age);
}