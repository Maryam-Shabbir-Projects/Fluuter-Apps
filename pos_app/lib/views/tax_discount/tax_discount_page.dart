import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/tax_discount_controller.dart';

class TaxDiscountPage extends StatefulWidget {
  const TaxDiscountPage({super.key});

  @override
  State<TaxDiscountPage> createState() => _TaxDiscountPageState();
}

class _TaxDiscountPageState extends State<TaxDiscountPage> {
  final TaxDiscountController controller = Get.find<TaxDiscountController>();

  late final TextEditingController _taxPercentController;
  late final TextEditingController _discountPercentController;

  @override
  void initState() {
    super.initState();
    _taxPercentController =
        TextEditingController(text: controller.taxPercent.value.toString());
    _discountPercentController =
        TextEditingController(text: controller.discountPercent.value.toString());

    // Listen to controller changes to update text fields if needed
    ever(controller.taxPercent, (val) {
      _taxPercentController.text = val.toString();
    });
    ever(controller.discountPercent, (val) {
      _discountPercentController.text = val.toString();
    });
  }

  @override
  void dispose() {
    _taxPercentController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  void _updateTaxPercent() {
    final value = double.tryParse(_taxPercentController.text.trim());
    if (value == null || value < 0) {
      Get.snackbar('Error', 'Please enter a valid tax percent');
      return;
    }
    controller.setTax(value);
  }

  void _updateDiscountPercent() {
    final value = double.tryParse(_discountPercentController.text.trim());
    if (value == null || value < 0) {
      Get.snackbar('Error', 'Please enter a valid discount percent');
      return;
    }
    controller.setDiscount(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax and Discount Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => SwitchListTile(
                title: const Text('Apply Tax on All Products'),
                value: controller.applyTaxToAllProducts.value,
                onChanged: controller.toggleApplyTax,
              )),
              const SizedBox(height: 16),

              const Text('Tax Percent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taxPercentController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tax Percent',
                        suffixText: '%',
                      ),
                      onEditingComplete: _updateTaxPercent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: _updateTaxPercent,
                    tooltip: 'Save Tax Percent',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Obx(() => SwitchListTile(
                title: const Text('Apply Discount on All Products'),
                value: controller.applyDiscountToAllProducts.value,
                onChanged: controller.toggleApplyDiscount,
              )),
              const SizedBox(height: 16),

              const Text('Discount Percent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountPercentController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Discount Percent',
                        suffixText: '%',
                      ),
                      onEditingComplete: _updateDiscountPercent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: _updateDiscountPercent,
                    tooltip: 'Save Discount Percent',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
