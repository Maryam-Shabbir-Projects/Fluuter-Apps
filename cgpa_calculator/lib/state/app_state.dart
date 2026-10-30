import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:cgpa_calculator/core/utils/format.dart';
import 'package:cgpa_calculator/core/utils/grade_calculator.dart';
import 'package:cgpa_calculator/data/models.dart';
import 'package:cgpa_calculator/data/storage_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this._repo);
  final StorageRepository _repo;

  GradingConfig? _config;
  List<Term> _terms = [];

  /// Database writes are chained so they always land in the order they were made.
  Future<void> _pendingWrite = Future.value();

  bool get onboarded => _config != null;
  GradingConfig get config => _config!;
  List<Term> get terms => List.unmodifiable(_terms);
  GradeCalculator get calc => GradeCalculator(config);

  double get cgpa => calc.cgpa(_terms);
  double get totalCredits => calc.credits(_terms.expand((t) => t.courses).toList());

  Future<void> load() async {
    _config = await _repo.readConfig();
    _terms = await _repo.readTerms();
  }

  Term termById(String id) => _terms.firstWhere((t) => t.id == id);

  void completeOnboarding(GradingConfig config) {
    _config = config;
    _persist(() => _repo.saveConfig(config));
    notifyListeners();
  }

  /// Replaces the whole grading setup (system, scale, weights, bands).
  void updateConfig(GradingConfig config) {
    final old = _config;
    _config = config;
    if (old != null) _remapCourses(old, config);
    _persist(() => _repo.saveConfig(config));
    notifyListeners();
  }

  /// When quizzes/assignments are merged or split in the weights, move the
  /// entered marks to the new components so nothing is lost.
  void _remapCourses(GradingConfig old, GradingConfig now) {
    final oldIds = old.components.map((c) => c.id).toSet();
    final newIds = now.components.map((c) => c.id).toSet();
    final merged = oldIds.contains('quiz') && newIds.contains('assess');
    final split = oldIds.contains('assess') && newIds.contains('quiz');
    if (!merged && !split) return;

    EntryMap remap(EntryMap m) {
      final out = {...m};
      if (merged) {
        final all = [...?out.remove('quiz'), ...?out.remove('assignment')];
        if (all.isNotEmpty) out['assess'] = all;
      } else if (split) {
        final all = out.remove('assess');
        if (all != null) out['quiz'] = all; // the user can move items to assignments by re-entering
      }
      return out;
    }

    _terms = [
      for (final t in _terms)
        t.copyWith(courses: [
          for (final c in t.courses)
            Course(
              id: c.id,
              name: c.name,
              credits: c.credits,
              entries: remap(c.entries),
              manualLetter: c.manualLetter,
              lab: c.lab == null
                  ? null
                  : Lab(credits: c.lab!.credits, entries: remap(c.lab!.entries), manualLetter: c.lab!.manualLetter),
            ),
        ]),
    ];
    for (final t in _terms) {
      for (final c in t.courses) {
        _persist(() => _repo.upsertCourse(t.id, c));
      }
    }
  }

  /// Wipes every term and the grading setup, returning the app to first launch.
  Future<void> resetAll() async {
    _config = null;
    _terms = [];
    await _pendingWrite;
    await _repo.clear();
    notifyListeners();
  }

  void updateBands(List<GradeBand> bands) {
    final updated = config.copyWith(bands: bands);
    _config = updated;
    _persist(() => _repo.saveConfig(updated));
    notifyListeners();
  }

  Term addTerm(String name) {
    final term = Term(id: newId(), name: name);
    _terms = [..._terms, term];
    _persist(() => _repo.insertTerm(term));
    notifyListeners();
    return term;
  }

  void renameTerm(String id, String name) {
    _terms = [for (final t in _terms) t.id == id ? t.copyWith(name: name) : t];
    _persist(() => _repo.renameTerm(id, name));
    notifyListeners();
  }

  void renameCourse(String termId, String courseId, String name) {
    final term = termById(termId);
    final old = term.courses.firstWhere((c) => c.id == courseId);
    upsertCourse(
      termId,
      Course(
        id: old.id,
        name: name,
        credits: old.credits,
        entries: old.entries,
        manualLetter: old.manualLetter,
        lab: old.lab,
      ),
    );
  }

  void deleteTerm(String id) {
    _terms = _terms.where((t) => t.id != id).toList();
    _persist(() => _repo.deleteTerm(id));
    notifyListeners();
  }

  void upsertCourse(String termId, Course course) {
    _terms = [
      for (final t in _terms)
        if (t.id != termId)
          t
        else
          t.copyWith(
            courses: t.courses.any((c) => c.id == course.id)
                ? [for (final c in t.courses) c.id == course.id ? course : c]
                : [...t.courses, course],
          ),
    ];
    _persist(() => _repo.upsertCourse(termId, course));
    notifyListeners();
  }

  void deleteCourse(String termId, String courseId) {
    _terms = [
      for (final t in _terms)
        t.id == termId ? t.copyWith(courses: t.courses.where((c) => c.id != courseId).toList()) : t,
    ];
    _persist(() => _repo.deleteCourse(courseId));
    notifyListeners();
  }

  /// Queues a database write behind any earlier ones. Errors are logged rather
  /// than thrown so one failed write can't block the ones after it.
  void _persist(Future<void> Function() write) {
    _pendingWrite = _pendingWrite.then((_) => write()).catchError((Object e, StackTrace st) {
      debugPrint('Storage write failed: $e');
    });
  }
}
