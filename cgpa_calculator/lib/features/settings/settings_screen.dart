import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/features/settings/grade_scale_screen.dart';
import 'package:cgpa_calculator/state/app_state.dart';

/// Lets the user change everything that was chosen during first-time setup.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (!s.onboarded) return const SizedBox.shrink();
    final cfg = s.config;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        Text('Change how your results are calculated.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        _Tile(
          icon: Icons.calendar_view_month_outlined,
          title: 'Academic system',
          value: cfg.system == AcademicSystem.semester ? 'Semester system' : 'Annual (year) system',
          onTap: () => _push(context, const SystemSettingsScreen()),
        ),
        _Tile(
          icon: Icons.speed_outlined,
          title: 'GPA scale',
          value: 'Out of ${fmtNum(cfg.scaleMax)}',
          onTap: () => _push(context, const ScaleSettingsScreen()),
        ),
        _Tile(
          icon: Icons.pie_chart_outline,
          title: 'Assessment weights',
          value: cfg.components.map((c) => '${c.name} ${fmtNum(c.weight)}%').join(' · '),
          onTap: () => _push(context, const WeightSettingsScreen()),
        ),
        _Tile(
          icon: Icons.tune,
          title: 'Grade table',
          value: 'Cut-offs and points for each letter',
          onTap: () => _push(context, const GradeScaleScreen()),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _confirmReset(context),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset app and start over'),
        ),
      ]),
    );
  }

  static void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _confirmReset(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset everything?'),
        content: const Text('All terms, courses and settings will be deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) await state.resetAll();
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.value, required this.onTap});
  final IconData icon;
  final String title, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        onTap: onTap,
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: .6))),
            ]),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurface.withValues(alpha: .4)),
        ]),
      ),
    );
  }
}

void _toast(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

// ---------------------------------------------------------------- system

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  late AcademicSystem _system = context.read<AppState>().config.system;

  void _save() {
    final state = context.read<AppState>();
    state.updateConfig(state.config.copyWith(system: _system));
    Navigator.pop(context);
    _toast(context, 'Academic system updated');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Academic system')),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                OptionCard(
                  badge: 'S',
                  title: 'Semester system',
                  subtitle: 'Fall, Spring and Summer terms',
                  selected: _system == AcademicSystem.semester,
                  onTap: () => setState(() => _system = AcademicSystem.semester),
                ),
                const SizedBox(height: 10),
                OptionCard(
                  badge: 'Y',
                  title: 'Annual (year) system',
                  subtitle: 'Year 1, Year 2 and so on',
                  selected: _system == AcademicSystem.annual,
                  onTap: () => setState(() => _system = AcademicSystem.annual),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your existing terms and courses are kept. Only the labels change.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6)),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- scale

class ScaleSettingsScreen extends StatefulWidget {
  const ScaleSettingsScreen({super.key});

  @override
  State<ScaleSettingsScreen> createState() => _ScaleSettingsScreenState();
}

enum _Scale { four, ten, custom }

class _ScaleSettingsScreenState extends State<ScaleSettingsScreen> {
  late final double _current = context.read<AppState>().config.scaleMax;
  late _Scale _scale = _current == 4 ? _Scale.four : (_current == 10 ? _Scale.ten : _Scale.custom);
  late final _customMax = TextEditingController(text: _scale == _Scale.custom ? fmtNum(_current) : '5');

  double get _max => switch (_scale) {
        _Scale.four => 4,
        _Scale.ten => 10,
        _Scale.custom => double.tryParse(_customMax.text) ?? 0,
      };

  bool get _valid => _max > 0 && _max <= 100;

  @override
  void dispose() {
    _customMax.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final max = _max;
    if (max == _current) {
      Navigator.pop(context);
      return;
    }
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to ${fmtNum(max)} scale?'),
        content: const Text(
            'The grade table will be reset to the default for this scale. Your courses and marks are kept, '
            'and you can edit the grade table afterwards.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Switch')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    state.updateConfig(state.config.copyWith(scaleMax: max, bands: GradingConfig.defaultBands(max)));
    Navigator.pop(context);
    _toast(context, 'GPA scale updated');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GPA scale')),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                OptionCard(
                  badge: '4.0',
                  title: 'Out of 4.0',
                  subtitle: 'A = 4.0, B = 3.0 and so on',
                  selected: _scale == _Scale.four,
                  onTap: () => setState(() => _scale = _Scale.four),
                ),
                const SizedBox(height: 10),
                OptionCard(
                  badge: '10',
                  title: 'Out of 10',
                  subtitle: 'Common in Indian universities',
                  selected: _scale == _Scale.ten,
                  onTap: () => setState(() => _scale = _Scale.ten),
                ),
                const SizedBox(height: 10),
                OptionCard(
                  badge: '+',
                  title: 'Custom scale',
                  subtitle: 'Set your own maximum',
                  selected: _scale == _Scale.custom,
                  onTap: () => setState(() => _scale = _Scale.custom),
                ),
                if (_scale == _Scale.custom) ...[
                  const SizedBox(height: 14),
                  NumberField(controller: _customMax, label: 'Maximum GPA', onChanged: (_) => setState(() {})),
                ],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(onPressed: _valid ? _save : null, child: const Text('Save')),
            ),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- weights

class WeightSettingsScreen extends StatefulWidget {
  const WeightSettingsScreen({super.key});

  @override
  State<WeightSettingsScreen> createState() => _WeightSettingsScreenState();
}

class _WeightSettingsScreenState extends State<WeightSettingsScreen> {
  late List<AssessmentComponent> _base;
  late List<TextEditingController> _ctrls;
  late bool _split;

  @override
  void initState() {
    super.initState();
    final comps = context.read<AppState>().config.components;
    _split = comps.any((c) => c.id == 'quiz');
    _load(comps);
  }

  void _load(List<AssessmentComponent> comps) {
    _base = comps;
    _ctrls = [for (final c in comps) TextEditingController(text: fmtNum(c.weight))];
  }

  void _disposeAll() {
    for (final c in _ctrls) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  double get _total => _ctrls.fold(0.0, (a, c) => a + (double.tryParse(c.text) ?? 0));
  bool get _valid => (_total - 100).abs() < 0.01;

  void _setSplit(bool v) {
    _disposeAll();
    setState(() {
      _split = v;
      _load(GradingConfig.defaultComponents(split: v));
    });
  }

  void _save() {
    final state = context.read<AppState>();
    final comps = [
      for (var i = 0; i < _base.length; i++)
        AssessmentComponent(_base[i].id, _base[i].name, double.tryParse(_ctrls[i].text) ?? 0),
    ];
    state.updateConfig(state.config.copyWith(components: comps));
    Navigator.pop(context);
    _toast(context, 'Assessment weights updated');
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment weights')),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text('Weights must add up to 100%.', style: TextStyle(color: muted)),
              const SizedBox(height: 16),
              for (var i = 0; i < _base.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Expanded(child: Text(_base[i].name, style: const TextStyle(fontSize: 16))),
                    SizedBox(
                      width: 100,
                      child: NumberField(
                          controller: _ctrls[i], label: '', suffix: '%', onChanged: (_) => setState(() {})),
                    ),
                  ]),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Split quizzes and assignments'),
                value: _split,
                onChanged: _setSplit,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Pill(_valid ? 'Total 100%' : 'Total ${_total.toStringAsFixed(1)}% (needs 100)', warn: !_valid),
              ),
              const SizedBox(height: 14),
              Text(
                'Marks already entered for your courses are kept. Course results are recalculated with the new weights.',
                style: TextStyle(color: muted),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(onPressed: _valid ? _save : null, child: const Text('Save')),
          ),
        ]),
      ),
    );
  }
}
