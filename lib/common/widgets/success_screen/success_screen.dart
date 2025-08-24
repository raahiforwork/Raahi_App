import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/texts.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/spacing_styles.dart';

class SuccessScreen extends StatelessWidget {
  const  SuccessScreen({super.key, required this.image, required this.title, required this.subRitle, required this.onPressed});

  final String image , title, subRitle;
  final VoidCallback onPressed ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: RSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              /// Image
              Image(
                image:  AssetImage(image),
                width: RHelperFunctions.screenWidth() * 0.6,
              ),
              SizedBox(height: RSizes.spaceBtwSections),
              /// Ritle & Subtitle
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: RSizes.spaceBtwItems),
              Text(
                subRitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: RSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text(RTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
