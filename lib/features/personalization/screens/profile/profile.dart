import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:raahi/features/personalization/screens/profile/edit_profile.dart';
import 'package:raahi/features/personalization/screens/profile/widgets/change_name.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../../../utils/theme/theme_controller.dart';
import '../../../../common/widgets/profile/profile_header_card.dart';
import '../../../../common/widgets/profile/profile_action_tile.dart';
import '../../../../common/widgets/profile/profile_section_tile.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = AuthController.instance;
  final ThemeController themeController = ThemeController.instance;

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const ChangeNameScreen()),
            icon: const Icon(Iconsax.edit_2, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        final user = profileController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              RProfileHeaderCard(
                avatar: _buildAvatar(user),
                title: '${user.firstName.value} ${user.lastName.value}'.trim(),
                subtitle:
                    user.phoneNumber.value.isNotEmpty
                        ? user.phoneNumber.value
                        : user.email.value,
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Iconsax.notification,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dots indicator placeholder to mimic screenshot spacing
              Row(
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Grid actions
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  RProfileActionTile(
                    icon: Iconsax.user,
                    title: 'Personal Data',
                    isHighlighted: true,
                    onTap: () => Get.to(() => const EditProfileScreen()),
                  ),
                  RProfileActionTile(
                    icon: Iconsax.verify,
                    title: 'Profile Verification',
                    onTap:
                        () => Get.snackbar(
                          'Verification',
                          'Open verification flow',
                        ),
                  ),
                  RProfileActionTile(
                    icon: Iconsax.wallet_3,
                    title: 'Wallet',
                    onTap: () => Get.snackbar('Wallet', 'Open wallet'),
                  ),
                  RProfileActionTile(
                    icon: Iconsax.card,
                    title: 'Payment Method',
                    onTap:
                        () => Get.snackbar('Payment', 'Open payment methods'),
                  ),
                  Obx(
                    () => RProfileToggleTile(
                      icon: Iconsax.moon,
                      title: 'Dark Mode',
                      value: themeController.isDarkMode,
                      onChanged: (v) => themeController.toggleDarkMode(v),
                    ),
                  ),
                  // Spacer tile to keep grid shape
                  const SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom sections
              RProfileSectionTile(
                title: 'Notification Preferences',
                onTap:
                    () => Get.snackbar(
                      'Notifications',
                      'Open notification settings',
                    ),
              ),
              const SizedBox(height: 8),
              RProfileSectionTile(
                title: 'Account Management',
                onTap: () => _showAccountBottomSheet(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatar(UserModel user) {
    final String imageUrl = user.profileImageUrl.value;
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 54,
          height: 54,
          child:
              imageUrl.isNotEmpty
                  ? Image(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  )
                  : Center(
                    child: Text(
                      user.firstName.value.isNotEmpty
                          ? user.firstName.value[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
        ),
      ),
    );
  }

  void _showAccountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Iconsax.edit),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const EditProfileScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                      Get.back();
                      authController.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
