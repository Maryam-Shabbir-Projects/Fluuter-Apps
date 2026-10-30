import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Green top bar used by the list and detail screens.
class ScreenHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final String urduTitle;
  final bool showBack;

  const ScreenHeader({
    super.key,
    required this.subtitle,
    required this.title,
    required this.urduTitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: AppColors.green,
        padding: EdgeInsets.fromLTRB(
            showBack ? 8 : 20, MediaQuery.of(context).padding.top + 12, 20, 18),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ivory, size: 20),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: AppTextStyles.body(13, AppColors.onGreenMuted)),
                  Text(title, style: AppTextStyles.title(28, AppColors.ivory)),
                ],
              ),
            ),
            Text(urduTitle,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.urdu(22, AppColors.lightGold)),
          ],
        ),
      );
}
