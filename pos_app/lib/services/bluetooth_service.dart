import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothService extends GetxService {
  // No need to get instance here since methods are static
  // final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final RxList<BluetoothDevice> scannedDevices = <BluetoothDevice>[].obs;
  BluetoothDevice? connectedDevice;

  // Start scanning for devices
  void startScan({Duration timeout = const Duration(seconds: 5)}) {
    scannedDevices.clear();

    FlutterBluePlus.startScan(timeout: timeout);

    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final device = result.device;
        if (!scannedDevices.any((d) => d.id == device.id)) {
          scannedDevices.add(device);
        }
      }
    });

    FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning) {
        // Optionally handle scan complete here
      }
    });
  }

  // Stop scanning manually
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      connectedDevice = device;
      print('Connected to ${device.name}');
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  // Disconnect device
  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      print('Device disconnected');
    }
  }

  @override
  void onClose() {
    stopScan();
    disconnectDevice();
    super.onClose();
  }
}
