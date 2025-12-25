class BillItem {
  int productId;
  String productName;
  int quantity;
  double price;
  double total;

  BillItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  }) : total = quantity * price;
}

class Bill {
  int id;
  int customerId;
  String customerName;
  DateTime date;
  List<BillItem> items;
  double totalAmount;

  Bill({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.items,
  }) : totalAmount = items.fold(0, (sum, item) => sum + item.total);
}
