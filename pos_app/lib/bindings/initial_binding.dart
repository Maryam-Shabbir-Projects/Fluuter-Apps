import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/category_controller.dart';  // file name
import '../controllers/products_controller.dart';
import '../controllers/customers_controller.dart';
import '../controllers/bills_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/reports_controller.dart';
import '../controllers/tax_discount_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<CategoriesController>(CategoriesController(), permanent: true);  // Use CategoriesController here!
    Get.put<ProductsController>(ProductsController(), permanent: true);
    Get.put<CustomersController>(CustomersController(), permanent: true);
    Get.put<BillsController>(BillsController(), permanent: true);
    Get.put<InventoryController>(InventoryController(), permanent: true);
    Get.put<ReportsController>(ReportsController(), permanent: true);
    Get.put<TaxDiscountController>(TaxDiscountController(), permanent: true);
  }
}
