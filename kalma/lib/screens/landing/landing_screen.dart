import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/star_emblem.dart';
import '../kalma_list/kalma_list_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.green,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 40),
            child: Column(
              children: [
                const Spacer(),
                const StarEmblem(),
                const SizedBox(height: 28),
                Text(' کلمے',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.urdu(48, AppColors.lightGold)),
                Text('The Six Kalmas', style: AppTextStyles.title(30, AppColors.ivory)),
                const SizedBox(height: 20),
                Text(
                  'Read, learn and understand the six kalmas with word-by-word Urdu meaning.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(15, AppColors.onGreenMuted, height: 1.6),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.darkGreen,
                      shape: const StadiumBorder(),
                      textStyle: AppTextStyles.body(17, AppColors.darkGreen, weight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KalmaListScreen()),
                    ),
                    child: const Text('Start Reading'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
