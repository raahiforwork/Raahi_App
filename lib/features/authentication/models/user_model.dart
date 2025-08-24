import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserModel {
  // ─── Reactive fields ───────────────────────────────────────────────
  final RxString uid              = ''.obs;
  final RxString email            = ''.obs;
  final RxString firstName        = ''.obs;
  final RxString lastName         = ''.obs;
  final RxString username         = ''.obs;
  final RxString studentId        = ''.obs;
  final RxString phoneNumber      = ''.obs;
  final RxString university       = ''.obs;
  final RxString department       = ''.obs;
  final RxString graduationYear   = ''.obs;
  final RxBool   isVerified       = false.obs;
  final Rx<DateTime> createdAt    = DateTime.now().obs;
  final RxString profileImageUrl  = ''.obs;
  final RxString gender           = ''.obs;
  final RxString emergencyContact = ''.obs;
  final RxInt    raahiCoins       = 0.obs;
  final RxDouble safetyRating     = 4.0.obs;
  final RxBool   isDriver         = false.obs;

  // ─── C-tors ────────────────────────────────────────────────────────
  UserModel();

  UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    uid.value              = doc.id;
    email.value            = data['email']            ?? '';
    firstName.value        = data['firstName']        ?? '';
    lastName.value         = data['lastName']         ?? '';
    username.value         = data['username']         ?? '';
    studentId.value        = data['studentId']        ?? '';
    phoneNumber.value      = data['phoneNumber']      ?? '';
    university.value       = data['university']       ?? '';
    department.value       = data['department']       ?? '';
    graduationYear.value   = data['graduationYear']   ?? '';
    isVerified.value       = data['isVerified']       ?? false;
    createdAt.value        = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    profileImageUrl.value  = data['profileImageUrl']  ?? '';
    gender.value           = data['gender']           ?? '';
    emergencyContact.value = data['emergencyContact'] ?? '';
    raahiCoins.value       = data['raahiCoins']       ?? 0;
    safetyRating.value     = (data['safetyRating']    ?? 4.0).toDouble();
    isDriver.value         = data['isDriver']         ?? false;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email'            : email.value,
      'firstName'        : firstName.value,
      'lastName'         : lastName.value,
      'username'         : username.value,
      'studentId'        : studentId.value,
      'phoneNumber'      : phoneNumber.value,
      'university'       : university.value,
      'department'       : department.value,
      'graduationYear'   : graduationYear.value,
      'isVerified'       : isVerified.value,
      'createdAt'        : Timestamp.fromDate(createdAt.value),
      'profileImageUrl'  : profileImageUrl.value,
      'gender'           : gender.value,
      'emergencyContact' : emergencyContact.value,
      'raahiCoins'       : raahiCoins.value,
      'safetyRating'     : safetyRating.value,
      'isDriver'         : isDriver.value,
      'lastSeen'         : FieldValue.serverTimestamp(),
    };
  }

  String get fullName => '${firstName.value} ${lastName.value}'.trim();

  static String generateUsername(String first, String last) {
    final base = '${first.toLowerCase()}${last.toLowerCase()}'
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return '$base$suffix';
  }
}
