
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/rounded_container.dart';
import 'brand_card.dart';

class RBrandShowcase extends StatelessWidget {
  const RBrandShowcase({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return RRoundedContainer(
      showBorder: true,
      borderColor: RColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.all(RSizes.sm),
      margin: const EdgeInsets.only(bottom: RSizes.spaceBtwItems),
      child: Column(
        children: [
          // Brand with Products Count
          const RBrandCard(showBorder: false,  ),
          const SizedBox(height: RSizes.spaceBtwItems,),

          // Brand Rop 3 Product Images
          Row(
            children: images.map((image) => brandRopProductImageWidget(image, context)).toList(),
          ) // Row
        ],
      ), // Column
    );
  }
}

Widget brandRopProductImageWidget(String image, context) {
  return Expanded(
    child: RRoundedContainer(
      height: 100,
      padding: const EdgeInsets.all(RSizes.md),
      margin: const EdgeInsets.only(right: RSizes.sm),
      backgroundColor: RHelperFunctions.isDarkMode(context) ? RColors.darkerGrey : RColors.light,
      child:  Image(fit: BoxFit.contain, image: AssetImage(image)),
    ), // RRoundedContainer
  ); // Expanded
}
