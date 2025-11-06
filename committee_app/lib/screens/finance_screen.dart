// lib/screens/finance_screen.dart
import 'package:flutter/material.dart';
import '../models/committee.dart';
import '../services/db_service.dart';
import '../models/member.dart';
import '../ui/widgets.dart';

class FinanceScreen extends StatefulWidget {
  final Committee committee;
  FinanceScreen({required this.committee});

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final DBService _db = DBService();
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _members = await _db.getMembersForCommittee(widget.committee.id);
    setState(() {});
  }

  Future<void> _showPaymentDialog(Member m, {required bool isAdd}) async {
    final controller = TextEditingController();
    final perMember = _db.perMemberPendingAmount(widget.committee);
    final pending = (perMember - m.paid) > 0 ? (perMember - m.paid) : 0.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isAdd ? 'Add Payment' : 'Deduct Payment'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Pending: ${pending.toStringAsFixed(2)}\nPaid: ${m.paid.toStringAsFixed(2)}'),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final input = controller.text.trim();
                if (input.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter amount')));
                  return;
                }
                final amt = double.tryParse(input);
                if (amt == null || amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter valid amount > 0')));
                  return;
                }

                if (isAdd) {
                  // cannot add more than pending
                  if (amt > pending) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Amount exceeds pending balance')));
                    return;
                  }
                  m.paid = m.paid + amt;
                } else {
                  // deduction: cannot make paid negative
                  if (amt > m.paid) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot deduct more than paid amount')));
                    return;
                  }
                  m.paid = m.paid - amt;
                }

                await _db.updateMember(m);
                Navigator.pop(ctx);
                await _load();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final perMember = _db.perMemberPendingAmount(widget.committee);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        Expanded(
          child: _members.isEmpty
              ? Center(child: Text('No members yet.'))
              : ListView.builder(
            itemCount: _members.length,
            itemBuilder: (ctx, i) {
              final m = _members[i];
              final pending = (perMember - m.paid) > 0 ? (perMember - m.paid) : 0.0;
              return AppCard(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text(
                    '\nPaid: ${m.paid.toStringAsFixed(2)}\nPending: ${pending.toStringAsFixed(2)}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 20),
                        onPressed: () => _showPaymentDialog(m, isAdd: false),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () => _showPaymentDialog(m, isAdd: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
