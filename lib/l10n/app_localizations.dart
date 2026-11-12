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

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your country and language.'**
  String get welcomeSubtitle;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @countryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your country'**
  String get countryHint;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

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

  /// No description provided for @sponsorInvitationLabel.
  ///
  /// In en, this message translates to:
  /// **'Sponsor invitation'**
  String get sponsorInvitationLabel;

  /// No description provided for @sponsorInvitationHint.
  ///
  /// In en, this message translates to:
  /// **'your sponsor’s username'**
  String get sponsorInvitationHint;

  /// No description provided for @sponsorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is this the person who invited you?'**
  String get sponsorQuestion;

  /// No description provided for @sponsorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get sponsorConfirm;

  /// No description provided for @sponsorConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Invitation confirmed: {name}'**
  String sponsorConfirmed(String name);

  /// No description provided for @sponsorChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get sponsorChange;

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
  /// **'To pay and to withdraw.'**
  String get numbersSubtitle;

  /// No description provided for @paymentNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment number'**
  String get paymentNumberLabel;

  /// No description provided for @paymentNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'Gets the payment requests (USSD).'**
  String get paymentNumberHelp;

  /// No description provided for @sameNumberForWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to this same number'**
  String get sameNumberForWithdrawals;

  /// No description provided for @receivingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiving number'**
  String get receivingNumberLabel;

  /// No description provided for @receivingNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawals arrive here.'**
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
  /// **'4 digits to confirm your withdrawals.'**
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

  /// No description provided for @searchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a country'**
  String get searchCountryHint;

  /// No description provided for @allCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get allCountries;

  /// No description provided for @countryNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not in this country yet'**
  String get countryNotAvailableTitle;

  /// No description provided for @countryNotAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Coming soon. Pick a country from the list.'**
  String get countryNotAvailableBody;

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
  /// **'We send a 6-digit code to your email.'**
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
  /// **'Code sent to'**
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
  /// **'A password you use nowhere else.'**
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

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A real photo, taken with the front camera.'**
  String get profilePhotoSubtitle;

  /// No description provided for @profilePhotoTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle'**
  String get profilePhotoTapHint;

  /// No description provided for @profilePhotoRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake the photo'**
  String get profilePhotoRetake;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @faceCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Take your photo'**
  String get faceCaptureTitle;

  /// No description provided for @faceCaptureButton.
  ///
  /// In en, this message translates to:
  /// **'Take the photo'**
  String get faceCaptureButton;

  /// No description provided for @faceHintNoFace.
  ///
  /// In en, this message translates to:
  /// **'Place your face in the circle'**
  String get faceHintNoFace;

  /// No description provided for @faceHintTooFar.
  ///
  /// In en, this message translates to:
  /// **'Come a little closer'**
  String get faceHintTooFar;

  /// No description provided for @faceHintSeveral.
  ///
  /// In en, this message translates to:
  /// **'One person at a time'**
  String get faceHintSeveral;

  /// No description provided for @faceHintReady.
  ///
  /// In en, this message translates to:
  /// **'Perfect, take the photo'**
  String get faceHintReady;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No front camera on this device.'**
  String get cameraNotAvailable;

  /// No description provided for @cameraAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow the camera in Settings.'**
  String get cameraAccessDenied;

  /// No description provided for @cameraFailed.
  ///
  /// In en, this message translates to:
  /// **'The camera could not open.'**
  String get cameraFailed;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeHello;

  /// No description provided for @balanceUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last updated at {time}'**
  String balanceUpdatedAt(String time);

  /// No description provided for @balanceHide.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get balanceHide;

  /// No description provided for @balanceShow.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get balanceShow;

  /// No description provided for @homeSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get homeSend;

  /// No description provided for @homeWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get homeWithdraw;

  /// No description provided for @homeActivity.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeActivity;

  /// No description provided for @homeHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get homeHide;

  /// No description provided for @homeShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get homeShow;

  /// No description provided for @homeNoTransfers.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet.'**
  String get homeNoTransfers;

  /// No description provided for @homeSeeAllTransfers.
  ///
  /// In en, this message translates to:
  /// **'See all history'**
  String get homeSeeAllTransfers;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get statusSuccess;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{today} =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String monthsAgo(int count);

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get tabScan;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @kycTitle.
  ///
  /// In en, this message translates to:
  /// **'Certify your username'**
  String get kycTitle;

  /// No description provided for @kycSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The blue badge proves this account is yours.'**
  String get kycSubtitle;

  /// No description provided for @kycStepIdTitle.
  ///
  /// In en, this message translates to:
  /// **'ID document'**
  String get kycStepIdTitle;

  /// No description provided for @kycStepIdBody.
  ///
  /// In en, this message translates to:
  /// **'Voter card, passport or licence.'**
  String get kycStepIdBody;

  /// No description provided for @kycStepSelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get kycStepSelfieTitle;

  /// No description provided for @kycStepSelfieBody.
  ///
  /// In en, this message translates to:
  /// **'Your face, with the front camera.'**
  String get kycStepSelfieBody;

  /// No description provided for @kycStepReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get kycStepReviewTitle;

  /// No description provided for @kycStepReviewBody.
  ///
  /// In en, this message translates to:
  /// **'The badge shows once approved.'**
  String get kycStepReviewBody;

  /// No description provided for @kycPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your documents are only used to verify you.'**
  String get kycPrivacy;

  /// No description provided for @kycStart.
  ///
  /// In en, this message translates to:
  /// **'Start the check'**
  String get kycStart;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsEdit;

  /// No description provided for @settingsNotCertified.
  ///
  /// In en, this message translates to:
  /// **'Username not certified'**
  String get settingsNotCertified;

  /// No description provided for @settingsCertify.
  ///
  /// In en, this message translates to:
  /// **'Certify'**
  String get settingsCertify;

  /// No description provided for @settingsCertified.
  ///
  /// In en, this message translates to:
  /// **'Certified username'**
  String get settingsCertified;

  /// No description provided for @settingsInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get settingsInvite;

  /// No description provided for @settingsInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 levels above, 3 below'**
  String get settingsInviteSubtitle;

  /// No description provided for @settingsPhones.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers'**
  String get settingsPhones;

  /// No description provided for @settingsPhonesHint.
  ///
  /// In en, this message translates to:
  /// **'Payments and withdrawals'**
  String get settingsPhonesHint;

  /// No description provided for @settingsDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get settingsDailyLimit;

  /// No description provided for @settingsDailyLimitValue.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String settingsDailyLimitValue(String used, String limit);

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsAppearanceAuto;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsNotificationsOn;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsPin.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get settingsPin;

  /// No description provided for @settingsDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get settingsDevices;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsHelp;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get settingsSupport;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Zawapay App'**
  String get settingsAbout;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite, earn together'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn on the transfers of 3 levels above and 3 below.'**
  String get inviteSubtitle;

  /// No description provided for @inviteYourHandle.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor invitation'**
  String get inviteYourHandle;

  /// No description provided for @inviteCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get inviteCopy;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Username copied'**
  String get inviteCopied;

  /// No description provided for @inviteHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get inviteHowTitle;

  /// No description provided for @inviteAbove.
  ///
  /// In en, this message translates to:
  /// **'Above you'**
  String get inviteAbove;

  /// No description provided for @inviteAbove3.
  ///
  /// In en, this message translates to:
  /// **'Level 2’s sponsor'**
  String get inviteAbove3;

  /// No description provided for @inviteAbove2.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor’s sponsor'**
  String get inviteAbove2;

  /// No description provided for @inviteAbove1.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor'**
  String get inviteAbove1;

  /// No description provided for @inviteYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get inviteYou;

  /// No description provided for @inviteBelow1.
  ///
  /// In en, this message translates to:
  /// **'Your invitees'**
  String get inviteBelow1;

  /// No description provided for @inviteBelow2.
  ///
  /// In en, this message translates to:
  /// **'Their invitees'**
  String get inviteBelow2;

  /// No description provided for @inviteBelow3.
  ///
  /// In en, this message translates to:
  /// **'The next level'**
  String get inviteBelow3;

  /// No description provided for @inviteBelow.
  ///
  /// In en, this message translates to:
  /// **'Below you'**
  String get inviteBelow;

  /// No description provided for @inviteChainNote.
  ///
  /// In en, this message translates to:
  /// **'These 6 levels earn on your transfers, and you on theirs.'**
  String get inviteChainNote;

  /// No description provided for @inviteExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get inviteExampleTitle;

  /// No description provided for @inviteExampleSent.
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get inviteExampleSent;

  /// No description provided for @inviteExampleFees.
  ///
  /// In en, this message translates to:
  /// **'Service fee ({rate})'**
  String inviteExampleFees(String rate);

  /// No description provided for @inviteExamplePool.
  ///
  /// In en, this message translates to:
  /// **'Commissions ({rate} of the fee)'**
  String inviteExamplePool(String rate);

  /// No description provided for @inviteExampleNote.
  ///
  /// In en, this message translates to:
  /// **'Rates shown as an example.'**
  String get inviteExampleNote;

  /// No description provided for @inviteRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'The rules'**
  String get inviteRulesTitle;

  /// No description provided for @inviteRuleFree.
  ///
  /// In en, this message translates to:
  /// **'Signing up is free.'**
  String get inviteRuleFree;

  /// No description provided for @inviteRuleRealTransfers.
  ///
  /// In en, this message translates to:
  /// **'Earnings on real transfers only.'**
  String get inviteRuleRealTransfers;

  /// No description provided for @inviteRuleConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Released once the recipient confirms.'**
  String get inviteRuleConfirmed;

  /// No description provided for @inviteRuleFees.
  ///
  /// In en, this message translates to:
  /// **'Taken from the fee, never the amount.'**
  String get inviteRuleFees;

  /// No description provided for @sendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get sendTitle;

  /// No description provided for @sendByUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get sendByUsername;

  /// No description provided for @sendByPhone.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get sendByPhone;

  /// No description provided for @sendUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get sendUsernameHint;

  /// No description provided for @sendPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get sendPhoneHint;

  /// No description provided for @sendPhoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account with this number.'**
  String get sendPhoneNotFound;

  /// No description provided for @sendRecents.
  ///
  /// In en, this message translates to:
  /// **'Recent ({count})'**
  String sendRecents(int count);

  /// No description provided for @sendFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get sendFrom;

  /// No description provided for @sendMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get sendMobileMoney;

  /// No description provided for @sendYouPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get sendYouPay;

  /// No description provided for @sendReceives.
  ///
  /// In en, this message translates to:
  /// **'They receive'**
  String get sendReceives;

  /// No description provided for @sendFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get sendFee;

  /// No description provided for @sendFeePaidByYou.
  ///
  /// In en, this message translates to:
  /// **'Paid by you'**
  String get sendFeePaidByYou;

  /// No description provided for @sendPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get sendPay;

  /// No description provided for @sendPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String sendPayAmount(String amount);

  /// No description provided for @sendNoteHint.
  ///
  /// In en, this message translates to:
  /// **'A note…'**
  String get sendNoteHint;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'Dollars'**
  String get currencyUsd;

  /// No description provided for @currencyCdf.
  ///
  /// In en, this message translates to:
  /// **'Congolese francs'**
  String get currencyCdf;

  /// No description provided for @sentTitle.
  ///
  /// In en, this message translates to:
  /// **'On its way'**
  String get sentTitle;

  /// No description provided for @sentTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get sentTo;

  /// No description provided for @sentFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get sentFee;

  /// No description provided for @sentNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get sentNote;

  /// No description provided for @sentReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get sentReference;

  /// No description provided for @sentDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sentDate;

  /// No description provided for @sentStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money payment'**
  String get sentStepPayment;

  /// No description provided for @sentStepPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Approve with your Mobile Money PIN.'**
  String get sentStepPaymentBody;

  /// No description provided for @sentStepPayout.
  ///
  /// In en, this message translates to:
  /// **'Sending to the recipient'**
  String get sentStepPayout;

  /// No description provided for @sentStepPayoutBody.
  ///
  /// In en, this message translates to:
  /// **'To {handle}’s Mobile Money.'**
  String sentStepPayoutBody(String handle);

  /// No description provided for @sentStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get sentStepConfirm;

  /// No description provided for @sentStepConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{handle} confirms receipt.'**
  String sentStepConfirmBody(String handle);

  /// No description provided for @sentBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get sentBackHome;

  /// No description provided for @detailStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer status'**
  String get detailStatusTitle;

  /// No description provided for @detailRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get detailRecipient;

  /// No description provided for @detailSender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get detailSender;

  /// No description provided for @detailSeeAllWith.
  ///
  /// In en, this message translates to:
  /// **'See all with {handle}'**
  String detailSeeAllWith(String handle);

  /// No description provided for @detailAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get detailAmountTitle;

  /// No description provided for @detailTransferAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get detailTransferAmount;

  /// No description provided for @detailFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get detailFee;

  /// No description provided for @detailTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get detailTotalPaid;

  /// No description provided for @detailTotalReceived.
  ///
  /// In en, this message translates to:
  /// **'They receive'**
  String get detailTotalReceived;

  /// No description provided for @detailInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer details'**
  String get detailInfoTitle;

  /// No description provided for @detailSentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent on'**
  String get detailSentOn;

  /// No description provided for @detailTransferId.
  ///
  /// In en, this message translates to:
  /// **'Transfer ID'**
  String get detailTransferId;

  /// No description provided for @detailReferenceId.
  ///
  /// In en, this message translates to:
  /// **'Reference ID'**
  String get detailReferenceId;

  /// No description provided for @detailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get detailCopied;

  /// No description provided for @detailTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get detailTryAgain;

  /// No description provided for @detailGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get detailGetHelp;

  /// No description provided for @detailStepSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get detailStepSubmitted;

  /// No description provided for @detailStepPaid.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money payment confirmed'**
  String get detailStepPaid;

  /// No description provided for @detailStepConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Received and confirmed by {handle}'**
  String detailStepConfirmed(String handle);

  /// No description provided for @detailStepWaitingRecipient.
  ///
  /// In en, this message translates to:
  /// **'{handle} must confirm'**
  String detailStepWaitingRecipient(String handle);

  /// No description provided for @detailStepWaitingYou.
  ///
  /// In en, this message translates to:
  /// **'Confirm you received this money'**
  String get detailStepWaitingYou;

  /// No description provided for @detailStepFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment was not approved in time, or a wrong PIN was entered. Please try again.'**
  String get detailStepFailed;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(String time);

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactTitle;

  /// No description provided for @contactSapottiText.
  ///
  /// In en, this message translates to:
  /// **'The fastest way to reach us'**
  String get contactSapottiText;

  /// No description provided for @contactRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get contactRecommended;

  /// No description provided for @contactEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get contactEmailTitle;

  /// No description provided for @contactEmailText.
  ///
  /// In en, this message translates to:
  /// **'Write to our support team'**
  String get contactEmailText;

  /// No description provided for @contactReplyTime.
  ///
  /// In en, this message translates to:
  /// **'We usually reply in less than an hour'**
  String get contactReplyTime;

  /// No description provided for @appearanceIntro.
  ///
  /// In en, this message translates to:
  /// **'Zawapay App appearance'**
  String get appearanceIntro;

  /// No description provided for @appearanceAutoText.
  ///
  /// In en, this message translates to:
  /// **'Follows your phone’s setting'**
  String get appearanceAutoText;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @historyFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get historyFilters;

  /// No description provided for @historyClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get historyClear;

  /// No description provided for @historyResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String historyResults(int count);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing for these filters.'**
  String get historyEmpty;

  /// No description provided for @filterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sent, received, by person or by date.'**
  String get filterSubtitle;

  /// No description provided for @filterPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get filterPerson;

  /// No description provided for @filterEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get filterEveryone;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get filterPeriod;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get filterSent;

  /// No description provided for @filterReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get filterReceived;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodMonth;

  /// No description provided for @periodDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String periodDays(int count);

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get periodYear;

  /// No description provided for @filterShowResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{Show 1 result} other{Show {count} results}}'**
  String filterShowResults(int count);

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay'**
  String get scanToPay;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code in the frame'**
  String get scanHint;

  /// No description provided for @scanMyCode.
  ///
  /// In en, this message translates to:
  /// **'My QR code'**
  String get scanMyCode;

  /// No description provided for @myQrCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy {handle}'**
  String myQrCopy(String handle);

  /// No description provided for @myQrAsked.
  ///
  /// In en, this message translates to:
  /// **'{amount} asked'**
  String myQrAsked(String amount);

  /// No description provided for @myQrShare.
  ///
  /// In en, this message translates to:
  /// **'Share QR code'**
  String get myQrShare;

  /// No description provided for @myQrShareText.
  ///
  /// In en, this message translates to:
  /// **'Pay me on Zawapay App: {handle}'**
  String myQrShareText(String handle);

  /// No description provided for @myQrShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing could not open'**
  String get myQrShareFailed;

  /// No description provided for @myQrRequestMoney.
  ///
  /// In en, this message translates to:
  /// **'Request money'**
  String get myQrRequestMoney;

  /// No description provided for @myQrEditRequest.
  ///
  /// In en, this message translates to:
  /// **'Change the request'**
  String get myQrEditRequest;

  /// No description provided for @myQrRequestAmount.
  ///
  /// In en, this message translates to:
  /// **'Request this amount'**
  String get myQrRequestAmount;

  /// No description provided for @myQrRemoveAmount.
  ///
  /// In en, this message translates to:
  /// **'Remove the amount'**
  String get myQrRemoveAmount;

  /// No description provided for @sendRequested.
  ///
  /// In en, this message translates to:
  /// **'Amount requested'**
  String get sendRequested;

  /// No description provided for @sendViaUssd.
  ///
  /// In en, this message translates to:
  /// **'USSD confirmation'**
  String get sendViaUssd;

  /// No description provided for @sendZawapayBalance.
  ///
  /// In en, this message translates to:
  /// **'Zawapay balance'**
  String get sendZawapayBalance;

  /// No description provided for @sendInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get sendInsufficient;

  /// No description provided for @sentStepBalance.
  ///
  /// In en, this message translates to:
  /// **'Paid with your Zawapay balance'**
  String get sentStepBalance;

  /// No description provided for @sentStepBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'Taken from your balance, no Mobile Money PIN.'**
  String get sentStepBalanceBody;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// No description provided for @scanUnknownCode.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a Zawapay App code'**
  String get scanUnknownCode;

  /// No description provided for @scanOwnCode.
  ///
  /// In en, this message translates to:
  /// **'This is your own QR code'**
  String get scanOwnCode;

  /// No description provided for @scanNoCodeInPhoto.
  ///
  /// In en, this message translates to:
  /// **'No QR code in this photo'**
  String get scanNoCodeInPhoto;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
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

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Try again.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'New code sent'**
  String get codeResent;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'This e-mail already has an account. Sign in.'**
  String get alreadyMember;

  /// No description provided for @notMemberYet.
  ///
  /// In en, this message translates to:
  /// **'This account is not on Zawapay App yet. Create your account with the same e-mail.'**
  String get notMemberYet;

  /// No description provided for @contactSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get contactSoon;

  /// No description provided for @socialJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Last step'**
  String get socialJoinTitle;

  /// No description provided for @socialJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who invited you to Zawapay App?'**
  String get socialJoinSubtitle;

  /// No description provided for @withdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw money'**
  String get withdrawTitle;

  /// No description provided for @withdrawTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get withdrawTo;

  /// No description provided for @withdrawToHelp.
  ///
  /// In en, this message translates to:
  /// **'Your receiving number'**
  String get withdrawToHelp;

  /// No description provided for @withdrawNoNumber.
  ///
  /// In en, this message translates to:
  /// **'Add a receiving number in Settings.'**
  String get withdrawNoNumber;

  /// No description provided for @withdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'You withdraw'**
  String get withdrawAmount;

  /// No description provided for @withdrawAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String withdrawAvailable(Object amount);

  /// No description provided for @withdrawAll.
  ///
  /// In en, this message translates to:
  /// **'Withdraw all'**
  String get withdrawAll;

  /// No description provided for @withdrawFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get withdrawFee;

  /// No description provided for @withdrawFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get withdrawFree;

  /// No description provided for @withdrawMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum {amount}'**
  String withdrawMinimum(Object amount);

  /// No description provided for @withdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount}'**
  String withdrawButton(Object amount);

  /// No description provided for @pinCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your PIN'**
  String get pinCreateTitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnterTitle;

  /// No description provided for @pinEnterBody.
  ///
  /// In en, this message translates to:
  /// **'To confirm this withdrawal.'**
  String get pinEnterBody;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two codes do not match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get pinWrong;

  /// No description provided for @pinForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get pinForgot;

  /// No description provided for @withdrawPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal in progress'**
  String get withdrawPendingTitle;

  /// No description provided for @withdrawStepSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to Mobile Money'**
  String get withdrawStepSent;

  /// No description provided for @withdrawStepSentBody.
  ///
  /// In en, this message translates to:
  /// **'pawaPay sends the money to your number.'**
  String get withdrawStepSentBody;

  /// No description provided for @withdrawStepReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get withdrawStepReceived;

  /// No description provided for @withdrawStepReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'The money arrives on {phone}.'**
  String withdrawStepReceivedBody(Object phone);

  /// No description provided for @withdrawReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get withdrawReceive;

  /// No description provided for @withdrawNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get withdrawNumber;

  /// No description provided for @sendWithdrawNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money number'**
  String get sendWithdrawNumberHint;

  /// No description provided for @sendWithdrawNumberNotFound.
  ///
  /// In en, this message translates to:
  /// **'This withdrawal number is not on any account.'**
  String get sendWithdrawNumberNotFound;

  /// No description provided for @sendUsernameNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account with this username.'**
  String get sendUsernameNotFound;

  /// No description provided for @sendOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'This is your own account.'**
  String get sendOwnAccount;

  /// No description provided for @sendReceivesOn.
  ///
  /// In en, this message translates to:
  /// **'Receives on {phone}'**
  String sendReceivesOn(Object phone);

  /// No description provided for @sendStraightToNumber.
  ///
  /// In en, this message translates to:
  /// **'The money goes straight to this number.'**
  String get sendStraightToNumber;

  /// No description provided for @sendCountryClosed.
  ///
  /// In en, this message translates to:
  /// **'Sending to this country is not available yet.'**
  String get sendCountryClosed;

  /// No description provided for @sendRate.
  ///
  /// In en, this message translates to:
  /// **'1 USD = {rate} {currency}'**
  String sendRate(String rate, String currency);

  /// No description provided for @sendLimits.
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max} {currency}.'**
  String sendLimits(String min, String max, String currency);

  /// No description provided for @sendValue.
  ///
  /// In en, this message translates to:
  /// **'Value in dollars'**
  String get sendValue;

  /// No description provided for @sendRateFrom.
  ///
  /// In en, this message translates to:
  /// **'1 {from} = {rate} {to}'**
  String sendRateFrom(String from, String rate, String to);

  /// No description provided for @withdrawYouReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive {amount} on your number.'**
  String withdrawYouReceive(String amount);

  /// No description provided for @earnPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} per month'**
  String earnPerMonth(String amount);

  /// No description provided for @earnPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount} per week'**
  String earnPerWeek(String amount);

  /// No description provided for @earnPerYear.
  ///
  /// In en, this message translates to:
  /// **'{amount} per year'**
  String earnPerYear(String amount);

  /// No description provided for @earnBigNote.
  ///
  /// In en, this message translates to:
  /// **'Real example: a team of {people} people, calculated with Zawapay\'s real percentages.'**
  String earnBigNote(String people);

  /// No description provided for @earnStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works, in 3 steps'**
  String get earnStepsTitle;

  /// No description provided for @earnStep1.
  ///
  /// In en, this message translates to:
  /// **'Share your sponsor invitation: it is your @.'**
  String get earnStep1;

  /// No description provided for @earnStep2.
  ///
  /// In en, this message translates to:
  /// **'Your people sign up for free and send money to their family, as usual.'**
  String get earnStep2;

  /// No description provided for @earnStep3.
  ///
  /// In en, this message translates to:
  /// **'On every transfer they make, you get a share. Automatically.'**
  String get earnStep3;

  /// No description provided for @earnPerSendTitle.
  ///
  /// In en, this message translates to:
  /// **'On every transfer of {amount}'**
  String earnPerSendTitle(String amount);

  /// No description provided for @earnFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee ({percent})'**
  String earnFee(String percent);

  /// No description provided for @earnPool.
  ///
  /// In en, this message translates to:
  /// **'Shared between sponsors and invitees ({percent} of the fee)'**
  String earnPool(String percent);

  /// No description provided for @earnWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who gets how much?'**
  String get earnWhoTitle;

  /// No description provided for @earnLevel1.
  ///
  /// In en, this message translates to:
  /// **'When your friend sends (level 1)'**
  String get earnLevel1;

  /// No description provided for @earnLevel2.
  ///
  /// In en, this message translates to:
  /// **'When your friend\'s friend sends (level 2)'**
  String get earnLevel2;

  /// No description provided for @earnLevel3.
  ///
  /// In en, this message translates to:
  /// **'The next level (level 3)'**
  String get earnLevel3;

  /// No description provided for @earnLevelSponsor.
  ///
  /// In en, this message translates to:
  /// **'When your sponsor sends'**
  String get earnLevelSponsor;

  /// No description provided for @earnYouGet.
  ///
  /// In en, this message translates to:
  /// **'you get {amount}'**
  String earnYouGet(String amount);

  /// No description provided for @earnExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple examples'**
  String get earnExamplesTitle;

  /// No description provided for @earnEx1.
  ///
  /// In en, this message translates to:
  /// **'Your friend sends {amount} to their family, once.'**
  String earnEx1(String amount);

  /// No description provided for @earnEx2.
  ///
  /// In en, this message translates to:
  /// **'They send {times} times a week.'**
  String earnEx2(String times);

  /// No description provided for @earnEx3.
  ///
  /// In en, this message translates to:
  /// **'They keep going for a month.'**
  String get earnEx3;

  /// No description provided for @earnEx4.
  ///
  /// In en, this message translates to:
  /// **'They keep going all year.'**
  String get earnEx4;

  /// No description provided for @earnTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Your team grows, so do your earnings'**
  String get earnTeamTitle;

  /// No description provided for @earnTeamIntro.
  ///
  /// In en, this message translates to:
  /// **'You invite {direct} friends. Each of them invites {each}. Everyone sends {amount}, {times} times a week.'**
  String earnTeamIntro(String direct, String each, String amount, String times);

  /// No description provided for @earnTeamLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}: {people} people ({percent})'**
  String earnTeamLevel(String level, String people, String percent);

  /// No description provided for @earnTeamTotal.
  ///
  /// In en, this message translates to:
  /// **'Your whole team: {people} people'**
  String earnTeamTotal(String people);

  /// No description provided for @earnMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money'**
  String get earnMoneyTitle;

  /// No description provided for @earnMoney1.
  ///
  /// In en, this message translates to:
  /// **'Your earnings land on your Zawapay balance, in dollars.'**
  String get earnMoney1;

  /// No description provided for @earnMoney2.
  ///
  /// In en, this message translates to:
  /// **'Withdraw them to your withdrawal number: dollars or francs in DR Congo, your country\'s currency elsewhere.'**
  String get earnMoney2;

  /// No description provided for @earnMoney3.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals from {amount}.'**
  String earnMoney3(String amount);

  /// No description provided for @earnMoneyFree.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals are free.'**
  String get earnMoneyFree;

  /// No description provided for @earnMoneyFee.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal fee: {percent}.'**
  String earnMoneyFee(String percent);

  /// No description provided for @earnFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get earnFaqTitle;

  /// No description provided for @earnQ1.
  ///
  /// In en, this message translates to:
  /// **'Do I have to pay to earn?'**
  String get earnQ1;

  /// No description provided for @earnA1.
  ///
  /// In en, this message translates to:
  /// **'No. Signing up and inviting are free.'**
  String get earnA1;

  /// No description provided for @earnQ2.
  ///
  /// In en, this message translates to:
  /// **'Do I have to sell anything?'**
  String get earnQ2;

  /// No description provided for @earnA2.
  ///
  /// In en, this message translates to:
  /// **'No. Your people send money to their family, as they already do. You get a share of the fee.'**
  String get earnA2;

  /// No description provided for @earnQ3.
  ///
  /// In en, this message translates to:
  /// **'When do I get my earnings?'**
  String get earnQ3;

  /// No description provided for @earnA3.
  ///
  /// In en, this message translates to:
  /// **'As soon as the money has reached the recipient.'**
  String get earnA3;

  /// No description provided for @earnQ4.
  ///
  /// In en, this message translates to:
  /// **'Does my share reduce the money sent to the family?'**
  String get earnQ4;

  /// No description provided for @earnA4.
  ///
  /// In en, this message translates to:
  /// **'No. Your share comes from Zawapay\'s fee, never from the money sent.'**
  String get earnA4;

  /// No description provided for @earnHonest.
  ///
  /// In en, this message translates to:
  /// **'These numbers use Zawapay\'s real percentages, updated automatically. The examples assume your team sends money regularly: your real earnings depend on their real transfers.'**
  String get earnHonest;

  /// No description provided for @earnShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get earnShareTitle;

  /// No description provided for @earnShareText.
  ///
  /// In en, this message translates to:
  /// **'Send your @ to your people. They type it in “Sponsor invitation” when they sign up.'**
  String get earnShareText;

  /// No description provided for @earnShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share my invitation'**
  String get earnShareButton;

  /// No description provided for @earnShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on Zawapay App to send money to your family. When you sign up, type my sponsor invitation: {handle}'**
  String earnShareMessage(String handle);

  /// No description provided for @earnLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The numbers could not be loaded. Pull the page down to try again.'**
  String get earnLoadFailed;

  /// No description provided for @commissionsOpen.
  ///
  /// In en, this message translates to:
  /// **'See where my earnings come from ›'**
  String get commissionsOpen;

  /// No description provided for @commissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commissions history'**
  String get commissionsTitle;

  /// No description provided for @commissionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get commissionsAvailable;

  /// No description provided for @commissionsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending: {amount}'**
  String commissionsPending(String amount);

  /// No description provided for @commissionsEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get commissionsEarned;

  /// No description provided for @commissionsWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Total withdrawn'**
  String get commissionsWithdrawn;

  /// No description provided for @commissionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every earning comes from a real transfer of your team. The percentage shown is exactly the one applied.'**
  String get commissionsIntro;

  /// No description provided for @commissionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No commission yet. They come as soon as someone in your team sends money.'**
  String get commissionsEmpty;

  /// No description provided for @commissionsInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite my people'**
  String get commissionsInvite;

  /// No description provided for @commissionsSent.
  ///
  /// In en, this message translates to:
  /// **'@{handle} sent {amount}'**
  String commissionsSent(String handle, String amount);

  /// No description provided for @commissionsUp1.
  ///
  /// In en, this message translates to:
  /// **'Your invitee (level 1)'**
  String get commissionsUp1;

  /// No description provided for @commissionsUp2.
  ///
  /// In en, this message translates to:
  /// **'Your invitee\'s invitee (level 2)'**
  String get commissionsUp2;

  /// No description provided for @commissionsUp3.
  ///
  /// In en, this message translates to:
  /// **'Your team, level 3'**
  String get commissionsUp3;

  /// No description provided for @commissionsDown1.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor'**
  String get commissionsDown1;

  /// No description provided for @commissionsDown2.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor\'s sponsor'**
  String get commissionsDown2;

  /// No description provided for @commissionsDown3.
  ///
  /// In en, this message translates to:
  /// **'Above, level 3'**
  String get commissionsDown3;

  /// No description provided for @commissionsShare.
  ///
  /// In en, this message translates to:
  /// **'{percent} of this transfer\'s commissions ({pool})'**
  String commissionsShare(String percent, String pool);

  /// No description provided for @commissionsShared.
  ///
  /// In en, this message translates to:
  /// **'{percent} shared between {count} people'**
  String commissionsShared(String percent, String count);

  /// No description provided for @commissionsStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get commissionsStatusAvailable;

  /// No description provided for @commissionsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get commissionsStatusPending;

  /// No description provided for @commissionsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled (transfer failed)'**
  String get commissionsStatusCancelled;

  /// No description provided for @commissionsWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal to your number'**
  String get commissionsWithdrawal;

  /// No description provided for @commissionsWithdrawalGot.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {phone}'**
  String commissionsWithdrawalGot(String amount, String phone);

  /// No description provided for @commissionsWithdrawalFee.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal fee'**
  String get commissionsWithdrawalFee;

  /// No description provided for @commissionsReturned.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal failed: money returned'**
  String get commissionsReturned;

  /// No description provided for @commissionsWdDone.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get commissionsWdDone;

  /// No description provided for @commissionsWdPending.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get commissionsWdPending;

  /// No description provided for @commissionsWdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get commissionsWdFailed;

  /// No description provided for @commissionsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The history could not be loaded. Pull the page down to try again.'**
  String get commissionsLoadFailed;

  /// No description provided for @commissionsRef.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get commissionsRef;

  /// No description provided for @commissionsSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get commissionsSentLabel;

  /// No description provided for @commissionsReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received by the recipient'**
  String get commissionsReceivedLabel;

  /// No description provided for @commissionsPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Commissions of this transfer'**
  String get commissionsPoolLabel;

  /// No description provided for @commissionsPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your percentage'**
  String get commissionsPercentLabel;

  /// No description provided for @pinSaved.
  ///
  /// In en, this message translates to:
  /// **'PIN saved.'**
  String get pinSaved;

  /// No description provided for @pinOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get pinOn;

  /// No description provided for @pinToCreate.
  ///
  /// In en, this message translates to:
  /// **'To create'**
  String get pinToCreate;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get devicesTitle;

  /// No description provided for @devicesIntro.
  ///
  /// In en, this message translates to:
  /// **'The phones signed in to your account. If you do not recognise a device, sign it out.'**
  String get devicesIntro;

  /// No description provided for @devicesThis.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get devicesThis;

  /// No description provided for @devicesSince.
  ///
  /// In en, this message translates to:
  /// **'Signed in since {date}'**
  String devicesSince(String date);

  /// No description provided for @devicesSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get devicesSignOut;

  /// No description provided for @devicesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign this device out? It will have to sign in again with your password.'**
  String get devicesConfirm;

  /// No description provided for @devicesDone.
  ///
  /// In en, this message translates to:
  /// **'Device signed out.'**
  String get devicesDone;

  /// No description provided for @devicesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get devicesCancel;

  /// No description provided for @devicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No other device.'**
  String get devicesEmpty;

  /// No description provided for @devicesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The devices could not be loaded. Pull the page down to try again.'**
  String get devicesLoadFailed;

  /// No description provided for @notifOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Zawapay App → Notifications on your phone.'**
  String get notifOpenFailed;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose the alerts you want to get.'**
  String get notifIntro;

  /// No description provided for @notifTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers sent and received'**
  String get notifTransfers;

  /// No description provided for @notifTransfersHelp.
  ///
  /// In en, this message translates to:
  /// **'“You received \$50”, “Your transfer arrived”.'**
  String get notifTransfersHelp;

  /// No description provided for @notifCommissions.
  ///
  /// In en, this message translates to:
  /// **'Commissions and withdrawals'**
  String get notifCommissions;

  /// No description provided for @notifCommissionsHelp.
  ///
  /// In en, this message translates to:
  /// **'“+\$0.78 commission”, “Withdrawal paid”.'**
  String get notifCommissionsHelp;

  /// No description provided for @notifNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get notifNews;

  /// No description provided for @notifNewsHelp.
  ///
  /// In en, this message translates to:
  /// **'New countries and new features of Zawapay App.'**
  String get notifNewsHelp;

  /// No description provided for @notifSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon: these alerts will come straight to your phone. Your choices are already saved.'**
  String get notifSoon;

  /// No description provided for @notifLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your choices could not be loaded. Pull the page down to try again.'**
  String get notifLoadFailed;

  /// No description provided for @kycTitle2.
  ///
  /// In en, this message translates to:
  /// **'Unlock your limit'**
  String get kycTitle2;

  /// No description provided for @kycToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {used} of {limit}'**
  String kycToday(String used, String limit);

  /// No description provided for @kycBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Send more than {limit} a day, with no limit.'**
  String kycBenefit1(String limit);

  /// No description provided for @kycBenefit2.
  ///
  /// In en, this message translates to:
  /// **'The blue “verified” badge next to your @.'**
  String get kycBenefit2;

  /// No description provided for @kycBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected: nobody can pretend to be you.'**
  String get kycBenefit3;

  /// No description provided for @kycHow.
  ///
  /// In en, this message translates to:
  /// **'It takes 2 minutes: a photo of your ID and a selfie, right here.'**
  String get kycHow;

  /// No description provided for @kycButton.
  ///
  /// In en, this message translates to:
  /// **'Verify my identity'**
  String get kycButton;

  /// No description provided for @kycDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get kycDoneTitle;

  /// No description provided for @kycDoneText.
  ///
  /// In en, this message translates to:
  /// **'Your limit is unlocked and your @ has the blue badge.'**
  String get kycDoneText;

  /// No description provided for @kycPending.
  ///
  /// In en, this message translates to:
  /// **'Verification in progress: the answer comes here, usually within minutes.'**
  String get kycPending;

  /// No description provided for @kycUnlimited.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get kycUnlimited;

  /// No description provided for @kycLimitValue.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String kycLimitValue(String used, String limit);

  /// No description provided for @earnSixTitle.
  ///
  /// In en, this message translates to:
  /// **'The 6 levels that earn you money'**
  String get earnSixTitle;

  /// No description provided for @earnSixIntro.
  ///
  /// In en, this message translates to:
  /// **'You earn on the transfers of the 3 levels below you AND the 3 levels above. Here is each level\'s share of a {amount} transfer:'**
  String earnSixIntro(String amount);

  /// No description provided for @earnSixAbove3.
  ///
  /// In en, this message translates to:
  /// **'Level 3 above'**
  String get earnSixAbove3;

  /// No description provided for @earnSixAbove2.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor\'s sponsor'**
  String get earnSixAbove2;

  /// No description provided for @earnSixAbove1.
  ///
  /// In en, this message translates to:
  /// **'Your sponsor'**
  String get earnSixAbove1;

  /// No description provided for @earnSixYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get earnSixYou;

  /// No description provided for @earnSixBelow1.
  ///
  /// In en, this message translates to:
  /// **'Your invitees'**
  String get earnSixBelow1;

  /// No description provided for @earnSixBelow2.
  ///
  /// In en, this message translates to:
  /// **'Your invitees\' invitees'**
  String get earnSixBelow2;

  /// No description provided for @earnSixBelow3.
  ///
  /// In en, this message translates to:
  /// **'Level 3 below'**
  String get earnSixBelow3;

  /// No description provided for @earnSixTotal.
  ///
  /// In en, this message translates to:
  /// **'Total shared: {percent} — always 100% of the transfer\'s commissions.'**
  String earnSixTotal(String percent);

  /// No description provided for @earnAboveTitle.
  ///
  /// In en, this message translates to:
  /// **'You also earn thanks to the people above you'**
  String get earnAboveTitle;

  /// No description provided for @earnAboveIntro.
  ///
  /// In en, this message translates to:
  /// **'When your sponsor (or the levels above) sends money, a share goes to their invitees. It is split equally between all the invitees of that level.'**
  String get earnAboveIntro;

  /// No description provided for @earnAbove1.
  ///
  /// In en, this message translates to:
  /// **'When your sponsor sends'**
  String get earnAbove1;

  /// No description provided for @earnAbove2.
  ///
  /// In en, this message translates to:
  /// **'When your sponsor\'s sponsor sends'**
  String get earnAbove2;

  /// No description provided for @earnAbove3.
  ///
  /// In en, this message translates to:
  /// **'When level 3 above sends'**
  String get earnAbove3;

  /// No description provided for @earnAboveShared.
  ///
  /// In en, this message translates to:
  /// **'{amount} shared between their invitees'**
  String earnAboveShared(String amount);

  /// No description provided for @earnAboveEach.
  ///
  /// In en, this message translates to:
  /// **'If there are {people}, each one gets {amount}'**
  String earnAboveEach(String people, String amount);

  /// No description provided for @earnWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where does the money of a {amount} transfer go?'**
  String earnWhereTitle(String amount);

  /// No description provided for @earnWhereReceived.
  ///
  /// In en, this message translates to:
  /// **'The family receives'**
  String get earnWhereReceived;

  /// No description provided for @earnWherePaid.
  ///
  /// In en, this message translates to:
  /// **'The sender pays'**
  String get earnWherePaid;

  /// No description provided for @earnWhereFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get earnWhereFee;

  /// No description provided for @earnWhereNetwork.
  ///
  /// In en, this message translates to:
  /// **'→ for sponsors and invitees'**
  String get earnWhereNetwork;

  /// No description provided for @earnWhereZawapay.
  ///
  /// In en, this message translates to:
  /// **'→ for Zawapay (Mobile Money, operators, running costs)'**
  String get earnWhereZawapay;

  /// No description provided for @earnWhereNote.
  ///
  /// In en, this message translates to:
  /// **'Your share only comes from the fee: the family always gets the full amount. An empty place (no sponsor or invitee yet) goes to Zawapay.'**
  String get earnWhereNote;

  /// No description provided for @earnProofTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I check it is true?'**
  String get earnProofTitle;

  /// No description provided for @earnProof.
  ///
  /// In en, this message translates to:
  /// **'Every earning appears in your “Commissions history” (tap your Zawapay balance on the home page): the transfer, the person, their level and the exact percentage applied. The percentages on this page are the ones really applied.'**
  String get earnProof;

  /// No description provided for @withdrawRate.
  ///
  /// In en, this message translates to:
  /// **'This week\'s rate: 1 USD = {rate} {currency}'**
  String withdrawRate(String rate, String currency);

  /// No description provided for @sendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get sendConfirm;

  /// No description provided for @sendIsThisThePerson.
  ///
  /// In en, this message translates to:
  /// **'Is this the right person?'**
  String get sendIsThisThePerson;

  /// No description provided for @receivePhoneTaken.
  ///
  /// In en, this message translates to:
  /// **'This number belongs to another account.'**
  String get receivePhoneTaken;

  /// No description provided for @phonesSaved.
  ///
  /// In en, this message translates to:
  /// **'Numbers saved'**
  String get phonesSaved;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Zawapay App?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and history stay safe. Sign in again with your e-mail or your @ and your password.'**
  String get signOutBody;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signInIdLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail or username'**
  String get signInIdLabel;

  /// No description provided for @signInIdHint.
  ///
  /// In en, this message translates to:
  /// **'E-mail or @username'**
  String get signInIdHint;

  /// No description provided for @languageIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageIntro;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get aboutTerms;

  /// No description provided for @aboutDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get aboutDeleteAccount;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfoTitle;

  /// No description provided for @handleLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get handleLabel;

  /// No description provided for @handleNeverChanges.
  ///
  /// In en, this message translates to:
  /// **'Never changes'**
  String get handleNeverChanges;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Information saved'**
  String get profileSaved;

  /// No description provided for @emailChanged.
  ///
  /// In en, this message translates to:
  /// **'E-mail address changed'**
  String get emailChanged;

  /// No description provided for @sentStepPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment declined or expired. Nothing was charged.'**
  String get sentStepPaymentFailed;

  /// No description provided for @sentStepPaymentDone.
  ///
  /// In en, this message translates to:
  /// **'Payment received.'**
  String get sentStepPaymentDone;

  /// No description provided for @sentStepPayoutDone.
  ///
  /// In en, this message translates to:
  /// **'Arrived on {handle}\'s Mobile Money.'**
  String sentStepPayoutDone(Object handle);

  /// No description provided for @sentStepPayoutFailed.
  ///
  /// In en, this message translates to:
  /// **'The payout failed. Our team is on it.'**
  String get sentStepPayoutFailed;

  /// No description provided for @sentStepConfirmDone.
  ///
  /// In en, this message translates to:
  /// **'{handle} confirmed receipt.'**
  String sentStepConfirmDone(Object handle);

  /// No description provided for @sentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer not completed'**
  String get sentFailedTitle;

  /// No description provided for @sentDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentDoneTitle;
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
