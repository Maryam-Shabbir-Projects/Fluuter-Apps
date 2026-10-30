import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/design.dart';
import '../services/storage_service.dart';
import '../widgets/dialogs.dart';
import '../widgets/stage.dart';
import 'editor/editor_screen.dart';

/// Home: pick a frame size, start a blank canvas, and open the user's saved work.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = StorageService.instance;
  List<Design>? _saved;
  FramePreset _frame = kFrames.first;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final l = await _store.list();
    if (mounted) setState(() => _saved = l);
  }

  Future<void> _open(Design d, {int tab = 0}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(design: d, initialTab: tab)));
    _reload(); // pick up anything the editor auto-saved
  }

  void _newBlank() => _open(Design(name: 'Untitled', doc: Doc([], const [Colors.white], null, null, _frame.w, _frame.h)));

  // 2 columns on phones, more on tablets
  static const _grid = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,
    childAspectRatio: 16 / 9,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
  );

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    return Scaffold(
      appBar: AppBar(title: Text('Thumbly', style: GoogleFonts.pacifico(fontSize: 30, color: kMaroon))),
      body: CustomScrollView(slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(child: Text('Choose frame size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ),
        SliverToBoxAdapter(child: _frameRow()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: _blankCanvas()),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(child: Text('My designs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ),
        if (saved == null)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())))
        else if (saved.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Text('Nothing saved yet. Your work is saved here automatically.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid.builder(
              gridDelegate: _grid,
              itemCount: saved.length,
              itemBuilder: (_, i) => _savedTile(saved[i]),
            ),
          ),
      ]),
    );
  }

  /// Frame size options: tap one and the blank canvas below changes shape.
  Widget _frameRow() => SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: kFrames.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final f = kFrames[i];
            final on = f == _frame;
            final k = 36 / (f.w > f.h ? f.w : f.h); // fit the shape icon in a 36px box
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _frame = f),
              child: Container(
                width: 104,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: on ? kBlue.withOpacity(.1) : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: on ? kBlue : Colors.transparent, width: 2),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Container(
                        width: f.w * k,
                        height: f.h * k,
                        decoration: BoxDecoration(
                          color: on ? kBlue : Colors.grey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text(f.label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ),
            );
          },
        ),
      );

  /// Empty canvas in the chosen frame size: tap to start designing.
  Widget _blankCanvas() => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _newBlank,
            child: AspectRatio(
              aspectRatio: _frame.ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBlue.withOpacity(.5), width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add_circle, color: kBlue, size: 56),
                      const SizedBox(height: 8),
                      Text('Blank ${_frame.name.toLowerCase()}', style: const TextStyle(color: kBlue, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(_frame.label, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _savedTile(Design s) => InkWell(
        onTap: () => _open(s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(fit: StackFit.expand, children: [
            Container(color: Colors.black12),
            Image.file(
              File(_store.thumb(s.id)),
              key: ValueKey(s.updated),
              fit: BoxFit.contain, // portrait / square designs are shown whole, not cropped
              errorBuilder: (_, __, ___) => StageView(s.doc, fit: BoxFit.contain),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.only(left: 8),
                child: Row(children: [
                  Expanded(
                    child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  PopupMenuButton<String>(
                    iconColor: Colors.white,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onSelected: (v) async {
                      if (v == 'rename') {
                        final n = await promptText(context, title: 'Rename', initial: s.name);
                        if (n != null && n.isNotEmpty) await _store.save(s..name = n, null);
                      } else if (v == 'copy') {
                        await _store.duplicate(s);
                      } else if (v == 'delete' && await confirm(context, 'Delete "${s.name}"?')) {
                        await _store.delete(s.id);
                      }
                      _reload();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'copy', child: Text('Duplicate')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}
