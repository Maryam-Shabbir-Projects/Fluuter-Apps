import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/kalma_data.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/word_meaning_row.dart';

class KalmaDetailScreen extends StatelessWidget {
  final int index;
  const KalmaDetailScreen({super.key, required this.index});

  void _go(BuildContext context, int i) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KalmaDetailScreen(index: i)),
      );

  @override
  Widget build(BuildContext context) {
    final k = kalmas[index];
    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            showBack: true,
            subtitle: k.english,
            title: k.transliteration,
            urduTitle: k.urduName,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  padding: const EdgeInsets.all(20),
                  child: Text(k.fullArabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.arabic(27, AppColors.green)),
                ),
                const SizedBox(height: 18),
                Text('WORD BY WORD · لفظی ترجمہ',
                    style: AppTextStyles.body(13, AppColors.darkGold,
                        weight: FontWeight.w600, letterSpacing: .8)),
                const SizedBox(height: 10),
                _card(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(children: [
                    for (int i = 0; i < k.words.length; i++)
                      WordMeaningRow(word: k.words[i], showDivider: i != k.words.length - 1),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                      ),
                      onPressed: index > 0 ? () => _go(context, index - 1) : null,
                      child: const Text('‹ Previous'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                        backgroundColor: AppColors.green,
                      ),
                      onPressed: index < kalmas.length - 1 ? () => _go(context, index + 1) : null,
                      child: const Text('Next ›'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, required EdgeInsets padding}) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}
