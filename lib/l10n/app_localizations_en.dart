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
  String get scanUnknownCode => 'This QR code is not a Zawapay App code';

  @override
  String get scanOwnCode => 'This is your own QR code';

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

  @override
  String get errorNetwork => 'No connection. Try again.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get codeResent => 'New code sent';

  @override
  String get passwordsDontMatch => 'The two passwords do not match';

  @override
  String get alreadyMember => 'This e-mail already has an account. Sign in.';

  @override
  String get notMemberYet =>
      'This account is not on Zawapay App yet. Create your account with the same e-mail.';

  @override
  String get contactSoon => 'Coming soon';

  @override
  String get socialJoinTitle => 'Last step';

  @override
  String get socialJoinSubtitle => 'Who invited you to Zawapay App?';

  @override
  String get withdrawTitle => 'Withdraw money';

  @override
  String get withdrawTo => 'To';

  @override
  String get withdrawToHelp => 'Your receiving number';

  @override
  String get withdrawNoNumber => 'Add a receiving number in Settings.';

  @override
  String get withdrawAmount => 'You withdraw';

  @override
  String withdrawAvailable(Object amount) {
    return 'Available: $amount';
  }

  @override
  String get withdrawAll => 'Withdraw all';

  @override
  String get withdrawFee => 'Fee';

  @override
  String get withdrawFree => 'Free';

  @override
  String withdrawMinimum(Object amount) {
    return 'Minimum $amount';
  }

  @override
  String withdrawButton(Object amount) {
    return 'Withdraw $amount';
  }

  @override
  String get pinCreateTitle => 'Create your PIN';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinEnterTitle => 'Enter your PIN';

  @override
  String get pinEnterBody => 'To confirm this withdrawal.';

  @override
  String get pinMismatch => 'The two codes do not match. Try again.';

  @override
  String get pinWrong => 'Wrong PIN.';

  @override
  String get pinForgot => 'Forgot your PIN?';

  @override
  String get withdrawPendingTitle => 'Withdrawal in progress';

  @override
  String get withdrawStepSent => 'Sent to Mobile Money';

  @override
  String get withdrawStepSentBody => 'pawaPay sends the money to your number.';

  @override
  String get withdrawStepReceived => 'Received';

  @override
  String withdrawStepReceivedBody(Object phone) {
    return 'The money arrives on $phone.';
  }

  @override
  String get withdrawReceive => 'You receive';

  @override
  String get withdrawNumber => 'Number';

  @override
  String get sendWithdrawNumberHint => 'Mobile Money number';

  @override
  String get sendWithdrawNumberNotFound =>
      'This withdrawal number is not on any account.';

  @override
  String get sendUsernameNotFound => 'No account with this username.';

  @override
  String get sendOwnAccount => 'This is your own account.';

  @override
  String sendReceivesOn(Object phone) {
    return 'Receives on $phone';
  }

  @override
  String get sendStraightToNumber => 'The money goes straight to this number.';

  @override
  String get sendCountryClosed =>
      'Sending to this country is not available yet.';

  @override
  String sendRate(String rate, String currency) {
    return '1 USD = $rate $currency';
  }

  @override
  String sendLimits(String min, String max, String currency) {
    return 'Between $min and $max $currency.';
  }

  @override
  String get sendValue => 'Value in dollars';

  @override
  String sendRateFrom(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String withdrawYouReceive(String amount) {
    return 'You receive $amount on your number.';
  }

  @override
  String earnPerMonth(String amount) {
    return '$amount per month';
  }

  @override
  String earnPerWeek(String amount) {
    return '$amount per week';
  }

  @override
  String earnPerYear(String amount) {
    return '$amount per year';
  }

  @override
  String earnBigNote(String people) {
    return 'Real example: a team of $people people, calculated with Zawapay\'s real percentages.';
  }

  @override
  String get earnStepsTitle => 'How it works, in 3 steps';

  @override
  String get earnStep1 => 'Share your sponsor invitation: it is your @.';

  @override
  String get earnStep2 =>
      'Your people sign up for free and send money to their family, as usual.';

  @override
  String get earnStep3 =>
      'On every transfer they make, you get a share. Automatically.';

  @override
  String earnPerSendTitle(String amount) {
    return 'On every transfer of $amount';
  }

  @override
  String earnFee(String percent) {
    return 'Transfer fee ($percent)';
  }

  @override
  String earnPool(String percent) {
    return 'Shared between sponsors and invitees ($percent of the fee)';
  }

  @override
  String get earnWhoTitle => 'Who gets how much?';

  @override
  String get earnLevel1 => 'When your friend sends (level 1)';

  @override
  String get earnLevel2 => 'When your friend\'s friend sends (level 2)';

  @override
  String get earnLevel3 => 'The next level (level 3)';

  @override
  String get earnLevelSponsor => 'When your sponsor sends';

  @override
  String earnYouGet(String amount) {
    return 'you get $amount';
  }

  @override
  String get earnExamplesTitle => 'Simple examples';

  @override
  String earnEx1(String amount) {
    return 'Your friend sends $amount to their family, once.';
  }

  @override
  String earnEx2(String times) {
    return 'They send $times times a week.';
  }

  @override
  String get earnEx3 => 'They keep going for a month.';

  @override
  String get earnEx4 => 'They keep going all year.';

  @override
  String get earnTeamTitle => 'Your team grows, so do your earnings';

  @override
  String earnTeamIntro(
    String direct,
    String each,
    String amount,
    String times,
  ) {
    return 'You invite $direct friends. Each of them invites $each. Everyone sends $amount, $times times a week.';
  }

  @override
  String earnTeamLevel(String level, String people, String percent) {
    return 'Level $level: $people people ($percent)';
  }

  @override
  String earnTeamTotal(String people) {
    return 'Your whole team: $people people';
  }

  @override
  String get earnMoneyTitle => 'Your money';

  @override
  String get earnMoney1 =>
      'Your earnings land on your Zawapay balance, in dollars.';

  @override
  String get earnMoney2 =>
      'Withdraw them to your withdrawal number: dollars or francs in DR Congo, your country\'s currency elsewhere.';

  @override
  String earnMoney3(String amount) {
    return 'Withdrawals from $amount.';
  }

  @override
  String get earnMoneyFree => 'Withdrawals are free.';

  @override
  String earnMoneyFee(String percent) {
    return 'Withdrawal fee: $percent.';
  }

  @override
  String get earnFaqTitle => 'Questions';

  @override
  String get earnQ1 => 'Do I have to pay to earn?';

  @override
  String get earnA1 => 'No. Signing up and inviting are free.';

  @override
  String get earnQ2 => 'Do I have to sell anything?';

  @override
  String get earnA2 =>
      'No. Your people send money to their family, as they already do. You get a share of the fee.';

  @override
  String get earnQ3 => 'When do I get my earnings?';

  @override
  String get earnA3 => 'As soon as the money has reached the recipient.';

  @override
  String get earnQ4 => 'Does my share reduce the money sent to the family?';

  @override
  String get earnA4 =>
      'No. Your share comes from Zawapay\'s fee, never from the money sent.';

  @override
  String get earnHonest =>
      'These numbers use Zawapay\'s real percentages, updated automatically. The examples assume your team sends money regularly: your real earnings depend on their real transfers.';

  @override
  String get earnShareTitle => 'Start now';

  @override
  String get earnShareText =>
      'Send your @ to your people. They type it in “Sponsor invitation” when they sign up.';

  @override
  String get earnShareButton => 'Share my invitation';

  @override
  String earnShareMessage(String handle) {
    return 'Join me on Zawapay App to send money to your family. When you sign up, type my sponsor invitation: $handle';
  }

  @override
  String get earnLoadFailed =>
      'The numbers could not be loaded. Pull the page down to try again.';

  @override
  String get commissionsOpen => 'See where my earnings come from ›';

  @override
  String get commissionsTitle => 'Commissions history';

  @override
  String get commissionsAvailable => 'Available';

  @override
  String commissionsPending(String amount) {
    return 'Pending: $amount';
  }

  @override
  String get commissionsEarned => 'Total earned';

  @override
  String get commissionsWithdrawn => 'Total withdrawn';

  @override
  String get commissionsIntro =>
      'Every earning comes from a real transfer of your team. The percentage shown is exactly the one applied.';

  @override
  String get commissionsEmpty =>
      'No commission yet. They come as soon as someone in your team sends money.';

  @override
  String get commissionsInvite => 'Invite my people';

  @override
  String commissionsSent(String handle, String amount) {
    return '@$handle sent $amount';
  }

  @override
  String get commissionsUp1 => 'Your invitee (level 1)';

  @override
  String get commissionsUp2 => 'Your invitee\'s invitee (level 2)';

  @override
  String get commissionsUp3 => 'Your team, level 3';

  @override
  String get commissionsDown1 => 'Your sponsor';

  @override
  String get commissionsDown2 => 'Your sponsor\'s sponsor';

  @override
  String get commissionsDown3 => 'Above, level 3';

  @override
  String commissionsShare(String percent, String pool) {
    return '$percent of this transfer\'s commissions ($pool)';
  }

  @override
  String commissionsShared(String percent, String count) {
    return '$percent shared between $count people';
  }

  @override
  String get commissionsStatusAvailable => 'Available';

  @override
  String get commissionsStatusPending => 'Waiting for confirmation';

  @override
  String get commissionsStatusCancelled => 'Cancelled (transfer failed)';

  @override
  String get commissionsWithdrawal => 'Withdrawal to your number';

  @override
  String commissionsWithdrawalGot(String amount, String phone) {
    return '$amount to $phone';
  }

  @override
  String get commissionsWithdrawalFee => 'Withdrawal fee';

  @override
  String get commissionsReturned => 'Withdrawal failed: money returned';

  @override
  String get commissionsWdDone => 'Paid';

  @override
  String get commissionsWdPending => 'In progress';

  @override
  String get commissionsWdFailed => 'Failed';

  @override
  String get commissionsLoadFailed =>
      'The history could not be loaded. Pull the page down to try again.';

  @override
  String get commissionsRef => 'Reference';

  @override
  String get commissionsSentLabel => 'Sent';

  @override
  String get commissionsReceivedLabel => 'Received by the recipient';

  @override
  String get commissionsPoolLabel => 'Commissions of this transfer';

  @override
  String get commissionsPercentLabel => 'Your percentage';

  @override
  String get pinSaved => 'PIN saved.';

  @override
  String get pinOn => 'On';

  @override
  String get pinToCreate => 'To create';

  @override
  String get devicesTitle => 'Connected devices';

  @override
  String get devicesIntro =>
      'The phones signed in to your account. If you do not recognise a device, sign it out.';

  @override
  String get devicesThis => 'This device';

  @override
  String devicesSince(String date) {
    return 'Signed in since $date';
  }

  @override
  String get devicesSignOut => 'Sign out';

  @override
  String get devicesConfirm =>
      'Sign this device out? It will have to sign in again with your password.';

  @override
  String get devicesDone => 'Device signed out.';

  @override
  String get devicesCancel => 'Cancel';

  @override
  String get devicesEmpty => 'No other device.';

  @override
  String get devicesLoadFailed =>
      'The devices could not be loaded. Pull the page down to try again.';

  @override
  String get notifOpenFailed =>
      'Open Settings → Zawapay App → Notifications on your phone.';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifIntro => 'Choose the alerts you want to get.';

  @override
  String get notifTransfers => 'Transfers sent and received';

  @override
  String get notifTransfersHelp =>
      '“You received \$50”, “Your transfer arrived”.';

  @override
  String get notifCommissions => 'Commissions and withdrawals';

  @override
  String get notifCommissionsHelp => '“+\$0.78 commission”, “Withdrawal paid”.';

  @override
  String get notifNews => 'News';

  @override
  String get notifNewsHelp => 'New countries and new features of Zawapay App.';

  @override
  String get notifSoon =>
      'Soon: these alerts will come straight to your phone. Your choices are already saved.';

  @override
  String get notifLoadFailed =>
      'Your choices could not be loaded. Pull the page down to try again.';

  @override
  String get kycTitle2 => 'Unlock your limit';

  @override
  String kycToday(String used, String limit) {
    return 'Today: $used of $limit';
  }

  @override
  String kycBenefit1(String limit) {
    return 'Send more than $limit a day, with no limit.';
  }

  @override
  String get kycBenefit2 => 'The blue “verified” badge next to your @.';

  @override
  String get kycBenefit3 =>
      'Your account is protected: nobody can pretend to be you.';

  @override
  String get kycHow =>
      'It takes 2 minutes: a photo of your ID and a selfie, right here.';

  @override
  String get kycButton => 'Verify my identity';

  @override
  String get kycDoneTitle => 'Identity verified';

  @override
  String get kycDoneText =>
      'Your limit is unlocked and your @ has the blue badge.';

  @override
  String get kycPending =>
      'Verification in progress: the answer comes here, usually within minutes.';

  @override
  String get kycUnlimited => 'No limit';

  @override
  String kycLimitValue(String used, String limit) {
    return '$used of $limit';
  }

  @override
  String get earnSixTitle => 'The 6 levels that earn you money';

  @override
  String earnSixIntro(String amount) {
    return 'You earn on the transfers of the 3 levels below you AND the 3 levels above. Here is each level\'s share of a $amount transfer:';
  }

  @override
  String get earnSixAbove3 => 'Level 3 above';

  @override
  String get earnSixAbove2 => 'Your sponsor\'s sponsor';

  @override
  String get earnSixAbove1 => 'Your sponsor';

  @override
  String get earnSixYou => 'YOU';

  @override
  String get earnSixBelow1 => 'Your invitees';

  @override
  String get earnSixBelow2 => 'Your invitees\' invitees';

  @override
  String get earnSixBelow3 => 'Level 3 below';

  @override
  String earnSixTotal(String percent) {
    return 'Total shared: $percent — always 100% of the transfer\'s commissions.';
  }

  @override
  String get earnAboveTitle => 'You also earn thanks to the people above you';

  @override
  String get earnAboveIntro =>
      'When your sponsor (or the levels above) sends money, a share goes to their invitees. It is split equally between all the invitees of that level.';

  @override
  String get earnAbove1 => 'When your sponsor sends';

  @override
  String get earnAbove2 => 'When your sponsor\'s sponsor sends';

  @override
  String get earnAbove3 => 'When level 3 above sends';

  @override
  String earnAboveShared(String amount) {
    return '$amount shared between their invitees';
  }

  @override
  String earnAboveEach(String people, String amount) {
    return 'If there are $people, each one gets $amount';
  }

  @override
  String earnWhereTitle(String amount) {
    return 'Where does the money of a $amount transfer go?';
  }

  @override
  String get earnWhereReceived => 'The family receives';

  @override
  String get earnWherePaid => 'The sender pays';

  @override
  String get earnWhereFee => 'Transfer fee';

  @override
  String get earnWhereNetwork => '→ for sponsors and invitees';

  @override
  String get earnWhereZawapay =>
      '→ for Zawapay (Mobile Money, operators, running costs)';

  @override
  String get earnWhereNote =>
      'Your share only comes from the fee: the family always gets the full amount. An empty place (no sponsor or invitee yet) goes to Zawapay.';

  @override
  String get earnProofTitle => 'How can I check it is true?';

  @override
  String get earnProof =>
      'Every earning appears in your “Commissions history” (tap your Zawapay balance on the home page): the transfer, the person, their level and the exact percentage applied. The percentages on this page are the ones really applied.';

  @override
  String withdrawRate(String rate, String currency) {
    return 'This week\'s rate: 1 USD = $rate $currency';
  }

  @override
  String get sendConfirm => 'Confirm';

  @override
  String get sendIsThisThePerson => 'Is this the right person?';

  @override
  String get receivePhoneTaken => 'This number belongs to another account.';

  @override
  String get phonesSaved => 'Numbers saved';

  @override
  String get signOutTitle => 'Sign out of Zawapay App?';

  @override
  String get signOutBody =>
      'Your account and history stay safe. Sign in again with your e-mail or your @ and your password.';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String get cancel => 'Cancel';

  @override
  String get signInIdLabel => 'E-mail or username';

  @override
  String get signInIdHint => 'E-mail or @username';

  @override
  String get languageIntro => 'Choose your language';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutTerms => 'Terms of use';

  @override
  String get aboutDeleteAccount => 'Delete account';

  @override
  String get aboutVersion => 'Version';

  @override
  String get personalInfoTitle => 'Personal information';

  @override
  String get handleLabel => 'Username';

  @override
  String get handleNeverChanges => 'Never changes';

  @override
  String get profileSaved => 'Information saved';

  @override
  String get emailChanged => 'E-mail address changed';

  @override
  String get sentStepPaymentFailed =>
      'Payment declined or expired. Nothing was charged.';

  @override
  String get sentStepPaymentDone => 'Payment received.';

  @override
  String sentStepPayoutDone(Object handle) {
    return 'Arrived on $handle\'s Mobile Money.';
  }

  @override
  String get sentStepPayoutFailed => 'The payout failed. Our team is on it.';

  @override
  String sentStepConfirmDone(Object handle) {
    return '$handle confirmed receipt.';
  }

  @override
  String get sentFailedTitle => 'Transfer not completed';

  @override
  String get sentDoneTitle => 'Sent';
}
