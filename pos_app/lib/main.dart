import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart'; // Make sure the filename matches exactly
import 'theme/app_theme.dart';
import 'views/auth/login_page.dart';
import 'views/dashboard/dashboard_page.dart';
import 'views/inventory/inventory_page.dart';
import 'views/items/categories_page.dart';
import 'views/items/products_page.dart';
import 'views/reports/reports_page.dart';
import 'views/tax_discount/tax_discount_page.dart';
import 'views/settings/profile_edit_page.dart';
import 'views/settings/store_info_page.dart';
import 'views/settings/currency_settings_page.dart';
import 'views/settings/user_management_page.dart';
import 'views/settings/printer_settings_page.dart';
import 'views/bills/bills_page.dart';
import 'views/customers/customers_page.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter POS',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/dashboard', page: () => DashboardPage()),
        GetPage(name: '/inventory', page: () => InventoryPage()),
        GetPage(name: '/categories', page: () => CategoriesPage()),
        GetPage(name: '/products', page: () => ProductsPage()),
        GetPage(name: '/reports', page: () => ReportPage()),
        GetPage(name: '/tax_discount', page: () => TaxDiscountPage()),

        // Settings subpages
        GetPage(name: '/settings/edit_profile', page: () => ProfileEditPage()),
        GetPage(name: '/settings/store_info', page: () => StoreInfoPage()),
        GetPage(name: '/settings/currency', page: () => CurrencySettingPage()),
        GetPage(name: '/settings/user_management', page: () => UserManagementPage()),
        GetPage(name: '/settings/printer', page: () => PrinterSettingPage()),

        // Other pages
        GetPage(name: '/bills', page: () => BillsPage()),
        GetPage(name: '/customers', page: () => CustomersPage()),
      ],
    );
  }
}
