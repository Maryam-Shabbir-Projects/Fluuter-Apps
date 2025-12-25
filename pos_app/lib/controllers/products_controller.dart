import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductsController extends GetxController {
  var products = <Product>[].obs;

  void addProduct(Product product) {
    products.add(product);
  }

  void deleteProduct(int id) {
    products.removeWhere((p) => p.id == id);
  }

  List<Product> getProductsByCategory(int categoryId) {
    if (categoryId == 0) return products;
    return products.where((p) => p.categoryId == categoryId).toList();
  }
}
