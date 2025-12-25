import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';

class CurrencySettingPage extends StatefulWidget {
  const CurrencySettingPage({super.key});

  @override
  State<CurrencySettingPage> createState() => _CurrencySettingPageState();
}

class _CurrencySettingPageState extends State<CurrencySettingPage> {
  final SettingsController settingsController = Get.find<SettingsController>();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController currencyNameController;
  late TextEditingController currencySymbolController;
  late TextEditingController currencyCodeController;
  late TextEditingController decimalDigitsController;

  @override
  void initState() {
    super.initState();
    final currency = settingsController.currency.value;
    currencyNameController = TextEditingController(text: currency.currencyName);
    currencySymbolController = TextEditingController(text: currency.currencySymbol);
    currencyCodeController = TextEditingController(text: currency.currencyCode);
    decimalDigitsController =
        TextEditingController(text: currency.decimalDigits.toString());
  }

  @override
  void dispose() {
    currencyNameController.dispose();
    currencySymbolController.dispose();
    currencyCodeController.dispose();
    decimalDigitsController.dispose();
    super.dispose();
  }

  void _updateCurrency() {
    if (!_formKey.currentState!.validate()) return;

    final updatedCurrency = Currency(
      currencyName: currencyNameController.text.trim(),
      currencySymbol: currencySymbolController.text.trim(),
      currencyCode: currencyCodeController.text.trim(),
      decimalDigits: int.parse(decimalDigitsController.text.trim()),
    );

    settingsController.updateCurrency(updatedCurrency);
    Get.snackbar('Success', 'Currency settings updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: currencyNameController,
                decoration: const InputDecoration(labelText: 'Currency Name'),
                validator: (val) =>
                val == null || val.trim().isEmpty ? 'Currency name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: currencySymbolController,
                decoration: const InputDecoration(labelText: 'Currency Symbol'),
                validator: (val) =>
                val == null || val.trim().isEmpty ? 'Currency symbol required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: currencyCodeController,
                decoration: const InputDecoration(labelText: 'Currency Code'),
                validator: (val) =>
                val == null || val.trim().isEmpty ? 'Currency code required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: decimalDigitsController,
                decoration: const InputDecoration(labelText: 'Decimal Digits'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Decimal digits required';
                  final n = int.tryParse(val);
                  if (n == null || n < 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateCurrency,
                child: const Text('Update Currency'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
