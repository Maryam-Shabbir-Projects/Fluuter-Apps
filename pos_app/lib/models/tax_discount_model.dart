class TaxDiscount {
  double taxPercent;
  double discountPercent;
  bool applyTaxToAllProducts;
  bool applyDiscountToAllProducts;

  TaxDiscount({
    this.taxPercent = 0.0,
    this.discountPercent = 0.0,
    this.applyTaxToAllProducts = false,
    this.applyDiscountToAllProducts = false,
  });
}
