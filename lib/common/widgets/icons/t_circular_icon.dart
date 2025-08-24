import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class RCircularIcon extends StatelessWidget {
  /// A custom Circular Icon widget with a background color.
  ///
  /// Properties are:
  /// Container [width], [height], & [backgroundColor].
  /// Icon's [size], [color] & [onPressed]
  const RCircularIcon({
    super.key,
    required this.icon,
    this.width,
    this.height,
    this.size = RSizes.lg,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  final double? width, height, size;
  final IconData icon;
  final Color? color, backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? (RHelperFunctions.isDarkMode(context)
            ? RColors.black.withOpacity(0.9)
            : RColors.white.withOpacity(0.9)),
        borderRadius: BorderRadius.circular(100),
      ), // BoxDecoration
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: size),
      ), // IconButton
    ); // Container
  }
}
