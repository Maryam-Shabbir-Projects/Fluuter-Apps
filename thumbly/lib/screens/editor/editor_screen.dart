import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/design.dart';
import '../../models/element_model.dart';
import '../../services/bg_remove_service.dart';
import '../../services/export_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/quick_bar.dart';
import '../../widgets/sheets.dart';
import '../../widgets/stage.dart';
import 'panels.dart';

class EditorScreen extends StatefulWidget {
  final Design design;
  final int initialTab; // 0 Text, 1 Icons, 2 Shapes, 3 Images, 4 Background
  const EditorScreen({super.key, required this.design, this.initialTab = 0});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with SingleTickerProviderStateMixin {
  late final Design design = widget.design;
  late final _tabs = TabController(length: 5, vsync: this, initialIndex: widget.initialTab.clamp(0, 4));
  final _history = <Doc>[];
  final _canvasKey = GlobalKey();
  final _picker = ImagePicker();
  int? _sel;
  bool _dirty = false;

  Doc get d => design.doc;
  El? get _cur {
    for (final e in d.els) {
      if (e.id == _sel) return e;
    }
    return null;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ---- undo-aware editing helpers ----

  void _snapshot() {
    _history.add(d.copy());
    if (_history.length > 50) _history.removeAt(0);
  }

  /// One discrete edit: records undo, marks unsaved, rebuilds.
  void _apply(VoidCallback f) {
    _snapshot();
    _dirty = true;
    setState(f);
  }

  /// Continuous edit (sliders / colour picker): call _snapshot() once first.
  void _live(VoidCallback f) => setState(() {
        f();
        _dirty = true;
      });

  /// Panels place items for a 1280x720 canvas; re-centre them for the current frame size.
  void _fit(El e) {
    if (d.w == 1280 && d.h == 720) return;
    if (e.k == K.shape && e.x == 0 && e.y == 0 && e.w == 1280 && e.h == 720) {
      e.w = d.w; // full-frame overlay
      e.h = d.h;
    } else {
      e.x += (d.w - 1280) / 2;
      e.y += (d.h - 720) / 2;
    }
  }

  void _add(El e) => _apply(() {
        _fit(e);
        d.els.add(e);
        _sel = e.id;
      });

  void _addGroup(List<El> g) => _apply(() {
        g.forEach(_fit);
        d.els.addAll(g);
        _sel = g.last.id;
      });

  void _addAndEdit(El e) {
    _add(e);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editText(e);
    });
  }

  void _undo() => setState(() {
        design.doc = _history.removeLast();
        _sel = null;
      });

  // ---- typing text ----

  /// Bottom sheet with a real text field; the canvas updates as you type.
  Future<void> _editText(El e) async {
    _snapshot();
    _dirty = true;
    final c = TextEditingController(text: e.text);
    c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: c,
            autofocus: true,
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(labelText: 'Type your text', hintText: 'Any language', border: OutlineInputBorder()),
            onChanged: (v) => setState(() {
              e.text = v;
              _dirty = true;
            }),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(child: Text('Enter = new line', style: TextStyle(fontSize: 12, color: Colors.grey))),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          ]),
        ]),
      ),
    );
  }

  // ---- colours & adjustments ----

  void _pickColor(El e) {
    _snapshot();
    showColorSheet(context, title: e.k == K.shape ? 'Fill colour' : 'Colour', initial: e.color, onChanged: (c) => _live(() => e.color = c!));
  }

  void _pickOutline(El e) {
    _snapshot();
    _live(() => e.outline = true);
    showColorSheet(context, title: 'Outline colour', initial: e.stroke, onChanged: (c) => _live(() => e.stroke = c!));
  }

  void _pickTextBg(El e) {
    _snapshot();
    const fallback = Color(0xFFE52D27);
    _live(() {
      e.bgFill ??= fallback;
      if (e.radius == 0) e.radius = 14;
    });
    showColorSheet(context, title: 'Text background', initial: e.bgFill, allowNone: true, onChanged: (c) => _live(() => e.bgFill = c));
  }

  void _editBg(int i) {
    _snapshot();
    showColorSheet(context, title: d.bg.length > 1 ? 'Background colour ${i + 1}' : 'Background colour', initial: d.bg[i], onChanged: (c) {
      _live(() {
        final n = List<Color>.of(d.bg);
        n[i] = c!;
        d.bg = n;
        d.bgImg = null; // a visible colour change replaces the photo
      });
    });
  }

  void _toggleGradient() => _apply(() {
        if (d.bg.length > 1) {
          d.bg = [d.bg.first];
        } else {
          final h = HSVColor.fromColor(d.bg.first);
          d.bg = [d.bg.first, h.withHue((h.hue + 40) % 360).toColor()];
        }
        d.bgImg = null;
      });

  // ---- photos ----

  Future<Size> _imageSize(String name) async {
    try {
      final bytes = await File(StorageService.instance.media(name)).readAsBytes();
      final buf = await ui.ImmutableBuffer.fromUint8List(bytes);
      final desc = await ui.ImageDescriptor.encoded(buf);
      final size = Size(desc.width.toDouble(), desc.height.toDouble());
      desc.dispose();
      buf.dispose();
      return size;
    } catch (_) {
      return const Size(600, 600);
    }
  }

  Future<void> _pickPhoto({required bool background, El? replace, bool cutout = false}) async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final name = await StorageService.instance.importImage(x.path);
    if (background) {
      _apply(() {
        d.bgImg = name;
        d.bgStyle = null;
      });
    } else if (replace != null) {
      _apply(() => replace.path = name);
    } else {
      // keep the photo's own proportions so cut-outs are not cropped
      final s = await _imageSize(name);
      final k = math.min(640 / s.width, 640 / s.height);
      final w = s.width * k, h = s.height * k;
      final el = El(K.image, path: name, x: (1280 - w) / 2, y: (720 - h) / 2, w: w, h: h, radius: 24); // _add re-centres it
      _add(el);
      if (cutout && mounted) await _removeBg(el);
    }
  }

  Future<void> _removeBg(El e) async {
    if (e.path == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Removing background…')]),
            ),
          ),
        ),
      ),
    );
    try {
      final name = await BgRemoveService.remove(e.path!);
      if (mounted) _apply(() { e.path = name; e.radius = 0; });
    } catch (err) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not remove background: $err')));
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // ---- drag / pinch / rotate ----
  El? _g;
  double _gSize = 0, _gW = 0, _gH = 0, _gRot = 0;

  void _gStart(int id) {
    _snapshot(); // one undo step per gesture
    final e = d.els.firstWhere((x) => x.id == id);
    _g = e;
    _gSize = e.size; _gW = e.w; _gH = e.h; _gRot = e.rot;
    setState(() {
      _sel = id;
      _dirty = true;
    });
  }

  void _gUpdate(int id, Offset dl, double s, double r) {
    final e = _g;
    if (e == null || e.id != id) return;
    setState(() {
      e.x += dl.dx;
      e.y += dl.dy;
      if (e.k == K.text || e.k == K.icon) {
        e.size = (_gSize * s).clamp(12.0, 1200.0);
        if (e.k == K.text) e.w = (_gW * s).clamp(40.0, 4000.0);
      } else {
        e.w = (_gW * s).clamp(20.0, 4000.0);
        e.h = (_gH * s).clamp(20.0, 4000.0);
      }
      e.rot = _gRot + r * 180 / math.pi;
    });
  }

  // ---- corner / edge handles (stretch like in any design app) ----
  El? _hEl;
  int _hx = 0, _hy = 0;
  double _tx = 0, _ty = 0, _x0 = 0, _y0 = 0, _w0 = 0, _h0 = 0, _size0 = 0, _sy0 = 1;
  Size _s0 = Size.zero;

  void _hStart(int id, int hx, int hy) {
    _snapshot(); // one undo step per drag
    final e = d.els.firstWhere((x) => x.id == id);
    _hEl = e;
    _hx = hx; _hy = hy; _tx = 0; _ty = 0;
    _x0 = e.x; _y0 = e.y; _w0 = e.w; _h0 = e.h; _size0 = e.size; _sy0 = e.sy;
    _s0 = elSize(e);
    _dirty = true;
  }

  Offset _rotate(Offset o, double deg) {
    final r = deg * math.pi / 180;
    return Offset(o.dx * math.cos(r) - o.dy * math.sin(r), o.dx * math.sin(r) + o.dy * math.cos(r));
  }

  void _hUpdate(int id, Offset delta) {
    final e = _hEl;
    if (e == null || e.id != id) return;
    final l = _rotate(delta, -e.rot); // finger movement in the item's own (rotated) frame
    _tx += l.dx;
    _ty += l.dy;
    final dw = _hx * _tx, dh = _hy * _ty; // growth along the dragged side(s)
    final corner = _hx != 0 && _hy != 0;
    final f = (1 + ((_hx != 0 ? dw / _s0.width : 0) + (_hy != 0 ? dh / _s0.height : 0)) / (corner ? 2 : 1)).clamp(.05, 40.0);
    setState(() {
      switch (e.k) {
        case K.shape:
        case K.image:
          // every handle stretches freely: a corner changes width AND height independently
          if (_hx != 0) e.w = math.max(20.0, _w0 + dw);
          if (_hy != 0) e.h = math.max(20.0, _h0 + dh);
        case K.icon:
          final w1 = _hx != 0 ? math.max(12.0, _size0 + dw) : _size0;
          final h1 = _hy != 0 ? math.max(12.0, _size0 * _sy0 + dh) : _size0 * _sy0;
          e.size = w1;
          e.sy = h1 / w1;
        case K.text:
          if (corner) {
            e.size = (_size0 * f).clamp(6.0, 1200.0);
            e.w = (_w0 * f).clamp(40.0, 4000.0);
          } else if (_hx != 0) {
            e.w = math.max(40.0, _w0 + dw);
          }
      }
      // keep the opposite corner/side where it was, even when the item is rotated
      final s1 = elSize(e);
      final c0 = Offset(_x0 + _s0.width / 2, _y0 + _s0.height / 2);
      final anchor = c0 + _rotate(Offset(-_hx * _s0.width / 2, -_hy * _s0.height / 2), e.rot);
      final c1 = anchor - _rotate(Offset(-_hx * s1.width / 2, -_hy * s1.height / 2), e.rot);
      e.x = c1.dx - s1.width / 2;
      e.y = c1.dy - s1.height / 2;
    });
  }

  // ---- replace / layers / box behind ----

  void _replaceIcon(El e) => showIconPicker(context, current: e.icon, onPick: (k) => _apply(() => e.icon = k));

  void _replaceShape(El e) => showShapePicker(context, current: e.shape, onPick: (k) => _apply(() {
        e.shape = k;
        if (k == 'rect' && e.radius > math.min(e.w, e.h) / 2) e.radius = math.min(e.w, e.h) / 2;
      }));

  /// Adds a coloured rounded box just behind the selected text / icon and selects it.
  void _boxBehind(El e) {
    final s = elSize(e);
    final padX = math.max(18.0, e.size * .3), padY = math.max(10.0, e.size * .15);
    final c = Offset(e.x + s.width / 2, e.y + s.height / 2);
    final w = s.width + padX * 2, h = s.height + padY * 2;
    final box = El(K.shape, x: c.dx - w / 2, y: c.dy - h / 2, w: w, h: h, rot: e.rot, radius: 18, outline: false,
        color: e.color.computeLuminance() > .5 ? const Color(0xFFE52D27) : const Color(0xFFFFE600));
    _apply(() {
      d.els.insert(d.els.indexOf(e), box);
      _sel = box.id;
    });
  }

  /// 0 = send to back, 1 = one step back, 2 = one step forward, 3 = bring to front.
  void _layer(El e, int where) => _apply(() {
        final i = d.els.indexOf(e);
        d.els.removeAt(i);
        final j = switch (where) { 0 => 0, 1 => math.max(0, i - 1), 2 => math.min(d.els.length, i + 1), _ => d.els.length };
        d.els.insert(j, e);
      });

  // ---- layers list: pick, reorder or delete any part (text, box, image, background) ----

  String _layerName(El e) => switch (e.k) {
        K.text => e.text.trim().isEmpty ? 'Text' : e.text.trim().split('\n').first,
        K.icon => 'Icon',
        K.image => e.path == null ? 'Photo frame' : 'Image',
        K.shape => faceKinds[e.shape] != null
            ? 'Face: ${faceKinds[e.shape]}'
            : (e.bgFill != null ? 'Box' : (e.shape == 'rect' ? 'Box / rectangle' : 'Shape: ${shapeKinds[e.shape] ?? e.shape}')),
      };

  IconData _layerIcon(El e) => switch (e.k) {
        K.text => Icons.title,
        K.icon => Icons.star_outline,
        K.image => Icons.image_outlined,
        K.shape => Icons.crop_square,
      };

  void _showLayers() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSheet) {
            final items = d.els.reversed.toList(); // top layer first
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: .55,
              maxChildSize: .92,
              builder: (_, scroll) => ListView(controller: scroll, padding: const EdgeInsets.only(bottom: 16), children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text('Layers  (top first, tap one to select it)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                for (final e in items)
                  ListTile(
                    dense: true,
                    selected: e.id == _sel,
                    leading: Icon(_layerIcon(e)),
                    title: Text(_layerName(e), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      setState(() => _sel = e.id);
                      Navigator.pop(ctx);
                    },
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        tooltip: 'Move up',
                        icon: const Icon(Icons.arrow_upward, size: 20),
                        onPressed: () {
                          _layer(e, 2);
                          setSheet(() {});
                        },
                      ),
                      IconButton(
                        tooltip: 'Move down',
                        icon: const Icon(Icons.arrow_downward, size: 20),
                        onPressed: () {
                          _layer(e, 1);
                          setSheet(() {});
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          _apply(() {
                            d.els.remove(e);
                            if (_sel == e.id) _sel = null;
                          });
                          setSheet(() {});
                        },
                      ),
                    ]),
                  ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.wallpaper),
                  title: const Text('Background'),
                  subtitle: Text(d.bgImg != null ? 'Picture (change or remove it in the Background tab)' : 'Colour / gradient'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _tabs.animateTo(4);
                  },
                ),
              ]),
            );
          },
        ),
      );

  // ---- save / export ----

  Future<Uint8List> _capture({double? width}) async {
    setState(() => _sel = null); // hide selection frame
    await WidgetsBinding.instance.endOfFrame;
    return ExportService.capture(_canvasKey, width: width ?? d.w);
  }

  Future<void> _save({bool toast = true}) async {
    final preview = await _capture(width: 480);
    await StorageService.instance.save(design, preview);
    _dirty = false;
    if (toast && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to My designs')));
  }

  Future<void> _export() async => ExportService.share(await _capture(), design.name);

  Future<void> _rename() async {
    final n = await promptText(context, title: 'Name', initial: design.name);
    if (n != null && n.isNotEmpty) {
      setState(() {
        design.name = n;
        _dirty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _cur;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_dirty && d.els.isNotEmpty) await _save(toast: false); // auto-save on exit
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // the typing sheet handles the keyboard itself
        appBar: AppBar(
          title: GestureDetector(onTap: _rename, child: Text(design.name, overflow: TextOverflow.ellipsis)),
          actions: [
            IconButton(tooltip: 'Layers', onPressed: _showLayers, icon: const Icon(Icons.layers_outlined)),
            IconButton(tooltip: 'Undo', onPressed: _history.isEmpty ? null : _undo, icon: const Icon(Icons.undo)),
            IconButton(tooltip: 'Save', onPressed: _save, icon: const Icon(Icons.save_outlined)),
            Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton.icon(onPressed: _export, icon: const Icon(Icons.download), label: const Text('Export'))),
          ],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(builder: (_, bc) {
              // keep tall frames (stories, portrait posts) from pushing the tools off screen
              final w = math.min(bc.maxWidth, MediaQuery.sizeOf(context).height * .42 * d.w / d.h);
              return Center(
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: SizedBox(
                    width: w, height: w * d.h / d.w,
                    child: ClipRect(
                      // FittedBox keeps hit-testing correct
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: d.w, height: d.h,
                          child: Stage(
                            doc: d, selected: _sel, viewScale: w / d.w,
                            onTap: (id) {
                              final t = d.els.firstWhere((x) => x.id == id);
                              if (id == _sel && t.k == K.text) {
                                _editText(t); // tap a selected text again -> keyboard
                              } else {
                                setState(() => _sel = id);
                              }
                            },
                            onGestureStart: _gStart,
                            onGestureUpdate: _gUpdate,
                            onHandleStart: _hStart,
                            onHandleUpdate: _hUpdate,
                            onClear: () => setState(() => _sel = null),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (e != null)
            QuickBar(
              el: e, change: _apply,
              onEditText: () => _editText(e),
              onFront: () => _layer(e, 3),
              onLayer: (w) => _layer(e, w),
              onSize: () {
                _snapshot();
                showSizeSheet(context, e, _live);
              },
              onFont: () => showFontPicker(context, current: e.font, onPick: (f) => _apply(() => e.font = f)),
              onReplaceIcon: () => _replaceIcon(e),
              onReplaceShape: () => _replaceShape(e),
              onBoxBehind: () => _boxBehind(e),
              onDuplicate: () => _apply(() { final n = e.copy(fresh: true); d.els.add(n); _sel = n.id; }),
              onDelete: () => _apply(() { d.els.remove(e); _sel = null; }),
              onDone: () => setState(() => _sel = null),
              onPickPhoto: () => _pickPhoto(background: false, replace: e),
              onRemoveBg: () => _removeBg(e),
              onColor: () => _pickColor(e),
              onOutlineColor: () => _pickOutline(e),
              onTextBg: () => _pickTextBg(e),
              onAdjust: () {
                _snapshot();
                showAdjustSheet(context, e, _live);
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(children: [
                const Expanded(child: Text('Tap an item to edit · drag to move · drag the blue dots to resize', style: TextStyle(fontSize: 12, color: Colors.grey))),
                TextButton.icon(onPressed: () => _tabs.animateTo(4), icon: const Icon(Icons.format_color_fill, size: 18), label: const Text('Background')),
              ]),
            ),
          TabBar(controller: _tabs, isScrollable: true, tabAlignment: TabAlignment.start, tabs: const [Tab(text: 'Text'), Tab(text: 'Icons'), Tab(text: 'Shapes'), Tab(text: 'Images'), Tab(text: 'Background')]),
          Expanded(
            child: TabBarView(controller: _tabs, children: [
              TextPanel(onAdd: _add, onAddAndEdit: _addAndEdit, onApplyFont: (f) => _apply(() { for (final x in d.els) { if (x.k == K.text) x.font = f; } })),
              IconPanel(onAdd: _add, onGroup: _addGroup),
              ShapePanel(onAdd: _add),
              ImagePanel(
                onAdd: _add,
                onImport: () => _pickPhoto(background: false),
                onImportCutout: () => _pickPhoto(background: false, cutout: true),
              ),
              BackgroundPanel(
                doc: d,
                onFill: (c, st) => _apply(() { d.bg = c; d.bgStyle = st; d.bgImg = null; }),
                onClearStyle: () => _apply(() => d.bgStyle = null),
                onEditColor: _editBg,
                onPhoto: () => _pickPhoto(background: true),
                onClearPhoto: () => _apply(() => d.bgImg = null),
                onToggleGradient: _toggleGradient,
                onSwap: () => _apply(() => d.bg = d.bg.reversed.toList()),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
