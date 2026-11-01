import 'package:flutter/material.dart';
import 'models.dart';
import 'ready_screen.dart';
import 'result_screen.dart';
import 'store.dart';
import 'widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _scanned = true;

  String _when(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    final t = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (days == 0) return 'Today, $t';
    if (days == 1) return 'Yesterday, $t';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: AppStore.I,
        builder: (context, _) {
          final list = AppStore.I.items.where((e) => e.created != _scanned).toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('History', style: headStyle(36)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Scanned')),
                    ButtonSegment(value: false, label: Text('Created')),
                  ],
                  selected: {_scanned},
                  onSelectionChanged: (s) => setState(() => _scanned = s.first),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Nothing here yet', style: TextStyle(color: kMuted)))
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: kLine),
                        itemBuilder: (context, i) {
                          final it = list[i];
                          final p = parseQr(it.raw);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(12)),
                              child: Icon(iconFor(p.kind), color: kPrimary),
                            ),
                            title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text('${p.kind.label} · ${_when(it.time)}',
                                style: const TextStyle(fontSize: 12, color: kMuted)),
                            trailing: IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline, color: kMuted),
                              onPressed: () => AppStore.I.remove(it),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => it.created ? ReadyScreen(raw: it.raw) : ResultScreen(raw: it.raw),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
