import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/autentication_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/http/network_manager.dart';
import '../../../../utils/popus/full_screen_loader.dart';
import '../../../../utils/popus/loaders.dart';
import '../../models/user_model.dart';
import '../../screens/signup/verify_email.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs;
  final privacyPolicy = true.obs;

  // Form controllers
  final email = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final studentId = TextEditingController();
  final phoneNumber = TextEditingController();
  final department = TextEditingController();
  final graduationYear = TextEditingController();
  final emergencyContact = TextEditingController();

  // Additional fields
  final gender = 'Not Specified'.obs;
  final selectedUniversity = ''.obs;

  // Form validation
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Loading states
  final isLoading = false.obs;
  final isValidatingEmail = false.obs;
  final isValidatingUsername = false.obs;

  /// Gender options
  final genderOptions = ['Male', 'Female', 'Other', 'Not Specified'];

  @override
  void onInit() {
    super.onInit();
    email.addListener(_detectUniversityFromEmail);
    firstName.addListener(_generateUsername);
    lastName.addListener(_generateUsername);
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    username.dispose();
    studentId.dispose();
    phoneNumber.dispose();
    department.dispose();
    graduationYear.dispose();
    emergencyContact.dispose();
    super.onClose();
  }

  /// Detect university from email domain
  void _detectUniversityFromEmail() {
    final emailText = email.text.trim();
    if (emailText.isNotEmpty && emailText.contains('@')) {
      final university = AuthenticationRepository.instance.getUniversityFromEmail(emailText);
      selectedUniversity.value = university;
    } else {
      selectedUniversity.value = '';
    }
  }

  /// Auto-generate username from first and last name
  void _generateUsername() {
    if (firstName.text.trim().isNotEmpty && lastName.text.trim().isNotEmpty) {
      final generatedUsername = UserModel.generateUsername(
          firstName.text.trim(),
          lastName.text.trim()
      );
      username.text = generatedUsername;
    }
  }

  /// Validate university email in real-time
  Future<void> validateUniversityEmail() async {
    final emailText = email.text.trim();
    if (emailText.isEmpty) return;

    isValidatingEmail.value = true;

    try {
      final isUniversityEmail = AuthenticationRepository.instance.isUniversityEmail(emailText);
      if (!isUniversityEmail) {
        RLoaders.errorSnackBar(
          title: 'Invalid Email',
          message: 'Please use your university email address to register for Raahi.',
        );
      }
    } catch (e) {
      RLoaders.errorSnackBar(title: 'Error', message: 'Failed to validate email');
    } finally {
      isValidatingEmail.value = false;
    }
  }

  /// Check username availability
  Future<void> validateUsernameAvailability() async {
    final usernameText = username.text.trim();
    if (usernameText.isEmpty) return;

    isValidatingUsername.value = true;

    try {
      final isAvailable = await UserRepository.instance.isUsernameAvailable(usernameText);
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

  /// Check if student ID already exists
  Future<bool> checkStudentIdAvailability() async {
    final studentIdText = studentId.text.trim();
    final university = selectedUniversity.value;

    if (studentIdText.isEmpty || university.isEmpty) return false;

    try {
      final exists = await UserRepository.instance.doesStudentIdExist(studentIdText, university);
      if (exists) {
        RLoaders.errorSnackBar(
          title: 'Student ID Taken',
          message: 'This Student ID is already registered. Please contact support if this is an error.',
        );
        return false;
      }
      return true;
    } catch (e) {
      RLoaders.errorSnackBar(title: 'Error', message: 'Failed to verify Student ID');
      return false;
    }
  }

  /// Main signup method
  /// Main signup method with debug
  void signup() async {
    try {
      print('🚀 Signup method called');

      isLoading.value = true;
      RFullScreenLoader.openLoadingDialog(
          "Creating your Raahi account...",
          RImages.docerAnimation
      );

      // Check Internet Connectivity
      print('📡 Checking internet connectivity...');
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        print('❌ No internet connection');
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
        );
        return;
      }
      print('✅ Internet connected');

      // Form Validation
      print('📝 Validating form...');
      if (!signupFormKey.currentState!.validate()) {
        print('❌ Form validation failed');
        RFullScreenLoader.stopLoading();
        return;
      }
      print('✅ Form validation passed');

      // Privacy Policy Check
      print('📋 Checking privacy policy...');
      if (!privacyPolicy.value) {
        print('❌ Privacy policy not accepted');
        RFullScreenLoader.stopLoading();
        RLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'In order to create account, you must read and accept the Privacy Policy & Terms of Use.',
        );
        return;
      }
      print('✅ Privacy policy accepted');

      // Print form data for debugging
      print('📄 Form data:');
      print('  First Name: ${firstName.text.trim()}');
      print('  Last Name: ${lastName.text.trim()}');
      print('  Username: ${username.text.trim()}');
      print('  Email: ${email.text.trim()}');
      print('  Student ID: ${studentId.text.trim()}');
      print('  Phone: ${phoneNumber.text.trim()}');

      // Validate university email
      final emailText = email.text.trim();
      print('🏫 Validating university email: $emailText');
      if (!AuthenticationRepository.instance.isUniversityEmail(emailText)) {
        print('❌ Invalid university email');
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'Invalid Email',
          message: 'Please use your university email address to register for Raahi.',
        );
        return;
      }
      print('✅ University email validated');

      // Check username availability
      print('👤 Checking username availability...');
      final isUsernameAvailable = await UserRepository.instance.isUsernameAvailable(username.text.trim());
      if (!isUsernameAvailable) {
        print('❌ Username not available');
        RFullScreenLoader.stopLoading();
        RLoaders.errorSnackBar(
          title: 'Username Taken',
          message: 'This username is already taken. Please choose another one.',
        );
        return;
      }
      print('✅ Username available');

      // Check student ID availability
      print('🆔 Checking student ID availability...');
      final isStudentIdAvailable = await checkStudentIdAvailability();
      if (!isStudentIdAvailable) {
        print('❌ Student ID not available');
        RFullScreenLoader.stopLoading();
        return;
      }
      print('✅ Student ID available');

      // Register user
      print('🔐 Creating user account...');
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(
        email: emailText,
        password: password.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        studentId: studentId.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        department: department.text.trim().isNotEmpty ? department.text.trim() : null,
        graduationYear: graduationYear.text.trim().isNotEmpty ? graduationYear.text.trim() : null,
      );
      print('✅ User account created successfully');

      // Additional profile updates
      if (userCredential.user != null) {
        print('📝 Updating additional profile data...');
        final additionalData = <String, dynamic>{};

        if (gender.value != 'Not Specified') {
          additionalData['gender'] = gender.value;
        }

        if (emergencyContact.text.trim().isNotEmpty) {
          additionalData['emergencyContact'] = emergencyContact.text.trim();
        }

        if (additionalData.isNotEmpty) {
          await UserRepository.instance.updateUserFields(
              userCredential.user!.uid,
              additionalData
          );
        }
        print('✅ Additional profile data updated');
      }

      RFullScreenLoader.stopLoading();

      print('🎉 Registration completed successfully');
      RLoaders.successSnackBar(
          title: 'Welcome to Raahi!',
          message: 'Your account has been created successfully! Please verify your email to continue.'
      );

      Get.to(() => VerifyEmailScreen(email: emailText));

    } catch (e) {
      print('💥 Error during signup: $e');
      RFullScreenLoader.stopLoading();
      RLoaders.errorSnackBar(
          title: 'Registration Failed',
          message: e.toString()
      );
    } finally {
      isLoading.value = false;
      print('🏁 Signup process finished');
    }
  }

  /// Validation methods
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

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    if (!AuthenticationRepository.instance.isUniversityEmail(value)) {
      return 'Please use your university email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    if (value.length < 3) {
      return 'Please enter a valid Student ID';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
