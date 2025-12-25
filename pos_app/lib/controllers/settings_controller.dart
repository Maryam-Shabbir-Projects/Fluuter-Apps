import 'package:get/get.dart';

class Profile {
  String roleName;
  String email;
  String phone;
  String password;

  Profile({
    required this.roleName,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class StoreInfo {
  String storeName;
  String storeAddress;

  StoreInfo({
    required this.storeName,
    required this.storeAddress,
  });
}

class Currency {
  String currencyName;
  String currencySymbol;
  String currencyCode;
  int decimalDigits;

  Currency({
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyCode,
    required this.decimalDigits,
  });
}

class User {
  int id;
  String name;
  String email;
  String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class SettingsController extends GetxController {
  var profile = Profile(
    roleName: 'Admin',
    email: 'admin@example.com',
    phone: '1234567890',
    password: 'admin123',
  ).obs;

  var storeInfo = StoreInfo(
    storeName: 'My Store',
    storeAddress: '123 Main St',
  ).obs;

  var currency = Currency(
    currencyName: 'US Dollar',
    currencySymbol: '\$',
    currencyCode: 'USD',
    decimalDigits: 2,
  ).obs;

  var users = <User>[].obs;
  int _userIdCounter = 1;

  // === NEW PRINTER STATE - KEEP SEPARATE ===
  // Use RxnString for nullable string observable for connected device
  var connectedPrinterDevice = RxnString();

  // List of scanned printer device names
  var discoveredPrinterDevices = <String>[].obs;

  void updateProfile(Profile updatedProfile) {
    profile.value = updatedProfile;
  }

  void updateStoreInfo(StoreInfo updatedStoreInfo) {
    storeInfo.value = updatedStoreInfo;
  }

  void updateCurrency(Currency updatedCurrency) {
    currency.value = updatedCurrency;
  }

  void addUser(User user) {
    user.id = _userIdCounter++;
    users.add(user);
  }

  void editUser(User updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
    }
  }

  void deleteUser(int id) {
    users.removeWhere((u) => u.id == id);
  }

  // === NEW PRINTER METHODS ===

  void scanForBluetoothDevices() {
    // Dummy scanning simulation
    Future.delayed(const Duration(seconds: 1), () {
      discoveredPrinterDevices.assignAll([
        'Printer One',
        'Printer Two',
        'Printer Three',
      ]);
      if (discoveredPrinterDevices.isNotEmpty) {
        connectedPrinterDevice.value = discoveredPrinterDevices.first;
      }
    });
  }

  void connectToDevice(String deviceName) {
    connectedPrinterDevice.value = deviceName;
  }

  void disconnectPrinter() {
    connectedPrinterDevice.value = null;
  }
}
