import 'package:get/get.dart';
import '../models/bill_model.dart';

class BillsController extends GetxController {
  final bills = <Bill>[].obs;
  int _billIdCounter = 1;

  void addBill(Bill bill) {
    bill.id = _billIdCounter++;
    bills.add(bill);
  }

  void deleteBill(int id) {
    bills.removeWhere((b) => b.id == id);
  }

  List<Bill> getBillsByCustomer(int customerId) {
    return bills.where((b) => b.customerId == customerId).toList();
  }
}
