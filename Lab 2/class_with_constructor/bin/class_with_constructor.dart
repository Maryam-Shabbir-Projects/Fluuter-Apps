//car
class Car{
  String brand;
  int year;
  Car(this.brand ,this.year );
}
void main(){
  Car car = Car("BMW" ,2025);
  print("brand is : ");
  print(car.brand);
  print("year is : ");
  print(car.year);
}