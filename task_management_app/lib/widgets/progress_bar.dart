import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0
  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.grey.shade300,
          color: progress >= 1.0 ? Colors.green : Colors.indigo,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% completed',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
