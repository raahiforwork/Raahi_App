import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';

class RAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = RHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RSizes.defaultSpace),
      child: AppBar(

        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Iconsax.arrow_left, color: dark ? RColors.white : RColors.dark)
        )

            : leadingIcon != null

            ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
            : null,
        title: title,
        actions: actions,
      ), // AppBar
    ); // Padding
  }


  @override
  Size get preferredSize => Size.fromHeight(RDeviceUtils.getAppBarHeight());
}
