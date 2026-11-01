import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/doc.dart';
import '../models/folder.dart';
import '../services/importer.dart';
import '../services/storage.dart';
import '../widgets/common.dart';
import '../widgets/fancy_title.dart';
import '../widgets/file_tile.dart';
import '../widgets/logo.dart';
import 'file_actions.dart';
import 'folder_page.dart';
import 'project_page.dart';
import 'welcome.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Doc> docs = [];
  List<Folder> folders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await Storage.loadFolders();
    final d = await Storage.loadDocs();
    if (mounted) setState(() { folders = f; docs = d; loading = false; });
  }

  Future<void> _openDoc(Doc d) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectPage(d)));
    if (mounted) setState(() {});
  }

  Future<void> _openFolder(Folder f) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderPage(f)));
    _load();
  }

  Future<void> _newFile([ImportedText? imp]) async {
    final d = await createDoc(context, imp: imp);
    if (d == null) return;
    docs.insert(0, d);
    if (mounted) _openDoc(d);
  }

  Future<void> _newFolder() async {
    final f = await createFolder(context);
    if (f != null) _load();
  }

  Future<void> _import() async {
    try {
      final r = await Importer.pickText();
      if (r != null) await _newFile(r);
    } catch (e) {
      if (mounted) snack(context, 'Could not import: $e');
    }
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) => Material(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
        ),
      );

  Widget _header() => Container(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 12, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F8F82), Color(0xFF0A5C56)]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const LeafLogo(size: 34),
            const SizedBox(width: 12),
            Text(kAppName, style: cursiveStyle(22)),
            const Spacer(),
            PopupMenuButton<String>(
              iconColor: Colors.white,
              onSelected: (v) => v == 'tour' ? Navigator.push(context, MaterialPageRoute(builder: (_) => const Welcome(fromMenu: true))) : _import(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'import', child: Text('Import text file as new file')),
                PopupMenuItem(value: 'tour', child: Text('Welcome tour')),
              ],
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [_action(Icons.note_add_outlined, 'New file', _newFile), const SizedBox(width: 10), _action(Icons.create_new_folder_outlined, 'New folder', _newFolder)]),
        ]),
      );

  Widget _label(String t) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(t, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.3))));

  Widget _folderCard(Folder f) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 14, offset: const Offset(0, 4))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openFolder(f),
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(children: [
            const Icon(Icons.folder_rounded, color: Color(0xFFF5A524), size: 30),
            const SizedBox(width: 10),
            Expanded(child: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'rename') {
                  if (await renameFolder(context, f)) _load();
                } else if (await deleteFolder(context, f)) {
                  _load();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Rename')])),
                PopupMenuItem(value: 'del', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _header()),
        if (loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (folders.isEmpty && docs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.folder_open_rounded, size: 56, color: cs.primary),
                const SizedBox(height: 12),
                Text('Nothing here yet', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Create a file, or a folder to keep several files together.', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
            ),
          )
        else ...[
          if (folders.isNotEmpty) ...[
            _label('FOLDERS'),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3, children: [for (final f in folders) _folderCard(f)]),
            ),
          ],
          if (docs.isNotEmpty) ...[
            _label('FILES'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final d = docs[i];
                  return FileTile(
                    d: d,
                    onOpen: () => _openDoc(d),
                    onRename: () async { await renameDoc(context, d); if (mounted) setState(() {}); },
                    onMove: () async { if (await moveDoc(context, d)) _load(); },
                    onDelete: () async { if (await deleteDoc(context, d)) _load(); },
                  );
                },
              ),
            ),
          ],
        ],
      ]),
    );
  }
}
