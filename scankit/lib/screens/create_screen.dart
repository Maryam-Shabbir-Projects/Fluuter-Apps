import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:scankit/models/entry.dart';
import 'package:scankit/services/store.dart';
import 'package:share_plus/share_plus.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  static final _types = <String, Barcode>{
    'Code 128': Barcode.code128(),
    'EAN-13': Barcode.ean13(),
    'UPC-A': Barcode.upcA(),
    'Code 39': Barcode.code39(),
  };

  final _input = TextEditingController(text: '4006381333931');
  String _type = 'Code 128';
  String? _data;

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _generate() {
    final v = _input.text.trim();
    if (v.isEmpty || !_types[_type]!.isValid(v)) {
      _snack('Invalid content for $_type');
      return;
    }
    setState(() => _data = v);
  }

  void _save() {
    Store.i.add(Entry(_data!, _type, true));
    _snack('Saved to history');
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create barcode')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Wrap(spacing: 8, children: [
            for (final t in _types.keys)
              ChoiceChip(
                label: Text(t),
                selected: _type == t,
                onSelected: (_) => setState(() {
                  _type = t;
                  _data = null;
                }),
              ),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 52, child: FilledButton(onPressed: _generate, child: const Text('Generate'))),
          if (_data != null) ...[
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: BarcodeWidget(barcode: _types[_type]!, data: _data!, width: 280, height: 110, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save'))),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(onPressed: () => Share.share(_data!), icon: const Icon(Icons.share), label: const Text('Share'))),
                  ]),
                ]),
              ),
            ),
          ],
        ]),
      );
}
