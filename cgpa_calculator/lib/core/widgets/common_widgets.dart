import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';

/// Small dialog asking for a name. Returns the trimmed text, or null if cancelled or left empty.
Future<String?> promptName(
  BuildContext context, {
  required String title,
  String initial = '',
  String label = 'Name',
  String action = 'Save',
}) async {
  final ctrl = TextEditingController(text: initial);
  ctrl.selection = TextSelection(baseOffset: 0, extentOffset: initial.length);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: Text(action),
        ),
      ],
    ),
  );
  ctrl.dispose();
  return (result == null || result.isEmpty) ? null : result;
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.onTap, this.onLongPress, this.selected = false});
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? context.softFill : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String badge;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      selected: selected,
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(gradient: context.heroGradient, borderRadius: BorderRadius.circular(14)),
          child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: .6))),
          ]),
        ),
        if (selected) Icon(Icons.check_circle, color: scheme.primary),
      ]),
    );
  }
}

class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.letter, required this.ratio, this.size = 42});
  final String letter;
  final double ratio;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color fg, bg;
    if (ratio >= .8) {
      fg = context.okColor;
      bg = context.okFill;
    } else if (ratio >= .55) {
      fg = Theme.of(context).colorScheme.primary;
      bg = context.softFill;
    } else {
      fg = context.clayColor;
      bg = context.clayFill;
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size / 3)),
      child: Text(letter, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: size * .4)),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.warn = false});
  final String text;
  final bool warn;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: warn ? context.clayFill : context.okFill,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: warn ? context.clayColor : context.okColor,
            )),
      );
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.validator,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(labelText: label, suffixText: suffix),
        validator: validator,
        onChanged: onChanged,
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: muted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: muted)),
        ]),
      ),
    );
  }
}
