// lib/services/db_service.dart
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/committee.dart';
import '../models/member.dart';
import '../models/winner.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;
  final _uuid = Uuid();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'committee_app.db');

    return await openDatabase(
      path,
      version: 2, // ✅ bumped version to trigger onUpgrade
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // ✅ Fix for missing 'createdAt' column
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS committees');
          await _createTables(db);
        }
      },
    );
  }

  /// Helper: create all tables cleanly
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE committees(
        id TEXT PRIMARY KEY,
        name TEXT,
        durationAmount INTEGER,
        durationUnit TEXT,
        totalAmount REAL,
        totalMembers INTEGER,
        round INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE members(
        id TEXT PRIMARY KEY,
        committeeId TEXT,
        name TEXT,
        phone TEXT,
        paid REAL,
        hasWon INTEGER,
        FOREIGN KEY(committeeId) REFERENCES committees(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE winners(
        id TEXT PRIMARY KEY,
        committeeId TEXT,
        memberId TEXT,
        memberName TEXT,
        round INTEGER,
        date TEXT,
        FOREIGN KEY(committeeId) REFERENCES committees(id) ON DELETE CASCADE
      )
    ''');
  }

  // ------------------------------
  // COMMITTEE OPERATIONS
  // ------------------------------

  Future<void> insertCommittee(Committee c) async {
    final database = await db;
    await database.insert('committees', c.toMap());
  }

  Future<List<Committee>> getAllCommittees() async {
    final database = await db;
    final res = await database.query('committees', orderBy: 'name');
    return res.map((m) => Committee.fromMap(m)).toList();
  }

  Future<void> updateCommittee(Committee c) async {
    final database = await db;
    await database.update(
      'committees',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<void> deleteCommittee(String id) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('members', where: 'committeeId = ?', whereArgs: [id]);
      await txn.delete('winners', where: 'committeeId = ?', whereArgs: [id]);
      await txn.delete('committees', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> clearAllCommittees() async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('winners');
      await txn.delete('members');
      await txn.delete('committees');
    });
  }

  // ------------------------------
  // MEMBER OPERATIONS
  // ------------------------------

  Future<void> insertMember(Member m) async {
    final database = await db;
    await database.insert('members', m.toMap());
  }

  Future<List<Member>> getMembersForCommittee(String committeeId) async {
    final database = await db;
    final res = await database.query(
      'members',
      where: 'committeeId = ?',
      whereArgs: [committeeId],
    );
    return res.map((r) => Member.fromMap(r)).toList();
  }

  Future<void> updateMember(Member m) async {
    final database = await db;
    await database.update(
      'members',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  Future<void> deleteMember(String id) async {
    final database = await db;
    await database.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------
  // WINNER OPERATIONS
  // ------------------------------

  Future<void> insertWinner(WinnerRecord w) async {
    final database = await db;
    await database.insert('winners', w.toMap());
  }

  Future<List<WinnerRecord>> getWinnersForCommittee(String committeeId) async {
    final database = await db;
    final res = await database.query(
      'winners',
      where: 'committeeId = ?',
      whereArgs: [committeeId],
      orderBy: 'round DESC',
    );
    return res.map((r) => WinnerRecord.fromMap(r)).toList();
  }

  // ------------------------------
  // HELPER METHODS
  // ------------------------------

  double perMemberPendingAmount(Committee c) {
    if (c.totalMembers == 0) return 0;
    return c.totalAmount / c.totalMembers;
  }

  String newId() => _uuid.v4();
}
