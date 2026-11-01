import 'package:flutter/material.dart';

/// Rounded bottom sheet used for every small form and question in the app.
Future<T?> showAppSheet<T>(BuildContext c, WidgetBuilder builder) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: builder,
    );

/// Big round icon with a soft halo.
Widget sheetBadge(IconData icon, Color color) => Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(36)),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withAlpha(90), blurRadius: 14, offset: const Offset(0, 6))]),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );

/// Asks for a name. Returns the trimmed text (may be empty when [allowEmpty]) or null if cancelled.
Future<String?> showNameSheet(
  BuildContext c, {
  required IconData icon,
  required String title,
  required String subtitle,
  required String hint,
  required String action,
  String initial = '',
  Color color = const Color(0xFF0B6E66),
  bool allowEmpty = true,
}) {
  final t = TextEditingController(text: initial)..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);
  return showAppSheet<String>(
    c,
    (x) {
      final cs = Theme.of(x).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 24 + MediaQuery.of(x).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          sheetBadge(icon, color),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(x).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 20),
          TextField(
            controller: t,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) {
              if (allowEmpty || v.trim().isNotEmpty) Navigator.pop(x, v.trim());
            },
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: color),
              filled: true,
              fillColor: cs.onSurface.withAlpha(10),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 1.6)),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: t,
            builder: (_, v, __) => Row(children: [
              Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)), onPressed: () => Navigator.pop(x), child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: color),
                  onPressed: allowEmpty || v.text.trim().isNotEmpty ? () => Navigator.pop(x, v.text.trim()) : null,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(action),
                ),
              ),
            ]),
          ),
        ]),
      );
    },
  );
}

/// Yes/no question. Returns true when confirmed.
Future<bool> showConfirmSheet(BuildContext c, {required IconData icon, required String title, required String body, required String action, Color color = const Color(0xFFD93025)}) async =>
    await showAppSheet<bool>(
      c,
      (x) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          sheetBadge(icon, color),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: Theme.of(x).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(x).colorScheme.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)), onPressed: () => Navigator.pop(x, false), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: color), onPressed: () => Navigator.pop(x, true), child: Text(action))),
          ]),
        ]),
      ),
    ) ==
    true;
