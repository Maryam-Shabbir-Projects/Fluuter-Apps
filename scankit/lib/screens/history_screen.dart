import 'package:flutter/material.dart';
import 'package:scankit/models/entry.dart';
import 'package:scankit/screens/result_screen.dart';
import 'package:scankit/services/store.dart';
import 'package:scankit/widgets/icon_badge.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Store.i,
        builder: (context, _) => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('History'),
              actions: [IconButton(tooltip: 'Clear all', onPressed: Store.i.clear, icon: const Icon(Icons.delete_outline))],
              bottom: const TabBar(tabs: [Tab(text: 'Scanned'), Tab(text: 'Created')]),
            ),
            body: TabBarView(children: [
              _EntryList(Store.i.byType(created: false)),
              _EntryList(Store.i.byType(created: true)),
            ]),
          ),
        ),
      );
}

class _EntryList extends StatelessWidget {
  final List<Entry> entries;
  const _EntryList(this.entries);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('Nothing here yet'));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = entries[i];
        return Card(
          elevation: 0,
          child: ListTile(
            leading: const IconBadge(Icons.qr_code_scanner),
            title: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${e.format} · ${e.timeLabel}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(e))),
          ),
        );
      },
    );
  }
}
