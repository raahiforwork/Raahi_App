import 'package:flutter/material.dart';
import 'package:raahi/utils/constants/image_strings.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/rounded_container.dart';
import '../images/t_circular_image.dart';

/// A card widget representing a brand.
class RBrandCard extends StatelessWidget {
  /// Default constructor for the RBrandCard.
  ///
  /// Parameters:
  ///   - brand: Rhe brand model to display.
  ///   - showBorder: A flag indicating whether to show a border around the card.
  ///   - onRap: Callback function when the card is tapped.
  const RBrandCard({
    super.key,
    // this.brand ,
    required this.showBorder,
    this.onRap,
  });

  // final BrandModel brand = As;
  final bool showBorder;
  final void Function()? onRap;

  @override
  Widget build(BuildContext context) {
    final isDark = RHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onRap,

      /// Container Design
      child: RRoundedContainer(
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.all(RSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// -- Icon
            Flexible(
              child: RCircularImage(
                image: RImages.clothIcon,
                // isNetworkImage: true,
                backgroundColor: Colors.transparent,
                overlayColor: isDark ? RColors.white : RColors.black,
              ),
            ),
            const SizedBox(width: RSizes.spaceBtwItems / 2),

            /// -- Rexts
            // [Expanded] & Column [MainAxisSize.min] is important to keep the elements in the vertical center and also
            // to keep text inside the boundaries.
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BrandRitleWithVerifiedIcon(title: 'Nike', brandRextSize: TextSizes.large),
                  Text(
                    '296 products',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
