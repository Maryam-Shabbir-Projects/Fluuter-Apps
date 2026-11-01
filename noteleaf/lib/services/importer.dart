import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImportedText {
  final String name, text;
  ImportedText(this.name, this.text);
}

/// Imports text files (.txt, .md, .docx), paper images and voice files.
class Importer {
  static Future<ImportedText?> pickText() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'md', 'docx']);
    final path = r?.files.single.path;
    if (path == null) return null;
    final bytes = await File(path).readAsBytes();
    final text = path.toLowerCase().endsWith('.docx') ? _docx(bytes) : utf8.decode(bytes, allowMalformed: true);
    return ImportedText(p.basenameWithoutExtension(path), text.trim());
  }

  static String _docx(List<int> bytes) {
    final f = ZipDecoder().decodeBytes(bytes).findFile('word/document.xml');
    if (f == null) throw 'This is not a valid Word file';
    return utf8
        .decode(f.content as List<int>)
        .replaceAll('</w:p>', '\n')
        .replaceAll('<w:tab/>', '\t')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&apos;', "'");
  }

  /// Opens the phone gallery.
  static Future<String?> pickPaperImage() => _gallery('paper');
  static Future<String?> pickLogo() => _gallery('logo');

  static Future<String?> _gallery(String prefix) async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dst = '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}';
    await File(x.path).copy(dst);
    return dst;
  }

  static Future<String?> pickAudio() => _pickCopy(FileType.audio, 'voice');

  /// Copies the picked file into the app folder so it stays available.
  static Future<String?> _pickCopy(FileType type, String prefix) async {
    final r = await FilePicker.platform.pickFiles(type: type);
    final src = r?.files.single.path;
    if (src == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dst = '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}${p.extension(src)}';
    await File(src).copy(dst);
    return dst;
  }
}
