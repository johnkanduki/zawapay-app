import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zawapay App'**
  String get appName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @legalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our '**
  String get legalPrefix;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get legalTerms;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **' and our '**
  String get legalAnd;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get legalPrivacy;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transfers, fully secure'**
  String get authSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account yet?'**
  String get noAccountYet;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot\npassword?'**
  String get forgotPasswordLink;

  /// No description provided for @contactSupportLink.
  ///
  /// In en, this message translates to:
  /// **'Contact\nsupport'**
  String get contactSupportLink;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameHint;

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get referralCodeLabel;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor’s code'**
  String get referralCodeHint;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'8 characters minimum'**
  String get passwordMinHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Retype your password'**
  String get confirmPasswordHint;

  /// No description provided for @acceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptPrefix;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get acceptTerms;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @numbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your number'**
  String get numbersTitle;

  /// No description provided for @numbersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Mobile Money number to pay and to withdraw.'**
  String get numbersSubtitle;

  /// No description provided for @paymentNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment number'**
  String get paymentNumberLabel;

  /// No description provided for @paymentNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'This number receives the payment confirmation requests (USSD).'**
  String get paymentNumberHelp;

  /// No description provided for @sameNumberForWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Receive my withdrawals on this same number'**
  String get sameNumberForWithdrawals;

  /// No description provided for @receivingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiving number'**
  String get receivingNumberLabel;

  /// No description provided for @receivingNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawals are sent to this number.'**
  String get receivingNumberHelp;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get phoneNumberHint;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinLabel;

  /// No description provided for @pinHelp.
  ///
  /// In en, this message translates to:
  /// **'4 digits to confirm your withdrawals, only in the app.'**
  String get pinHelp;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN code'**
  String get confirmPinLabel;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get chooseCountry;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email: we will send you a 6-digit code to choose a new password.'**
  String get forgotPasswordBody;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the code? '**
  String get codeNotReceived;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCodeTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get codeSentTo;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a password you don’t use anywhere else.'**
  String get newPasswordBody;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @ruleMinLength.
  ///
  /// In en, this message translates to:
  /// **'8 characters minimum'**
  String get ruleMinLength;

  /// No description provided for @ruleUppercase.
  ///
  /// In en, this message translates to:
  /// **'An uppercase letter'**
  String get ruleUppercase;

  /// No description provided for @ruleLowercase.
  ///
  /// In en, this message translates to:
  /// **'A lowercase letter'**
  String get ruleLowercase;

  /// No description provided for @ruleDigits.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get ruleDigits;

  /// No description provided for @ruleSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols (@, #, ! …)'**
  String get ruleSymbols;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get strengthMedium;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection\nand try again'**
  String get noConnectionBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @countryCD.
  ///
  /// In en, this message translates to:
  /// **'DR Congo'**
  String get countryCD;

  /// No description provided for @countryBJ.
  ///
  /// In en, this message translates to:
  /// **'Benin'**
  String get countryBJ;

  /// No description provided for @countryCM.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get countryCM;

  /// No description provided for @countryCG.
  ///
  /// In en, this message translates to:
  /// **'Congo-Brazzaville'**
  String get countryCG;

  /// No description provided for @countryCI.
  ///
  /// In en, this message translates to:
  /// **'Côte d’Ivoire'**
  String get countryCI;

  /// No description provided for @countryGA.
  ///
  /// In en, this message translates to:
  /// **'Gabon'**
  String get countryGA;

  /// No description provided for @countrySN.
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get countrySN;

  /// No description provided for @countryKE.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get countryKE;

  /// No description provided for @countryUG.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get countryUG;

  /// No description provided for @countrySL.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leone'**
  String get countrySL;

  /// No description provided for @countryZM.
  ///
  /// In en, this message translates to:
  /// **'Zambia'**
  String get countryZM;

  /// No description provided for @countryRW.
  ///
  /// In en, this message translates to:
  /// **'Rwanda'**
  String get countryRW;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
