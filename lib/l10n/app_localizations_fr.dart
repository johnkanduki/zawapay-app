// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Zawapay App';

  @override
  String get welcomeTitle => 'Bienvenue';

  @override
  String get welcomeSubtitle => 'Votre pays et votre langue.';

  @override
  String get countryLabel => 'Pays';

  @override
  String get countryHint => 'Choisissez votre pays';

  @override
  String get languageLabel => 'Langue';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S’inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get legalPrefix => 'En continuant, vous acceptez nos ';

  @override
  String get legalTerms => 'conditions';

  @override
  String get legalAnd => ' et notre ';

  @override
  String get legalPrivacy => 'politique de confidentialité';

  @override
  String get authSubtitle => 'Vos transferts en toute sécurité';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Entrez votre email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get noAccountYet => 'Vous n’avez pas encore de compte ?';

  @override
  String get forgotPasswordLink => 'Mot de passe\noublié ?';

  @override
  String get contactSupportLink => 'Contacter le\nsupport';

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get firstNameHint => 'Prénom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get lastNameHint => 'Nom';

  @override
  String get sponsorInvitationLabel => 'Invitation parrain ou marraine';

  @override
  String get sponsorInvitationHint => 'identifiant parrain ou marraine';

  @override
  String get sponsorQuestion => 'Est-ce bien votre parrain ou marraine ?';

  @override
  String get sponsorConfirm => 'Confirmer';

  @override
  String sponsorConfirmed(String name) {
    return 'Invitation confirmée : $name';
  }

  @override
  String get sponsorChange => 'Modifier';

  @override
  String get passwordMinHint => '8 caractères minimum';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Retapez votre mot de passe';

  @override
  String get acceptPrefix => 'J’accepte les ';

  @override
  String get acceptTerms => 'conditions générales';

  @override
  String get continueButton => 'Continuer';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get numbersTitle => 'Votre numéro';

  @override
  String get numbersSubtitle => 'Pour payer et pour retirer.';

  @override
  String get paymentNumberLabel => 'Numéro de paiement';

  @override
  String get paymentNumberHelp => 'Reçoit les demandes de paiement (USSD).';

  @override
  String get sameNumberForWithdrawals => 'Retraits sur ce même numéro';

  @override
  String get receivingNumberLabel => 'Numéro de réception';

  @override
  String get receivingNumberHelp => 'Vos retraits arrivent ici.';

  @override
  String get phoneNumberHint => 'Numéro';

  @override
  String get pinLabel => 'Code PIN';

  @override
  String get pinHelp => '4 chiffres pour confirmer vos retraits.';

  @override
  String get confirmPinLabel => 'Confirmer le code PIN';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get searchCountryHint => 'Rechercher un pays';

  @override
  String get allCountries => 'Tous les pays';

  @override
  String get countryNotAvailableTitle => 'Pas encore dans ce pays';

  @override
  String get countryNotAvailableBody =>
      'Bientôt chez vous. Choisissez un pays de la liste.';

  @override
  String get chooseCountry => 'Choisir un pays';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordBody =>
      'Nous envoyons un code à 6 chiffres à votre email.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get codeNotReceived => 'Vous n’avez pas reçu le code ? ';

  @override
  String get resend => 'Renvoyer';

  @override
  String get enterCodeTitle => 'Entrez le code';

  @override
  String get codeSentTo => 'Code envoyé à';

  @override
  String get verify => 'Vérifier';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get newPasswordBody =>
      'Un mot de passe que vous n’utilisez nulle part ailleurs.';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get ruleMinLength => '8 caractères minimum';

  @override
  String get ruleUppercase => 'Une lettre majuscule';

  @override
  String get ruleLowercase => 'Une lettre minuscule';

  @override
  String get ruleDigits => 'Des chiffres';

  @override
  String get ruleSymbols => 'Des symboles (@, #, ! …)';

  @override
  String get strengthWeak => 'Faible';

  @override
  String get strengthMedium => 'Moyen';

  @override
  String get strengthStrong => 'Fort';

  @override
  String get save => 'Enregistrer';

  @override
  String get profilePhotoTitle => 'Votre photo de profil';

  @override
  String get profilePhotoSubtitle =>
      'Une vraie photo, prise avec la caméra frontale.';

  @override
  String get profilePhotoTapHint => 'Touchez le cercle';

  @override
  String get profilePhotoRetake => 'Reprendre la photo';

  @override
  String get finish => 'Terminer';

  @override
  String get faceCaptureTitle => 'Prenez votre photo';

  @override
  String get faceCaptureButton => 'Prendre la photo';

  @override
  String get faceHintNoFace => 'Placez votre visage dans le cercle';

  @override
  String get faceHintTooFar => 'Rapprochez-vous un peu';

  @override
  String get faceHintSeveral => 'Une seule personne à la fois';

  @override
  String get faceHintReady => 'Parfait, prenez la photo';

  @override
  String get cameraNotAvailable => 'Pas de caméra frontale sur cet appareil.';

  @override
  String get cameraAccessDenied => 'Autorisez la caméra dans les Réglages.';

  @override
  String get cameraFailed => 'La caméra n’a pas pu s’ouvrir.';

  @override
  String get homeHello => 'Bonjour';

  @override
  String balanceUpdatedAt(String time) {
    return 'Dernière mise à jour à $time';
  }

  @override
  String get balanceHide => 'Masquer le solde';

  @override
  String get balanceShow => 'Afficher le solde';

  @override
  String get homeSend => 'Envoyer';

  @override
  String get homeWithdraw => 'Retirer';

  @override
  String get homeActivity => 'Historique';

  @override
  String get homeHide => 'Masquer';

  @override
  String get homeShow => 'Afficher';

  @override
  String get homeNoTransfers => 'Aucun transfert pour l’instant.';

  @override
  String get homeSeeAllTransfers => 'Voir tout l’historique';

  @override
  String get statusSuccess => 'Réussi';

  @override
  String get statusPending => 'En cours';

  @override
  String get statusFailed => 'Échoué';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
      zero: 'aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count mois',
      one: 'il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabScan => 'Scanner';

  @override
  String get tabSettings => 'Réglages';

  @override
  String get kycTitle => 'Certifiez votre identifiant';

  @override
  String get kycSubtitle =>
      'Le badge bleu prouve que ce compte est bien le vôtre.';

  @override
  String get kycStepIdTitle => 'Pièce d’identité';

  @override
  String get kycStepIdBody => 'Carte d’électeur, passeport ou permis.';

  @override
  String get kycStepSelfieTitle => 'Selfie';

  @override
  String get kycStepSelfieBody => 'Votre visage, avec la caméra frontale.';

  @override
  String get kycStepReviewTitle => 'Vérification';

  @override
  String get kycStepReviewBody => 'Le badge apparaît dès la validation.';

  @override
  String get kycPrivacy => 'Vos documents servent seulement à vous vérifier.';

  @override
  String get kycStart => 'Commencer la vérification';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsEdit => 'Modifier';

  @override
  String get settingsNotCertified => 'Identifiant non certifié';

  @override
  String get settingsCertify => 'Certifier';

  @override
  String get settingsCertified => 'Identifiant certifié';

  @override
  String get settingsInvite => 'Inviter des amis';

  @override
  String get settingsInviteSubtitle => '3 niveaux au-dessus, 3 en dessous';

  @override
  String get settingsPhones => 'Numéros de téléphone';

  @override
  String get settingsPhonesHint => 'Paiement et retraits';

  @override
  String get settingsDailyLimit => 'Limite quotidienne';

  @override
  String settingsDailyLimitValue(String used, String limit) {
    return '$used sur $limit';
  }

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAppearanceAuto => 'Automatique';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsOn => 'Activées';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsPin => 'Code PIN';

  @override
  String get settingsDevices => 'Appareils connectés';

  @override
  String get settingsHelp => 'Support';

  @override
  String get settingsSupport => 'Contacter le support';

  @override
  String get settingsAbout => 'À propos de Zawapay App';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get inviteTitle => 'Invitez, gagnez ensemble';

  @override
  String get inviteSubtitle =>
      'Gagnez sur les transferts de 3 niveaux au-dessus et 3 en dessous.';

  @override
  String get inviteYourHandle => 'Votre invitation parrain ou marraine';

  @override
  String get inviteCopy => 'Copier';

  @override
  String get inviteCopied => 'Identifiant copié';

  @override
  String get inviteHowTitle => 'Comment ça marche';

  @override
  String get inviteAbove => 'Au-dessus de vous';

  @override
  String get inviteAbove3 => 'Le parrain du niveau 2';

  @override
  String get inviteAbove2 => 'Le parrain de votre parrain';

  @override
  String get inviteAbove1 => 'Votre parrain ou marraine';

  @override
  String get inviteYou => 'Vous';

  @override
  String get inviteBelow1 => 'Vos invités';

  @override
  String get inviteBelow2 => 'Leurs invités';

  @override
  String get inviteBelow3 => 'Le niveau suivant';

  @override
  String get inviteBelow => 'En dessous de vous';

  @override
  String get inviteChainNote =>
      'Ces 6 niveaux gagnent sur vos transferts, et vous sur les leurs.';

  @override
  String get inviteExampleTitle => 'Exemple';

  @override
  String get inviteExampleSent => 'Montant envoyé';

  @override
  String inviteExampleFees(String rate) {
    return 'Frais de service ($rate)';
  }

  @override
  String inviteExamplePool(String rate) {
    return 'Commissions ($rate des frais)';
  }

  @override
  String get inviteExampleNote => 'Taux donnés à titre d’exemple.';

  @override
  String get inviteRulesTitle => 'Les règles';

  @override
  String get inviteRuleFree => 'L’inscription est gratuite.';

  @override
  String get inviteRuleRealTransfers =>
      'Gains sur de vrais transferts uniquement.';

  @override
  String get inviteRuleConfirmed =>
      'Débloqué après la confirmation du destinataire.';

  @override
  String get inviteRuleFees => 'Pris sur les frais, jamais sur le montant.';

  @override
  String get sendTitle => 'Envoyer de l’argent';

  @override
  String get sendByUsername => 'Identifiant';

  @override
  String get sendByPhone => 'Numéro';

  @override
  String get sendUsernameHint => 'identifiant';

  @override
  String get sendPhoneHint => 'Numéro de téléphone';

  @override
  String get sendPhoneNotFound => 'Aucun compte avec ce numéro.';

  @override
  String sendRecents(int count) {
    return 'Récents ($count)';
  }

  @override
  String get sendFrom => 'Depuis';

  @override
  String get sendMobileMoney => 'Mobile Money';

  @override
  String get sendYouPay => 'Vous payez';

  @override
  String get sendReceives => 'Il reçoit';

  @override
  String get sendFee => 'Frais';

  @override
  String get sendFeePaidByYou => 'Payés par vous';

  @override
  String get sendPay => 'Payer';

  @override
  String sendPayAmount(String amount) {
    return 'Payer $amount';
  }

  @override
  String get sendNoteHint => 'Une note…';

  @override
  String get currencyUsd => 'Dollars';

  @override
  String get currencyCdf => 'Francs congolais';

  @override
  String get sentTitle => 'Envoi en cours';

  @override
  String get sentTo => 'pour';

  @override
  String get sentFee => 'Frais';

  @override
  String get sentNote => 'Note';

  @override
  String get sentReference => 'Référence';

  @override
  String get sentDate => 'Date';

  @override
  String get sentStepPayment => 'Paiement Mobile Money';

  @override
  String get sentStepPaymentBody => 'Validez avec votre code Mobile Money.';

  @override
  String get sentStepPayout => 'Envoi au destinataire';

  @override
  String sentStepPayoutBody(String handle) {
    return 'Vers le Mobile Money de $handle.';
  }

  @override
  String get sentStepConfirm => 'Confirmation';

  @override
  String sentStepConfirmBody(String handle) {
    return '$handle confirme la réception.';
  }

  @override
  String get sentBackHome => 'Retour à l’accueil';

  @override
  String get detailStatusTitle => 'Statut du transfert';

  @override
  String get detailRecipient => 'Destinataire';

  @override
  String get detailSender => 'Expéditeur';

  @override
  String detailSeeAllWith(String handle) {
    return 'Voir tout avec $handle';
  }

  @override
  String get detailAmountTitle => 'Montant';

  @override
  String get detailTransferAmount => 'Montant';

  @override
  String get detailFee => 'Frais';

  @override
  String get detailTotalPaid => 'Total payé';

  @override
  String get detailTotalReceived => 'Il reçoit';

  @override
  String get detailInfoTitle => 'Détails du transfert';

  @override
  String get detailSentOn => 'Date d’envoi';

  @override
  String get detailTransferId => 'ID de transfert';

  @override
  String get detailReferenceId => 'ID de référence';

  @override
  String get detailCopied => 'Copié';

  @override
  String get detailTryAgain => 'Réessayer';

  @override
  String get detailGetHelp => 'Contacter le support';

  @override
  String get detailStepSubmitted => 'Soumis';

  @override
  String get detailStepPaid => 'Paiement Mobile Money confirmé';

  @override
  String detailStepConfirmed(String handle) {
    return 'Reçu et confirmé par $handle';
  }

  @override
  String detailStepWaitingRecipient(String handle) {
    return '$handle doit confirmer';
  }

  @override
  String get detailStepWaitingYou => 'Confirmez la réception de cet argent';

  @override
  String get detailStepFailed =>
      'Le paiement n’a pas été approuvé à temps, ou un code PIN incorrect a été saisi. Réessayez.';

  @override
  String todayAt(String time) {
    return 'Aujourd’hui à $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Hier à $time';
  }

  @override
  String get contactTitle => 'Nous contacter';

  @override
  String get contactSapottiText => 'Le moyen le plus rapide de nous joindre';

  @override
  String get contactRecommended => 'Recommandé';

  @override
  String get contactEmailTitle => 'E-mail';

  @override
  String get contactEmailText => 'Écrivez à notre équipe support';

  @override
  String get contactReplyTime =>
      'Nous répondons généralement en moins d’une heure';

  @override
  String get appearanceIntro => 'Apparence de Zawapay App';

  @override
  String get appearanceAutoText => 'Suit le réglage de votre téléphone';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get historyFilters => 'Filtres';

  @override
  String get historyClear => 'Effacer';

  @override
  String historyResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get historyEmpty => 'Rien pour ces filtres.';

  @override
  String get filterSubtitle => 'Envoyés, reçus, par personne ou par date.';

  @override
  String get filterPerson => 'Personne';

  @override
  String get filterEveryone => 'Tout le monde';

  @override
  String get filterType => 'Type';

  @override
  String get filterStatus => 'Statut';

  @override
  String get filterPeriod => 'Période';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterSent => 'Envoyé';

  @override
  String get filterReceived => 'Reçu';

  @override
  String get periodAll => 'Toute la période';

  @override
  String get periodMonth => 'Ce mois';

  @override
  String periodDays(int count) {
    return '$count jours';
  }

  @override
  String get periodYear => '1 an';

  @override
  String filterShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voir $count résultats',
      one: 'Voir 1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get scanToPay => 'Scanner pour payer';

  @override
  String get scanHint => 'Placez le code QR dans le cadre';

  @override
  String get scanMyCode => 'Mon code QR';

  @override
  String myQrCopy(String handle) {
    return 'Copier $handle';
  }

  @override
  String myQrAsked(String amount) {
    return '$amount demandé';
  }

  @override
  String get myQrShare => 'Partager le code QR';

  @override
  String myQrShareText(String handle) {
    return 'Payez-moi sur Zawapay App : $handle';
  }

  @override
  String get myQrShareFailed => 'Le partage n’a pas pu s’ouvrir';

  @override
  String get myQrRequestMoney => 'Demander de l’argent';

  @override
  String get myQrEditRequest => 'Modifier la demande';

  @override
  String get myQrRequestAmount => 'Demander le montant';

  @override
  String get myQrRemoveAmount => 'Supprimer le montant';

  @override
  String get sendRequested => 'Montant demandé';

  @override
  String get sendViaUssd => 'Confirmation USSD';

  @override
  String get sendZawapayBalance => 'Solde Zawapay';

  @override
  String get sendInsufficient => 'Solde insuffisant';

  @override
  String get sentStepBalance => 'Payé avec votre solde Zawapay';

  @override
  String get sentStepBalanceBody =>
      'Débité de votre solde, sans code Mobile Money.';

  @override
  String get scanGallery => 'Galerie';

  @override
  String get scanUnknownCode => 'Ce code QR n’est pas un code Zawapay App';

  @override
  String get scanOwnCode => 'C’est votre propre code QR';

  @override
  String get scanNoCodeInPhoto => 'Aucun code QR dans cette photo';

  @override
  String get noConnectionTitle => 'Pas de connexion internet';

  @override
  String get noConnectionBody => 'Vérifiez votre connexion et réessayez';

  @override
  String get retry => 'Réessayer';

  @override
  String get countryCD => 'RD Congo';

  @override
  String get countryBJ => 'Bénin';

  @override
  String get countryCM => 'Cameroun';

  @override
  String get countryCG => 'Congo-Brazzaville';

  @override
  String get countryCI => 'Côte d’Ivoire';

  @override
  String get countryGA => 'Gabon';

  @override
  String get countrySN => 'Sénégal';

  @override
  String get countryKE => 'Kenya';

  @override
  String get countryUG => 'Ouganda';

  @override
  String get countrySL => 'Sierra Leone';

  @override
  String get countryZM => 'Zambie';

  @override
  String get countryRW => 'Rwanda';

  @override
  String get errorNetwork => 'Pas de connexion. Réessayez.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get codeResent => 'Nouveau code envoyé';

  @override
  String get passwordsDontMatch =>
      'Les deux mots de passe ne sont pas identiques';

  @override
  String get alreadyMember => 'Cet e-mail a déjà un compte. Connectez-vous.';

  @override
  String get notMemberYet =>
      'Ce compte n’est pas encore sur Zawapay App. Créez votre compte avec le même e-mail.';

  @override
  String get contactSoon => 'Bientôt disponible';

  @override
  String get socialJoinTitle => 'Dernière étape';

  @override
  String get socialJoinSubtitle => 'Qui vous a invité sur Zawapay App ?';

  @override
  String get withdrawTitle => 'Retirer de l’argent';

  @override
  String get withdrawTo => 'Vers';

  @override
  String get withdrawToHelp => 'Votre numéro de réception';

  @override
  String get withdrawNoNumber =>
      'Ajoutez un numéro de réception dans les Réglages.';

  @override
  String get withdrawAmount => 'Vous retirez';

  @override
  String withdrawAvailable(Object amount) {
    return 'Disponible : $amount';
  }

  @override
  String get withdrawAll => 'Tout retirer';

  @override
  String get withdrawFee => 'Frais';

  @override
  String get withdrawFree => 'Gratuit';

  @override
  String withdrawMinimum(Object amount) {
    return 'Minimum $amount';
  }

  @override
  String withdrawButton(Object amount) {
    return 'Retirer $amount';
  }

  @override
  String get pinCreateTitle => 'Créez votre code PIN';

  @override
  String get pinConfirmTitle => 'Confirmez votre code PIN';

  @override
  String get pinEnterTitle => 'Entrez votre code PIN';

  @override
  String get pinEnterBody => 'Pour confirmer ce retrait.';

  @override
  String get pinMismatch =>
      'Les deux codes ne sont pas identiques. Recommencez.';

  @override
  String get pinWrong => 'Code PIN incorrect.';

  @override
  String get pinForgot => 'Code PIN oublié ?';

  @override
  String get withdrawPendingTitle => 'Retrait en cours';

  @override
  String get withdrawStepSent => 'Envoyé à Mobile Money';

  @override
  String get withdrawStepSentBody =>
      'pawaPay envoie l’argent sur votre numéro.';

  @override
  String get withdrawStepReceived => 'Reçu';

  @override
  String withdrawStepReceivedBody(Object phone) {
    return 'L’argent arrive sur le $phone.';
  }

  @override
  String get withdrawReceive => 'Vous recevez';

  @override
  String get withdrawNumber => 'Numéro';

  @override
  String get sendWithdrawNumberHint => 'Numéro Mobile Money';

  @override
  String get sendWithdrawNumberNotFound =>
      'Ce numéro de retrait n’est enregistré sur aucun compte.';

  @override
  String get sendUsernameNotFound => 'Aucun compte avec cet identifiant.';

  @override
  String get sendOwnAccount => 'C’est votre propre compte.';

  @override
  String sendReceivesOn(Object phone) {
    return 'Reçoit sur $phone';
  }

  @override
  String get sendStraightToNumber =>
      'L’argent arrive directement sur ce numéro.';

  @override
  String get sendCountryClosed =>
      'L’envoi vers ce pays n’est pas encore disponible.';

  @override
  String sendRate(String rate, String currency) {
    return '1 USD = $rate $currency';
  }

  @override
  String sendLimits(String min, String max, String currency) {
    return 'Entre $min et $max $currency.';
  }

  @override
  String get sendValue => 'Valeur en dollars';

  @override
  String sendRateFrom(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String withdrawYouReceive(String amount) {
    return 'Vous recevez $amount sur votre numéro.';
  }

  @override
  String earnPerMonth(String amount) {
    return '$amount par mois';
  }

  @override
  String earnPerWeek(String amount) {
    return '$amount par semaine';
  }

  @override
  String earnPerYear(String amount) {
    return '$amount par an';
  }

  @override
  String earnBigNote(String people) {
    return 'Exemple réel : une équipe de $people personnes, calculé avec les vrais pourcentages de Zawapay.';
  }

  @override
  String get earnStepsTitle => 'Comment ça marche, en 3 étapes';

  @override
  String get earnStep1 =>
      'Partagez votre invitation parrain ou marraine : c’est votre @.';

  @override
  String get earnStep2 =>
      'Vos proches s’inscrivent gratuitement et envoient de l’argent à leur famille, comme d’habitude.';

  @override
  String get earnStep3 =>
      'À chacun de leurs envois, vous recevez une part. Automatiquement, sans rien faire.';

  @override
  String earnPerSendTitle(String amount) {
    return 'Sur chaque envoi de $amount';
  }

  @override
  String earnFee(String percent) {
    return 'Frais de l’envoi ($percent)';
  }

  @override
  String earnPool(String percent) {
    return 'Partagé entre parrains et filleuls ($percent des frais)';
  }

  @override
  String get earnWhoTitle => 'Qui reçoit combien ?';

  @override
  String get earnLevel1 => 'Quand votre ami envoie (niveau 1)';

  @override
  String get earnLevel2 => 'Quand l’ami de votre ami envoie (niveau 2)';

  @override
  String get earnLevel3 => 'Le niveau suivant (niveau 3)';

  @override
  String get earnLevelSponsor => 'Quand votre parrain ou marraine envoie';

  @override
  String earnYouGet(String amount) {
    return 'vous recevez $amount';
  }

  @override
  String get earnExamplesTitle => 'Des exemples simples';

  @override
  String earnEx1(String amount) {
    return 'Votre ami envoie $amount à sa famille, une seule fois.';
  }

  @override
  String earnEx2(String times) {
    return 'Il envoie $times fois par semaine.';
  }

  @override
  String get earnEx3 => 'Il continue pendant un mois.';

  @override
  String get earnEx4 => 'Il continue toute l’année.';

  @override
  String get earnTeamTitle => 'Votre équipe grandit, vos gains aussi';

  @override
  String earnTeamIntro(
    String direct,
    String each,
    String amount,
    String times,
  ) {
    return 'Vous invitez $direct amis. Chacun d’eux en invite $each. Chaque personne envoie $amount, $times fois par semaine.';
  }

  @override
  String earnTeamLevel(String level, String people, String percent) {
    return 'Niveau $level : $people personnes ($percent)';
  }

  @override
  String earnTeamTotal(String people) {
    return 'Toute votre équipe : $people personnes';
  }

  @override
  String get earnMoneyTitle => 'Votre argent';

  @override
  String get earnMoney1 =>
      'Vos gains arrivent sur votre solde Zawapay, en dollars.';

  @override
  String get earnMoney2 =>
      'Vous les retirez sur votre numéro de retrait : en dollars ou en francs en RD Congo, dans la monnaie de votre pays ailleurs.';

  @override
  String earnMoney3(String amount) {
    return 'Retrait possible dès $amount.';
  }

  @override
  String get earnMoneyFree => 'Le retrait est gratuit.';

  @override
  String earnMoneyFee(String percent) {
    return 'Frais de retrait : $percent.';
  }

  @override
  String get earnFaqTitle => 'Questions fréquentes';

  @override
  String get earnQ1 => 'Est-ce que je dois payer pour gagner ?';

  @override
  String get earnA1 => 'Non. L’inscription et l’invitation sont gratuites.';

  @override
  String get earnQ2 => 'Est-ce que je dois vendre quelque chose ?';

  @override
  String get earnA2 =>
      'Non. Vos proches envoient de l’argent à leur famille, comme ils le font déjà. Vous recevez une part des frais.';

  @override
  String get earnQ3 => 'Quand est-ce que je reçois mes gains ?';

  @override
  String get earnA3 => 'Dès que l’argent est bien arrivé chez le destinataire.';

  @override
  String get earnQ4 =>
      'Est-ce que ma part diminue l’argent envoyé à la famille ?';

  @override
  String get earnA4 =>
      'Non. Votre part vient des frais de Zawapay, jamais de l’argent envoyé.';

  @override
  String get earnHonest =>
      'Ces chiffres utilisent les vrais pourcentages de Zawapay, mis à jour automatiquement. Les exemples supposent que votre équipe envoie de l’argent régulièrement : vos gains réels dépendent de leurs envois réels.';

  @override
  String get earnShareTitle => 'Commencez maintenant';

  @override
  String get earnShareText =>
      'Envoyez votre @ à vos proches. Ils l’écrivent dans « Invitation parrain ou marraine » quand ils s’inscrivent.';

  @override
  String get earnShareButton => 'Partager mon invitation';

  @override
  String earnShareMessage(String handle) {
    return 'Rejoins-moi sur Zawapay App pour envoyer de l’argent à ta famille. À l’inscription, écris mon invitation parrain ou marraine : $handle';
  }

  @override
  String get earnLoadFailed =>
      'Impossible de charger les chiffres. Tirez la page vers le bas pour réessayer.';

  @override
  String get commissionsOpen => 'Voir d’où viennent mes gains ›';

  @override
  String get commissionsTitle => 'Historique des commissions';

  @override
  String get commissionsAvailable => 'Disponible';

  @override
  String commissionsPending(String amount) {
    return 'En attente : $amount';
  }

  @override
  String get commissionsEarned => 'Total gagné';

  @override
  String get commissionsWithdrawn => 'Total retiré';

  @override
  String get commissionsIntro =>
      'Chaque gain vient d’un vrai envoi de votre équipe. Le pourcentage affiché est exactement celui appliqué.';

  @override
  String get commissionsEmpty =>
      'Pas encore de commission. Elles arrivent dès qu’une personne de votre équipe envoie de l’argent.';

  @override
  String get commissionsInvite => 'Inviter mes proches';

  @override
  String commissionsSent(String handle, String amount) {
    return '@$handle a envoyé $amount';
  }

  @override
  String get commissionsUp1 => 'Votre invité (niveau 1)';

  @override
  String get commissionsUp2 => 'L’invité de votre invité (niveau 2)';

  @override
  String get commissionsUp3 => 'Votre équipe, niveau 3';

  @override
  String get commissionsDown1 => 'Votre parrain ou marraine';

  @override
  String get commissionsDown2 => 'Le parrain de votre parrain';

  @override
  String get commissionsDown3 => 'Au-dessus, niveau 3';

  @override
  String commissionsShare(String percent, String pool) {
    return '$percent des commissions de cet envoi ($pool)';
  }

  @override
  String commissionsShared(String percent, String count) {
    return '$percent partagés entre $count personnes';
  }

  @override
  String get commissionsStatusAvailable => 'Disponible';

  @override
  String get commissionsStatusPending => 'En attente de confirmation';

  @override
  String get commissionsStatusCancelled => 'Annulée (envoi échoué)';

  @override
  String get commissionsWithdrawal => 'Retrait vers votre numéro';

  @override
  String commissionsWithdrawalGot(String amount, String phone) {
    return '$amount sur $phone';
  }

  @override
  String get commissionsWithdrawalFee => 'Frais de retrait';

  @override
  String get commissionsReturned => 'Retrait échoué : argent rendu';

  @override
  String get commissionsWdDone => 'Versé';

  @override
  String get commissionsWdPending => 'En cours';

  @override
  String get commissionsWdFailed => 'Échoué';

  @override
  String get commissionsLoadFailed =>
      'Impossible de charger l’historique. Tirez la page vers le bas pour réessayer.';

  @override
  String get commissionsRef => 'Référence';

  @override
  String get commissionsSentLabel => 'Envoyé';

  @override
  String get commissionsReceivedLabel => 'Reçu par le destinataire';

  @override
  String get commissionsPoolLabel => 'Commissions de cet envoi';

  @override
  String get commissionsPercentLabel => 'Votre pourcentage';

  @override
  String get pinSaved => 'Code PIN enregistré.';

  @override
  String get pinOn => 'Activé';

  @override
  String get pinToCreate => 'À créer';

  @override
  String get devicesTitle => 'Appareils connectés';

  @override
  String get devicesIntro =>
      'Les téléphones connectés à votre compte. Si vous ne reconnaissez pas un appareil, déconnectez-le.';

  @override
  String get devicesThis => 'Cet appareil';

  @override
  String devicesSince(String date) {
    return 'Connecté depuis le $date';
  }

  @override
  String get devicesSignOut => 'Déconnecter';

  @override
  String get devicesConfirm =>
      'Déconnecter cet appareil ? Il devra se reconnecter avec votre mot de passe.';

  @override
  String get devicesDone => 'Appareil déconnecté.';

  @override
  String get devicesCancel => 'Annuler';

  @override
  String get devicesEmpty => 'Aucun autre appareil.';

  @override
  String get devicesLoadFailed =>
      'Impossible de charger les appareils. Tirez la page vers le bas pour réessayer.';

  @override
  String get notifOpenFailed =>
      'Ouvrez Réglages → Zawapay App → Notifications sur votre téléphone.';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifIntro => 'Choisissez les alertes que vous voulez recevoir.';

  @override
  String get notifTransfers => 'Envois et réceptions';

  @override
  String get notifTransfersHelp =>
      '« Vous avez reçu 50 \$ », « Votre envoi est arrivé ».';

  @override
  String get notifCommissions => 'Commissions et retraits';

  @override
  String get notifCommissionsHelp =>
      '« +0,78 \$ de commission », « Retrait versé ».';

  @override
  String get notifNews => 'Nouveautés';

  @override
  String get notifNewsHelp =>
      'Les nouveaux pays, les nouvelles fonctions de Zawapay App.';

  @override
  String get notifSoon =>
      'Bientôt : ces alertes arriveront directement sur votre téléphone. Vos choix sont déjà enregistrés.';

  @override
  String get notifLoadFailed =>
      'Impossible de charger vos choix. Tirez la page vers le bas pour réessayer.';

  @override
  String get kycTitle2 => 'Débloquez votre limite';

  @override
  String kycToday(String used, String limit) {
    return 'Aujourd’hui : $used sur $limit';
  }

  @override
  String kycBenefit1(String limit) {
    return 'Envoyez plus de $limit par jour, sans limite.';
  }

  @override
  String get kycBenefit2 => 'Le badge bleu « certifié » à côté de votre @.';

  @override
  String get kycBenefit3 =>
      'Votre compte est protégé : personne ne peut se faire passer pour vous.';

  @override
  String get kycHow =>
      'Ça prend 2 minutes : une photo de votre pièce d’identité et un selfie, directement ici.';

  @override
  String get kycButton => 'Vérifier mon identité';

  @override
  String get kycDoneTitle => 'Identité vérifiée';

  @override
  String get kycDoneText =>
      'Votre limite est débloquée et votre @ porte le badge bleu.';

  @override
  String get kycPending =>
      'Vérification en cours : vous recevrez la réponse ici, en général en quelques minutes.';

  @override
  String get kycUnlimited => 'Sans limite';

  @override
  String kycLimitValue(String used, String limit) {
    return '$used sur $limit';
  }

  @override
  String get earnSixTitle => 'Les 6 niveaux qui vous rapportent';

  @override
  String earnSixIntro(String amount) {
    return 'Vous gagnez sur les envois des 3 niveaux en dessous de vous ET des 3 niveaux au-dessus. Voici la part de chaque niveau sur un envoi de $amount :';
  }

  @override
  String get earnSixAbove3 => 'Niveau 3 au-dessus';

  @override
  String get earnSixAbove2 => 'Le parrain de votre parrain';

  @override
  String get earnSixAbove1 => 'Votre parrain ou marraine';

  @override
  String get earnSixYou => 'VOUS';

  @override
  String get earnSixBelow1 => 'Vos invités';

  @override
  String get earnSixBelow2 => 'Les invités de vos invités';

  @override
  String get earnSixBelow3 => 'Niveau 3 en dessous';

  @override
  String earnSixTotal(String percent) {
    return 'Total partagé : $percent — toujours 100 % des commissions de l’envoi.';
  }

  @override
  String get earnAboveTitle =>
      'Vous gagnez aussi grâce aux personnes au-dessus de vous';

  @override
  String get earnAboveIntro =>
      'Quand votre parrain (ou les niveaux au-dessus) envoie de l’argent, une part revient à ses invités. Elle est partagée à parts égales entre tous les invités de ce niveau.';

  @override
  String get earnAbove1 => 'Quand votre parrain ou marraine envoie';

  @override
  String get earnAbove2 => 'Quand le parrain de votre parrain envoie';

  @override
  String get earnAbove3 => 'Quand le niveau 3 au-dessus envoie';

  @override
  String earnAboveShared(String amount) {
    return '$amount partagés entre ses invités';
  }

  @override
  String earnAboveEach(String people, String amount) {
    return 'S’ils sont $people, chacun reçoit $amount';
  }

  @override
  String earnWhereTitle(String amount) {
    return 'Où va l’argent d’un envoi de $amount ?';
  }

  @override
  String get earnWhereReceived => 'La famille reçoit';

  @override
  String get earnWherePaid => 'L’expéditeur paie';

  @override
  String get earnWhereFee => 'Frais de l’envoi';

  @override
  String get earnWhereNetwork => '→ pour les parrains et filleuls';

  @override
  String get earnWhereZawapay =>
      '→ pour Zawapay (Mobile Money, opérateurs, fonctionnement)';

  @override
  String get earnWhereNote =>
      'Votre part vient uniquement des frais : la famille reçoit toujours la somme complète. Une place vide (pas encore de parrain ou d’invité) revient à Zawapay.';

  @override
  String get earnProofTitle => 'Comment vérifier que c’est vrai ?';

  @override
  String get earnProof =>
      'Chaque gain apparaît dans votre « Historique des commissions » (touchez votre solde Zawapay sur l’accueil) : l’envoi, la personne, son niveau et le pourcentage exact appliqué. Les pourcentages de cette page sont ceux réellement appliqués.';

  @override
  String withdrawRate(String rate, String currency) {
    return 'Taux de la semaine : 1 USD = $rate $currency';
  }

  @override
  String get pinResetTitle => 'Code reçu par e-mail';

  @override
  String pinResetBody(String email) {
    return 'Entrez le code envoyé à $email.';
  }

  @override
  String get pinNewTitle => 'Nouveau code PIN';

  @override
  String get pinNewBody => '4 chiffres, ni 1234 ni quatre chiffres identiques.';

  @override
  String get pinResetDone =>
      'Nouveau code PIN enregistré. Pour votre sécurité, les retraits seront possibles dans 24 heures.';

  @override
  String get pinChangeBody => 'Pour changer vos numéros.';

  @override
  String get pinCurrentTitle => 'Votre code PIN actuel';

  @override
  String get phoneCodeTitle => 'Code de vérification';

  @override
  String phoneCodeBody(String phone) {
    return 'Code envoyé au $phone — regardez votre WhatsApp, ou vos SMS si vous n’avez pas WhatsApp.';
  }

  @override
  String get phoneCodeResend => 'Renvoyer par SMS';

  @override
  String get phoneCodeResent => 'Code renvoyé par SMS.';

  @override
  String phoneCodeResendIn(String time) {
    return 'Renvoyer par SMS dans $time';
  }

  @override
  String get accountCreatedTitle => 'Compte créé !';

  @override
  String get accountCreatedBody =>
      'Votre compte Zawapay a été créé avec succès. Connectez-vous pour commencer à l’utiliser.';

  @override
  String get accountCreatedSignIn => 'Se connecter';

  @override
  String get sendConfirm => 'Confirmer';

  @override
  String get sendIsThisThePerson => 'Est-ce bien la personne ?';

  @override
  String get receivePhoneTaken => 'Ce numéro appartient à un autre compte.';

  @override
  String get phonesSaved => 'Numéros enregistrés';

  @override
  String get signOutTitle => 'Se déconnecter de Zawapay App ?';

  @override
  String get signOutBody =>
      'Votre compte et votre historique restent intacts. Reconnectez-vous avec votre e-mail ou votre @ et votre mot de passe.';

  @override
  String get signOutConfirm => 'Se déconnecter';

  @override
  String get cancel => 'Annuler';

  @override
  String get signInIdLabel => 'E-mail ou identifiant';

  @override
  String get signInIdHint => 'E-mail ou @identifiant';

  @override
  String get languageIntro => 'Sélectionnez votre langue préférée';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutPrivacy => 'Politique de confidentialité';

  @override
  String get aboutTerms => 'Conditions d’utilisation';

  @override
  String get aboutDeleteAccount => 'Supprimer le compte';

  @override
  String get aboutVersion => 'Version';

  @override
  String get personalInfoTitle => 'Informations personnelles';

  @override
  String get handleLabel => 'Identifiant';

  @override
  String get handleNeverChanges => 'Ne change jamais';

  @override
  String get profileSaved => 'Informations enregistrées';

  @override
  String get emailChanged => 'Adresse e-mail changée';

  @override
  String get sentStepPaymentFailed =>
      'Paiement refusé ou expiré. Rien n’a été débité.';

  @override
  String get sentStepPaymentDone => 'Paiement reçu.';

  @override
  String sentStepPayoutDone(Object handle) {
    return 'Arrivé sur le Mobile Money de $handle.';
  }

  @override
  String get sentStepPayoutFailed =>
      'Le versement a échoué. Notre équipe s’en occupe.';

  @override
  String sentStepConfirmDone(Object handle) {
    return '$handle a confirmé la réception.';
  }

  @override
  String get sentFailedTitle => 'Envoi non abouti';

  @override
  String get sentDoneTitle => 'Envoyé';
}
