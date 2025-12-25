import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class PrinterSettingPage extends StatelessWidget {
  const PrinterSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Printer Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() {
              final connectedDevice = settingsController.connectedPrinterDevice.value;
              return ListTile(
                title: const Text('Bluetooth Printer'),
                subtitle: Text(connectedDevice ?? 'No device connected'),
                trailing: ElevatedButton(
                  onPressed: () {
                    settingsController.scanForBluetoothDevices();
                  },
                  child: const Text('Scan for Devices'),
                ),
              );
            }),
            // Additional printer settings can go here
          ],
        ),
      ),
    );
  }
}
