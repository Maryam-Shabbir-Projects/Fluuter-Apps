import 'package:flutter/material.dart';
import '../models/doc.dart';
import '../models/folder.dart';
import '../services/importer.dart';
import '../services/storage.dart';
import '../widgets/sheets.dart';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

/// Creates and saves a file (optionally from imported text) on the home screen or inside a folder.
Future<Doc?> createDoc(BuildContext c, {String? folderId, ImportedText? imp}) async {
  final name = imp?.name ??
      await showNameSheet(c, icon: Icons.note_add_rounded, title: 'New file', subtitle: 'Give your notes a name. You can change it any time.', hint: 'e.g. Chapter 1', action: 'Create file');
  if (name == null) return null;
  final d = Doc(_newId(), name.trim().isEmpty ? 'Untitled' : name.trim())..folderId = folderId;
  if (imp != null) d.importText(imp.text);
  await d.save();
  return d;
}

Future<Folder?> createFolder(BuildContext c) async {
  final name = await showNameSheet(c,
      icon: Icons.create_new_folder_rounded, color: const Color(0xFFF5A524), title: 'New folder', subtitle: 'A folder keeps several files together.', hint: 'e.g. My novel', action: 'Create folder', allowEmpty: false);
  if (name == null || name.trim().isEmpty) return null;
  final f = Folder(_newId(), name.trim());
  await Storage.saveFolder(f);
  return f;
}

Future<void> renameDoc(BuildContext c, Doc d) async {
  final t = await showNameSheet(c,
      icon: Icons.drive_file_rename_outline, title: 'Rename file', subtitle: 'Choose a new name for this file.', hint: 'File name', initial: d.title, action: 'Save name', allowEmpty: false);
  if (t != null && t.trim().isNotEmpty) {
    d.rename(t.trim());
    await d.save();
  }
}

Future<bool> renameFolder(BuildContext c, Folder f) async {
  final t = await showNameSheet(c,
      icon: Icons.drive_file_rename_outline, color: const Color(0xFFF5A524), title: 'Rename folder', subtitle: 'Choose a new name for this folder.', hint: 'Folder name', initial: f.name, action: 'Save name', allowEmpty: false);
  if (t == null || t.trim().isEmpty) return false;
  f.name = t.trim();
  await Storage.saveFolder(f);
  return true;
}

Future<bool> _confirm(BuildContext c, String title, String body) =>
    showConfirmSheet(c, icon: Icons.delete_outline_rounded, title: title, body: body, action: 'Delete');

Future<bool> deleteDoc(BuildContext c, Doc d) async {
  if (!await _confirm(c, 'Delete "${d.title}"?', 'This cannot be undone.')) return false;
  await Storage.deleteDoc(d);
  return true;
}

Future<bool> deleteFolder(BuildContext c, Folder f) async {
  final n = await Storage.countDocs(f.id);
  if (!c.mounted) return false;
  if (!await _confirm(c, 'Delete folder "${f.name}"?', n == 0 ? 'This folder is empty.' : 'The $n file${n == 1 ? '' : 's'} inside will be deleted too.')) return false;
  await Storage.deleteFolder(f);
  return true;
}

/// Lets the user pick a folder (or the home screen) for [d].
Future<bool> moveDoc(BuildContext c, Doc d) async {
  final folders = await Storage.loadFolders();
  if (!c.mounted) return false;
  final pick = await showAppSheet<String>(
    c,
    (x) {
      final cs = Theme.of(x).colorScheme;
      Widget row(IconData ic, Color col, String name, String id) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: col.withAlpha(36), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: col)),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: (d.folderId ?? '') == id ? Icon(Icons.check_circle, color: cs.primary) : null,
            onTap: () => Navigator.pop(x, id),
          );
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 8), child: Text('Move to', style: Theme.of(x).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
        row(Icons.home_rounded, cs.primary, 'Home (no folder)', ''),
        for (final f in folders) row(Icons.folder_rounded, const Color(0xFFF5A524), f.name, f.id),
        const SizedBox(height: 16),
      ]);
    },
  );
  if (pick == null) return false;
  d.folderId = pick.isEmpty ? null : pick;
  await d.save();
  return true;
}
