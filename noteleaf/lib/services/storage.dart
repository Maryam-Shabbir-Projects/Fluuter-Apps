import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/doc.dart';
import '../models/folder.dart';

/// SQLite storage. `projects` = files (settings + styled text as JSON, `folder` = parent folder id or NULL),
/// `folders` = folders, `meta` = app flags.
class Storage {
  static Database? _db;

  static Future<Database> get _database async => _db ??= await openDatabase(
        p.join(await getDatabasesPath(), 'noteleaf.db'),
        version: 2,
        onCreate: (d, _) async {
          await d.execute('CREATE TABLE projects(id TEXT PRIMARY KEY, title TEXT NOT NULL, data TEXT NOT NULL, updated INTEGER NOT NULL, folder TEXT)');
          await d.execute('CREATE TABLE folders(id TEXT PRIMARY KEY, name TEXT NOT NULL, updated INTEGER NOT NULL)');
          await d.execute('CREATE TABLE meta(k TEXT PRIMARY KEY, v TEXT)');
        },
        onUpgrade: (d, from, _) async {
          if (from < 2) {
            await d.execute('ALTER TABLE projects ADD COLUMN folder TEXT');
            await d.execute('CREATE TABLE folders(id TEXT PRIMARY KEY, name TEXT NOT NULL, updated INTEGER NOT NULL)');
          }
        },
      );

  static Future<bool> hasSeen() async => (await (await _database).query('meta', where: 'k = ?', whereArgs: ['seen'])).isNotEmpty;

  static Future<void> markSeen() async =>
      (await _database).insert('meta', {'k': 'seen', 'v': '1'}, conflictAlgorithm: ConflictAlgorithm.replace);

  /// Files directly on the home screen ([folderId] null) or inside one folder.
  static Future<List<Doc>> loadDocs({String? folderId}) async {
    final rows = await (await _database).query('projects',
        where: folderId == null ? 'folder IS NULL' : 'folder = ?', whereArgs: folderId == null ? null : [folderId], orderBy: 'updated DESC');
    return [for (final r in rows) Doc.fromJson(jsonDecode(r['data'] as String))..folderId = r['folder'] as String?];
  }

  static Future<int> countDocs(String folderId) async =>
      (await (await _database).rawQuery('SELECT COUNT(*) AS n FROM projects WHERE folder = ?', [folderId])).first['n'] as int;

  static Future<List<Folder>> loadFolders() async =>
      [for (final r in await (await _database).query('folders', orderBy: 'name COLLATE NOCASE')) Folder(r['id'] as String, r['name'] as String)];

  static Future<void> saveFolder(Folder f) async => (await _database).insert(
      'folders', {'id': f.id, 'name': f.name, 'updated': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace);

  /// Deletes the folder and every file inside it.
  static Future<void> deleteFolder(Folder f) async {
    final db = await _database;
    await db.delete('projects', where: 'folder = ?', whereArgs: [f.id]);
    await db.delete('folders', where: 'id = ?', whereArgs: [f.id]);
  }

  static Future<void> saveDoc(Doc d) async => (await _database).insert(
        'projects',
        {'id': d.id, 'title': d.title, 'data': jsonEncode(d.toJson()), 'updated': DateTime.now().millisecondsSinceEpoch, 'folder': d.folderId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  static Future<void> deleteDoc(Doc d) async => (await _database).delete('projects', where: 'id = ?', whereArgs: [d.id]);
}
