import 'package:flutter/material.dart';

/// Rounded card with an optional heading and icon.
class Panel extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  const Panel({super.key, this.title, this.icon, this.trailing, required this.child});

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, size: 16, color: cs.onPrimaryContainer),
                ),
              Text(title!, style: Theme.of(c).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              if (trailing != null) ...[const Spacer(), trailing!],
            ]),
          ),
        child,
      ]),
    );
  }
}

Future<String?> askText(BuildContext c, String title, {String initial = '', String label = 'Name', String action = 'OK'}) {
  final t = TextEditingController(text: initial);
  return showDialog<String>(
    context: c,
    builder: (x) => AlertDialog(
      title: Text(title),
      content: TextField(controller: t, autofocus: true, decoration: InputDecoration(labelText: label)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(x, t.text), child: Text(action)),
      ],
    ),
  );
}

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

/// Soft tinted tips box: each line has a small icon.
class InfoBanner extends StatelessWidget {
  final List<(IconData, String)> lines;
  const InfoBanner(this.lines, {super.key});
  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(90), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(l.$1, size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(l.$2, style: TextStyle(fontSize: 12.5, height: 1.35, color: cs.onSurface))),
            ]),
          ),
      ]),
    );
  }
}
