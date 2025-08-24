import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/http/network_manager.dart';
import '../../../utils/popus/full_screen_loader.dart';
import '../../../utils/popus/loaders.dart';
import '../screens/profile/profile.dart';
import 'auth_controller.dart';

class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final userRepository = Get.find<UserRepository>();

  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  // Loading states
  final isLoading = false.obs;
  final isValidatingUsername = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeNames();
  }

  /// Initialize name fields from current user data
  void initializeNames() {
    final user = AuthController.instance.currentUser.value;
    firstName.text = user.firstName.value;
    lastName.text = user.lastName.value;
    username.text = user.username.value;
  }

  /// Check username availability (async method for real-time checking)
  Future<void> validateUsernameAvailability() async {
    final usernameText = username.text.trim();
    if (usernameText.isEmpty) return;

    // Don't validate if it's the same as current username
    final currentUsername = AuthController.instance.currentUser.value.username.value;
    if (usernameText.toLowerCase() == currentUsername.toLowerCase()) return;

    isValidatingUsername.value = true;

    try {
      final isAvailable = await userRepository.isUsernameAvailable(usernameText);
      if (!isAvailable) {
        RLoaders.errorSnackBar(
          title: 'Username Taken',
          message: 'This username is already taken. Please choose another one.',
        );
      }
    } catch (e) {
      RLoaders.errorSnackBar(title: 'Error', message: 'Failed to check username availability');
    } finally {
      isValidatingUsername.value = false;
    }
  }

  /// Update user's first name, last name, and username
  Future<void> updateUserName() async {
    try {
      isLoading.value = true;

      // Start Loading
      RFullScreenLoader.openLoadingDialog(
          'We are updating your information...',
          RImages.docerAnimation
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
            title: 'No Internet',
            message: 'Please check your internet connection.'
        );
        return;
      }

      // Form Validation
      if (!updateUserNameFormKey.currentState!.validate()) {
        RFullScreenLoader.stopLoading();
        return;
      }

      // Get current user ID
      final userId = AuthController.instance.getCurrentUserId;
      if (userId.isEmpty) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(title: 'Error', message: 'User not authenticated');
        return;
      }

      // Check username availability if username changed
      final currentUsername = AuthController.instance.currentUser.value.username.value;
      final newUsername = username.text.trim().toLowerCase();

      if (newUsername != currentUsername.toLowerCase()) {
        final isUsernameAvailable = await userRepository.isUsernameAvailable(newUsername);
        if (!isUsernameAvailable) {
          RFullScreenLoader.stopLoading();
          RLoaders.errorSnackBar(
            title: 'Username Taken',
            message: 'This username is already taken. Please choose another one.',
          );
          return;
        }
      }

      // Prepare update data
      final updateData = {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'username': newUsername,
      };

      print('🔥 Updating user with data: $updateData'); // Debug log

      // Update user's firstName, lastName, and username fields in Firestore
      await userRepository.updateUserFields(userId, updateData);

      print('✅ Firebase update completed'); // Debug log

      // Force refresh the current user from AuthController
      await AuthController.instance.refresh;

      // Remove Loader
      RFullScreenLoader.stopLoading();

      // Show Success Message
      RLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your profile has been updated successfully.'
      );

      // Move to previous screens
      Get.off(() => ProfileScreen());

    } catch (e) {
      print('❌ Error updating user: $e'); // Debug log
      RFullScreenLoader.stopLoading();

      // Enhanced Error Handling
      if (e is FirebaseException) {
        RLoaders.errorSnackBar(
            title: 'Firebase Error',
            message: 'An error occurred with Firebase: ${e.message}'
        );
      } else {
        RLoaders.errorSnackBar(
            title: 'Oh Snap!',
            message: e.toString()
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate first name (for form validation)
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'First name can only contain letters';
    }
    return null;
  }

  /// Validate last name (for form validation)
  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Last name can only contain letters';
    }
    return null;
  }

  /// Validate username (for form validation)
  String? validateUsernameFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    if (value.startsWith('_') || value.endsWith('_')) {
      return 'Username cannot start or end with underscore';
    }
    return null;
  }

  /// Reset form to original values
  void resetForm() {
    initializeNames();
  }

  /// Clear all form fields
  void clearForm() {
    firstName.clear();
    lastName.clear();
    username.clear();
  }

  /// Check if form has changes
  bool get hasChanges {
    final user = AuthController.instance.currentUser.value;
    return firstName.text.trim() != user.firstName.value ||
        lastName.text.trim() != user.lastName.value ||
        username.text.trim().toLowerCase() != user.username.value.toLowerCase();
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    username.dispose();
    super.onClose();
  }
}
