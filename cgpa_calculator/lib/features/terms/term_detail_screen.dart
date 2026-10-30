import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/features/courses/course_form_screen.dart';
import 'package:cgpa_calculator/state/app_state.dart';

class TermDetailScreen extends StatelessWidget {
  const TermDetailScreen({super.key, required this.termId});
  final String termId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final term = s.termById(termId);
    final calc = s.calc;
    final scaleMax = s.config.scaleMax;

    return Scaffold(
      appBar: AppBar(
        title: Text(term.name),
        actions: [
          IconButton(
            tooltip: 'Rename ${s.config.termLabel.toLowerCase()}',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final n = await promptName(context, title: 'Rename ${s.config.termLabel.toLowerCase()}', initial: term.name);
              if (n != null) s.renameTerm(termId, n);
            },
          ),
          Padding(padding: const EdgeInsets.only(right: 16), child: Pill('GPA ${fmt(calc.sgpa(term.courses))}')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseFormScreen(termId: termId)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add course'),
      ),
      body: term.courses.isEmpty
          ? const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No courses yet',
              message: 'Add a course and enter its marks to see the grade.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: term.courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = term.courses[i];
                final band = calc.bandFor(c);
                final detail = c.manualLetter != null
                    ? 'Grade entered directly'
                    : '${fmtNum(double.parse(calc.totalMarks(c).toStringAsFixed(2)))}/100';
                return Dismissible(
                  key: ValueKey(c.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) => s.deleteCourse(termId, c.id),
                  child: SoftCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CourseFormScreen(termId: termId, course: c)),
                    ),
                    onLongPress: () => _renameCourse(context, s, c),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(
                              c.lab == null
                                  ? '${fmtNum(c.credits)} credits · $detail'
                                  : '${fmtNum(c.credits)}+${fmtNum(c.lab!.credits)} lab credits · $detail',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6))),
                        ]),
                      ),
                      GradeBadge(letter: band.letter, ratio: band.points / scaleMax),
                      if (c.lab != null) ...[
                        const SizedBox(width: 6),
                        GradeBadge(
                          letter: calc.labBandFor(c.lab!).letter,
                          ratio: calc.labBandFor(c.lab!).points / scaleMax,
                        ),
                      ],
                      PopupMenuButton<String>(
                        tooltip: 'More',
                        icon: const Icon(Icons.more_vert),
                        onSelected: (v) {
                          if (v == 'rename') {
                            _renameCourse(context, s, c);
                          } else if (v == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CourseFormScreen(termId: termId, course: c)),
                            );
                          } else if (v == 'delete') {
                            s.deleteCourse(termId, c.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'edit', child: Text('Edit marks')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _renameCourse(BuildContext context, AppState s, Course c) async {
    final n = await promptName(context, title: 'Rename course', initial: c.name, label: 'Course name');
    if (n != null) s.renameCourse(termId, c.id, n);
  }
}
