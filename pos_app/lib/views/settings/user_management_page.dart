import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart' as settings_controller;
import '../../models/user_model.dart' as user_model;

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<settings_controller.SettingsController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    // Helper: convert user_model.User to settings_controller.User
    settings_controller.User toSettingsUser(user_model.User u) {
      return settings_controller.User(
        id: u.id,
        name: u.name,
        email: u.email,
        phone: u.phone,
      );
    }

    void _showAddUserDialog() {
      nameController.clear();
      emailController.clear();
      phoneController.clear();

      Get.defaultDialog(
        title: 'Add User',
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        textCancel: 'Cancel',
        textConfirm: 'Save',
        onConfirm: () {
          final name = nameController.text.trim();
          final email = emailController.text.trim();
          final phone = phoneController.text.trim();

          if (name.isEmpty) {
            Get.snackbar('Error', 'Name is required');
            return;
          }
          if (email.isEmpty) {
            Get.snackbar('Error', 'Email is required');
            return;
          }

          // Create a user_model.User first (id 0, will be assigned later)
          final newUserModel = user_model.User(
            id: 0,
            name: name,
            email: email,
            phone: phone,
          );

          // Convert to settings_controller.User before adding
          final newUserSettings = toSettingsUser(newUserModel);

          settingsController.addUser(newUserSettings);
          Get.back();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Obx(() {
        final List<settings_controller.User> users = settingsController.users;

        if (users.isEmpty) {
          return const Center(child: Text('No users added yet.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('${user.email}\n${user.phone}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => settingsController.deleteUser(user.id),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                onPressed: _showAddUserDialog,
              ),
            ),
          ],
        );
      }),
    );
  }
}
