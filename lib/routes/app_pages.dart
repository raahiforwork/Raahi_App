import 'package:get/get.dart';

import '../features/authentication/screens/login/login.dart';
import '../features/authentication/screens/signup/signup.dart';
import '../features/authentication/screens/onboarding/onboarding.dart';
import '../features/authentication/screens/signup/verify_email.dart';
import '../features/authentication/screens/password_configuration/forget_password.dart';
import '../features/authentication/screens/password_configuration/reset_password.dart';
import '../features/personalization/screens/profile/profile.dart';
import '../features/personalization/screens/profile/widgets/change_name.dart';
import '../features/personalization/screens/settings/settings.dart';
import '../features/rides/screens/chat_screen.dart';
import '../navigation_menu.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARDING;

  static final pages = [
    // Authentication Pages
    GetPage(name: _Paths.LOGIN, page: () => const LoginScreen()),
    GetPage(name: _Paths.SIGNUP, page: () => const SignUpScreen()),
    GetPage(name: _Paths.ONBOARDING, page: () => const OnBoardingScreen()),
    GetPage(name: _Paths.VERIFY_EMAIL, page: () => const VerifyEmailScreen()),
    GetPage(name: _Paths.FORGOT_PASSWORD, page: () => const ForgetPassword()),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(email: ''),
    ),

    // Main App Pages
    GetPage(name: _Paths.NAVIGATION_MENU, page: () => const NavigationMenu()),
    GetPage(name: _Paths.HOME, page: () => const NavigationMenu()),

    // Profile Pages
    GetPage(name: _Paths.PROFILE, page: () => ProfileScreen()),
    GetPage(name: _Paths.CHANGE_NAME, page: () => const ChangeNameScreen()),

    // Settings Pages
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsScreen()),

    // Chat Pages
    GetPage(
      name: _Paths.CHAT,
      page:
          () => const ChatScreen(
            otherUserId: '',
            rideInfo: null,
            otherUserName: null,
          ),
    ),
  ];
}

abstract class _Paths {
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const ONBOARDING = '/onboarding';
  static const VERIFY_EMAIL = '/verify-email';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const RESET_PASSWORD = '/reset-password';
  static const NAVIGATION_MENU = '/navigation-menu';
  static const PROFILE = '/profile';
  static const CHANGE_NAME = '/change-name';
  static const SETTINGS = '/settings';
  static const CHAT = '/chat';
}
