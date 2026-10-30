import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/state/app_state.dart';

class GradeScaleScreen extends StatefulWidget {
  const GradeScaleScreen({super.key});

  @override
  State<GradeScaleScreen> createState() => _GradeScaleScreenState();
}

class _GradeScaleScreenState extends State<GradeScaleScreen> {
  late List<GradeBand> _bands;
  late List<TextEditingController> _min;
  late List<TextEditingController> _pts;

  @override
  void initState() {
    super.initState();
    _load(context.read<AppState>().config.bands);
  }

  void _load(List<GradeBand> bands) {
    _bands = [...bands]..sort((a, b) => b.minMarks.compareTo(a.minMarks));
    _min = [for (final b in _bands) TextEditingController(text: fmtNum(b.minMarks))];
    _pts = [for (final b in _bands) TextEditingController(text: fmtNum(b.points))];
  }

  void _disposeAll() {
    for (final c in [..._min, ..._pts]) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  void _save() {
    final max = context.read<AppState>().config.scaleMax;
    final result = <GradeBand>[];
    for (var i = 0; i < _bands.length; i++) {
      final m = double.tryParse(_min[i].text);
      final p = double.tryParse(_pts[i].text);
      if (m == null || p == null || m < 0 || m > 100 || p < 0 || p > max) {
        _toast('Check ${_bands[i].letter}: marks must be 0-100 and points 0-${fmtNum(max)}.');
        return;
      }
      result.add(_bands[i].copyWith(minMarks: m, points: p));
    }
    context.read<AppState>().updateBands(result);
    _toast('Grade scale saved');
  }

  void _reset() {
    final max = context.read<AppState>().config.scaleMax;
    _disposeAll();
    setState(() => _load(GradingConfig.defaultBands(max)));
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    return Scaffold(
      appBar: AppBar(title: const Text('Grade scale')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        Text('Edit the cut-offs your university uses.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        Row(children: [
          const SizedBox(width: 56),
          Expanded(child: Text('Min marks', style: TextStyle(color: muted, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(child: Text('Points', style: TextStyle(color: muted, fontSize: 12))),
        ]),
        const SizedBox(height: 6),
        for (var i = 0; i < _bands.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 56, child: Text(_bands[i].letter, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
              Expanded(child: NumberField(controller: _min[i], label: '')),
              const SizedBox(width: 10),
              Expanded(child: NumberField(controller: _pts[i], label: '')),
            ]),
          ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _reset, child: const Text('Reset to default')),
        const SizedBox(height: 10),
        FilledButton(onPressed: _save, child: const Text('Save scale')),
      ]),
    );
  }
}
