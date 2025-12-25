class Product {
  int id;
  String name;
  int categoryId;
  String? imageUrl;
  String? brand;
  String? description;
  int quantity;
  String unit;
  String vendor;
  double purchasePrice;
  double salePrice;
  double? discount;
  double? tax;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    this.imageUrl,
    this.brand,
    this.description,
    required this.quantity,
    required this.unit,
    required this.vendor,
    required this.purchasePrice,
    required this.salePrice,
    this.discount,
    this.tax,
  });
}
