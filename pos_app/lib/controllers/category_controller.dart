import 'package:get/get.dart';
import '../models/category_model.dart';

class CategoriesController extends GetxController {
  var categories = <Category>[].obs;
  int _id = 1;

  void addCategory(String name) {
    categories.add(Category(id: _id++, name: name));
  }

  void editCategory(int id, String name) {
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index].name = name;
      categories.refresh();
    }
  }

  void deleteCategory(int id) {
    categories.removeWhere((c) => c.id == id);
  }
}
