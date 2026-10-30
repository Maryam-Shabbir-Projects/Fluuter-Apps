import 'package:flutter/material.dart';
import '../../data/kalma_data.dart';
import '../../widgets/kalma_card.dart';
import '../../widgets/screen_header.dart';
import '../kalma_detail/kalma_detail_screen.dart';

class KalmaListScreen extends StatelessWidget {
  const KalmaListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const ScreenHeader(
              subtitle: 'Choose a kalma',
              title: ' Kalmas',
              urduTitle: ' کلمے',
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: kalmas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => KalmaCard(
                  kalma: kalmas[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KalmaDetailScreen(index: i)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
