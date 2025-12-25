import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bills_controller.dart';
import '../../controllers/customers_controller.dart';
import '../../models/bill_model.dart';
import '../../models/customer_model.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final BillsController billsController = Get.find<BillsController>();
  final CustomersController customersController = Get.find<CustomersController>();

  Customer? selectedCustomer;
  final RxList<Bill> filteredBills = <Bill>[].obs;

  void loadBills(int customerId) {
    filteredBills.assignAll(
      billsController.getBillsByCustomer(customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                  if (customer != null) {
                    loadBills(customer.id);
                  } else {
                    filteredBills.clear();
                  }
                },
              );
            }),

            const SizedBox(height: 16),

            /// BILLS LIST
            Expanded(
              child: Obx(() {
                if (selectedCustomer == null) {
                  return const Center(
                    child: Text('Select a customer to view bills'),
                  );
                }

                if (filteredBills.isEmpty) {
                  return const Center(
                    child: Text('No bills found'),
                  );
                }

                return ListView.separated(
                  itemCount: filteredBills.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    return ListTile(
                      title: Text('Bill #${bill.id}'),
                      subtitle: Text(
                        'Date: ${bill.date.toLocal().toString().split(' ')[0]}\n'
                            'Total: \$${bill.totalAmount.toStringAsFixed(2)}',
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
