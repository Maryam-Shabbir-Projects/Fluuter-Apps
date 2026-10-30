import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/kalma.dart';

class KalmaCard extends StatelessWidget {
  final Kalma kalma;
  final VoidCallback onTap;
  const KalmaCard({super.key, required this.kalma, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.green,
                  child: Text('${kalma.number}',
                      style: AppTextStyles.body(18, AppColors.lightGold, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${kalma.english} · ${kalma.transliteration}',
                          style: AppTextStyles.body(16, AppColors.textDark, weight: FontWeight.w600)),
                      Text(kalma.urduName,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.urdu(14, AppColors.textMuted)),
                      SizedBox(
                        width: double.infinity,
                        child: Text(kalma.previewArabic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.arabic(18, AppColors.green, height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.chevron),
              ],
            ),
          ),
        ),
      );
}
