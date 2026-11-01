import 'package:flutter/material.dart';
import '../models/doc.dart';
import '../widgets/save_button.dart';
import '../widgets/sheets.dart';
import '../widgets/dock.dart';
import '../widgets/fancy_title.dart';
import 'tabs/design_tab.dart';
import 'tabs/export_tab.dart';
import 'tabs/pages_tab.dart';
import 'tabs/write_tab.dart';

class ProjectPage extends StatefulWidget {
  final Doc doc;
  const ProjectPage(this.doc, {super.key});
  @override
  State<ProjectPage> createState() => _ProjectState();
}

class _ProjectState extends State<ProjectPage> {
  int tab = 0;

  @override
  void dispose() {
    widget.doc.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final d = widget.doc;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final t = await showNameSheet(c, icon: Icons.drive_file_rename_outline, title: 'Rename file', subtitle: 'Choose a new name for this file.', hint: 'File name', initial: d.title, action: 'Save name', allowEmpty: false);
            if (t != null && t.trim().isNotEmpty) d.rename(t.trim());
          },
          child: ListenableBuilder(
            listenable: d,
            builder: (_, __) => Row(children: [
              Flexible(child: FancyTitle(d.title, size: 20)),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 15),
            ]),
          ),
        ),
        actions: [
          SaveButton(onSave: d.save),
          const SizedBox(width: 14),
        ],
      ),
      body: ListenableBuilder(listenable: d, builder: (_, __) => [WriteTab(d), DesignTab(d), PagesTab(d), ExportTab(d)][tab]),
      bottomNavigationBar: Dock(
        index: tab,
        onTap: (i) {
          FocusManager.instance.primaryFocus?.unfocus();
          d.save();
          setState(() => tab = i);
        },
      ),
    );
  }
}
