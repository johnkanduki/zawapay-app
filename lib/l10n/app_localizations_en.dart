// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zawapay App';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Your country and language.';

  @override
  String get countryLabel => 'Country';

  @override
  String get countryHint => 'Choose your country';

  @override
  String get languageLabel => 'Language';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create an account';

  @override
  String get legalPrefix => 'By continuing, you accept our ';

  @override
  String get legalTerms => 'terms';

  @override
  String get legalAnd => ' and our ';

  @override
  String get legalPrivacy => 'privacy policy';

  @override
  String get authSubtitle => 'Your transfers, fully secure';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Password';

  @override
  String get noAccountYet => 'Don’t have an account yet?';

  @override
  String get forgotPasswordLink => 'Forgot\npassword?';

  @override
  String get contactSupportLink => 'Contact\nsupport';

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get sponsorInvitationLabel => 'Sponsor invitation';

  @override
  String get sponsorInvitationHint => 'your sponsor’s username';

  @override
  String get sponsorQuestion => 'Is this the person who invited you?';

  @override
  String get sponsorConfirm => 'Confirm';

  @override
  String sponsorConfirmed(String name) {
    return 'Invitation confirmed: $name';
  }

  @override
  String get sponsorChange => 'Change';

  @override
  String get passwordMinHint => '8 characters minimum';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Retype your password';

  @override
  String get acceptPrefix => 'I accept the ';

  @override
  String get acceptTerms => 'terms and conditions';

  @override
  String get continueButton => 'Continue';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get numbersTitle => 'Your number';

  @override
  String get numbersSubtitle => 'To pay and to withdraw.';

  @override
  String get paymentNumberLabel => 'Payment number';

  @override
  String get paymentNumberHelp => 'Gets the payment requests (USSD).';

  @override
  String get sameNumberForWithdrawals => 'Withdraw to this same number';

  @override
  String get receivingNumberLabel => 'Receiving number';

  @override
  String get receivingNumberHelp => 'Your withdrawals arrive here.';

  @override
  String get phoneNumberHint => 'Number';

  @override
  String get pinLabel => 'PIN code';

  @override
  String get pinHelp => '4 digits to confirm your withdrawals.';

  @override
  String get confirmPinLabel => 'Confirm PIN code';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get searchCountryHint => 'Search for a country';

  @override
  String get allCountries => 'All countries';

  @override
  String get countryNotAvailableTitle => 'Not in this country yet';

  @override
  String get countryNotAvailableBody =>
      'Coming soon. Pick a country from the list.';

  @override
  String get chooseCountry => 'Choose a country';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordBody => 'We send a 6-digit code to your email.';

  @override
  String get sendCode => 'Send code';

  @override
  String get codeNotReceived => 'Didn’t receive the code? ';

  @override
  String get resend => 'Resend';

  @override
  String get enterCodeTitle => 'Enter the code';

  @override
  String get codeSentTo => 'Code sent to';

  @override
  String get verify => 'Verify';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordBody => 'A password you use nowhere else.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get ruleMinLength => '8 characters minimum';

  @override
  String get ruleUppercase => 'An uppercase letter';

  @override
  String get ruleLowercase => 'A lowercase letter';

  @override
  String get ruleDigits => 'Numbers';

  @override
  String get ruleSymbols => 'Symbols (@, #, ! …)';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthMedium => 'Medium';

  @override
  String get strengthStrong => 'Strong';

  @override
  String get save => 'Save';

  @override
  String get profilePhotoTitle => 'Your profile photo';

  @override
  String get profilePhotoSubtitle =>
      'A real photo, taken with the front camera.';

  @override
  String get profilePhotoTapHint => 'Tap the circle';

  @override
  String get profilePhotoRetake => 'Retake the photo';

  @override
  String get finish => 'Finish';

  @override
  String get faceCaptureTitle => 'Take your photo';

  @override
  String get faceCaptureButton => 'Take the photo';

  @override
  String get faceHintNoFace => 'Place your face in the circle';

  @override
  String get faceHintTooFar => 'Come a little closer';

  @override
  String get faceHintSeveral => 'One person at a time';

  @override
  String get faceHintReady => 'Perfect, take the photo';

  @override
  String get cameraNotAvailable => 'No front camera on this device.';

  @override
  String get cameraAccessDenied => 'Allow the camera in Settings.';

  @override
  String get cameraFailed => 'The camera could not open.';

  @override
  String get homeHello => 'Hello';

  @override
  String balanceUpdatedAt(String time) {
    return 'Last updated at $time';
  }

  @override
  String get balanceHide => 'Hide balance';

  @override
  String get balanceShow => 'Show balance';

  @override
  String get homeSend => 'Send';

  @override
  String get homeWithdraw => 'Withdraw';

  @override
  String get homeActivity => 'History';

  @override
  String get homeHide => 'Hide';

  @override
  String get homeShow => 'Show';

  @override
  String get homeNoTransfers => 'No transfers yet.';

  @override
  String get homeSeeAllTransfers => 'See all history';

  @override
  String get statusSuccess => 'Successful';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabSettings => 'Settings';

  @override
  String get kycTitle => 'Certify your username';

  @override
  String get kycSubtitle => 'The blue badge proves this account is yours.';

  @override
  String get kycStepIdTitle => 'ID document';

  @override
  String get kycStepIdBody => 'Voter card, passport or licence.';

  @override
  String get kycStepSelfieTitle => 'Selfie';

  @override
  String get kycStepSelfieBody => 'Your face, with the front camera.';

  @override
  String get kycStepReviewTitle => 'Review';

  @override
  String get kycStepReviewBody => 'The badge shows once approved.';

  @override
  String get kycPrivacy => 'Your documents are only used to verify you.';

  @override
  String get kycStart => 'Start the check';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEdit => 'Edit';

  @override
  String get settingsNotCertified => 'Username not certified';

  @override
  String get settingsCertify => 'Certify';

  @override
  String get settingsCertified => 'Certified username';

  @override
  String get settingsInvite => 'Invite friends';

  @override
  String get settingsInviteSubtitle => '3 levels above, 3 below';

  @override
  String get settingsPhones => 'Phone numbers';

  @override
  String get settingsPhonesHint => 'Payments and withdrawals';

  @override
  String get settingsDailyLimit => 'Daily limit';

  @override
  String settingsDailyLimitValue(String used, String limit) {
    return '$used of $limit';
  }

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceAuto => 'Automatic';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsOn => 'On';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsPin => 'PIN code';

  @override
  String get settingsDevices => 'Connected devices';

  @override
  String get settingsHelp => 'Support';

  @override
  String get settingsSupport => 'Contact support';

  @override
  String get settingsAbout => 'About Zawapay App';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get inviteTitle => 'Invite, earn together';

  @override
  String get inviteSubtitle =>
      'Earn on the transfers of 3 levels above and 3 below.';

  @override
  String get inviteYourHandle => 'Your sponsor invitation';

  @override
  String get inviteCopy => 'Copy';

  @override
  String get inviteCopied => 'Username copied';

  @override
  String get inviteHowTitle => 'How it works';

  @override
  String get inviteAbove => 'Above you';

  @override
  String get inviteAbove3 => 'Level 2’s sponsor';

  @override
  String get inviteAbove2 => 'Your sponsor’s sponsor';

  @override
  String get inviteAbove1 => 'Your sponsor';

  @override
  String get inviteYou => 'You';

  @override
  String get inviteBelow1 => 'Your invitees';

  @override
  String get inviteBelow2 => 'Their invitees';

  @override
  String get inviteBelow3 => 'The next level';

  @override
  String get inviteBelow => 'Below you';

  @override
  String get inviteChainNote =>
      'These 6 levels earn on your transfers, and you on theirs.';

  @override
  String get inviteExampleTitle => 'Example';

  @override
  String get inviteExampleSent => 'Amount sent';

  @override
  String inviteExampleFees(String rate) {
    return 'Service fee ($rate)';
  }

  @override
  String inviteExamplePool(String rate) {
    return 'Commissions ($rate of the fee)';
  }

  @override
  String get inviteExampleNote => 'Rates shown as an example.';

  @override
  String get inviteRulesTitle => 'The rules';

  @override
  String get inviteRuleFree => 'Signing up is free.';

  @override
  String get inviteRuleRealTransfers => 'Earnings on real transfers only.';

  @override
  String get inviteRuleConfirmed => 'Released once the recipient confirms.';

  @override
  String get inviteRuleFees => 'Taken from the fee, never the amount.';

  @override
  String get sendTitle => 'Send money';

  @override
  String get sendByUsername => 'Username';

  @override
  String get sendByPhone => 'Number';

  @override
  String get sendUsernameHint => 'username';

  @override
  String get sendPhoneHint => 'Phone number';

  @override
  String get sendPhoneNotFound => 'No account with this number.';

  @override
  String sendRecents(int count) {
    return 'Recent ($count)';
  }

  @override
  String get sendFrom => 'From';

  @override
  String get sendMobileMoney => 'Mobile Money';

  @override
  String get sendYouPay => 'You pay';

  @override
  String get sendReceives => 'They receive';

  @override
  String get sendFee => 'Fee';

  @override
  String get sendFeePaidByYou => 'Paid by you';

  @override
  String get sendPay => 'Pay';

  @override
  String sendPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get sendNoteHint => 'A note…';

  @override
  String get currencyUsd => 'Dollars';

  @override
  String get currencyCdf => 'Congolese francs';

  @override
  String get sentTitle => 'On its way';

  @override
  String get sentTo => 'to';

  @override
  String get sentFee => 'Fee';

  @override
  String get sentNote => 'Note';

  @override
  String get sentReference => 'Reference';

  @override
  String get sentDate => 'Date';

  @override
  String get sentStepPayment => 'Mobile Money payment';

  @override
  String get sentStepPaymentBody => 'Approve with your Mobile Money PIN.';

  @override
  String get sentStepPayout => 'Sending to the recipient';

  @override
  String sentStepPayoutBody(String handle) {
    return 'To $handle’s Mobile Money.';
  }

  @override
  String get sentStepConfirm => 'Confirmation';

  @override
  String sentStepConfirmBody(String handle) {
    return '$handle confirms receipt.';
  }

  @override
  String get sentBackHome => 'Back to home';

  @override
  String get detailStatusTitle => 'Transfer status';

  @override
  String get detailRecipient => 'Recipient';

  @override
  String get detailSender => 'Sender';

  @override
  String detailSeeAllWith(String handle) {
    return 'See all with $handle';
  }

  @override
  String get detailAmountTitle => 'Amount';

  @override
  String get detailTransferAmount => 'Amount';

  @override
  String get detailFee => 'Fee';

  @override
  String get detailTotalPaid => 'Total paid';

  @override
  String get detailTotalReceived => 'They receive';

  @override
  String get detailInfoTitle => 'Transfer details';

  @override
  String get detailSentOn => 'Sent on';

  @override
  String get detailTransferId => 'Transfer ID';

  @override
  String get detailReferenceId => 'Reference ID';

  @override
  String get detailCopied => 'Copied';

  @override
  String get detailTryAgain => 'Try again';

  @override
  String get detailGetHelp => 'Contact support';

  @override
  String get detailStepSubmitted => 'Submitted';

  @override
  String get detailStepPaid => 'Mobile Money payment confirmed';

  @override
  String detailStepConfirmed(String handle) {
    return 'Received and confirmed by $handle';
  }

  @override
  String detailStepWaitingRecipient(String handle) {
    return '$handle must confirm';
  }

  @override
  String get detailStepWaitingYou => 'Confirm you received this money';

  @override
  String get detailStepFailed =>
      'The payment was not approved in time, or a wrong PIN was entered. Please try again.';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String get contactTitle => 'Contact us';

  @override
  String get contactSapottiText => 'The fastest way to reach us';

  @override
  String get contactRecommended => 'Recommended';

  @override
  String get contactEmailTitle => 'E-mail';

  @override
  String get contactEmailText => 'Write to our support team';

  @override
  String get contactReplyTime => 'We usually reply in less than an hour';

  @override
  String get appearanceIntro => 'Zawapay App appearance';

  @override
  String get appearanceAutoText => 'Follows your phone’s setting';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get historyFilters => 'Filters';

  @override
  String get historyClear => 'Clear';

  @override
  String historyResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get historyEmpty => 'Nothing for these filters.';

  @override
  String get filterSubtitle => 'Sent, received, by person or by date.';

  @override
  String get filterPerson => 'Person';

  @override
  String get filterEveryone => 'Everyone';

  @override
  String get filterType => 'Type';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterPeriod => 'Period';

  @override
  String get filterAll => 'All';

  @override
  String get filterSent => 'Sent';

  @override
  String get filterReceived => 'Received';

  @override
  String get periodAll => 'All time';

  @override
  String get periodMonth => 'This month';

  @override
  String periodDays(int count) {
    return '$count days';
  }

  @override
  String get periodYear => '1 year';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count results',
      one: 'Show 1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get scanToPay => 'Scan to pay';

  @override
  String get scanHint => 'Place the QR code in the frame';

  @override
  String get scanMyCode => 'My QR code';

  @override
  String myQrCopy(String handle) {
    return 'Copy $handle';
  }

  @override
  String myQrAsked(String amount) {
    return '$amount asked';
  }

  @override
  String get myQrShare => 'Share QR code';

  @override
  String myQrShareText(String handle) {
    return 'Pay me on Zawapay App: $handle';
  }

  @override
  String get myQrShareFailed => 'Sharing could not open';

  @override
  String get myQrRequestMoney => 'Request money';

  @override
  String get myQrEditRequest => 'Change the request';

  @override
  String get myQrRequestAmount => 'Request this amount';

  @override
  String get myQrRemoveAmount => 'Remove the amount';

  @override
  String get sendRequested => 'Amount requested';

  @override
  String get sendViaUssd => 'USSD confirmation';

  @override
  String get sendZawapayBalance => 'Zawapay balance';

  @override
  String get sendInsufficient => 'Insufficient balance';

  @override
  String get sentStepBalance => 'Paid with your Zawapay balance';

  @override
  String get sentStepBalanceBody =>
      'Taken from your balance, no Mobile Money PIN.';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanUnknownCode => 'This is not a Zawapay App code';

  @override
  String get scanNoCodeInPhoto => 'No QR code in this photo';

  @override
  String get noConnectionTitle => 'No internet connection';

  @override
  String get noConnectionBody => 'Check your connection and try again';

  @override
  String get retry => 'Try again';

  @override
  String get countryCD => 'DR Congo';

  @override
  String get countryBJ => 'Benin';

  @override
  String get countryCM => 'Cameroon';

  @override
  String get countryCG => 'Congo-Brazzaville';

  @override
  String get countryCI => 'Côte d’Ivoire';

  @override
  String get countryGA => 'Gabon';

  @override
  String get countrySN => 'Senegal';

  @override
  String get countryKE => 'Kenya';

  @override
  String get countryUG => 'Uganda';

  @override
  String get countrySL => 'Sierra Leone';

  @override
  String get countryZM => 'Zambia';

  @override
  String get countryRW => 'Rwanda';
}
