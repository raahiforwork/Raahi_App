import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';
import '../../controllers/update_name_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Iconsax.arrow_left),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.hasChanges && !controller.isLoading.value
                ? controller.updateUserName
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: controller.hasChanges && !controller.isLoading.value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(RSizes.defaultSpace),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Headings
              Text(
                'Update your profile details below.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: RSizes.spaceBtwSections),

              /// Form
              Form(
                key: controller.updateUserNameFormKey,
                child: Column(
                  children: [
                    /// First Name
                    TextFormField(
                      controller: controller.firstName,
                      validator: controller.validateFirstName,
                      decoration: const InputDecoration(
                        labelText: RTexts.firstName,
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                    const SizedBox(height: RSizes.spaceBtwInputFields),

                    /// Last Name
                    TextFormField(
                      controller: controller.lastName,
                      validator: controller.validateLastName,
                      decoration: const InputDecoration(
                        labelText: RTexts.lastName,
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                    const SizedBox(height: RSizes.spaceBtwInputFields),

                    /// Username
                    TextFormField(
                      controller: controller.username,
                      validator: controller.validateUsernameFormat,
                      onChanged: (_) => controller.validateUsernameAvailability(),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Iconsax.user_edit),
                        prefixText: '@',
                        suffixIcon: Obx(() => controller.isValidatingUsername.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : const SizedBox.shrink()),
                        helperText: 'Your unique username for Raahi',
                        helperStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: RSizes.spaceBtwSections),

              /// Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.hasChanges && !controller.isLoading.value
                      ? controller.updateUserName
                      : null,
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Save Changes'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
