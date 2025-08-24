import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/authentication/autentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../navigation_menu.dart';
import '../../authentication/models/user_model.dart';
import 'dart:async';

import '../../authentication/screens/login/login.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = Get.find<UserRepository>();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel> currentUser = UserModel().obs;
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  StreamSubscription<UserModel?>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  @override
  void onClose() {
    _userStreamSubscription?.cancel();
    super.onClose();
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      currentUser.value = UserModel();
      _userStreamSubscription?.cancel();
      Get.offAll(() => const LoginScreen());
    } else {
      isLoggedIn.value = true;
      await _loadUserProfile(user.uid);
      Get.offAll(() => const NavigationMenu());
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      print('🔄 Loading user profile for UID: $uid'); // Debug log

      // Cancel previous subscription
      _userStreamSubscription?.cancel();

      // Get initial user data
      final userModel = await _userRepository.getUserById(uid);
      if (userModel != null) {
        currentUser.value = userModel;
        print('✅ Initial user loaded: ${userModel.firstName.value} ${userModel.lastName.value}'); // Debug log
      }

      // Start listening for real-time updates
      _userStreamSubscription = _userRepository.getCurrentUserStream().listen(
              (user) {
            if (user != null) {
              print('🔥 Real-time update received: ${user.firstName.value} ${user.lastName.value}'); // Debug log
              currentUser.value = user;
              currentUser.refresh(); // Force UI update
            }
          },
          onError: (error) {
            print('❌ Error in user stream: $error'); // Debug log
            Get.snackbar('Error', 'Failed to sync profile: $error');
          }
      );
    } catch (e) {
      print('❌ Error loading user profile: $e'); // Debug log
      Get.snackbar('Error', 'Failed to load profile: $e');
    }
  }

  // Method to refresh current user data
  Future<void> refreshCurrentUser() async {
    try {
      final userId = getCurrentUserId;
      if (userId.isNotEmpty) {
        print('🔄 Refreshing current user data...'); // Debug log
        final updatedUser = await _userRepository.getUserById(userId);
        if (updatedUser != null) {
          currentUser.value = updatedUser;
          currentUser.refresh(); // Force UI update
          print('✅ User data refreshed: ${updatedUser.firstName.value} ${updatedUser.lastName.value}'); // Debug log
        }
      }
    } catch (e) {
      print('❌ Error refreshing user: $e'); // Debug log
    }
  }

  Future<void> signOut() async {
    try {
      _userStreamSubscription?.cancel();
      await AuthenticationRepository.instance.logout();
      currentUser.value = UserModel();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  // Getters
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  String get getCurrentUserEmail => _auth.currentUser?.email ?? '';
  String get getCurrentUserId => _auth.currentUser?.uid ?? '';
  bool get isSignedIn => _auth.currentUser != null;
  User? get firebaseCurrentUser => _auth.currentUser;

  // Check if current user is verified
  bool get isCurrentUserVerified => currentUser.value.isVerified.value;

  // Get current user's university
  String get currentUserUniversity => currentUser.value.university.value;

  // Get current user's Raahi coins
  int get currentUserCoins => currentUser.value.raahiCoins.value;

  // Check if current user is a driver
  bool get isCurrentUserDriver => currentUser.value.isDriver.value;

  // Get full name
  String get currentUserFullName => '${currentUser.value.firstName.value} ${currentUser.value.lastName.value}'.trim();

  // Get first name
  String get currentUserFirstName => currentUser.value.firstName.value;

  // Get last name
  String get currentUserLastName => currentUser.value.lastName.value;

  // Get username
  String get currentUserUsername => currentUser.value.username.value;
}
