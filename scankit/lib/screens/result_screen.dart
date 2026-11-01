import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scankit/models/entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final Entry entry;
  const ResultScreen(this.entry, {super.key});

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );

  void _search() => launchUrl(
        Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(entry.value)}'),
        mode: LaunchMode.externalApplication,
      );

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: entry.value));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Scan result')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Chip(label: Text(entry.format.toUpperCase())),
                const SizedBox(height: 12),
                SelectableText(entry.value, style: Theme.of(context).textTheme.headlineSmall),
                const Divider(height: 32),
                _row('Format', entry.format),
                _row('Length', '${entry.value.length} characters'),
                _row('Time', entry.timeLabel),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(onPressed: _search, icon: const Icon(Icons.search), label: const Text('Search product')),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _copy(context), icon: const Icon(Icons.copy), label: const Text('Copy'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => Share.share(entry.value), icon: const Icon(Icons.share), label: const Text('Share'))),
          ]),
        ]),
      );
}
