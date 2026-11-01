import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'ready_screen.dart';
import 'widgets.dart';

class ResultScreen extends StatelessWidget {
  final String raw;
  const ResultScreen({super.key, required this.raw});

  Future<void> _confirmOpen(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Open this link?'),
        content: Text(raw),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Open')),
        ],
      ),
    );
    if (ok == true && context.mounted) await openUri(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    final p = parseQr(raw);
    final password = p.fields['P'] ?? '';
    final copyText = p.kind == QrKind.wifi && password.isNotEmpty ? password : raw;

    Widget? primary;
    switch (p.kind) {
      case QrKind.website:
        primary = AppButton('Open link', onTap: () => _confirmOpen(context));
      case QrKind.wifi:
        primary = AppButton('Connect to network', onTap: () async {
          if (password.isNotEmpty) await Clipboard.setData(ClipboardData(text: password));
          if (context.mounted) toast(context, 'Password copied. Choose "${p.title}" in Wi-Fi settings.');
          await AppSettings.openAppSettings(type: AppSettingsType.wifi);
        });
      case QrKind.email:
        primary = AppButton('Send email', onTap: () => openUri(context, raw));
      case QrKind.phone:
        primary = AppButton('Call', onTap: () => openUri(context, raw));
      case QrKind.contact || QrKind.text:
        primary = null;
    }

    Widget action(IconData i, String t, VoidCallback f) => Expanded(
          child: OutlinedButton(
            onPressed: f,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              foregroundColor: kInk,
              side: const BorderSide(color: kLine),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(i, color: kPrimary, size: 22),
              const SizedBox(height: 4),
              Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kLine),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              KindChip(p.kind),
              const SizedBox(height: 14),
              SelectableText(
                p.kind == QrKind.website || p.kind == QrKind.text ? raw : p.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              if (p.kind == QrKind.wifi) ...[
                const SizedBox(height: 8),
                Text(password.isEmpty ? 'Open network' : 'Password protected', style: const TextStyle(color: kMuted)),
              ],
              if (p.kind == QrKind.contact || p.kind == QrKind.email || p.kind == QrKind.phone)
                for (final e in p.fields.entries)
                  if (e.key != 'FN')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('${e.key}: ${e.value}', style: const TextStyle(color: kMuted)),
                    ),
            ]),
          ),
          const SizedBox(height: 16),
          if (primary != null) ...[primary, const SizedBox(height: 12)],
          Row(children: [
            action(Icons.copy, p.kind == QrKind.wifi && password.isNotEmpty ? 'Copy password' : 'Copy', () async {
              await Clipboard.setData(ClipboardData(text: copyText));
              if (context.mounted) toast(context, 'Copied');
            }),
            if (p.kind != QrKind.wifi) ...[
              const SizedBox(width: 10),
              action(Icons.share_outlined, 'Share', () => Share.share(raw)),
            ],
            const SizedBox(width: 10),
            action(Icons.add_box_outlined, 'Make QR',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadyScreen(raw: raw)))),
          ]),
          const SizedBox(height: 20),
          const Text(
            'Only open links from sources you trust. Qrisp asks before opening a link, unless you turn on auto-open in Settings.',
            style: TextStyle(fontSize: 12, color: kMuted, height: 1.5),
          ),
        ]),
      ),
    );
  }
}
