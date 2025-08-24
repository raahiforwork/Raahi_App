
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/t_circular_image.dart';

class RUserProfileTile extends StatelessWidget {
  const RUserProfileTile({
    super.key,required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    final controller = UserController.instance;

    return ListTile(
      leading: RCircularImage(image: RImages.user, width: 50, height: 50, padding: 0,),
      title: Text(controller.user.value.fullName.toString(), style: Theme.of(context).textTheme.headlineSmall! .apply(color: RColors.white)),
      subtitle: Text(controller.user.value.email.toString(), style: Theme.of(context) .textTheme.bodyMedium! .apply(color: RColors.white)),
      trailing: IconButton(onPressed: onPressed, icon: const Icon(Iconsax.edit, color: RColors.white),),
    );
  }
}