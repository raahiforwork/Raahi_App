import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../../utils/constants/texts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/update_name_controller.dart';

class ChangeNameScreen extends StatelessWidget {
  const ChangeNameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, controller, isDark),
          SliverToBoxAdapter(
            child: _buildBody(context, controller, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UpdateNameController controller, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: controller.hasChanges && !controller.isLoading.value
                  ? LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              )
                  : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: controller.hasChanges && !controller.isLoading.value
                    ? () {
                  print('💾 Save button pressed');
                  controller.updateUserName();
                }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          )),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ]
                  : [
                Colors.blue.shade50,
                Colors.indigo.shade50,
                Colors.purple.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'Update your personal information',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UpdateNameController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatsCard(controller, isDark),
          const SizedBox(height: 24),
          _buildFormCard(context, controller, isDark),
          const SizedBox(height: 24),
          _buildActionButtons(controller, isDark),
          const SizedBox(height: 24),
          _buildInfoCard(context, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsCard(UpdateNameController controller, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              Colors.grey.shade800,
              Colors.grey.shade900,
            ]
                : [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() => Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.user_edit,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AuthController.instance.currentUser.value.firstName.value} ${AuthController.instance.currentUser.value.lastName.value}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.hasChanges
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.hasChanges ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.hasChanges ? 'Modified' : 'Current',
                    style: TextStyle(
                      color: controller.hasChanges ? Colors.orange : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (controller.hasChanges) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have unsaved changes. Tap Save to apply them.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, UpdateNameController controller, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: controller.updateUserNameFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              /// First Name
              _buildAnimatedTextField(
                controller: controller.firstName,
                validator: controller.validateFirstName,
                label: RTexts.firstName,
                icon: Iconsax.user,
                isDark: isDark,
                delay: 200,
              ),
              const SizedBox(height: 20),

              /// Last Name
              _buildAnimatedTextField(
                controller: controller.lastName,
                validator: controller.validateLastName,
                label: RTexts.lastName,
                icon: Iconsax.user,
                isDark: isDark,
                delay: 400,
              ),
              const SizedBox(height: 20),

              /// Username
              _buildUsernameField(controller, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String label,
    required IconData icon,
    required bool isDark,
    required int delay,
  }) {
    return FadeInRight(
      duration: Duration(milliseconds: 600 + delay),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: isDark
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.grey.shade600
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade400,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(UpdateNameController controller, bool isDark) {
    return FadeInRight(
      duration: const Duration(milliseconds: 1200),
      child: TextFormField(
        controller: controller.username,
        validator: controller.validateUsernameFormat,
        onChanged: (_) => controller.validateUsernameAvailability(),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Username',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.teal.shade400],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.user_edit, color: Colors.white, size: 20),
          ),
          prefixText: '@',
          prefixStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: Obx(() => controller.isValidatingUsername.value
              ? Container(
            margin: const EdgeInsets.all(12),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: isDark
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.grey.shade600
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade400,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
          helperText: 'Your unique username for Raahi',
          helperStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UpdateNameController controller, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          /// Save Button
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: controller.hasChanges && !controller.isLoading.value
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade600,
                  Colors.indigo.shade600,
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: controller.hasChanges && !controller.isLoading.value
                  ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: controller.hasChanges && !controller.isLoading.value
                    ? () {
                  print('💾 Save Changes button pressed');
                  controller.updateUserName();
                }
                    : null,
                child: Container(
                  child: Center(
                    child: controller.isLoading.value
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Saving...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.tick_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
          const SizedBox(height: 16),

          /// Reset Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: controller.resetForm,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.refresh,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reset to Original',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              Colors.indigo.shade900.withOpacity(0.3),
              Colors.purple.shade900.withOpacity(0.3),
            ]
                : [
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.indigo.withOpacity(0.3)
                : Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.info_circle,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              '• Your first and last name will be visible to other Raahi users',
              isDark,
            ),
            _buildInfoItem(
              '• Your username must be unique and can be used to find you',
              isDark,
            ),
            _buildInfoItem(
              '• You can change your name and username anytime',
              isDark,
            ),
            _buildInfoItem(
              '• Use your real name for verification purposes',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
