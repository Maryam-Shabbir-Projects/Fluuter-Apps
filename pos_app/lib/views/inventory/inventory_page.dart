import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/inventory_controller.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryController inventoryController =
  Get.find<InventoryController>();

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// Search
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Product',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim();
                });
              },
            ),
            const SizedBox(height: 12),

            /// Inventory List
            Expanded(
              child: Obx(() {
                List inventory =
                List.from(inventoryController.inventoryList);

                if (searchQuery.isNotEmpty) {
                  inventory = inventory
                      .where((item) => item.productName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                if (inventory.isEmpty) {
                  return const Center(
                    child: Text('No inventory found.'),
                  );
                }

                return ListView.separated(
                  itemCount: inventory.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = inventory[index];

                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        'Category ID: ${item.categoryId}\n'
                            'In Stock: ${item.inStock}\n'
                            'Purchase: \$${item.purchasePrice.toStringAsFixed(2)} | '
                            'Sale: \$${item.salePrice.toStringAsFixed(2)}\n'
                            'Last Purchase: ${item.lastPurchaseDate.toLocal().toString().split(' ')[0]}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          inventoryController
                              .deleteInventoryItem(item.productId);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
