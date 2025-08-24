import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../utils/constants/colors.dart';

class QuickActionsWidget extends StatelessWidget {
  final bool isDark;

  const QuickActionsWidget({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? RColors.textWhite : RColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildQuickAction(
                  'Find Ride',
                  'Search for available rides',
                  Iconsax.search_favorite,
                  RColors.info,
                      () => _findRide(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildQuickAction(
                  'Post Ride',
                  'Offer your ride to others',
                  Iconsax.add_circle,
                  RColors.success,
                      () => _postRide(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: _buildQuickAction(
                  'Schedule',
                  'Plan future rides',
                  Iconsax.calendar,
                  RColors.warning,
                      () => _scheduleRide(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: _buildQuickAction(
                  'Safety',
                  'Emergency & safety center',
                  Iconsax.shield_tick,
                  RColors.error,
                      () => _openSafetyCenter(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: RColors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? RColors.textWhite : RColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? RColors.darkGrey : RColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _findRide() {
    Get.snackbar(
      'Find Ride',
      'Searching for available rides near you...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.info,
      colorText: RColors.white,
    );
    // Navigate to find ride screens
  }

  void _postRide() {
    Get.snackbar(
      'Post Ride',
      'Create a new ride offer...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.success,
      colorText: RColors.white,
    );
    // Navigate to post ride screens
  }

  void _scheduleRide() {
    Get.snackbar(
      'Schedule Ride',
      'Plan your future rides...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.warning,
      colorText: RColors.white,
    );
    // Navigate to schedule screens
  }

  void _openSafetyCenter() {
    Get.snackbar(
      'Safety Center',
      'Access emergency features and safety tools...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.error,
      colorText: RColors.white,
    );
    // Navigate to safety center
  }
}
