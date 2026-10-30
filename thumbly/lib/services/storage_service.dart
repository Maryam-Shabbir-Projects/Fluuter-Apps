import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../models/design.dart';

/// Saves the user's designs on the phone: <app documents>/thumbly/{designs,media}.
/// Each design = <id>.json (data) + <id>.png (preview). Photos are copied to media/.
class StorageService {
  StorageService._();
  static final instance = StorageService._();

  late final Directory _root;

  Future<void> init() async {
    final base = await getApplicationDocumentsDirectory();
    _root = Directory('${base.path}/thumbly');
    await Directory('${_root.path}/designs').create(recursive: true);
    await Directory('${_root.path}/media').create(recursive: true);
  }

  String media(String name) => '${_root.path}/media/$name';
  String thumb(String id) => '${_root.path}/designs/$id.png';
  File _json(String id) => File('${_root.path}/designs/$id.json');

  /// Copies a picked image into app storage and returns its permanent file name.
  Future<String> importImage(String sourcePath) async {
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
    final name = '${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(sourcePath).copy(media(name));
    return name;
  }

  /// Writes raw bytes (e.g. a cut-out PNG) into app storage and returns the file name.
  Future<String> saveBytes(Uint8List bytes, String ext) async {
    final name = '${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(media(name)).writeAsBytes(bytes);
    return name;
  }

  Future<void> save(Design d, Uint8List? previewPng) async {
    d.updated = DateTime.now();
    await _json(d.id).writeAsString(jsonEncode(d.toJson()));
    if (previewPng != null) await File(thumb(d.id)).writeAsBytes(previewPng);
  }

  Future<List<Design>> list() async {
    final out = <Design>[];
    await for (final f in Directory('${_root.path}/designs').list()) {
      if (f is File && f.path.endsWith('.json')) {
        try {
          out.add(Design.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>));
        } catch (_) {/* skip corrupt file */}
      }
    }
    out.sort((a, b) => b.updated.compareTo(a.updated));
    return out;
  }

  Future<void> delete(String id) async {
    if (await _json(id).exists()) await _json(id).delete();
    final t = File(thumb(id));
    if (await t.exists()) await t.delete();
  }

  Future<void> duplicate(Design s) async {
    final c = Design(name: '${s.name} copy', doc: s.doc.copy());
    await save(c, null);
    final t = File(thumb(s.id));
    if (await t.exists()) await t.copy(thumb(c.id));
  }
}
