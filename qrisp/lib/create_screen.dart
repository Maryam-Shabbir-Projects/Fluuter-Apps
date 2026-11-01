import 'package:flutter/material.dart';
import 'form_screen.dart';
import 'models.dart';
import 'widgets.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create a QR code', style: headStyle(36)),
          const SizedBox(height: 6),
          const Text('Choose what the code should hold', style: TextStyle(color: kMuted)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView(
              padding: const EdgeInsets.only(bottom: 16),
              // Fixed tile height: no overflow on small screens or large fonts.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 152,
              ),
              children: [
                for (final k in QrKind.values)
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(kind: k))),
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kLine),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(12)),
                          child: Icon(iconFor(k), color: kPrimary),
                        ),
                        const SizedBox(height: 14),
                        Text(k.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(k.hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: kMuted)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
