// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Artisan AI';

  @override
  String get authTitle => 'Authentication';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailHint => 'Please enter your email';

  @override
  String get passwordHint => 'Please enter your password';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get hasAccount => 'Already have an account? Login';

  @override
  String get authFailed => 'Authentication Failed';

  @override
  String get homeTitle => 'Artisan AI';

  @override
  String get logoutButton => 'Logout';

  @override
  String get credits => 'Credits';

  @override
  String get generateImage => 'Generate Image';

  @override
  String get promptHint =>
      'Describe the image you want to generate...\\nExample: \"A cute cat sitting on a rainbow\"';

  @override
  String get emptyStateTitle => 'Start creating your AI images';

  @override
  String get emptyStateSubtitle =>
      'Enter a description to have AI generate a unique image for you';

  @override
  String get insufficientCreditsTitle => 'Credits Exhausted';

  @override
  String get insufficientCreditsContent =>
      'Your image generation credits have been used up. Please purchase a plan to continue.';

  @override
  String get cancel => 'Cancel';

  @override
  String get rechargeNow => 'Recharge Now';

  @override
  String get subscriptionTitle => 'Subscription';
}
