import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<UserModel?> getCurrentUserProfile() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'User not authenticated';

    await _firestore.collection('users').doc(currentUser.uid).update({
      ...updates,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'User not authenticated';

    final ref = _storage.ref().child('profile_images/${currentUser.uid}.jpg');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addRaahiCoins(int coins, String reason) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'User not authenticated';

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(
        _firestore.collection('users').doc(currentUser.uid),
      );

      if (!userDoc.exists) throw 'User not found';

      final currentCoins = userDoc.data()?['raahiCoins'] ?? 0;

      transaction.update(userDoc.reference, {
        'raahiCoins': currentCoins + coins,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      transaction.set(_firestore.collection('coin_transactions').doc(), {
        'userId': currentUser.uid,
        'amount': coins,
        'reason': reason,
        'type': 'earned',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<Map<String, dynamic>>> getCoinHistory() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('coin_transactions')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList());
  }
}
