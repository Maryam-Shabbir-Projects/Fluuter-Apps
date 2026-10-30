import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cgpa_calculator/core/theme/app_theme.dart';
import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/widgets/assessment_editor.dart';
import 'package:cgpa_calculator/core/widgets/common_widgets.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/state/app_state.dart';

class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key, required this.termId, this.course});
  final String termId;
  final Course? course;

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _credits;
  late final TextEditingController _labCredits;
  late final DraftSet _theory;
  late final DraftSet _lab;
  late bool _manual;
  late String _letter;
  late bool _hasLab;
  late String _labLetter;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<AppState>().config;
    final c = widget.course;
    _name = TextEditingController(text: c?.name ?? '');
    _credits = TextEditingController(text: c == null ? '3' : fmtNum(c.credits));
    _theory = DraftSet(cfg.components, c?.entries ?? const {});
    _hasLab = c?.lab != null;
    _labCredits = TextEditingController(text: c?.lab == null ? '1' : fmtNum(c!.lab!.credits));
    _lab = DraftSet(cfg.components, c?.lab?.entries ?? const {});
    _manual = c?.manualLetter != null || c?.lab?.manualLetter != null;
    _letter = c?.manualLetter ?? cfg.bands.first.letter;
    _labLetter = c?.lab?.manualLetter ?? cfg.bands.first.letter;
  }

  @override
  void dispose() {
    _name.dispose();
    _credits.dispose();
    _labCredits.dispose();
    _theory.dispose();
    _lab.dispose();
    super.dispose();
  }

  Course _draft() => Course(
        id: widget.course?.id ?? newId(),
        name: _name.text.trim(),
        credits: double.tryParse(_credits.text) ?? 0,
        entries: _theory.toEntries(),
        manualLetter: _manual ? _letter : null,
        lab: _hasLab
            ? Lab(
                credits: double.tryParse(_labCredits.text) ?? 0,
                entries: _lab.toEntries(),
                manualLetter: _manual ? _labLetter : null,
              )
            : null,
      );

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().upsertCourse(widget.termId, _draft());
    Navigator.pop(context);
  }

  Widget _gradeDropdown(GradingConfig cfg, String value, ValueChanged<String> onChanged, String label) =>
      DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final b in cfg.bands) DropdownMenuItem(value: b.letter, child: Text('${b.letter}  ·  ${fmt(b.points)} points')),
        ],
        onChanged: (v) => setState(() => onChanged(v ?? value)),
      );

  Widget _result(String title, String value, GradeBand band, double scaleMax) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.softFill, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title),
            Text(
              value,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
            ),
          ]),
          GradeBadge(letter: band.letter, ratio: band.points / scaleMax, size: 56),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cfg = s.config;
    final calc = s.calc;
    final draft = _draft();
    final band = calc.bandFor(draft);
    final labBand = draft.lab == null ? null : calc.labBandFor(draft.lab!);
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Scaffold(
      appBar: AppBar(title: Text(widget.course == null ? 'Add course' : 'Edit course')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Course name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a course name' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          NumberField(
            controller: _credits,
            label: 'Credit hours',
            validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'Enter credit hours',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Marks')),
              ButtonSegment(value: true, label: Text('Enter grade')),
            ],
            selected: {_manual},
            onSelectionChanged: (v) => setState(() => _manual = v.first),
          ),
          const SizedBox(height: 16),
          if (!_manual) ...[
            Text(
              'Enter each exam, quiz and assignment with the marks you got and what it was out of. '
              'Different totals are fine.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 14),
            AssessmentEditor(components: cfg.components, drafts: _theory, onChanged: () => setState(() {})),
          ] else
            _gradeDropdown(cfg, _letter, (v) => _letter = v, 'Grade'),
          const Divider(height: 28),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('This course has a lab'),
            subtitle: const Text('The lab has its own credit hours and marks'),
            value: _hasLab,
            onChanged: (v) => setState(() => _hasLab = v),
          ),
          if (_hasLab) ...[
            const SizedBox(height: 8),
            NumberField(
              controller: _labCredits,
              label: 'Lab credit hours',
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'Enter lab credit hours',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (!_manual) ...[
              Text('Lab marks', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              AssessmentEditor(components: cfg.components, drafts: _lab, onChanged: () => setState(() {})),
            ] else
              _gradeDropdown(cfg, _labLetter, (v) => _labLetter = v, 'Lab grade'),
          ],
          const SizedBox(height: 8),
          _result(
            _manual ? 'Grade points' : (_hasLab ? 'Theory marks' : 'Total marks'),
            _manual ? fmt(band.points) : '${fmtNum(double.parse(calc.totalMarks(draft).toStringAsFixed(2)))} / 100',
            band,
            cfg.scaleMax,
          ),
          if (labBand != null)
            _result(
              _manual ? 'Lab grade points' : 'Lab marks',
              _manual ? fmt(labBand.points) : '${fmtNum(double.parse(calc.marksFor(draft.lab!.entries).toStringAsFixed(2)))} / 100',
              labBand,
              cfg.scaleMax,
            ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Save course')),
        ]),
      ),
    );
  }
}
