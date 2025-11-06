class Member {
  String id;
  String committeeId;
  String name;
  String phone; // stored in E.164 if possible
  double paid; // total paid so far
  bool hasWon; // whether member has already won in any round

  Member({
    required this.id,
    required this.committeeId,
    required this.name,
    required this.phone,
    this.paid = 0.0,
    this.hasWon = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'committeeId': committeeId,
    'name': name,
    'phone': phone,
    'paid': paid,
    'hasWon': hasWon ? 1 : 0,
  };

  static Member fromMap(Map<String, dynamic> m) => Member(
    id: m['id'],
    committeeId: m['committeeId'],
    name: m['name'],
    phone: m['phone'],
    paid: (m['paid'] as num).toDouble(),
    hasWon: (m['hasWon'] as int) == 1,
  );
}
