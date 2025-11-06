class WinnerRecord {
  String id;
  String committeeId;
  String memberId;
  String memberName;
  int round;
  DateTime date;

  WinnerRecord({
    required this.id,
    required this.committeeId,
    required this.memberId,
    required this.memberName,
    required this.round,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'committeeId': committeeId,
    'memberId': memberId,
    'memberName': memberName,
    'round': round,
    'date': date.toIso8601String(),
  };

  static WinnerRecord fromMap(Map<String, dynamic> m) => WinnerRecord(
    id: m['id'],
    committeeId: m['committeeId'],
    memberId: m['memberId'],
    memberName: m['memberName'],
    round: m['round'],
    date: DateTime.parse(m['date']),
  );
}
