import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../navigation_menu.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../user/user_repository.dart';
import '../../../features/authentication/models/user_model.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  final List<String> _universityDomains = [
    '@university.edu',
    '@bennett.edu.in',
    '@student.university.edu',
    '@vu.edu.pk',
    '@ucp.edu.pk',
    '@lums.edu.pk',
    '@iba.edu.pk',
  ];

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        final userModel = await UserRepository.instance.getCurrentUser();

        if (userModel != null && userModel.isVerified.value) {
          Get.offAll(() => const NavigationMenu());
        } else {
          Get.offAll(() => const NavigationMenu());
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstRime', true);
      deviceStorage.read('IsFirstRime') != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }

  bool isUniversityEmail(String email) {
    // For development/testing - temporarily allow any email
    // Comment out the line below and uncomment the university validation for production
    return true; // Allow any email for testing

    // Uncomment this for production with actual university domains:
    // return _universityDomains.any((domain) => email.toLowerCase().endsWith(domain.toLowerCase()));
  }

  String getUniversityFromEmail(String email) {
    final domain = email.split('@').last.toLowerCase();

    final universityMap = {
      'university.edu': 'Main University',
      'student.university.edu': 'Main University',
      'vu.edu.pk': 'Virtual University',
      'ucp.edu.pk': 'University of Central Punjab',
      'lums.edu.pk': 'Lahore University of Management Sciences',
      'iba.edu.pk': 'Institute of Business Administration',
    };

    return universityMap[domain] ?? 'Unknown University';
  }

  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (!isUniversityEmail(email)) {
        throw 'Please use your university email address to access Raahi.';
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await UserRepository.instance.updateLastSeen(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String studentId,
    required String phoneNumber,
    String? department,
    String? graduationYear,
  }) async {
    try {
      if (!isUniversityEmail(email)) {
        throw 'Please use your university email address to register for Raahi.';
      }

      final university = getUniversityFromEmail(email);
      final studentIdExists = await UserRepository.instance.doesStudentIdExist(
        studentId,
        university,
      );

      if (studentIdExists) {
        throw 'Student ID already registered. Please contact support if this is an error.';
      }

      final usernameAvailable = await UserRepository.instance
          .isUsernameAvailable(username);
      if (!usernameAvailable) {
        throw 'Username is already taken. Please choose another one.';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final newUser = UserModel();
        newUser.uid.value = credential.user!.uid;
        newUser.email.value = email;
        newUser.firstName.value = firstName;
        newUser.lastName.value = lastName;
        newUser.username.value = username.toLowerCase();
        newUser.studentId.value = studentId;
        newUser.phoneNumber.value = phoneNumber;
        newUser.university.value = university;
        newUser.department.value = department ?? '';
        newUser.graduationYear.value = graduationYear ?? '';
        newUser.createdAt.value = DateTime.now();
        newUser.isVerified.value = false;
        newUser.raahiCoins.value = 100;

        await UserRepository.instance.saveUser(newUser);

        await UserRepository.instance.addRaahiCoins(
          credential.user!.uid,
          100,
          'Welcome to Raahi! Your journey starts here.',
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!isUniversityEmail(email)) {
        throw 'Please use your university email address.';
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;

      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final credential = await _auth.signInWithCredential(credentials);

      if (credential.user != null) {
        final email = credential.user!.email ?? '';

        if (!isUniversityEmail(email)) {
          await _auth.signOut();
          await GoogleSignIn().signOut();
          throw 'Please use your university email address to access Raahi.';
        }

        final existingUser = await UserRepository.instance.getUserById(
          credential.user!.uid,
        );

        if (existingUser == null) {
          final newUser = UserModel();
          newUser.uid.value = credential.user!.uid;
          newUser.email.value = email;

          final displayName = credential.user!.displayName ?? '';
          final nameParts = displayName.split(' ');
          newUser.firstName.value = nameParts.isNotEmpty ? nameParts.first : '';
          newUser.lastName.value =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          newUser.username.value = UserModel.generateUsername(
            newUser.firstName.value,
            newUser.lastName.value,
          );

          newUser.university.value = getUniversityFromEmail(email);
          newUser.createdAt.value = DateTime.now();
          newUser.profileImageUrl.value = credential.user!.photoURL ?? '';
          newUser.isVerified.value = false;
          newUser.raahiCoins.value = 100;

          await UserRepository.instance.saveUser(newUser);

          await UserRepository.instance.addRaahiCoins(
            credential.user!.uid,
            100,
            'Welcome to Raahi via Google Sign-in!',
          );
        } else {
          await UserRepository.instance.updateLastSeen(credential.user!.uid);
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      if (_auth.currentUser != null) {
        await UserRepository.instance.updateLastSeen(_auth.currentUser!.uid);
      }

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong during logout. Please try again';
    }
  }

  Future<void> deleteAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw 'No user logged in';

      await UserRepository.instance.deleteUser(currentUser.uid);
      await GoogleSignIn().signOut();
      await currentUser.delete();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw RFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw RFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const RFormatException();
    } on PlatformException catch (e) {
      throw RPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while deleting account. Please try again';
    }
  }

  // Getters
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  String get getCurrentUserEmail => _auth.currentUser?.email ?? '';
  String get getCurrentUserId => _auth.currentUser?.uid ?? '';
  bool get isSignedIn => _auth.currentUser != null;
  User? get firebaseCurrentUser => _auth.currentUser;

  List<String> get supportedUniversityDomains => _universityDomains;

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
