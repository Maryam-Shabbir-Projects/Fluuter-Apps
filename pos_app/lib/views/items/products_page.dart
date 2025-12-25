import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/products_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});

  final ProductsController productsController = Get.find();
  final CategoriesController categoriesController = Get.find();

  final RxInt selectedCategoryId = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddProductDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButtonFormField<int>(
              value: selectedCategoryId.value,
              decoration:
              const InputDecoration(labelText: 'Filter by Category'),
              items: [
                const DropdownMenuItem(
                    value: 0, child: Text('All Categories')),
                ...categoriesController.categories.map(
                      (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (v) => selectedCategoryId.value = v ?? 0,
            ),
          )),
          Expanded(
            child: Obx(() {
              final products = productsController
                  .getProductsByCategory(selectedCategoryId.value);

              if (products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle:
                    Text('Qty: ${p.quantity} | Price: ${p.salePrice}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          productsController.deleteProduct(p.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAddProductDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    int? categoryId;

    Get.dialog(
      AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sale Price'),
            ),
            Obx(() => DropdownButtonFormField<int>(
              decoration:
              const InputDecoration(labelText: 'Category'),
              items: categoriesController.categories
                  .map(
                    (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                ),
              )
                  .toList(),
              onChanged: (v) => categoryId = v,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryId == null) return;

              productsController.addProduct(
                Product(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameCtrl.text,
                  categoryId: categoryId!,
                  quantity: int.parse(qtyCtrl.text),
                  unit: 'pcs',
                  vendor: 'N/A',
                  purchasePrice: 0,
                  salePrice: double.parse(priceCtrl.text),
                ),
              );

              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
