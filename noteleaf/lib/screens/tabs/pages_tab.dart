import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../models/doc.dart';
import '../../models/rich_text.dart';
import '../../widgets/common.dart';
import '../../widgets/page_preview.dart';
import '../../widgets/style_bar.dart';

class PagesTab extends StatelessWidget {
  final Doc d;
  const PagesTab(this.d, {super.key});

  @override
  Widget build(BuildContext c) {
    final n = d.pages.length, cs = Theme.of(c).colorScheme;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Row(children: [
          Text('$n pages', style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text('  ·  ${d.words} words', style: TextStyle(color: cs.onSurfaceVariant)),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: InfoBanner([
          (Icons.touch_app_outlined, 'Tap a page to open it.'),
          (Icons.edit_note, 'Edit right on the page. Extra lines move to the next page.'),
        ]),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: d.px.height > d.px.width ? 3 : 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: d.px.width / d.px.height),
          itemCount: n,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PageViewer(d, i))),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Stack(children: [
                Positioned.fill(child: PagePreview(d, i)),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Swipe through pages full width; "Edit page" opens that page itself for editing.
class PageViewer extends StatefulWidget {
  final Doc d;
  final int start;
  const PageViewer(this.d, this.start, {super.key});
  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> {
  late final PageController _pc = PageController(initialPage: widget.start);
  late int _cur = widget.start;

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: widget.d,
        builder: (_, __) {
          final d = widget.d, n = d.pages.length;
          _cur = _cur.clamp(0, n - 1);
          return Scaffold(
            appBar: AppBar(title: Text('Page ${_cur + 1} of $n')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => PageEditor(d, d.pages[_cur], _cur))),
              icon: const Icon(Icons.edit),
              label: const Text('Edit this page'),
            ),
            body: PageView.builder(
              controller: _pc,
              itemCount: n,
              onPageChanged: (i) => setState(() => _cur = i),
              itemBuilder: (_, i) => Center(child: Padding(padding: const EdgeInsets.all(14), child: PagePreview(d, i))),
            ),
          );
        },
      );
}

/// Edits one page directly on the page: the paper, font, size, spacing, logo and faded text are all shown
/// exactly as exported, and you type into the page itself. Saving re-flows the pages after this one.
class PageEditor extends StatefulWidget {
  final Doc d;
  final PageSlice page;
  final int number;
  const PageEditor(this.d, this.page, this.number, {super.key});
  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  final rc = RichController();

  @override
  void initState() {
    super.initState();
    rc.load(widget.page.runs);
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return ListenableBuilder(
      listenable: widget.d,
      builder: (_, __) {
        final d = widget.d, W = d.px.width, H = d.px.height;
        rc.ptPx = d.ptPx;
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit page ${widget.number + 1}'),
            actions: [
              FilledButton(
                onPressed: () {
                  d.replacePage(widget.page, rc);
                  Navigator.pop(c);
                },
                child: const Text('Done'),
              ),
              const SizedBox(width: 14),
            ],
          ),
          body: Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 14, offset: const Offset(0, 4))]),
              child: StyleBar(ctrl: rc, basePt: d.pt, baseFont: d.font, onChanged: () {}),
            ),
            Expanded(
              child: LayoutBuilder(builder: (_, k) {
                final s = (k.maxWidth - 28) / W;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    width: W * s,
                    height: H * s,
                    decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 18, offset: const Offset(0, 8))]),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: W,
                        height: H,
                        child: Stack(children: [
                          Positioned.fill(child: CustomPaint(painter: LayerPainter(d, false))),
                          Positioned(
                            left: d.mg,
                            top: d.mg,
                            right: d.mg,
                            bottom: d.mg,
                            child: TextField(
                              controller: rc,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              textDirection: d.td,
                              textAlign: [TextAlign.start, TextAlign.center, TextAlign.justify][d.al],
                              style: d.baseStyle,
                              cursorColor: d.fg,
                              cursorWidth: 4,
                              decoration: const InputDecoration.collapsed(hintText: ''),
                            ),
                          ),
                          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: LayerPainter(d, true)))),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                const Icon(Icons.format_line_spacing, size: 20),
                const SizedBox(width: 8),
                const Text('Line spacing'),
                Expanded(child: Slider(value: d.lh.clamp(1.0, 3.0), min: 1.0, max: 3.0, onChanged: (v) { d.lh = (v * 20).round() / 20; d.touch(); })),
                Text(d.lh.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        );
      },
    );
  }
}
