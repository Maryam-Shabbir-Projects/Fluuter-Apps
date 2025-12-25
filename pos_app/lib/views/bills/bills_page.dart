import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bills_controller.dart';
import '../../controllers/customers_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/products_controller.dart';
import '../../models/bill_model.dart';
import '../../models/customer_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final BillsController billsController = Get.find<BillsController>();
  final CustomersController customersController = Get.find<CustomersController>();
  final CategoriesController categoriesController = Get.find<CategoriesController>();
  final ProductsController productsController = Get.find<ProductsController>();

  Customer? selectedCustomer;
  Category? selectedCategory;
  Product? selectedProduct;

  final TextEditingController quantityController = TextEditingController(text: '1');

  List<BillItem> billItems = [];

  void _addItemToBill() {
    if (selectedProduct == null) return;

    final quantity = int.tryParse(quantityController.text) ?? 1;
    if (quantity <= 0) return;

    final existingIndex = billItems.indexWhere((item) => item.productId == selectedProduct!.id);

    if (existingIndex != -1) {
      // Update quantity if product already added
      final existingItem = billItems[existingIndex];
      billItems[existingIndex] = BillItem(
        productId: existingItem.productId,
        productName: existingItem.productName,
        quantity: existingItem.quantity + quantity,
        price: existingItem.price,
      );
    } else {
      billItems.add(BillItem(
        productId: selectedProduct!.id,
        productName: selectedProduct!.name,
        quantity: quantity,
        price: selectedProduct!.salePrice,
      ));
    }

    setState(() {
      quantityController.text = '1';
      selectedProduct = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      billItems.removeAt(index);
    });
  }

  void _saveBill() {
    if (selectedCustomer == null) {
      Get.snackbar('Error', 'Please select a customer');
      return;
    }
    if (billItems.isEmpty) {
      Get.snackbar('Error', 'Add at least one product');
      return;
    }

    final bill = Bill(
      id: 0, // will be set by controller
      customerId: selectedCustomer!.id,
      customerName: selectedCustomer!.name,
      date: DateTime.now(),
      items: List.from(billItems),
    );

    billsController.addBill(bill);

    // Clear form
    setState(() {
      selectedCustomer = null;
      selectedCategory = null;
      selectedProduct = null;
      billItems.clear();
    });

    Get.snackbar('Success', 'Bill created successfully');
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == null
        ? productsController.products
        : productsController.getProductsByCategory(selectedCategory!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CUSTOMER DROPDOWN
            Obx(() {
              return DropdownButtonFormField<Customer>(
                decoration: const InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                ),
                value: selectedCustomer,
                items: customersController.customers.map((c) {
                  return DropdownMenuItem<Customer>(
                    value: c,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (customer) {
                  setState(() {
                    selectedCustomer = customer;
                  });
                },
              );
            }),
            const SizedBox(height: 12),

            /// CATEGORY DROPDOWN
            Obx(() {
              return DropdownButtonFormField<Category>(
                decoration: const InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items: [
                  const DropdownMenuItem<Category>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categoriesController.categories.map((cat) {
                    return DropdownMenuItem<Category>(
                      value: cat,
                      child: Text(cat.name),
                    );
                  }).toList(),
                ],
                onChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                    selectedProduct = null;
                  });
                },
              );
            }),
            const SizedBox(height: 12),

            /// PRODUCT DROPDOWN
            DropdownButtonFormField<Product>(
              decoration: const InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(),
              ),
              value: selectedProduct,
              items: filteredProducts.map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  selectedProduct = product;
                });
              },
            ),
            const SizedBox(height: 12),

            /// QUANTITY INPUT
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            /// ADD ITEM BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Item'),
              onPressed: _addItemToBill,
            ),

            const SizedBox(height: 20),

            /// BILL ITEMS LIST
            const Text('Bill Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              child: billItems.isEmpty
                  ? const Center(child: Text('No items added'))
                  : ListView.separated(
                itemCount: billItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  return ListTile(
                    title: Text(item.productName),
                    subtitle: Text('Quantity: ${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${item.total.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// SAVE BILL BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Bill'),
              onPressed: _saveBill,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
