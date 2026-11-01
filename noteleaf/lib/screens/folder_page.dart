import 'package:flutter/material.dart';
import '../models/doc.dart';
import '../models/folder.dart';
import '../services/importer.dart';
import '../services/storage.dart';
import '../widgets/common.dart';
import '../widgets/fancy_title.dart';
import '../widgets/file_tile.dart';
import 'file_actions.dart';
import 'project_page.dart';

/// Inside a folder: any number of files.
class FolderPage extends StatefulWidget {
  final Folder folder;
  const FolderPage(this.folder, {super.key});
  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<Doc> docs = [];
  bool loading = true;
  Folder get f => widget.folder;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await Storage.loadDocs(folderId: f.id);
    if (mounted) setState(() { docs = d; loading = false; });
  }

  Future<void> _open(Doc d) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectPage(d)));
    if (mounted) setState(() {});
  }

  Future<void> _newFile([ImportedText? imp]) async {
    final d = await createDoc(context, folderId: f.id, imp: imp);
    if (d == null) return;
    docs.insert(0, d);
    if (mounted) _open(d);
  }

  Future<void> _import() async {
    try {
      final r = await Importer.pickText();
      if (r != null) await _newFile(r);
    } catch (e) {
      if (mounted) snack(context, 'Could not import: $e');
    }
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: FancyTitle(f.name),
        actions: [
          IconButton(tooltip: 'Import file', icon: const Icon(Icons.upload_file), onPressed: _import),
          IconButton(tooltip: 'Rename folder', icon: const Icon(Icons.edit_outlined), onPressed: () async { if (await renameFolder(c, f)) setState(() {}); }),
          IconButton(
            tooltip: 'Delete folder',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (await deleteFolder(c, f) && c.mounted) Navigator.pop(c);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(tooltip: 'New file', onPressed: () => _newFile(), child: const Icon(Icons.note_add_outlined)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : docs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.folder_open_rounded, size: 56, color: Color(0xFFF5A524)),
                      const SizedBox(height: 12),
                      Text('This folder is empty', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Tap + to add a file.', style: TextStyle(color: cs.onSurfaceVariant)),
                    ]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    return FileTile(
                      d: d,
                      onOpen: () => _open(d),
                      onRename: () async { await renameDoc(c, d); if (mounted) setState(() {}); },
                      onMove: () async { if (await moveDoc(c, d)) _load(); },
                      onDelete: () async { if (await deleteDoc(c, d)) _load(); },
                    );
                  },
                ),
    );
  }
}
