import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../services/export_service.dart';

class ExportSelectScreen extends StatefulWidget {
  const ExportSelectScreen({Key? key}) : super(key: key);

  @override
  State<ExportSelectScreen> createState() => _ExportSelectScreenState();
}

class _ExportSelectScreenState extends State<ExportSelectScreen> {
  List<Task> allTasks = [];
  Set<int> selectedTaskIds = {};
  bool selectAll = false;
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
  }

  Future<void> _loadAllTasks() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.loadAllTasks(context);
    setState(() {
      allTasks = provider.tasks;
      selectedTaskIds = allTasks
          .where((t) => t.id != null)
          .map((t) => t.id!)
          .toSet();
      selectAll = selectedTaskIds.length == allTasks.length && allTasks.isNotEmpty;
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedTaskIds = allTasks.where((t) => t.id != null).map((t) => t.id!).toSet();
      } else {
        selectedTaskIds.clear();
      }
    });
  }

  void _toggleTaskSelection(int? taskId, bool? value) {
    if (taskId == null) return;
    setState(() {
      if (value == true) {
        selectedTaskIds.add(taskId);
      } else {
        selectedTaskIds.remove(taskId);
      }
      selectAll = selectedTaskIds.length == allTasks.length && allTasks.isNotEmpty;
    });
  }

  Future<void> _exportSelectedTasks() async {
    if (selectedTaskIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one task to export.')),
      );
      return;
    }

    setState(() {
      isExporting = true;
    });

    final selectedTasks = allTasks.where((task) => task.id != null && selectedTaskIds.contains(task.id)).toList();

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Export tasks to PDF file
      await ExportService.exportTasksToPdf(selectedTasks, tempFilePath);

      final params = SaveFileDialogParams(sourceFilePath: tempFilePath);
      final savedFilePath = await FlutterFileDialog.saveFile(params: params);

      if (savedFilePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tasks exported successfully to:\n$savedFilePath')),
        );
        // Close the screen after a short delay to allow snackbar to show
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during export: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Tasks to Export'),
      ),
      body: allTasks.isEmpty
          ? const Center(child: Text('No tasks available'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: isExporting ? null : _exportSelectedTasks,
              icon: isExporting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(isExporting ? 'Exporting...' : 'Export Selected Tasks'),
            ),
          ),
          CheckboxListTile(
            title: const Text('Select All'),
            value: selectAll,
            onChanged: isExporting ? null : _toggleSelectAll,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                final task = allTasks[index];
                return CheckboxListTile(
                  title: Text(task.title),
                  subtitle: task.description.isNotEmpty ? Text(task.description) : null,
                  value: task.id != null && selectedTaskIds.contains(task.id),
                  onChanged: isExporting ? null : (value) => _toggleTaskSelection(task.id, value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
