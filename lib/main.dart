import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app.dart';
import 'data/repositories/authentication/autentication_repository.dart';
import 'firebase_options.dart';

// var cloudinary = Cloudinary.fromStringUrl('CLOUDINARY_URL=cloudinary://<276542114554522>:<WmWG11jigsAlBig9Cv-CxJXiXAs>@dcpygpsre');

Future<void> main() async {
  // Create a Cloudinary instance and set your cloud name.

  // Todo Add Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Todo Init Local Storage
  await GetStorage.init();

  // Todo Await Native Splash

  /// Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Todo Initialize Firebase

  /// Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
        (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  // Set Firebase locale
  FirebaseAuth.instance.setLanguageCode('en'); // or your preferred locale

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use .playIntegrity for production
    appleProvider: AppleProvider.debug,     // Use .deviceCheck for production
    // webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'), // Uncomment & set for web
  );

  // cloudinary.config.urlConfig.secure = true;
  // upload();

  // Todo Initialize Authentication

  runApp(const App());
}

// upload() async {
//   var response = await cloudinary.uploader().upload(
//     'https://cloudinary-devs.github.io/cld-docs-assets/assets/images/butterfly.jpeg',
//     params: UploadParams(
//       publicId: 'quickstart_butterfly',
//       uniqueFilename: false,
//       overwrite: true,
//     ),
//   );
//   print(response?.data?.publicId);
//   print(response?.data?.secureUrl);
// }
