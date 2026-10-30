import 'package:cgpa_calculator/data/models.dart';

/// Pure, UI-independent grade maths. Easy to unit test.
class GradeCalculator {
  const GradeCalculator(this.config);
  final GradingConfig config;

  /// Marks (out of 100) earned in one component: the total obtained across all
  /// its entries divided by the total available, scaled to the component's weight.
  /// So a 7/10 quiz and a 15/20 quiz count as 22/30 of the quiz weight.
  double componentMarks(AssessmentComponent comp, EntryMap entries) {
    final list = entries[comp.id] ?? const [];
    var got = 0.0, max = 0.0;
    for (final e in list) {
      if (e.max <= 0) continue;
      got += e.obtained.clamp(0.0, e.max).toDouble();
      max += e.max;
    }
    return max == 0 ? 0 : got / max * comp.weight;
  }

  double marksFor(EntryMap entries) =>
      config.components.fold(0.0, (a, comp) => a + componentMarks(comp, entries));

  double totalMarks(Course c) => marksFor(c.entries);

  GradeBand bandForMarks(double marks) {
    final sorted = [...config.bands]..sort((a, b) => b.minMarks.compareTo(a.minMarks));
    return sorted.firstWhere((b) => marks >= b.minMarks, orElse: () => sorted.last);
  }

  GradeBand _bandFrom(String? letter, EntryMap entries) {
    if (letter != null) {
      for (final b in config.bands) {
        if (b.letter == letter) return b;
      }
    }
    return bandForMarks(marksFor(entries));
  }

  GradeBand bandFor(Course c) => _bandFrom(c.manualLetter, c.entries);

  GradeBand labBandFor(Lab lab) => _bandFrom(lab.manualLetter, lab.entries);

  double _weighted(Iterable<Course> courses) {
    var credits = 0.0, points = 0.0;
    for (final c in courses) {
      credits += c.credits;
      points += c.credits * bandFor(c).points;
      final lab = c.lab;
      if (lab != null) {
        credits += lab.credits;
        points += lab.credits * labBandFor(lab).points;
      }
    }
    return credits == 0 ? 0 : points / credits;
  }

  double sgpa(List<Course> courses) => _weighted(courses);

  double cgpa(List<Term> terms) => _weighted(terms.expand((t) => t.courses));

  double credits(List<Course> courses) => courses.fold(0.0, (a, c) => a + c.totalCredits);

  /// Average GPA needed over [upcomingCredits] to reach [target] overall.
  static double? requiredAverage({
    required double currentCgpa,
    required double currentCredits,
    required double target,
    required double upcomingCredits,
  }) {
    if (upcomingCredits <= 0) return null;
    final needed = (target * (currentCredits + upcomingCredits) - currentCgpa * currentCredits) / upcomingCredits;
    return needed < 0 ? 0 : needed;
  }

  /// Marks needed in the final to reach [target] total marks (out of 100).
  /// [otherMarks] is what has been earned so far in everything except the final.
  /// Returns the share of the final's weight that must be earned (0..1+).
  static double finalFractionNeeded({
    required double target,
    required double otherMarks,
    required double finalWeight,
  }) {
    if (finalWeight <= 0) return 0;
    final need = target - otherMarks;
    return need <= 0 ? 0 : need / finalWeight;
  }
}
