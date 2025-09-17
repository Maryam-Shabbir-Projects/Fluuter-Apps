//rectangle
class Rectangle {
  int length;
  int width;
  Rectangle(this.length , this.width);
  int area(){
    return length*width;
  }
}
void main(){
  Rectangle rectangle = Rectangle(10,6);
  print("area is : ");
  print(rectangle.area());
}