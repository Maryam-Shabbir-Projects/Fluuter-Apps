// lib/screens/winner_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/committee.dart';
import '../services/db_service.dart';
import '../models/member.dart';
import '../models/winner.dart';
import 'package:uuid/uuid.dart';
import '../ui/widgets.dart';

class WinnerScreen extends StatefulWidget {
  final Committee committee;
  WinnerScreen({required this.committee});

  @override
  _WinnerScreenState createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  final DBService _db = DBService();
  List<Member> _members = [];
  List<WinnerRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _members = await _db.getMembersForCommittee(widget.committee.id);
    _history = await _db.getWinnersForCommittee(widget.committee.id);
    setState(() {});
  }

  bool _allPaid() {
    final per = _db.perMemberPendingAmount(widget.committee);
    if (_members.length != widget.committee.totalMembers) return false;
    return _members.every((m) => m.paid >= per);
  }

  int _durationInDays(Committee c) {
    final amt = c.durationAmount;
    switch (c.durationUnit) {
      case 'day':
        return amt;
      case 'week':
        return amt * 7;
      case 'month':
        return amt * 30; // approximate
      default:
        return amt;
    }
  }

  bool _durationCompleted() {
    final endDate = widget.committee.createdAt.add(Duration(days: _durationInDays(widget.committee)));
    return DateTime.now().isAfter(endDate) || DateTime.now().isAtSameMomentAs(endDate);
  }

  Future<void> _generateWinnerIfEligible() async {
    // Check all payments complete
    if (!_allPaid()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not all members have paid yet.')));
      return;
    }

    // Check duration completed
    if (!_durationCompleted()) {
      final endDate = widget.committee.createdAt.add(Duration(days: _durationInDays(widget.committee)));
      final formatted = endDate.toLocal().toString().split(' ')[0];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Committee duration not completed yet. Ends on $formatted')));
      return;
    }

    // Choose eligible members (those who haven't won yet)
    final eligible = _members.where((m) => !m.hasWon).toList();
    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No eligible members left.')));
      return;
    }

    final rnd = Random();
    final winner = eligible[rnd.nextInt(eligible.length)];

    // Record winner
    final rec = WinnerRecord(
      id: Uuid().v4(),
      committeeId: widget.committee.id,
      memberId: winner.id,
      memberName: winner.name,
      round: widget.committee.round,
      date: DateTime.now(),
    );
    await _db.insertWinner(rec);

    // Mark member as hasWon
    winner.hasWon = true;
    await _db.updateMember(winner);

    // Reset all paid records to 0
    for (final m in _members) {
      m.paid = 0.0;
      await _db.updateMember(m);
    }

    // Increment committee round
    widget.committee.round = widget.committee.round + 1;
    await _db.updateCommittee(widget.committee);

    await _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${winner.name} is the winner for round ${rec.round}!')));
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _members.where((m) => !m.hasWon).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Eligible Members', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              eligible.isEmpty
                  ? Text('No eligible members (all have won).')
                  : Column(
                children: eligible.map((m) => ListTile(title: Text(m.name), subtitle: Text(m.phone))).toList(),
              ),
              SizedBox(height: 8),
              PrimaryButton(
                label: 'Generate Winner (Round ${widget.committee.round})',
                icon: Icons.emoji_events,
                onPressed: _generateWinnerIfEligible,
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Winner History', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _history.isEmpty
                  ? Text('No winners yet.')
                  : Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final w = _history[i];
                    return ListTile(
                      title: Text(w.memberName),
                      subtitle: Text('Round ${w.round} • ${w.date.toLocal().toString().split('.')[0]}'),
                    );
                  },
                ),
              ),
            ]),
          ),
        )
      ]),
    );
  }
}
