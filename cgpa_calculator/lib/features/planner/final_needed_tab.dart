import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';
import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/utils/grade_calculator.dart';
import 'package:cgpa_calculator/core/widgets/assessment_editor.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/state/app_state.dart';

/// "What do I need in the final?" Enter mid and quiz/assignment marks (each with
/// its own total) plus the final's total marks, and see the marks needed for
/// every grade.
class FinalNeededTab extends StatefulWidget {
  const FinalNeededTab({super.key});

  @override
  State<FinalNeededTab> createState() => _FinalNeededTabState();
}

class _FinalNeededTabState extends State<FinalNeededTab> {
  late final DraftSet _drafts;
  String? _target;

  @override
  void initState() {
    super.initState();
    final comps = context.read<AppState>().config.components;
    _drafts = DraftSet(comps, const {});
  }

  @override
  void dispose() {
    _drafts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cfg = s.config;
    final calc = s.calc;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    final finalComp = cfg.components.where((c) => c.id == 'final').firstOrNull;
    if (finalComp == null) {
      return const EmptyState(
        icon: Icons.info_outline,
        title: 'No final exam set up',
        message: 'Add a final exam under Settings > Assessment weights to use this calculator.',
      );
    }
    final others = cfg.components.where((c) => c.id != 'final').toList();
    final entries = _drafts.toEntries();
    final otherMarks = others.fold(0.0, (a, c) => a + calc.componentMarks(c, entries));
    final finalMax = double.tryParse(_drafts.rows['final']!.first.max.text) ?? 0;

    // Bands from best to worst, so the list reads top-down.
    final bands = [...cfg.bands]..sort((a, b) => b.minMarks.compareTo(a.minMarks));
    final target = bands.where((b) => b.letter == _target).firstOrNull ?? bands.first;

    double neededMarks(GradeBand b) =>
        GradeCalculator.finalFractionNeeded(target: b.minMarks, otherMarks: otherMarks, finalWeight: finalComp.weight) *
        finalMax;

    final needed = neededMarks(target);
    final possible = finalMax > 0 && needed <= finalMax + 1e-9;
    final already = otherMarks >= target.minMarks;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
      Text(
        'Enter what you have so far. Quizzes and assignments can each have their own total. '
        'Leave the final blank and see what it takes.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 16),
      Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AssessmentEditor(
          components: cfg.components,
          drafts: _drafts,
          totalOnly: const {'final'},
          onChanged: () => setState(() {}),
        ),
      ),
      DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: target.letter,
        decoration: const InputDecoration(labelText: 'Grade I want'),
        items: [for (final b in bands) DropdownMenuItem(value: b.letter, child: Text('${b.letter}  ·  needs ${fmtNum(b.minMarks)}% overall'))],
        onChanged: (v) => setState(() => _target = v),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: finalMax <= 0 || possible ? context.softFill : context.clayFill,
          borderRadius: BorderRadius.circular(22),
        ),
        child: finalMax <= 0
            ? const Text('Enter the total marks of the final exam to see the result.')
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('So far you have ${fmt(otherMarks)} out of ${fmtNum(100 - finalComp.weight)}.', style: TextStyle(color: muted)),
                const SizedBox(height: 6),
                if (already) ...[
                  Text('You already have enough for ${target.letter}.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                  Text('Any score in the final keeps you at ${target.letter} or better.', style: TextStyle(color: muted)),
                ] else ...[
                  Text('To get ${target.letter} you need at least', style: TextStyle(color: muted)),
                  Text(
                    '${fmt(needed)} / ${fmtNum(finalMax)}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: possible ? Theme.of(context).colorScheme.primary : context.clayColor,
                    ),
                  ),
                  Text(possible
                      ? 'in the final, which is ${fmt(needed / finalMax * 100, 1)}%.'
                      : 'That is more than the final is worth, so ${target.letter} is out of reach.',
                      style: TextStyle(color: possible ? null : context.clayColor)),
                ],
              ]),
      ),
      if (finalMax > 0) ...[
        const SizedBox(height: 20),
        const Text('Every grade', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        for (final b in bands)
          Builder(builder: (_) {
            final n = neededMarks(b);
            final ok = n <= finalMax + 1e-9;
            final done = otherMarks >= b.minMarks;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SoftCard(
                selected: b.letter == target.letter,
                onTap: () => setState(() => _target = b.letter),
                child: Row(children: [
                  GradeBadge(letter: b.letter, ratio: b.points / cfg.scaleMax),
                  const SizedBox(width: 12),
                  Expanded(child: Text(done ? 'Already secured' : ok ? '${fmt(n)} / ${fmtNum(finalMax)}' : 'Not reachable')),
                  Text('${fmtNum(b.minMarks)}%', style: TextStyle(color: muted)),
                ]),
              ),
            );
          }),
      ],
    ]);
  }
}
