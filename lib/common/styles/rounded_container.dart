
import 'package:flutter/cupertino.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';

class RRoundedContainer extends StatelessWidget {
  const RRoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.showBorder = false,
    this.radius = RSizes.cardRadiusLg,
    this.backgroundColor = RColors.white,
    this.borderColor = RColors.borderPrimary,
  });

  final double? width;
  final double? height;
  final double radius;
  final Widget? child;
  final bool showBorder;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder ? Border.all(color: borderColor) : null,
      ), // BoxDecoration
      child: child,
    ); // Container
  }
}
