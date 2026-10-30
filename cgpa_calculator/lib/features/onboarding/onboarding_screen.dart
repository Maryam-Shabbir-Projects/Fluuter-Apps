import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/state/app_state.dart';

enum _Scale { four, ten, custom }

class _WeightField {
  _WeightField(this.id, this.name, double weight) : controller = TextEditingController(text: _show(weight));
  final String id;
  final String name;
  final TextEditingController controller;
  double get value => double.tryParse(controller.text) ?? 0;
  static String _show(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onBack});

  /// Called when the user goes back from the first step (to the landing page).
  final VoidCallback? onBack;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  final _customMax = TextEditingController(text: '5');
  int _step = 0;
  AcademicSystem _system = AcademicSystem.semester;
  _Scale _scale = _Scale.four;
  bool _split = false;
  late List<_WeightField> _weights = _fieldsFor(split: false);

  List<_WeightField> _fieldsFor({required bool split}) =>
      [for (final c in GradingConfig.defaultComponents(split: split)) _WeightField(c.id, c.name, c.weight)];

  double get _scaleMax => switch (_scale) {
        _Scale.four => 4,
        _Scale.ten => 10,
        _Scale.custom => double.tryParse(_customMax.text) ?? 0,
      };

  double get _total => _weights.fold(0.0, (a, w) => a + w.value);
  bool get _weightsValid => (_total - 100).abs() < 0.01;

  bool get _canContinue => switch (_step) {
        1 => _scaleMax > 0,
        2 => _weightsValid,
        _ => true,
      };

  void _setSplit(bool v) {
    for (final w in _weights) {
      w.controller.dispose();
    }
    setState(() {
      _split = v;
      _weights = _fieldsFor(split: v);
    });
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      return;
    }
    final max = _scaleMax;
    context.read<AppState>().completeOnboarding(GradingConfig(
          system: _system,
          scaleMax: max,
          components: [for (final w in _weights) AssessmentComponent(w.id, w.name, w.value)],
          bands: GradingConfig.defaultBands(max),
        ));
  }

  void _back() {
    if (_step == 0) {
      widget.onBack?.call();
      return;
    }
    setState(() => _step--);
    _pages.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pages.dispose();
    _customMax.dispose();
    for (final w in _weights) {
      w.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: (_step > 0 || widget.onBack != null) ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back) : null,
        title: Row(children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: i <= _step ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: _pages,
              physics: const NeverScrollableScrollPhysics(),
              children: [_systemPage(), _scalePage(), _weightPage()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: FilledButton(
              onPressed: _canContinue ? _next : null,
              child: Text(_step == 2 ? 'Finish setup' : 'Continue'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header(String title, String sub) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6))),
        ]),
      );

  Widget _systemPage() => ListView(padding: const EdgeInsets.all(20), children: [
        _header('How does your university run?', 'This decides how your courses are grouped.'),
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
      ]);

  Widget _scalePage() => ListView(padding: const EdgeInsets.all(20), children: [
        _header('Which GPA scale is used?', 'You can edit the grade table later.'),
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
      ]);

  Widget _weightPage() {
    final ok = _weightsValid;
    return ListView(padding: const EdgeInsets.all(20), children: [
      _header('How are marks split?', 'Weights must add up to 100%.'),
      for (final w in _weights)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Expanded(child: Text(w.name, style: const TextStyle(fontSize: 16))),
            SizedBox(
              width: 100,
              child: NumberField(controller: w.controller, label: '', suffix: '%', onChanged: (_) => setState(() {})),
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
        child: Pill(ok ? 'Total 100%' : 'Total ${_total.toStringAsFixed(1)}% (needs 100)', warn: !ok),
      ),
    ]);
  }
}
