import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../controllers/home_controller.dart';

class ServiceSelectionWidget extends StatelessWidget {
  final HomeController homeController;

  const ServiceSelectionWidget({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your ride',
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
              child: Obx(() => FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: _buildServiceCard(
                  'Carpool',
                  'Share ride with others',
                  Iconsax.car,
                  homeController.selectedService.value == 'Carpool',
                      () => homeController.selectedService.value = 'Carpool',
                  isDark,
                ),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: _buildServiceCard(
                  'Bike Pool',
                  'Quick & eco-friendly',
                  Iconsax.activity,
                  homeController.selectedService.value == 'Bike Pool',
                      () => homeController.selectedService.value = 'Bike Pool',
                  isDark,
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      String title,
      String subtitle,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      bool isDark,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [RColors.primary, RColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: !isSelected
              ? (isDark ? RColors.darkContainer : RColors.lightContainer)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? RColors.primary
                : (isDark ? RColors.borderSecondary : RColors.borderPrimary),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: RColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? RColors.white.withOpacity(0.2)
                    : RColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? RColors.white : RColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? RColors.white
                    : (isDark ? RColors.textWhite : RColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? RColors.white.withOpacity(0.8)
                    : (isDark ? RColors.darkGrey : RColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
