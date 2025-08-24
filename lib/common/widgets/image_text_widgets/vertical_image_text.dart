

import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class RVerticalImageRext extends StatelessWidget {
  const RVerticalImageRext({
    super.key, required this.image, required this.title, this.textColor= RColors.white, this.backgroundColor, this.onRap,
  });

  final String image, title;
  final Color textColor ;
  final Color? backgroundColor ;
  final void Function()? onRap;

  @override
  Widget build(BuildContext context) {

    final dark = RHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onRap,
      child: Padding(
        padding: const EdgeInsets.only(right: RSizes.spaceBtwItems),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: EdgeInsets.all(RSizes.sm),
              decoration: BoxDecoration(
                color: backgroundColor ?? (dark ? RColors.black : RColors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Image(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  color: dark? RColors.light :RColors.dark,
                ),
              ),
            ),
            SizedBox(
              height: RSizes.spaceBtwItems / 2,
            ),
            SizedBox(
                width: 55,
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .apply(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))
          ],
        ),
      ),
    );
  }
}
