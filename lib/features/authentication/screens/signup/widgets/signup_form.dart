import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:raahi/features/authentication/screens/signup/widgets/terms_and_conditions_checkbox.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/signup/signup_controller.dart';

class RSignupForm extends StatelessWidget {
  const RSignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final dark = RHelperFunctions.isDarkMode(context);

    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          /// First Name & Last Name Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: controller.validateFirstName,
                  decoration: InputDecoration(
                    labelText: RTexts.firstName,
                    labelStyle: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                    ),
                    prefixIcon: const Icon(Iconsax.user),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: dark ? Colors.white : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: dark ? Colors.white : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: controller.validateLastName,
                  decoration: InputDecoration(
                    labelText: RTexts.lastName,
                    labelStyle: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                    ),
                    prefixIcon: const Icon(Iconsax.user),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: dark ? Colors.white : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: dark ? Colors.white : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// Username
          TextFormField(
            controller: controller.username,
            validator: controller.validateUsername, // ✅ Fixed method name
            onChanged: (_) => controller.validateUsernameAvailability(),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: dark ? Colors.white : Colors.black),
              prefixIcon: const Icon(Iconsax.user_edit),
              prefixText: '@',
              suffixIcon: Obx(
                () =>
                    controller.isValidatingUsername.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : const SizedBox.shrink(),
              ), // ✅ Fixed: No null
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// Student ID
          TextFormField(
            controller: controller.studentId,
            validator: controller.validateStudentId,
            decoration: InputDecoration(
              labelText: 'Student ID',
              labelStyle: TextStyle(color: dark ? Colors.white : Colors.black),
              prefixIcon: const Icon(Iconsax.card),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// University Email - FIXED
          TextFormField(
            controller: controller.email,
            validator: controller.validateEmail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => controller.validateUniversityEmail(),
            decoration: InputDecoration(
              labelText: 'University Email',
              labelStyle: TextStyle(color: dark ? Colors.white : Colors.black),
              prefixIcon: const Icon(Iconsax.direct),
              suffixIcon: Obx(
                () =>
                    controller.isValidatingEmail.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : controller.selectedUniversity.value.isNotEmpty
                        ? const Icon(Iconsax.verify, color: Colors.green)
                        : const SizedBox.shrink(),
              ), // ✅ Fixed: Always return Widget
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          /// University Display
          Obx(
            () =>
                controller.selectedUniversity.value.isNotEmpty
                    ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: RColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.building,
                            size: 16,
                            color: RColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'University: ${controller.selectedUniversity.value}',
                            style: const TextStyle(
                              color: RColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ), // ✅ Fixed: Always return Widget

          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// Phone Number
          TextFormField(
            controller: controller.phoneNumber,
            validator: controller.validatePhoneNumber,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: RTexts.phonoNo,
              labelStyle: TextStyle(color: dark ? Colors.white : Colors.black),
              prefixIcon: const Icon(Iconsax.call),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// Department (Optional)
          TextFormField(
            controller: controller.department,
            decoration: InputDecoration(
              labelText: 'Department (Optional)',
              labelStyle: TextStyle(color: dark ? Colors.white : Colors.black),
              prefixIcon: const Icon(Iconsax.buildings),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: RSizes.spaceBtwInputFields),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: controller.validatePassword,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: RTexts.password,
                labelStyle: TextStyle(
                  color: dark ? Colors.white : Colors.black,
                ),
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed:
                      () =>
                          controller.hidePassword.value =
                              !controller.hidePassword.value,
                  icon: Icon(
                    controller.hidePassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: RSizes.spaceBtwSections),

          /// Terms & Conditions Checkbox
          const RTermsAndConditionCheckbox(),

          const SizedBox(height: RSizes.spaceBtwSections),

          /// Sign Up Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () {
                          print('Create Account button pressed');
                          controller.signup();
                        },
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(RTexts.createAccount),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
