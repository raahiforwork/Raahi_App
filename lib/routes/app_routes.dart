abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP = _Paths.SIGNUP;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const VERIFY_EMAIL = _Paths.VERIFY_EMAIL;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const RESET_PASSWORD = _Paths.RESET_PASSWORD;
  static const NAVIGATION_MENU = _Paths.NAVIGATION_MENU;
  static const PROFILE = _Paths.PROFILE;
  static const CHANGE_NAME = _Paths.CHANGE_NAME;
  static const SETTINGS = _Paths.SETTINGS;
  static const CHAT = _Paths.CHAT;
}

abstract class _Paths {
  _Paths._();

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
