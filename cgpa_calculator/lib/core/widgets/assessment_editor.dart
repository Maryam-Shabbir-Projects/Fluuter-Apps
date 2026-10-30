import 'package:flutter/material.dart';

import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';

/// Text controllers for one graded item ("obtained" out of "max").
class EntryDraft {
  EntryDraft({double? obtained, double? max})
      : obtained = TextEditingController(text: obtained == null ? '' : fmtNum(obtained)),
        max = TextEditingController(text: max == null ? '' : fmtNum(max));

  final TextEditingController obtained;
  final TextEditingController max;

  double? get obtainedValue => double.tryParse(obtained.text);
  double? get maxValue => double.tryParse(max.text);
  bool get isEmpty => obtained.text.trim().isEmpty && max.text.trim().isEmpty;

  void dispose() {
    obtained.dispose();
    max.dispose();
  }
}

/// All the rows being edited for a set of components. Owns the controllers.
class DraftSet {
  DraftSet(List<AssessmentComponent> comps, EntryMap initial) {
    for (final c in comps) {
      final list = initial[c.id] ?? const [];
      rows[c.id] = list.isEmpty
          ? [EntryDraft()]
          : [for (final e in list) EntryDraft(obtained: e.obtained, max: e.max)];
    }
  }

  final Map<String, List<EntryDraft>> rows = {};

  /// Only complete, valid rows become entries (blank rows are ignored).
  EntryMap toEntries() => {
        for (final e in rows.entries)
          e.key: [
            for (final r in e.value)
              if (r.obtainedValue != null && (r.maxValue ?? 0) > 0) AssessmentEntry(r.obtainedValue!, r.maxValue!),
          ],
      };

  void dispose() {
    for (final list in rows.values) {
      for (final r in list) {
        r.dispose();
      }
    }
  }
}

/// Editor for the marks of each component. A component can have several items
/// (quiz 1, quiz 2 ...), each with its own total, except the ones in [single].
class AssessmentEditor extends StatefulWidget {
  const AssessmentEditor({
    super.key,
    required this.components,
    required this.drafts,
    required this.onChanged,
    this.single = const {'final'},
    this.totalOnly = const {},
  });

  final List<AssessmentComponent> components;
  final DraftSet drafts;
  final VoidCallback onChanged;

  /// Component ids that always have exactly one row (e.g. the final exam).
  final Set<String> single;

  /// Component ids where only the "out of" value is asked, not marks obtained.
  final Set<String> totalOnly;

  @override
  State<AssessmentEditor> createState() => _AssessmentEditorState();
}

class _AssessmentEditorState extends State<AssessmentEditor> {
  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  String? _validateObtained(EntryDraft r) {
    if (r.isEmpty) return null;
    final o = r.obtainedValue;
    if (o == null) return 'Enter marks';
    final m = r.maxValue;
    if (m != null && o > m) return 'More than total';
    return null;
  }

  String? _validateMax(EntryDraft r) {
    if (r.isEmpty) return null;
    final m = r.maxValue;
    if (m == null || m <= 0) return 'Enter total';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final comp in widget.components) ...[
        Row(children: [
          Expanded(child: Text(comp.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
          Pill('${fmtNum(comp.weight)}% of grade'),
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < widget.drafts.rows[comp.id]!.length; i++)
          _row(comp, widget.drafts.rows[comp.id]![i], i, muted),
        if (!widget.single.contains(comp.id))
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                widget.drafts.rows[comp.id]!.add(EntryDraft());
                _changed();
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add another to ${comp.name.toLowerCase()}'),
            ),
          ),
        const SizedBox(height: 14),
      ],
    ]);
  }

  Widget _row(AssessmentComponent comp, EntryDraft r, int i, Color muted) {
    final list = widget.drafts.rows[comp.id]!;
    final multi = !widget.single.contains(comp.id);
    final totalOnly = widget.totalOnly.contains(comp.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (multi)
          Container(
            width: 28,
            height: 56,
            alignment: Alignment.center,
            child: Text('${i + 1}', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
          ),
        if (!totalOnly) ...[
          Expanded(
            child: NumberField(
              controller: r.obtained,
              label: 'Obtained',
              validator: (_) => _validateObtained(r),
              onChanged: (_) => _changed(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text('out of', style: TextStyle(color: muted)),
          ),
        ],
        Expanded(
          child: NumberField(
            controller: r.max,
            label: totalOnly ? 'Total marks of the exam' : 'Total',
            validator: (_) => totalOnly ? ((r.maxValue ?? 0) > 0 ? null : 'Enter total') : _validateMax(r),
            onChanged: (_) => _changed(),
          ),
        ),
        if (multi)
          IconButton(
            tooltip: 'Remove',
            onPressed: list.length <= 1
                ? null
                : () {
                    list.removeAt(i).dispose();
                    _changed();
                  },
            icon: const Icon(Icons.close),
          ),
      ]),
    );
  }
}
