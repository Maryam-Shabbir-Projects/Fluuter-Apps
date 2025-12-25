import 'package:get/get.dart';

class AuthController extends GetxController {
  var roleName = 'Admin'.obs;
  var email = 'admin@example.com'.obs;
  var phone = '1234567890'.obs;

  var password = ''.obs;
  var isLoggedIn = false.obs;

  // Hardcoded admin password for now (can be replaced with real auth)
  final String _adminPassword = 'admin123';

  bool login(String inputPassword) {
    if (inputPassword == _adminPassword) {
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  void logout() {
    isLoggedIn.value = false;
  }

  // Update profile data method
  void updateProfile(String newRoleName, String newEmail, String newPhone, String newPassword) {
    roleName.value = newRoleName;
    email.value = newEmail;
    phone.value = newPhone;

    if (newPassword.isNotEmpty) {
      password.value = newPassword;
      // You might want to update _adminPassword or handle real auth here
    }
  }
}
