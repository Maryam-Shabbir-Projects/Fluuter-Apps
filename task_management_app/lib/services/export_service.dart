import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../models/task.dart';

class ExportService {
  static Future<void> exportTasksToPdf(List<Task> tasks, String filePath) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Tasks Export', style: pw.TextStyle(fontSize: 24)),
          ),
          ...tasks.map((task) {
            final timeStr = _formatTime(task.time);
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Title: ${task.title}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                if (task.description.isNotEmpty)
                  pw.Text('Description: ${task.description}'),
                pw.Text('Date: ${task.date.toLocal().toString().split(' ')[0]}'),
                pw.Text('Time: $timeStr'),
                pw.Text('Completed: ${task.isCompleted ? "Yes" : "No"}'),
                pw.SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
