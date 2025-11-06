// lib/models/committee.dart
import 'package:flutter/foundation.dart';

class Committee {
  String id;
  String name;
  int durationAmount; // number e.g., 3
  String durationUnit; // 'day' | 'week' | 'month'
  double totalAmount;
  int totalMembers;
  int round; // current round (starts at 1)
  DateTime createdAt;

  Committee({
    required this.id,
    required this.name,
    required this.durationAmount,
    required this.durationUnit,
    required this.totalAmount,
    required this.totalMembers,
    this.round = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'durationAmount': durationAmount,
    'durationUnit': durationUnit,
    'totalAmount': totalAmount,
    'totalMembers': totalMembers,
    'round': round,
    'createdAt': createdAt.toIso8601String(), // ✅ MUST match DB column name exactly
  };

  static Committee fromMap(Map<String, dynamic> m) => Committee(
    id: m['id'],
    name: m['name'],
    durationAmount: m['durationAmount'],
    durationUnit: m['durationUnit'],
    totalAmount: (m['totalAmount'] as num).toDouble(),
    totalMembers: m['totalMembers'],
    round: m['round'] ?? 1,
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(), // ✅ safer parsing
  );
}
