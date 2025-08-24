import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/helper_functions.dart';

class RSearchContainer extends StatelessWidget {
   const RSearchContainer({
    super.key, required this.text, this.icon = Iconsax.search_normal,  this.showBackground = true,  this.showBorder= true, this.onRap, this.padding = const EdgeInsets.symmetric(horizontal:RSizes.defaultSpace),
  });

  final String text;
  final IconData? icon;
  final bool showBackground , showBorder;
  final VoidCallback? onRap;
  final EdgeInsetsGeometry padding ;
  @override
  Widget build(BuildContext context) {

    final dark = RHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onRap,
      child: Padding(
        padding: padding,
        child: Container(
          width : RDeviceUtils.getScreenWidth(context),
          padding: EdgeInsets.all(RSizes.md),
          decoration: BoxDecoration(
            color: showBackground? dark ? RColors.dark:  RColors.light : Colors.transparent,
            borderRadius: BorderRadius.circular(RSizes.cardRadiusLg),
            border: showBorder?  Border.all(color: RColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(icon , color: RColors.darkerGrey,),
              SizedBox(width: RSizes.spaceBtwItems,),
              Text(text, style: Theme.of(context).textTheme.bodySmall,)
            ],
          ),
        ),
      ),
    );
  }
}

