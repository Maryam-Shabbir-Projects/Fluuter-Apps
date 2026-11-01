import 'package:flutter/material.dart';

/// Small tonal "Save" pill that shows Saving... and Saved.
class SaveButton extends StatefulWidget {
  final Future<void> Function() onSave;
  const SaveButton({super.key, required this.onSave});
  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  int _state = 0; // 0 idle, 1 saving, 2 saved

  Future<void> _tap() async {
    if (_state == 1) return;
    setState(() => _state = 1);
    await widget.onSave();
    if (!mounted) return;
    setState(() => _state = 2);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _state = 0);
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    const green = Color(0xFF1B7F4B);
    final saved = _state == 2;
    final color = saved ? green : cs.primary;
    return Material(
      color: saved ? green.withAlpha(30) : cs.primaryContainer.withAlpha(150),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _tap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _state == 1
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  : Icon(saved ? Icons.check_circle_rounded : Icons.save_outlined, size: 18, color: color),
              const SizedBox(width: 6),
              Text(_state == 1 ? 'Saving' : (saved ? 'Saved' : 'Save'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}
