import 'package:flutter/material.dart';

import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';

class RLoginHeader extends StatelessWidget {
  const RLoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image(
            height: 200,
            image: AssetImage(
                dark ? RImages.lightAppLogo : RImages.darkAppLogo),
          ),
        ),
        Center(
          child: Text(
            RTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        SizedBox(height: RSizes.sm),
        Center(
          child: Text(
            RTexts.loginSubTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
