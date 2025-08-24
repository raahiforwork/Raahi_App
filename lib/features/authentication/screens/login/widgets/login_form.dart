import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/login/login_controller.dart';
import '../../password_configuration/forget_password.dart';
import '../../signup/signup.dart';

class RLoginForm extends StatelessWidget {
  const RLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final dark = RHelperFunctions.isDarkMode(context);

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RSizes.spaceBtwSections),
        child: Column(
          children: [
            // Email TextField with Border Radius
            TextFormField(
              controller: controller.email,
              validator: (value) => RValidator.validateEmail(value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.direct_right),
                labelText: RTexts.email,
                labelStyle: TextStyle(
                  color: dark ? Colors.white : Colors.black, // Label color changes based on the theme
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black, // Focused border color
                  ),
                  borderRadius: BorderRadius.circular(15), // Border Radius
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black, // Enabled border color
                  ),
                  borderRadius: BorderRadius.circular(15), // Border Radius
                ),
              ),
            ),
            const SizedBox(height: RSizes.spaceBtwInputFields),

            // Password TextField with Border Radius
            Obx(() => TextFormField(
              validator: (value) => RValidator.validatePassword(value),
              controller: controller.password,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: RTexts.password ,
                labelStyle: TextStyle(
                  color: dark ? Colors.white : Colors.black, // Label color changes based on the theme
                ),
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                  icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(15), // Border Radius
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(15), // Border Radius
                ),
              ),
            )),
            const SizedBox(height: RSizes.spaceBtwInputFields / 2),

            // Remember Me & Forget Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  children: [
                    Obx(() => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (value) => controller.rememberMe.value = !controller.rememberMe.value)),
                    const Text(RTexts.rememberMe),
                  ],
                ),
                // Forget Password
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ForgetPassword());
                  },
                  child: Text(
                    RTexts.forgetPassword,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RSizes.spaceBtwSections),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.emailAndPasswordSignIn(),
                child: const Text(RTexts.signIn),
              ),
            ),

            const SizedBox(height: RSizes.defaultSpace),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(() => SignUpScreen());
                },
                child: const Text(RTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
