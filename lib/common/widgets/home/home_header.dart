import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/personalization/controllers/auth_controller.dart';

class RHomeHeader extends StatelessWidget {
  const RHomeHeader({super.key, this.onNotifications});

  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Obx(() {
        final user = AuthController.instance.currentUser.value;
        final name = (user.firstName.value + ' ' + user.lastName.value).trim();
        final ImageProvider avatarProvider =
            user.profileImageUrl.value.isNotEmpty
                ? NetworkImage(user.profileImageUrl.value)
                : const AssetImage('assets/images/content/user.png');

        return Row(
          children: [
            CircleAvatar(radius: 22, backgroundImage: avatarProvider),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${name.isNotEmpty ? name : 'User'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Where do you want to go?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.notification, color: Colors.white),
              onPressed: onNotifications,
            ),
          ],
        );
      }),
    );
  }
}
