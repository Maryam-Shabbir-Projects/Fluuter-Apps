// lib/providers/committee_provider.dart
import 'package:flutter/material.dart';
import '../models/committee.dart';
import '../services/db_service.dart';

class CommitteeProvider extends ChangeNotifier {
  final DBService _db = DBService();
  List<Committee> _committees = [];

  List<Committee> get committees => _committees;

  // Load all committees
  Future<void> load() async {
    _committees = await _db.getAllCommittees();
    notifyListeners();
  }

  // Add new committee
  Future<void> addCommittee(Committee c) async {
    await _db.insertCommittee(c);
    await load();
  }

  // Delete committee (with local update for faster UI response)
  Future<void> deleteCommittee(String id) async {
    await _db.deleteCommittee(id);
    _committees.removeWhere((c) => c.id == id); // instantly reflect in UI
    notifyListeners();
  }

  // Update committee details
  Future<void> updateCommittee(Committee c) async {
    await _db.updateCommittee(c);
    await load();
  }
}
