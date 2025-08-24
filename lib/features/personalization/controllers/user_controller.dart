import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authentication/autentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/http/network_manager.dart';
import '../../../utils/popus/full_screen_loader.dart';
import '../../../utils/popus/loaders.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/screens/login/login.dart';
import '../screens/profile/widgets/re_authenticate_user_login_form.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel().obs;

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.find<UserRepository>();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Fetch user record
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final currentUser = await userRepository.getCurrentUser();
      if (currentUser != null) {
        user.value = currentUser;
      } else {
        user.value = UserModel();
      }
    } catch (e) {
      user.value = UserModel();
      RLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to fetch user data: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any Registration provider (Google Sign-in)
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        final firebaseUser = userCredentials.user!;

        // Check if user already exists
        final existingUser = await userRepository.getUserById(firebaseUser.uid);

        if (existingUser == null) {
          // Create new user profile for Google sign-in
          final newUser = UserModel();
          newUser.uid.value = firebaseUser.uid;
          newUser.email.value = firebaseUser.email ?? '';

          // Split display name into first and last name
          final displayName = firebaseUser.displayName ?? '';
          final nameParts = displayName.split(' ');
          newUser.firstName.value = nameParts.isNotEmpty ? nameParts.first : '';
          newUser.lastName.value = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          // Generate username from name
          newUser.username.value = UserModel.generateUsername(
              newUser.firstName.value,
              newUser.lastName.value
          );

          newUser.phoneNumber.value = firebaseUser.phoneNumber ?? '';
          newUser.profileImageUrl.value = firebaseUser.photoURL ?? '';
          newUser.university.value = AuthenticationRepository.instance.getUniversityFromEmail(firebaseUser.email ?? '');
          newUser.createdAt.value = DateTime.now();
          newUser.isVerified.value = false; // Requires admin verification
          newUser.raahiCoins.value = 100; // Welcome bonus

          await userRepository.saveUser(newUser);

          // Add welcome coins transaction
          await userRepository.addRaahiCoins(
              firebaseUser.uid,
              100,
              'Welcome to Raahi via Google Sign-in!'
          );

          user.value = newUser;
        } else {
          user.value = existingUser;
          // Update last seen
          await userRepository.updateLastSeen(firebaseUser.uid);
        }
      }
    } catch (e) {
      RLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  /// Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      profileLoading.value = true;

      final userId = user.value.uid.value;
      if (userId.isEmpty) {
        throw 'User not authenticated';
      }

      await userRepository.updateUserFields(userId, updates);

      // Update local user model
      updates.forEach((key, value) {
        switch (key) {
          case 'firstName':
            user.value.firstName.value = value;
            break;
          case 'lastName':
            user.value.lastName.value = value;
            break;
          case 'username':
            user.value.username.value = value;
            break;
          case 'phoneNumber':
            user.value.phoneNumber.value = value;
            break;
          case 'department':
            user.value.department.value = value;
            break;
          case 'gender':
            user.value.gender.value = value;
            break;
          case 'emergencyContact':
            user.value.emergencyContact.value = value;
            break;
          case 'profileImageUrl':
            user.value.profileImageUrl.value = value;
            break;
        }
      });

      RLoaders.successSnackBar(
        title: 'Success',
        message: 'Profile updated successfully!',
      );
    } catch (e) {
      RLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update profile: $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(RSizes.md),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible and all of your data including your Raahi coins will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: RSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  /// Delete User Account
  void deleteUserAccount() async {
    try {
      RFullScreenLoader.openLoadingDialog('Deleting Account...', RImages.docerAnimation);

      // First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          RFullScreenLoader.stopLoading();
          Get.offAll(() => const LoginScreen());
        } else if (provider == 'password') {
          RFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      RFullScreenLoader.stopLoading();
      RLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// RE-AUTHENTICATE before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      RFullScreenLoader.openLoadingDialog('Processing...', RImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        RFullScreenLoader.stopLoading();
        return;
      }

      // Validate university email
      if (!AuthenticationRepository.instance.isUniversityEmail(verifyEmail.text.trim())) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'Invalid Email',
          message: 'Please use your university email address.',
        );
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(
          verifyEmail.text.trim(),
          verifyPassword.text.trim()
      );

      await AuthenticationRepository.instance.deleteAccount();

      RFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      RFullScreenLoader.stopLoading();
      RLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    await fetchUserRecord();
  }

  // Getters for backward compatibility
  int get userRaahiCoins => user.value.raahiCoins.value;
  bool get isUserVerified => user.value.isVerified.value;
  bool get isUserDriver => user.value.isDriver.value;
  String get userUniversity => user.value.university.value;
  double get userSafetyRating => user.value.safetyRating.value;
  String get userFullName => user.value.fullName;
  String get userFirstName => user.value.firstName.value;
  String get userLastName => user.value.lastName.value;
  String get userUsername => user.value.username.value;

  @override
  void onClose() {
    verifyEmail.dispose();
    verifyPassword.dispose();
    super.onClose();
  }
}
