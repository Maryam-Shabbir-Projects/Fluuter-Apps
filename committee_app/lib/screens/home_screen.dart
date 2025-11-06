import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/committee_provider.dart';
import '../ui/widgets.dart';
import 'add_committee_screen.dart';
import '../models/committee.dart';
import 'committee_display_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CommitteeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Committee Management')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            PrimaryButton(
              label: 'Add Committee',
              icon: Icons.add,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddCommitteeScreen()),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: prov.committees.isEmpty
                  ? const Center(child: Text('No committees yet.'))
                  : ListView.builder(
                itemCount: prov.committees.length,
                itemBuilder: (ctx, i) {
                  final c = prov.committees[i];
                  return AppCard(
                    child: ListTile(
                      title: Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Duration: ${c.durationAmount} ${_capitalize(c.durationUnit)}(s)'),
                            Text('Total Amount: ${c.totalAmount.toStringAsFixed(2)}'),
                            Text('Total Members: ${c.totalMembers}'),
                            Text('Started: ${c.createdAt.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),
                      isThreeLine: false,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🗑️ Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: 'Delete Committee',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Delete Committee'),
                                  content: Text(
                                    'Are you sure you want to delete "${c.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton.icon(
                                      label: const Text('Delete',style: TextStyle(color: Colors.red),),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await prov.deleteCommittee(c.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Committee "${c.name}" deleted'),
                                  ),
                                );
                              }
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommitteeDisplayScreen(committee: c),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
