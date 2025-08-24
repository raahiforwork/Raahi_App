import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raahi/features/authentication/screens/onboarding/widgets/onboarding_navigation.dart';
import 'package:raahi/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:raahi/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:raahi/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/texts.dart';
import '../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        //   Horizontal Scrollable Pages
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,

            children: const [
              OnBoardingPage(
                image: RImages.onBoardingImage1,
                title: RTexts.onBoardingTitle1,
                subTitle: RTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: RImages.onBoardingImage2,
                title: RTexts.onBoardingTitle2,
                subTitle: RTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: RImages.onBoardingImage3,
                title: RTexts.onBoardingTitle3,
                subTitle: RTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          //   Skip Button
          const OnBoardingSkip(),

          //   dot Navigation SmoothPageIndicator

          const OnBoardingDotNavigation(),

        //   Circular Button
          OnBoardingNextButton()
        ],

      ),
    );
  }
}





