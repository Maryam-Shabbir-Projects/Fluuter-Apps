import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/customers_controller.dart';
import '../../models/customer_model.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomersController customerController = Get.find<CustomersController>();

  final TextEditingController searchController = TextEditingController();
  DateTimeRange? selectedDateRange;

  List<Customer> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    // Initially show all customers
    filteredCustomers = customerController.customers;
    // Listen to customers list changes to update filtered list
    ever(customerController.customers, (_) => _applyFilters());
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    final start = selectedDateRange?.start;
    final end = selectedDateRange?.end;

    filteredCustomers = customerController.customers.where((customer) {
      final matchesSearch = customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);

      final matchesDate = start != null && end != null
          ? (customer.createdAt != null &&
          customer.createdAt!.isAfter(start.subtract(const Duration(days: 1))) &&
          customer.createdAt!.isBefore(end.add(const Duration(days: 1))))
          : true;

      return matchesSearch && matchesDate;
    }).toList();

    setState(() {});
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

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
          id: 0, // assign id in controller or backend
          name: name,
          phone: phone,
          email: email,
          createdAt: DateTime.now(), // assuming this field exists
        );

        customerController.addCustomer(newCustomer);
        Get.back();
      },
    );
  }

  // Summary stats based on filtered customers
  int get totalCustomers => filteredCustomers.length;

  int get activeCustomers =>
      filteredCustomers.where((c) => c.isActive == true).length;

  int get newCustomers => filteredCustomers
      .where((c) =>
  c.createdAt != null &&
      selectedDateRange != null &&
      c.createdAt!.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
      c.createdAt!.isBefore(selectedDateRange!.end.add(const Duration(days: 1))))
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Customer',
            onPressed: _showAddCustomerDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name, email or phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _applyFilters();
                  },
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => _applyFilters(),
            ),

            const SizedBox(height: 12),

            // Date Range Picker
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(selectedDateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat.yMd().format(selectedDateRange!.start)} - ${DateFormat.yMd().format(selectedDateRange!.end)}'),
                    onPressed: _pickDateRange,
                  ),
                ),
                if (selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        selectedDateRange = null;
                      });
                      _applyFilters();
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Customer Summary Card
            Card(
              elevation: 3,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      icon: Icons.group,
                      label: 'Total Customers',
                      value: totalCustomers.toString(),
                      onTap: () {
                        // On tap show all customers - here already filtered list
                        Get.snackbar('Info', 'Showing all customers');
                      },
                    ),
                    _SummaryItem(
                      icon: Icons.check_circle,
                      label: 'Active Customers',
                      value: activeCustomers.toString(),
                      onTap: () {
                        Get.snackbar('Info', 'Showing active customers');
                      },
                    ),
                    _SummaryItem(
                      icon: Icons.new_releases,
                      label: 'New Customers',
                      value: newCustomers.toString(),
                      onTap: () {
                        Get.snackbar('Info', 'Showing new customers');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer List
            Expanded(
              child: Obx(() {
                final customers = filteredCustomers;

                if (customers.isEmpty) {
                  return const Center(
                    child: Text('No customers found.'),
                  );
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
