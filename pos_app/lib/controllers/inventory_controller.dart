import 'package:get/get.dart';

class InventoryItem {
  int productId;
  String productName;
  int categoryId;
  int inStock;
  double salePrice;
  double purchasePrice;
  DateTime lastPurchaseDate;

  InventoryItem({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.inStock,
    required this.salePrice,
    required this.purchasePrice,
    required this.lastPurchaseDate,
  });
}

class InventoryController extends GetxController {
  var inventoryList = <InventoryItem>[].obs;

  void addInventoryItem(InventoryItem item) {
    inventoryList.add(item);
  }

  void updateInventoryItem(InventoryItem updatedItem) {
    final index = inventoryList.indexWhere((i) => i.productId == updatedItem.productId);
    if (index != -1) {
      inventoryList[index] = updatedItem;
      inventoryList.refresh();
    }
  }

  void deleteInventoryItem(int productId) {
    inventoryList.removeWhere((i) => i.productId == productId);
  }

  List<InventoryItem> getInventoryByCategory(int categoryId) {
    if (categoryId == 0) return inventoryList;
    return inventoryList.where((item) => item.categoryId == categoryId).toList();
  }
}
