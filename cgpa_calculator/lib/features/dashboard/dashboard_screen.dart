import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';
import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/features/terms/term_detail_screen.dart';
import 'package:cgpa_calculator/state/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cfg = s.config;
    final calc = s.calc;
    final terms = s.terms;
    final last = terms.isEmpty ? 0.0 : calc.sgpa(terms.last.courses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My results'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Pill('${fmtNum(cfg.scaleMax)} scale'))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTerm(context, s),
        icon: const Icon(Icons.add),
        label: Text('Add ${cfg.termLabel.toLowerCase()}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _HeroCard(
            cgpa: s.cgpa,
            scaleMax: cfg.scaleMax,
            credits: s.totalCredits,
            termCount: terms.length,
            lastSgpa: last,
            termLabel: cfg.termLabel,
          ),
          const SizedBox(height: 16),
          if (terms.isEmpty)
            SizedBox(
              height: 240,
              child: EmptyState(
                icon: Icons.school_outlined,
                title: 'No ${cfg.termLabel.toLowerCase()}s yet',
                message: 'Add your first ${cfg.termLabel.toLowerCase()} to start tracking your CGPA.',
              ),
            )
          else
            for (final t in terms.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TermDetailScreen(termId: t.id)),
                  ),
                  onLongPress: () => _termMenu(context, s, t.id, t.name),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(
                          '${t.courses.length} courses · ${fmtNum(calc.credits(t.courses))} credits',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6)),
                        ),
                      ]),
                    ),
                    Pill(fmt(calc.sgpa(t.courses)), warn: calc.sgpa(t.courses) < cfg.scaleMax * .6),
                    IconButton(
                      tooltip: 'More',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _termMenu(context, s, t.id, t.name),
                    ),
                  ]),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _addTerm(BuildContext context, AppState s) async {
    final ctrl = TextEditingController(text: '${s.config.termLabel} ${s.terms.length + 1}');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${s.config.termLabel.toLowerCase()}'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final term = s.addTerm(name);
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => TermDetailScreen(termId: term.id)));
    }
  }

  /// Rename / delete options for a semester or year.
  Future<void> _termMenu(BuildContext context, AppState s, String id, String name) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('Rename ${s.config.termLabel.toLowerCase()}'),
            onTap: () => Navigator.pop(ctx, 'rename'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text('Delete ${s.config.termLabel.toLowerCase()}'),
            onTap: () => Navigator.pop(ctx, 'delete'),
          ),
        ]),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'rename') {
      final n = await promptName(context, title: 'Rename ${s.config.termLabel.toLowerCase()}', initial: name);
      if (n != null) s.renameTerm(id, n);
    } else if (choice == 'delete') {
      await _confirmDelete(context, s, id, name);
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppState s, String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $name?'),
        content: const Text('All courses in it will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) s.deleteTerm(id);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.cgpa,
    required this.scaleMax,
    required this.credits,
    required this.termCount,
    required this.lastSgpa,
    required this.termLabel,
  });
  final double cgpa, scaleMax, credits, lastSgpa;
  final int termCount;
  final String termLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = (cgpa / scaleMax).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: context.heroGradient, borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cumulative GPA', style: TextStyle(color: Colors.white70)),
            Text(fmt(cgpa), style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w600)),
            Text('out of ${fmtNum(scaleMax)}', style: const TextStyle(color: Colors.white70)),
          ]),
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                value: ratio,
                strokeWidth: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
              Center(
                child: Text('${(ratio * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _Stat(fmtNum(credits), 'Credits'),
          const SizedBox(width: 8),
          _Stat('$termCount', '${termLabel}s'),
          const SizedBox(width: 8),
          _Stat(fmt(lastSgpa), 'Last GPA'),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      );
}
