import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../authentication/models/user_model.dart';
import '../../../data/repositories/user/user_repository.dart';
import 'dart:async';

class ProfileController extends GetxController {
  final UserRepository _repository = Get.find<UserRepository>();
  final ImagePicker _picker = ImagePicker();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  RxList<Map<String, dynamic>> coinHistory = <Map<String, dynamic>>[].obs;

  // For stream subscription management
  StreamSubscription<UserModel?>? _userProfileSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _coinHistorySubscription;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadCoinHistory();
  }

  @override
  void onClose() {
    // Cancel subscriptions to prevent memory leaks
    _userProfileSubscription?.cancel();
    _coinHistorySubscription?.cancel();
    super.onClose();
  }

  void loadUserProfile() {
    _userProfileSubscription?.cancel(); // Cancel previous subscription
    _userProfileSubscription = _repository.getCurrentUserStream().listen(
      (user) {
        currentUser.value = user;
      },
      onError: (error) {
        Get.snackbar('Profile Error', 'Failed to load user profile: $error');
        currentUser.value = null;
      },
    );
  }

  void loadCoinHistory() {
    final currentUserId = currentUser.value?.uid.value;
    if (currentUserId == null || currentUserId.isEmpty) return;

    _coinHistorySubscription?.cancel(); // Cancel previous subscription
    _coinHistorySubscription = _repository
        .getCoinHistory(currentUserId)
        .listen(
          (history) {
            coinHistory.value = history;
          },
          onError: (error) {
            Get.snackbar(
              'Coin History Error',
              'Failed to load coin history: $error',
            );
            coinHistory.value = [];
          },
        );
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;

      final userId = currentUser.value?.uid.value;
      if (userId == null || userId.isEmpty) {
        throw 'User not authenticated';
      }

      await _repository.updateUserFields(userId, updates);
      Get.snackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      Get.snackbar('Update Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        isUploading.value = true;

        final userId = currentUser.value?.uid.value;
        if (userId == null || userId.isEmpty) {
          throw 'User not authenticated';
        }

        final imageUrl = await _repository.uploadProfileImage(
          File(image.path),
          userId,
        );
        await _repository.updateUserFields(userId, {
          'profileImageUrl': imageUrl,
        });
        Get.snackbar('Success', 'Profile image updated!');
      }
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload image: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> addCoins(int coins, String reason) async {
    try {
      final userId = currentUser.value?.uid.value;
      if (userId == null || userId.isEmpty) {
        throw 'User not authenticated';
      }

      await _repository.addRaahiCoins(userId, coins, reason);
      Get.snackbar('Coins Added!', '+$coins Raahi Coins for $reason');

      // Refresh coin history after adding coins
      loadCoinHistory();
    } catch (e) {
      Get.snackbar('Coin Error', 'Failed to add coins: $e');
    }
  }

  // Clear profile data on logout
  void clearProfileData() {
    currentUser.value = null;
    coinHistory.value = [];
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    loadUserProfile();
    loadCoinHistory();
  }
}
