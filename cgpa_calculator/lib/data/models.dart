enum AcademicSystem { semester, annual }

class GradeBand {
  const GradeBand(this.letter, this.minMarks, this.points);
  final String letter;
  final double minMarks;
  final double points;

  GradeBand copyWith({double? minMarks, double? points}) =>
      GradeBand(letter, minMarks ?? this.minMarks, points ?? this.points);

  Map<String, dynamic> toJson() => {'letter': letter, 'min': minMarks, 'points': points};

  factory GradeBand.fromJson(Map<String, dynamic> j) => GradeBand(
        j['letter'] as String,
        (j['min'] as num).toDouble(),
        (j['points'] as num).toDouble(),
      );
}

/// One graded part of a course, e.g. "Midterm" with a weight of 25 marks.
class AssessmentComponent {
  const AssessmentComponent(this.id, this.name, this.weight);
  final String id;
  final String name;
  final double weight;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'weight': weight};

  factory AssessmentComponent.fromJson(Map<String, dynamic> j) => AssessmentComponent(
        j['id'] as String,
        j['name'] as String,
        (j['weight'] as num).toDouble(),
      );
}

class GradingConfig {
  const GradingConfig({
    required this.system,
    required this.scaleMax,
    required this.components,
    required this.bands,
  });

  final AcademicSystem system;
  final double scaleMax;
  final List<AssessmentComponent> components;
  final List<GradeBand> bands;

  String get termLabel => system == AcademicSystem.semester ? 'Semester' : 'Year';
  double get totalWeight => components.fold(0.0, (a, c) => a + c.weight);

  GradingConfig copyWith({
    AcademicSystem? system,
    double? scaleMax,
    List<AssessmentComponent>? components,
    List<GradeBand>? bands,
  }) =>
      GradingConfig(
        system: system ?? this.system,
        scaleMax: scaleMax ?? this.scaleMax,
        components: components ?? this.components,
        bands: bands ?? this.bands,
      );

  static List<AssessmentComponent> defaultComponents({bool split = false}) => split
      ? const [
          AssessmentComponent('mid', 'Midterm', 25),
          AssessmentComponent('quiz', 'Quizzes', 12.5),
          AssessmentComponent('assignment', 'Assignments', 12.5),
          AssessmentComponent('final', 'Final exam', 50),
        ]
      : const [
          AssessmentComponent('mid', 'Midterm', 25),
          AssessmentComponent('assess', 'Quizzes + assignments', 25),
          AssessmentComponent('final', 'Final exam', 50),
        ];

  static List<GradeBand> defaultBands(double scaleMax) {
    if (scaleMax == 10) {
      return const [
        GradeBand('O', 90, 10),
        GradeBand('A+', 80, 9),
        GradeBand('A', 70, 8),
        GradeBand('B+', 60, 7),
        GradeBand('B', 55, 6),
        GradeBand('C', 50, 5),
        GradeBand('P', 40, 4),
        GradeBand('F', 0, 0),
      ];
    }
    const base = [
      GradeBand('A', 85, 4.0),
      GradeBand('A-', 80, 3.67),
      GradeBand('B+', 75, 3.33),
      GradeBand('B', 70, 3.0),
      GradeBand('B-', 65, 2.67),
      GradeBand('C+', 60, 2.33),
      GradeBand('C', 55, 2.0),
      GradeBand('D', 50, 1.0),
      GradeBand('F', 0, 0),
    ];
    final f = scaleMax / 4;
    return [for (final b in base) b.copyWith(points: double.parse((b.points * f).toStringAsFixed(2)))];
  }

  Map<String, dynamic> toJson() => {
        'system': system.name,
        'scaleMax': scaleMax,
        'components': components.map((c) => c.toJson()).toList(),
        'bands': bands.map((b) => b.toJson()).toList(),
      };

  factory GradingConfig.fromJson(Map<String, dynamic> j) => GradingConfig(
        system: AcademicSystem.values.byName(j['system'] as String),
        scaleMax: (j['scaleMax'] as num).toDouble(),
        components: [for (final c in j['components'] as List) AssessmentComponent.fromJson(c as Map<String, dynamic>)],
        bands: [for (final b in j['bands'] as List) GradeBand.fromJson(b as Map<String, dynamic>)],
      );
}

/// One graded item, e.g. "Quiz 2: 7 out of 10".
class AssessmentEntry {
  const AssessmentEntry(this.obtained, this.max);
  final double obtained;
  final double max;

  Map<String, dynamic> toJson() => {'o': obtained, 'm': max};

  factory AssessmentEntry.fromJson(Map<String, dynamic> j) =>
      AssessmentEntry((j['o'] as num).toDouble(), (j['m'] as num).toDouble());
}

/// Entries per component id (e.g. 'mid' -> [30/40], 'assess' -> [7/10, 15/20]).
typedef EntryMap = Map<String, List<AssessmentEntry>>;

Map<String, dynamic> entriesToJson(EntryMap m) => {
      for (final e in m.entries) e.key: e.value.map((x) => x.toJson()).toList(),
    };

EntryMap entriesFromJson(Map<String, dynamic> j) => {
      for (final e in j.entries)
        e.key: [for (final x in e.value as List) AssessmentEntry.fromJson(x as Map<String, dynamic>)],
    };

/// The lab part of a course. It has its own credits and its own marks, graded
/// with the same weights as the theory part.
class Lab {
  const Lab({required this.credits, this.entries = const {}, this.manualLetter});
  final double credits;
  final EntryMap entries;
  final String? manualLetter;

  Map<String, dynamic> toJson() =>
      {'credits': credits, 'entries': entriesToJson(entries), 'letter': manualLetter};

  factory Lab.fromJson(Map<String, dynamic> j) => Lab(
        credits: (j['credits'] as num).toDouble(),
        entries: entriesFromJson((j['entries'] as Map).cast<String, dynamic>()),
        manualLetter: j['letter'] as String?,
      );
}

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.credits,
    this.entries = const {},
    this.manualLetter,
    this.lab,
  });

  final String id;
  final String name;
  final double credits;

  /// Every mark entered for the theory part, per component id.
  final EntryMap entries;

  /// When set, the grade was entered directly instead of calculated from marks.
  final String? manualLetter;

  /// Present only when the course has a lab.
  final Lab? lab;

  /// Theory plus lab credits.
  double get totalCredits => credits + (lab?.credits ?? 0);

  /// Turns old-style marks (already out of each component's weight) into entries.
  static EntryMap entriesFromLegacy(Map<String, double> marks, List<AssessmentComponent>? comps) => {
        for (final e in marks.entries)
          e.key: [
            AssessmentEntry(
              e.value,
              comps?.where((c) => c.id == e.key).map((c) => c.weight).firstOrNull ?? _legacyWeight[e.key] ?? 100,
            ),
          ],
      };

  static const _legacyWeight = {'mid': 25.0, 'assess': 25.0, 'quiz': 12.5, 'assignment': 12.5, 'final': 50.0};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'credits': credits,
        'entries': entriesToJson(entries),
        'letter': manualLetter,
        'lab': lab?.toJson(),
      };

  factory Course.fromJson(Map<String, dynamic> j) {
    final EntryMap entries = j['entries'] != null
        ? entriesFromJson((j['entries'] as Map).cast<String, dynamic>())
        : entriesFromLegacy({
            for (final e in ((j['marks'] ?? {}) as Map).entries) e.key as String: (e.value as num).toDouble(),
          }, null);
    return Course(
      id: j['id'] as String,
      name: j['name'] as String,
      credits: (j['credits'] as num).toDouble(),
      entries: entries,
      manualLetter: j['letter'] as String?,
      lab: j['lab'] == null ? null : Lab.fromJson((j['lab'] as Map).cast<String, dynamic>()),
    );
  }
}

class Term {
  const Term({required this.id, required this.name, this.courses = const []});
  final String id;
  final String name;
  final List<Course> courses;

  Term copyWith({String? name, List<Course>? courses}) =>
      Term(id: id, name: name ?? this.name, courses: courses ?? this.courses);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'courses': courses.map((c) => c.toJson()).toList()};

  factory Term.fromJson(Map<String, dynamic> j) => Term(
        id: j['id'] as String,
        name: j['name'] as String,
        courses: [for (final c in j['courses'] as List) Course.fromJson(c as Map<String, dynamic>)],
      );
}
