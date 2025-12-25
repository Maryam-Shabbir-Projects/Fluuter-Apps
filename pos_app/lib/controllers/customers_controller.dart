import 'package:get/get.dart';
import '../models/customer_model.dart';

class CustomersController extends GetxController {
  final customers = <Customer>[].obs;
  int _customerIdCounter = 1;

  void addCustomer(Customer customer) {
    customer.id = _customerIdCounter++;
    customers.add(customer);
  }

  void editCustomer(Customer updatedCustomer) {
    final index = customers.indexWhere((c) => c.id == updatedCustomer.id);
    if (index != -1) {
      customers[index] = updatedCustomer;
      customers.refresh();
    }
  }

  void deleteCustomer(int id) {
    customers.removeWhere((c) => c.id == id);
  }
}
