import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    final _formKey = GlobalKey<FormState>();
    final storeNameController = TextEditingController(text: settingsController.storeInfo.value.storeName);
    final storeAddressController = TextEditingController(text: settingsController.storeInfo.value.storeAddress);

    return Scaffold(
      appBar: AppBar(title: const Text('Store Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: storeNameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Store name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: storeAddressController,
                decoration: const InputDecoration(labelText: 'Store Address'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Store address required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  settingsController.updateStoreInfo(
                    StoreInfo(
                      storeName: storeNameController.text.trim(),
                      storeAddress: storeAddressController.text.trim(),
                    ),
                  );
                  Get.snackbar('Success', 'Store info updated');
                },
                child: const Text('Update Store Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
