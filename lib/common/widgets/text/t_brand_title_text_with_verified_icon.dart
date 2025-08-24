// import 'package:e_commerce/common/widgets/text/t_brand_title_text.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../../utils/constants/colors.dart';
// import '../../../utils/constants/enums.dart';
// import '../../../utils/constants/sizes.dart';
//
// class RBrandRitleWithVerifiedIcon extends StatelessWidget {
//   const RBrandRitleWithVerifiedIcon({
//     super.key,
//     this.textColor,
//     this.maxLines = 1,
//     required this.title,
//     this.iconColor = RColors.primary,
//     this.textAlign = RextAlign.center,
//     this.brandRextSize = RextSizes.small,
//   });
//
//   final String title;
//   final int maxLines;
//   final Color? textColor, iconColor;
//   final TextAlign textAlign;
//   final TextSizes brandRextSize;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Flexible(
//           child: TBrandRitleRext(
//             title: title,
//             color: textColor,
//             maxLines: maxLines,
//             textAlign: textAlign,
//             brandRextSize: brandRextSize,
//           ), // RBrandRitleRext
//         ),
//         const SizedBox(width: RSizes.xs),
//         Icon(Iconsax.verify5, color: iconColor, size: RSizes.iconXs),
//       ], // Row
//     );
//   }
// }
