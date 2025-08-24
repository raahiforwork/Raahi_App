import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../features/authentication/models/user_model.dart';

class UserRepository {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user data stream
  Stream<UserModel?> getCurrentUserStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _db
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Get current user data (one-time)
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _db.collection('users').doc(currentUser.uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw 'Failed to get current user: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check username availability: $e';
    }
  }

  // Update user fields
  // Update this method in your UserRepository
  Future<void> updateUserFields(String userId, Map<String, dynamic> data) async {
    try {
      print('🔥 Updating user fields in Firestore:');
      print('   User ID: $userId');
      print('   Data: $data');

      await _db.collection('users').doc(userId).update({
        ...data,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore update completed successfully');
    } catch (e) {
      print('❌ Error updating user fields: $e');
      throw 'Failed to update user: $e';
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload profile image: $e';
    }
  }

  // Add Raahi coins
  Future<void> addRaahiCoins(String userId, int coins, String reason) async {
    try {
      await _db.runTransaction((transaction) async {
        final userDoc = await transaction.get(_db.collection('users').doc(userId));

        if (!userDoc.exists) throw 'User not found';

        final currentCoins = userDoc.data()?['raahiCoins'] ?? 0;
        final newTotal = currentCoins + coins;

        transaction.update(userDoc.reference, {
          'raahiCoins': newTotal,
          'lastSeen': FieldValue.serverTimestamp(),
        });

        transaction.set(_db.collection('coin_transactions').doc(), {
          'userId': userId,
          'amount': coins,
          'reason': reason,
          'type': 'earned',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw 'Failed to add Raahi coins: $e';
    }
  }

  // Get coin history
  Stream<List<Map<String, dynamic>>> getCoinHistory(String userId) {
    return _db
        .collection('coin_transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList());
  }

  // Check if student ID exists
  Future<bool> doesStudentIdExist(String studentId, String university) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .where('university', isEqualTo: university)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check student ID: $e';
    }
  }

  // Save user
  Future<void> saveUser(UserModel user) async {
    try {
      await _db
          .collection('users')
          .doc(user.uid.value)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save user: $e';
    }
  }

  // Update last seen
  Future<void> updateLastSeen(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _db.runTransaction((transaction) async {
        transaction.delete(_db.collection('users').doc(userId));

        final coinTransactions = await _db
            .collection('coin_transactions')
            .where('userId', isEqualTo: userId)
            .get();

        for (final doc in coinTransactions.docs) {
          transaction.delete(doc.reference);
        }
      });

      try {
        await _storage.ref().child('profile_images/$userId.jpg').delete();
      } catch (e) {
        // Image might not exist
      }
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // Fetch user details (for backward compatibility)
  Future<UserModel?> fetchUserDetails() async {
    return await getCurrentUser();
  }

  // Save user record (for backward compatibility)
  Future<void> saveUserRecord(UserModel user) async {
    await saveUser(user);
  }

  // Update single field (for backward compatibility)
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await updateUserFields(currentUser.uid, json);
    }
  }
}
