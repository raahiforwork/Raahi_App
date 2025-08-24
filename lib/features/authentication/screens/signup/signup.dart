import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raahi/features/authentication/screens/signup/widgets/signup_form.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_button.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(RSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              RTexts.signupTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: RSizes.spaceBtwSections,
            ),

            //   Form
            RSignupForm(),

            SizedBox(height: RSizes.spaceBtwSections),


            /// Divider
            RFormDivider(dividerText: RTexts.orSignUpWith.capitalize!),
            SizedBox(height: RSizes.spaceBtwSections),

            /// Social Buttons
            const RSocialButtons(),
          ],
        ),
      ),
    );
  }
}
