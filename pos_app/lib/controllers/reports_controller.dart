import 'package:get/get.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class Report {
  final String title;
  final String subtitle;
  final String value;

  Report({
    required this.title,
    required this.subtitle,
    required this.value,
  });
}

class ReportsController extends GetxController {
  var categories = <Category>[].obs;
  var products = <Product>[].obs;

  var filteredReports = <Report>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    // Load categories (replace with your real data source)
    categories.assignAll([
      Category(id: 1, name: 'Electronics'),
      Category(id: 2, name: 'Groceries'),
      Category(id: 3, name: 'Clothing'),
    ]);

    // Load products (replace with your real data source)
    products.assignAll([
      Product(
          id: 101,
          name: 'Laptop',
          categoryId: 1,
          quantity: 10,
          unit: 'pcs',
          vendor: 'Vendor A',
          purchasePrice: 800,
          salePrice: 1000),
      Product(
          id: 102,
          name: 'Smartphone',
          categoryId: 1,
          quantity: 20,
          unit: 'pcs',
          vendor: 'Vendor B',
          purchasePrice: 300,
          salePrice: 450),
      Product(
          id: 201,
          name: 'Rice',
          categoryId: 2,
          quantity: 100,
          unit: 'kg',
          vendor: 'Vendor C',
          purchasePrice: 1,
          salePrice: 1.5),
    ]);

    // Initially, show empty or some default reports
    filteredReports.clear();
  }

  List<Product> getProductsByCategory(String? categoryId) {
    if (categoryId == null || categoryId == 'null' || categoryId.isEmpty) {
      return products.toList();
    }
    int? cid = int.tryParse(categoryId);
    if (cid == null || cid == 0) return products.toList();
    return products.where((p) => p.categoryId == cid).toList();
  }

  void filterReports({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? productId,
  }) {
    // For demo, generate dummy reports according to filters

    // Clear previous reports
    filteredReports.clear();

    String categoryName = 'All Categories';
    if (categoryId != null && categoryId != 'null') {
      final cat = categories.firstWhereOrNull((c) => c.id.toString() == categoryId);
      if (cat != null) categoryName = cat.name;
    }

    String productName = 'All Products';
    if (productId != null && productId != 'null') {
      final prod = products.firstWhereOrNull((p) => p.id.toString() == productId);
      if (prod != null) productName = prod.name;
    }

    String dateRange = (startDate != null && endDate != null)
        ? "${startDate.toLocal().toString().split(' ')[0]} - ${endDate.toLocal().toString().split(' ')[0]}"
        : "All Dates";

    // Add a dummy report entry for demo
    filteredReports.add(
      Report(
        title: "$reportType Report",
        subtitle: "Category: $categoryName\nProduct: $productName\nDate: $dateRange",
        value: "\$1234.56",
      ),
    );
  }
}
