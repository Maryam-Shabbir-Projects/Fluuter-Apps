import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:cgpa_calculator/data/models.dart';

/// SQLite-backed persistence for the grading setup and all terms/courses.
///
/// Schema (v2):
///   grading_config(id=1, system, scale_max)
///   components(id, name, weight, position)
///   grade_bands(letter, min_marks, points, position)
///   terms(id, name)
///   courses(id, term_id -> terms, name, credits, manual_letter, details)
///   course_marks(course_id -> courses, component_id, marks)
///
/// Terms and courses are listed in insertion order (rowid).
class StorageRepository {
  StorageRepository._(this._db);
  final Database _db;

  static const _dbName = 'cgpa_calculator.db';
  static const _dbVersion = 2;

  // Keys used by the previous SharedPreferences-based storage.
  static const _legacyConfigKey = 'grading_config';
  static const _legacyTermsKey = 'terms';

  static Future<StorageRepository> create() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      '$dir/$_dbName',
      version: _dbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    final repo = StorageRepository._(db);
    await repo._migrateFromPreferences();
    return repo;
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE grading_config (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        system TEXT NOT NULL,
        scale_max REAL NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE components (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        weight REAL NOT NULL,
        position INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE grade_bands (
        letter TEXT PRIMARY KEY,
        min_marks REAL NOT NULL,
        points REAL NOT NULL,
        position INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE terms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        term_id TEXT NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        credits REAL NOT NULL,
        manual_letter TEXT,
        details TEXT
      )''');
    batch.execute('''
      CREATE TABLE course_marks (
        course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
        component_id TEXT NOT NULL,
        marks REAL NOT NULL,
        PRIMARY KEY (course_id, component_id)
      )''');
    batch.execute('CREATE INDEX idx_courses_term ON courses(term_id)');
    await batch.commit(noResult: true);
  }

  /// v2 adds `details`: JSON with every entry (marks + out-of) and the lab.
  /// Older courses keep their rows in course_marks, which are converted on read.
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE courses ADD COLUMN details TEXT');
    }
  }

  // ---------------------------------------------------------------- reads

  Future<GradingConfig?> readConfig() async {
    final rows = await _db.query('grading_config', limit: 1);
    if (rows.isEmpty) return null;
    try {
      final row = rows.first;
      final components = await _db.query('components', orderBy: 'position');
      final bands = await _db.query('grade_bands', orderBy: 'position');
      return GradingConfig(
        system: AcademicSystem.values.byName(row['system'] as String),
        scaleMax: (row['scale_max'] as num).toDouble(),
        components: [
          for (final c in components)
            AssessmentComponent(
              c['id'] as String,
              c['name'] as String,
              (c['weight'] as num).toDouble(),
            ),
        ],
        bands: [
          for (final b in bands)
            GradeBand(
              b['letter'] as String,
              (b['min_marks'] as num).toDouble(),
              (b['points'] as num).toDouble(),
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Term>> readTerms() async {
    final termRows = await _db.query('terms', orderBy: 'rowid');
    final courseRows = await _db.query('courses', orderBy: 'rowid');
    final markRows = await _db.query('course_marks');

    final marksByCourse = <String, Map<String, double>>{};
    for (final m in markRows) {
      (marksByCourse[m['course_id'] as String] ??= {})[m['component_id'] as String] =
          (m['marks'] as num).toDouble();
    }

    final components = (await readConfig())?.components;
    final coursesByTerm = <String, List<Course>>{};
    for (final c in courseRows) {
      final id = c['id'] as String;
      EntryMap entries = Course.entriesFromLegacy(marksByCourse[id] ?? const {}, components);
      Lab? lab;
      final raw = c['details'] as String?;
      if (raw != null) {
        try {
          final d = jsonDecode(raw) as Map<String, dynamic>;
          entries = entriesFromJson((d['entries'] as Map).cast<String, dynamic>());
          if (d['lab'] != null) lab = Lab.fromJson((d['lab'] as Map).cast<String, dynamic>());
        } catch (_) {}
      }
      (coursesByTerm[c['term_id'] as String] ??= []).add(Course(
        id: id,
        name: c['name'] as String,
        credits: (c['credits'] as num).toDouble(),
        entries: entries,
        manualLetter: c['manual_letter'] as String?,
        lab: lab,
      ));
    }

    return [
      for (final t in termRows)
        Term(
          id: t['id'] as String,
          name: t['name'] as String,
          courses: coursesByTerm[t['id']] ?? const [],
        ),
    ];
  }

  // --------------------------------------------------------------- writes

  /// Replaces the whole grading setup (system, scale, components, bands).
  Future<void> saveConfig(GradingConfig config) =>
      _db.transaction((txn) => _writeConfig(txn, config));

  Future<void> insertTerm(Term term) => _db.transaction((txn) => _writeTerm(txn, term));

  Future<void> renameTerm(String termId, String name) =>
      _db.update('terms', {'name': name}, where: 'id = ?', whereArgs: [termId]);

  /// Deletes the term; its courses and marks go with it (ON DELETE CASCADE).
  Future<void> deleteTerm(String termId) =>
      _db.delete('terms', where: 'id = ?', whereArgs: [termId]);

  Future<void> upsertCourse(String termId, Course course) =>
      _db.transaction((txn) => _writeCourse(txn, termId, course));

  Future<void> deleteCourse(String courseId) =>
      _db.delete('courses', where: 'id = ?', whereArgs: [courseId]);

  /// Wipes all data, returning the app to its first-launch state.
  Future<void> clear() => _db.transaction((txn) async {
        await txn.delete('course_marks');
        await txn.delete('courses');
        await txn.delete('terms');
        await txn.delete('components');
        await txn.delete('grade_bands');
        await txn.delete('grading_config');
      });

  // -------------------------------------------------------------- helpers

  Future<void> _writeConfig(DatabaseExecutor txn, GradingConfig config) async {
    await txn.delete('components');
    await txn.delete('grade_bands');
    await txn.delete('grading_config');

    await txn.insert('grading_config', {
      'id': 1,
      'system': config.system.name,
      'scale_max': config.scaleMax,
    });
    for (var i = 0; i < config.components.length; i++) {
      final c = config.components[i];
      await txn.insert('components', {
        'id': c.id,
        'name': c.name,
        'weight': c.weight,
        'position': i,
      });
    }
    for (var i = 0; i < config.bands.length; i++) {
      final b = config.bands[i];
      await txn.insert('grade_bands', {
        'letter': b.letter,
        'min_marks': b.minMarks,
        'points': b.points,
        'position': i,
      });
    }
  }

  Future<void> _writeTerm(DatabaseExecutor txn, Term term) async {
    await txn.insert('terms', {'id': term.id, 'name': term.name});
    for (final course in term.courses) {
      await _writeCourse(txn, term.id, course);
    }
  }

  /// Insert-or-update that keeps a course's existing position in the list
  /// (REPLACE would delete + reinsert and push it to the end).
  Future<void> _writeCourse(DatabaseExecutor txn, String termId, Course course) async {
    final values = {
      'term_id': termId,
      'name': course.name,
      'credits': course.credits,
      'manual_letter': course.manualLetter,
      'details': jsonEncode({'entries': entriesToJson(course.entries), 'lab': course.lab?.toJson()}),
    };
    final updated = await txn.update('courses', values, where: 'id = ?', whereArgs: [course.id]);
    if (updated == 0) {
      await txn.insert('courses', {'id': course.id, ...values});
    }

    // Marks now live in `details`; drop any old-style rows for this course.
    await txn.delete('course_marks', where: 'course_id = ?', whereArgs: [course.id]);
  }

  // ------------------------------------------------------------ migration

  /// One-time import of data saved by the old SharedPreferences storage, so
  /// existing users keep their terms and grading setup after updating.
  Future<void> _migrateFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final rawConfig = prefs.getString(_legacyConfigKey);
    final rawTerms = prefs.getString(_legacyTermsKey);
    if (rawConfig == null && rawTerms == null) return;

    try {
      final dbIsEmpty = await readConfig() == null && (await readTerms()).isEmpty;
      if (dbIsEmpty) {
        final config = rawConfig == null
            ? null
            : GradingConfig.fromJson(jsonDecode(rawConfig) as Map<String, dynamic>);
        final terms = rawTerms == null
            ? <Term>[]
            : [for (final t in jsonDecode(rawTerms) as List) Term.fromJson(t as Map<String, dynamic>)];

        await _db.transaction((txn) async {
          if (config != null) await _writeConfig(txn, config);
          for (final term in terms) {
            await _writeTerm(txn, term);
          }
        });
      }
      // Only drop the old copy once the import has succeeded.
      await prefs.remove(_legacyConfigKey);
      await prefs.remove(_legacyTermsKey);
    } catch (_) {
      // Leave the legacy data untouched; the import is retried next launch.
    }
  }
}
