import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});

  final CategoriesController categoriesController =
  Get.find<CategoriesController>();

  final TextEditingController categoryNameController =
  TextEditingController();

  void _showCategoryDialog({
    int? categoryId,
    String? currentName,
  }) {
    if (currentName != null) {
      categoryNameController.text = currentName;
    } else {
      categoryNameController.clear();
    }

    Get.defaultDialog(
      title: categoryId == null ? 'Add Category' : 'Edit Category',
      content: TextField(
        controller: categoryNameController,
        decoration: const InputDecoration(
          labelText: 'Category Name',
          border: OutlineInputBorder(),
        ),
      ),
      textCancel: 'Cancel',
      textConfirm: categoryId == null ? 'Add' : 'Update',
      onConfirm: () {
        final name = categoryNameController.text.trim();

        if (name.isEmpty) {
          Get.snackbar('Error', 'Category name cannot be empty');
          return;
        }

        if (categoryId == null) {
          categoriesController.addCategory(name);
        } else {
          categoriesController.editCategory(categoryId, name);
        }

        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: Obx(() {
        final categories = categoriesController.categories;

        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }

        return ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final category = categories[index];

            return ListTile(
              title: Text(category.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                    const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCategoryDialog(
                      categoryId: category.id,
                      currentName: category.name,
                    ),
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        categoriesController.deleteCategory(
                            category.id),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
