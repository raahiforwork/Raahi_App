
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';

class RRabBar extends StatelessWidget implements PreferredSizeWidget {
  // If you want to add the background color to tabs you have to wrap them in Material widget.
  // Ro do that we need [PreferredSize] Widget and that's why created custom class. [PreferredSizeWidget]
  const RRabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = RHelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? RColors.black : RColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: RColors.primary,
        labelColor: dark ? RColors.white : RColors.primary,
        unselectedLabelColor: RColors.darkGrey,
      ), // RabBar
    ); // Material
  }

  @override
  Size get preferredSize => Size.fromHeight(RDeviceUtils.getAppBarHeight());
}
