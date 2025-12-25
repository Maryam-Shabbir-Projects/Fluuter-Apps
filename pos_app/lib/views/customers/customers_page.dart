import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customers_controller.dart';
import '../../models/customer_model.dart';

class CustomersPage extends StatelessWidget {
  CustomersPage({super.key});

  final CustomersController customerController = Get.find<CustomersController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void _showAddCustomerDialog() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();

    Get.defaultDialog(
      title: 'Add Customer',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      textCancel: 'Cancel',
      textConfirm: 'Save',
      onConfirm: () {
        final name = nameController.text.trim();
        final phone = phoneController.text.trim();
        final email = emailController.text.trim();

        if (name.isEmpty) {
          Get.snackbar('Error', 'Customer name is required');
          return;
        }

        final newCustomer = Customer(
          id: 0, // controller will assign ID
          name: name,
          phone: phone,
          email: email,
        );

        customerController.addCustomer(newCustomer);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCustomerDialog,
          ),
        ],
      ),
      body: Obx(() {
        final customers = customerController.customers;

        if (customers.isEmpty) {
          return const Center(child: Text('No customers found.'));
        }

        return ListView.separated(
          itemCount: customers.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final customer = customers[index];
            return ListTile(
              title: Text(customer.name),
              subtitle: Text(
                'Phone: ${customer.phone}\nEmail: ${customer.email}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    customerController.deleteCustomer(customer.id),
              ),
            );
          },
        );
      }),
    );
  }
}
