import 'package:flutter/material.dart';
import '../models/committee.dart';
import 'member_screen.dart';
import 'finance_screen.dart';
import 'winner_screen.dart';

class CommitteeDisplayScreen extends StatefulWidget {
  final Committee committee;
  CommitteeDisplayScreen({required this.committee});

  @override
  _CommitteeDisplayScreenState createState() => _CommitteeDisplayScreenState();
}

class _CommitteeDisplayScreenState extends State<CommitteeDisplayScreen> {
  int _currentIndex = 0;

  final tabs = <Widget>[];

  @override
  Widget build(BuildContext context) {
    final children = [
      MemberScreen(committee: widget.committee),
      FinanceScreen(committee: widget.committee),
      WinnerScreen(committee: widget.committee),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.committee.name)),
      body: children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Winner'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
