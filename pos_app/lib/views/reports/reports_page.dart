import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reports_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportsController reportController = Get.find<ReportsController>();

  String selectedReportType = 'Sales'; // Sales, Purchase, Item Sale
  DateTimeRange? selectedDateRange;
  String? selectedCategoryId = 'null'; // 'null' means All
  String? selectedProductId = 'null'; // 'null' means All

  @override
  void initState() {
    super.initState();
    reportController.loadInitialData();
    // Initial filter call
    reportController.filterReports(
      reportType: selectedReportType,
      startDate: null,
      endDate: null,
      categoryId: null,
      productId: null,
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      reportController.filterReports(
        reportType: selectedReportType,
        startDate: picked.start,
        endDate: picked.end,
        categoryId: selectedCategoryId != 'null' ? selectedCategoryId : null,
        productId: selectedProductId != 'null' ? selectedProductId : null,
      );
    }
  }

  void _onReportTypeChanged(String? val) {
    if (val == null) return;
    setState(() {
      selectedReportType = val;
      // Reset filters when report type changes
      selectedCategoryId = 'null';
      selectedProductId = 'null';
      selectedDateRange = null;
    });
    reportController.filterReports(
      reportType: selectedReportType,
      startDate: null,
      endDate: null,
      categoryId: null,
      productId: null,
    );
  }

  void _onCategoryChanged(String? val) {
    setState(() {
      selectedCategoryId = val ?? 'null';
      selectedProductId = 'null'; // Reset product filter on category change
    });
    reportController.filterReports(
      reportType: selectedReportType,
      startDate: selectedDateRange?.start,
      endDate: selectedDateRange?.end,
      categoryId: selectedCategoryId != 'null' ? selectedCategoryId : null,
      productId: null,
    );
  }

  void _onProductChanged(String? val) {
    setState(() {
      selectedProductId = val ?? 'null';
    });
    reportController.filterReports(
      reportType: selectedReportType,
      startDate: selectedDateRange?.start,
      endDate: selectedDateRange?.end,
      categoryId: selectedCategoryId != 'null' ? selectedCategoryId : null,
      productId: selectedProductId != 'null' ? selectedProductId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Report Type Selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Report Type'),
              value: selectedReportType,
              items: const [
                DropdownMenuItem(value: 'Sales', child: Text('Sales Report')),
                DropdownMenuItem(value: 'Purchase', child: Text('Purchase Report')),
                DropdownMenuItem(value: 'Item Sale', child: Text('Item Sale Report')),
              ],
              onChanged: _onReportTypeChanged,
            ),

            const SizedBox(height: 12),

            // Date Range Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDateRange == null
                        ? 'Select Date Range'
                        : '${selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateRange,
                  child: const Text('Pick Date Range'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category Dropdown (optional)
            Obx(() {
              final categories = reportController.categories;
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Filter by Category'),
                isExpanded: true,
                value: selectedCategoryId,
                items: [
                  const DropdownMenuItem(value: 'null', child: Text('All Categories')),
                  ...categories.map((cat) => DropdownMenuItem(
                    value: cat.id.toString(),
                    child: Text(cat.name),
                  )),
                ],
                onChanged: _onCategoryChanged,
              );
            }),

            const SizedBox(height: 12),

            // Product Dropdown (optional, filtered by category)
            Obx(() {
              final products = reportController.getProductsByCategory(
                  selectedCategoryId != 'null' ? selectedCategoryId : null);
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Filter by Product'),
                isExpanded: true,
                value: selectedProductId,
                items: [
                  const DropdownMenuItem(value: 'null', child: Text('All Products')),
                  ...products.map((prod) => DropdownMenuItem(
                    value: prod.id.toString(),
                    child: Text(prod.name),
                  )),
                ],
                onChanged: _onProductChanged,
              );
            }),

            const SizedBox(height: 20),

            // Report results (list or summary)
            Expanded(
              child: Obx(() {
                final reports = reportController.filteredReports;
                if (reports.isEmpty) {
                  return const Center(
                      child: Text('No data found for the selected criteria.'));
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      title: Text(report.title),
                      subtitle: Text(report.subtitle),
                      trailing: Text(report.value),
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
