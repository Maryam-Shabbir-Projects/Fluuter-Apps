import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/word.dart';

class WordMeaningRow extends StatelessWidget {
  final Word word;
  final bool showDivider;
  const WordMeaningRow({super.key, required this.word, this.showDivider = true});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.border))
              : null,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(word.arabic,
                    style: AppTextStyles.arabic(22, AppColors.green, height: 1.6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Text(word.urdu, style: AppTextStyles.urdu(16, AppColors.textDark)),
              ),
            ],
          ),
        ),
      );
}
