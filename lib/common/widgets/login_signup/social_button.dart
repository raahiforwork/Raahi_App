
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../features/authentication/controllers/login/login_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';

class RSocialButtons extends StatelessWidget {
  const RSocialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(LoginController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [




        Container(
          decoration: BoxDecoration(
            border: Border.all(color: RColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () => controller.googleSignIn(),
            icon: const Image(
              width: RSizes.iconMd,
              height: RSizes.iconMd,
              image: AssetImage(RImages.google),
            ),
          ),
        ), // Container

        const SizedBox(width: RSizes.spaceBtwItems),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: RColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              width: RSizes.iconMd,
              height: RSizes.iconMd,
              image: AssetImage(RImages.facebook),
            ),
          ),
        ), // Container
      ],
    );
  }
}



