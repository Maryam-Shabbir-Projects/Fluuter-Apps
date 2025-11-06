import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/task.dart';

class ExportService {
  // Export tasks to CSV and share them
  static Future<void> exportToCSV(List<Task> tasks, {String fileName = 'tasks_export.csv'}) async {
    final List<List<dynamic>> rows = [
      ['Title', 'Description', 'Due Date', 'Completed', 'Progress', 'Repeat']
    ];

    for (final task in tasks) {
      rows.add([
        task.title,
        task.description,
        task.dueDate.toIso8601String(),
        task.isCompleted ? 'Yes' : 'No',
        '${(task.progress * 100).toStringAsFixed(0)}%',
        task.repeat ? 'Yes' : 'No',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvData, flush: true);

    // Use share_plus to share the created file
    await Share.shareXFiles([XFile(file.path)], text: 'Here is my task list (CSV)');
  }

  // Export tasks to PDF and share them
  static Future<void> exportToPDF(List<Task> tasks, {String fileName = 'tasks_export.pdf'}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Task Management Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: [
              'Title',
              'Description',
              'Due Date',
              'Completed',
              'Progress',
              'Repeat'
            ],
            data: tasks.map((task) {
              return [
                task.title,
                task.description,
                task.dueDate.toIso8601String(),
                task.isCompleted ? 'Yes' : 'No',
                '${(task.progress * 100).toStringAsFixed(0)}%',
                task.repeat ? 'Yes' : 'No',
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    final bytes = await pdf.save(); // Uint8List

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    // Share the PDF via share_plus
    await Share.shareXFiles([XFile(file.path)], text: 'Here is my task list (PDF)');
  }
}
