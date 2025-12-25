class Customer {
  int id;
  String name;
  String phone;
  String email;
  DateTime? createdAt;
  bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.createdAt,
    this.isActive = true,
  });
}
