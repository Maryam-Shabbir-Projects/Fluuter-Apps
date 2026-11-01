import 'package:flutter/material.dart';
import 'models.dart';
import 'ready_screen.dart';
import 'store.dart';
import 'widgets.dart';

class _F {
  final String k, label, hint;
  final TextInputType type;
  final bool req;
  final int lines;
  const _F(this.k, this.label, this.hint,
      {this.type = TextInputType.text, this.req = false, this.lines = 1});
}

const _specs = <QrKind, List<_F>>{
  QrKind.website: [_F('url', 'Website link', 'https://', type: TextInputType.url, req: true)],
  QrKind.text: [_F('text', 'Your text', 'Type or paste text', type: TextInputType.multiline, req: true, lines: 4)],
  QrKind.wifi: [
    _F('ssid', 'Network name', 'Your Wi-Fi name', req: true),
    _F('pw', 'Password', 'Your Wi-Fi password'),
  ],
  QrKind.contact: [
    _F('first', 'First name', 'First name', req: true),
    _F('last', 'Last name', 'Last name'),
    _F('phone', 'Phone', '+92', type: TextInputType.phone),
    _F('email', 'Email', 'name@email.com', type: TextInputType.emailAddress),
  ],
  QrKind.email: [
    _F('to', 'To', 'name@email.com', type: TextInputType.emailAddress, req: true),
    _F('subject', 'Subject', 'Subject'),
    _F('body', 'Message', 'Message', type: TextInputType.multiline, lines: 4),
  ],
  QrKind.phone: [_F('phone', 'Phone number', '+92', type: TextInputType.phone, req: true)],
};

class FormScreen extends StatefulWidget {
  final QrKind kind;
  const FormScreen({super.key, required this.kind});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _key = GlobalKey<FormState>();
  late final List<_F> _fields = _specs[widget.kind]!;
  late final Map<String, TextEditingController> _c = {for (final f in _fields) f.k: TextEditingController()};
  String _sec = 'WPA';

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _payload() {
    String v(String k) => _c[k]!.text.trim();
    switch (widget.kind) {
      case QrKind.website:
        return normaliseUrl(v('url'));
      case QrKind.text:
        return v('text');
      case QrKind.wifi:
        return buildWifi(v('ssid'), _c['pw']!.text, _sec);
      case QrKind.contact:
        return buildVcard(first: v('first'), last: v('last'), phone: v('phone'), email: v('email'));
      case QrKind.email:
        return buildEmail(v('to'), v('subject'), v('body'));
      case QrKind.phone:
        return 'tel:${v('phone').replaceAll(' ', '')}';
    }
  }

  void _create() {
    if (!_key.currentState!.validate()) return;
    final raw = _payload();
    AppStore.I.add(raw, created: true);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReadyScreen(raw: raw)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.kind.label)),
      body: SafeArea(
        child: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
            for (final f in _fields) ...[
              Text(f.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _c[f.k],
                keyboardType: f.type,
                minLines: f.lines,
                maxLines: f.lines,
                decoration: InputDecoration(hintText: f.hint),
                validator: (v) => f.req && (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
            ],
            if (widget.kind == QrKind.wifi) ...[
              const Text('Security', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 6),
              Wrap(spacing: 10, children: [
                for (final o in const {'WPA': 'WPA/WPA2', 'WEP': 'WEP', 'nopass': 'None'}.entries)
                  ChoiceChip(
                    label: Text(o.value),
                    selected: _sec == o.key,
                    onSelected: (_) => setState(() => _sec = o.key),
                  ),
              ]),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            AppButton('Create QR code', onTap: _create),
            const SizedBox(height: 12),
            const Text('Everything is made on your phone. Nothing is sent online.',
                style: TextStyle(fontSize: 12, color: kMuted)),
          ]),
        ),
      ),
    );
  }
}
