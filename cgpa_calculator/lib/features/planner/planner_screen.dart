import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';
import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/utils/grade_calculator.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/features/planner/final_needed_tab.dart';
import 'package:cgpa_calculator/state/app_state.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Planner'),
            bottom: const TabBar(tabs: [Tab(text: 'Target CGPA'), Tab(text: 'Final exam needed')]),
          ),
          body: const TabBarView(children: [_TargetCgpaTab(), FinalNeededTab()]),
        ),
      );
}

class _TargetCgpaTab extends StatefulWidget {
  const _TargetCgpaTab();

  @override
  State<_TargetCgpaTab> createState() => _TargetCgpaTabState();
}

class _TargetCgpaTabState extends State<_TargetCgpaTab> {
  late final TextEditingController _target;
  final _credits = TextEditingController(text: '15');
  int _terms = 1;

  @override
  void initState() {
    super.initState();
    final max = context.read<AppState>().config.scaleMax;
    _target = TextEditingController(text: fmt(max * .9));
  }

  @override
  void dispose() {
    _target.dispose();
    _credits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cfg = s.config;
    final target = double.tryParse(_target.text) ?? 0;
    final perTerm = double.tryParse(_credits.text) ?? 0;
    final required = GradeCalculator.requiredAverage(
      currentCgpa: s.cgpa,
      currentCredits: s.totalCredits,
      target: target,
      upcomingCredits: perTerm * _terms,
    );
    final reachable = required != null && required <= cfg.scaleMax + 1e-9;
    final label = cfg.termLabel.toLowerCase();
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
        Text('Find the GPA you need in the coming ${label}s.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: NumberField(controller: _target, label: 'Target CGPA', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(child: NumberField(controller: _credits, label: 'Credits per $label', onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Plan over', style: TextStyle(color: muted))),
          SegmentedButton<int>(
            segments: [for (final n in [1, 2, 3, 4]) ButtonSegment(value: n, label: Text('$n'))],
            selected: {_terms},
            onSelectionChanged: (v) => setState(() => _terms = v.first),
          ),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: required == null || reachable ? context.softFill : context.clayFill,
            borderRadius: BorderRadius.circular(22),
          ),
          child: required == null
              ? const Text('Enter your credits per term to see the result.')
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('You need an average GPA of at least', style: TextStyle(color: muted)),
                  Text(
                    fmt(required),
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: reachable ? Theme.of(context).colorScheme.primary : context.clayColor,
                    ),
                  ),
                  Text('across ${fmtNum(perTerm * _terms)} credits over $_terms $label${_terms > 1 ? 's' : ''}'),
                  if (!reachable) ...[
                    const SizedBox(height: 8),
                    Text(
                      'That is above the ${fmtNum(cfg.scaleMax)} maximum. Try a lower target or plan over more ${label}s.',
                      style: TextStyle(color: context.clayColor),
                    ),
                  ],
                ]),
        ),
        const SizedBox(height: 12),
        Text('Current CGPA ${fmt(s.cgpa)} over ${fmtNum(s.totalCredits)} credits.', style: TextStyle(color: muted)),
      ]);
  }
}
