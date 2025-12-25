import 'package:get/get.dart';

class TaxDiscountController extends GetxController {
  var taxPercent = 0.0.obs;
  var discountPercent = 0.0.obs;
  var applyTaxToAllProducts = false.obs;
  var applyDiscountToAllProducts = false.obs;

  void setTax(double value) {
    taxPercent.value = value;
  }

  void setDiscount(double value) {
    discountPercent.value = value;
  }

  void toggleApplyTax(bool value) {
    applyTaxToAllProducts.value = value;
  }

  void toggleApplyDiscount(bool value) {
    applyDiscountToAllProducts.value = value;
  }
}
