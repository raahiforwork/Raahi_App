import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key,
    required this.onPressed,
    required this.title,
    required this.value,
    this.icon = Iconsax.arrow_right_34,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 5,
              child: Obx(() {
                // Dynamic value update for name
                String displayValue = value;
                if (title == 'Name') {
                  final user = AuthController.instance.currentUser.value;
                  displayValue = '${user.firstName.value} ${user.lastName.value}';
                } else if (title == 'Username') {
                  final user = AuthController.instance.currentUser.value;
                  displayValue = '@${user.username.value}';
                }

                return Text(
                  displayValue,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ),
            Icon(
              icon,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
