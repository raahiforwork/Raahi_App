import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/autentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/http/network_manager.dart';
import '../../../../utils/popus/full_screen_loader.dart';
import '../../../../utils/popus/loaders.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  // Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  /// Email and password SignIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start loading
      RFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        RImages.docerAnimation,
      );

      // Check Internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'No Connection',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        RFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // Login user using Email & Password Authentication
      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Remove Loader
      RFullScreenLoader.stopLoading();

      // Redirect (correctly)
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      RFullScreenLoader.stopLoading();
      RLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Google SignIn Autentication

  Future<void> googleSignIn() async {
    try {
      RFullScreenLoader.openLoadingDialog(
        'Signing you in...',
        RImages.docerAnimation,
      );

      // Check Internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'No Connection',
          message: 'Please check your internet connection.',
        );
        return;
      }

      /// Google Authentication
      final userCredential =
          await AuthenticationRepository.instance.signInWithGoogle();

      //   Save User Record
      await userController.saveUserRecord(userCredential);

      //   remove Loader
      RFullScreenLoader.stopLoading();

      //   Redirect User
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      //   remove Loader
      RFullScreenLoader.stopLoading();
      RLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
