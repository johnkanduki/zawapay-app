import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show FileImage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Server error, or no network ([status] is null).
class AccountException implements Exception {
  const AccountException(this.message, {this.status, this.code});

  /// Server message (French), empty when the network failed.
  final String message;
  final int? status;

  /// Server error code, e.g. "account_exists", "invalid_code".
  final String? code;

  bool get isNetwork => status == null;
  bool get rejected => status == 400 || status == 401 || status == 403;

  @override
  String toString() => message;
}

/// A Zawapay App member as the server sends it.
class ZawapayMember {
  const ZawapayMember({
    required this.handle,
    required this.name,
    required this.country,
    this.certified = false,
    this.hasPhoto = false,
    this.sponsor,
    this.paymentPhone,
    this.receivePhone,
  });

  factory ZawapayMember.fromJson(Map<String, dynamic> json) => ZawapayMember(
    handle: json['handle'] as String? ?? '',
    name: json['name'] as String? ?? '',
    country: json['country'] as String? ?? '',
    certified: json['certified'] == true,
    hasPhoto: json['hasPhoto'] == true,
    sponsor: json['sponsor'] as String?,
    paymentPhone: json['paymentPhone'] as String?,
    receivePhone: json['receivePhone'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'handle': handle,
    'name': name,
    'country': country,
    'certified': certified,
    'hasPhoto': hasPhoto,
    'sponsor': sponsor,
    'paymentPhone': paymentPhone,
    'receivePhone': receivePhone,
  };

  /// Without the "@"; never changes.
  final String handle;
  final String name;

  /// ISO code, e.g. "CD".
  final String country;
  final bool certified;
  final bool hasPhoto;

  /// Only for my own account.
  final String? sponsor;
  final String? paymentPhone;
  final String? receivePhone;

  String get photoUrl => ZawapayAccount.photoUrlOf(handle);
}

/// What the home page needs: kept on the phone so the app opens at once,
/// even without network.
class SignedIn {
  const SignedIn({
    required this.member,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoPath,
  });

  final ZawapayMember member;
  final String firstName;
  final String lastName;
  final String email;

  /// Profile photo saved on the phone.
  final String? photoPath;
}

/// The OMINIMUM account server (https://api.ominimum.com), app "zawapay":
/// same sign-up and sign-in as Sapotti (e-mail + 6-digit code + password).
///
/// The session key stays in the Keychain / Keystore.
class ZawapayAccount {
  ZawapayAccount({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const app = 'zawapay';
  static final _base = Uri.parse('https://api.ominimum.com');
  static const _refreshKey = 'ominimum.refresh_token';
  static const _cacheKey = 'zawapay.signed_in';
  static const _timeout = Duration(seconds: 15);

  static String photoUrlOf(String handle) =>
      _base.resolve('/v1/zawapay/members/$handle/photo').toString();

  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _accessToken;
  DateTime? _accessExpiresAt;
  Map<String, dynamic> _user = const {};

  /// Profile photo saved on the phone; set when a download finishes, so the
  /// home page shows it without waiting for it.
  final photo = ValueNotifier<String?>(null);

  /// The signed-in member, kept current when the numbers change, so the
  /// home page and the settings show the new numbers at once.
  final current = ValueNotifier<SignedIn?>(null);

  /// Language of the e-mails ("fr" or "en").
  String lang = 'fr';

  // ---------- Sign-up ----------

  /// "Create my account": the server sends a 6-digit code by e-mail.
  Future<void> startSignUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _request(
    'POST',
    '/v1/auth/email/signup/start',
    body: {
      'app': app,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'lang': lang,
    },
  );

  /// The right code creates the account and opens the session.
  Future<void> verifySignUp(String email, String code) => _signIn(
    '/v1/auth/email/signup/verify',
    {'app': app, 'email': email, 'code': code},
  );

  /// Sign in with the e-mail, or with the @username.
  Future<void> signIn(String identifier, String password) {
    final value = identifier.trim();
    final isEmail = value.indexOf('@') > 0;
    return _signIn('/v1/auth/email/login', {
      'app': app,
      if (isEmail) 'email': value else 'handle': value,
      'password': password,
    });
  }

  /// "Continue with Google": the proof from Google opens (or creates) the
  /// OMINIMUM account.
  Future<void> signInWithGoogle(String idToken) =>
      _signIn('/v1/auth/google', {'app': app, 'idToken': idToken});

  /// "Continue with Apple". The name comes only at the very first sign-in.
  Future<void> signInWithApple({
    required String identityToken,
    required String rawNonce,
    String? firstName,
    String? lastName,
  }) => _signIn('/v1/auth/apple', {
    'app': app,
    'identityToken': identityToken,
    'rawNonce': rawNonce,
    if (firstName != null && firstName.trim().isNotEmpty)
      'firstName': firstName.trim(),
    if (lastName != null && lastName.trim().isNotEmpty)
      'lastName': lastName.trim(),
  });

  /// First and last name of the signed-in account ('' when unknown).
  String get firstName => _user['firstName'] as String? ?? '';
  String get lastName => _user['lastName'] as String? ?? '';

  // ---------- Forgotten password ----------

  Future<void> startReset(String email) => _request(
    'POST',
    '/v1/auth/email/reset/start',
    body: {'app': app, 'email': email, 'lang': lang},
  );

  /// The code → a 10-minute ticket for [completeReset].
  Future<String> verifyReset(String email, String code) async {
    final json = await _request(
      'POST',
      '/v1/auth/email/reset/verify',
      body: {'app': app, 'email': email, 'code': code},
    );
    return json['resetToken'] as String? ?? '';
  }

  /// The new password; signs in.
  Future<void> completeReset(String resetToken, String newPassword) =>
      _signIn('/v1/auth/email/reset/complete', {
        'app': app,
        'resetToken': resetToken,
        'newPassword': newPassword,
        'lang': lang,
      });

  // ---------- Zawapay App ----------

  /// Public: check a sponsor invitation, find who to send to. Null when the
  /// @ does not exist.
  Future<ZawapayMember?> findMember(String handle) async {
    try {
      final json = await _request(
        'GET',
        '/v1/zawapay/members/${Uri.encodeComponent(handle)}',
      );
      return ZawapayMember.fromJson(json['member'] as Map<String, dynamic>);
    } on AccountException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  /// Sign-up "Continue": true when this e-mail is already a Zawapay App
  /// member (then: "Sign in"). An OMINIMUM account (Sapotti…) that is not a
  /// member yet may sign up with the same password.
  Future<bool> isMemberEmail(String email) async {
    final json = await _request(
      'POST',
      '/v1/zawapay/email-check',
      body: {'email': email},
    );
    return json['member'] == true;
  }

  /// "Contact us" links, set in the admin dashboard (admin.zawapay.com):
  /// the support's Sapotti conversation and e-mail. Empty when not set.
  Future<({String sapottiUrl, String email})> supportLinks() async {
    final json = await _request('GET', '/v1/apps/$app/support');
    return (
      sapottiUrl: json['sapottiUrl'] as String? ?? '',
      email: json['supportEmail'] as String? ?? '',
    );
  }

  /// "Send" by number: the member whose WITHDRAWAL number this is (payment
  /// numbers are never searched). Null when no account has it.
  Future<ZawapayMember?> findByReceivePhone(String phone) async {
    try {
      final json = await _request(
        'GET',
        '/v1/zawapay/receivers?${Uri(queryParameters: {'phone': phone}).query}',
      );
      return ZawapayMember.fromJson(json['member'] as Map<String, dynamic>);
    } on AccountException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  /// Fees and commissions set in the admin dashboard (public).
  Future<Map<String, dynamic>> fetchRules() =>
      _request('GET', '/v1/zawapay/rules');

  /// Countries open to sends from RD Congo, with what the amount page needs
  /// ("Payer … $"); never balances or costs.
  Future<List<Map<String, dynamic>>> fetchDestinations() async =>
      ((await _authorized('GET', '/v1/zawapay/destinations'))['destinations']
              as List)
          .cast<Map<String, dynamic>>();

  /// My membership; null until I have joined.
  Future<ZawapayMember?> me() async {
    final m = (await _authorized('GET', '/v1/zawapay/me'))['member'];
    return m is Map<String, dynamic> ? ZawapayMember.fromJson(m) : null;
  }

  /// After sign-up: the sponsor (for ever), the country and the numbers.
  /// The @ is made by the server from the first and last name.
  Future<ZawapayMember> join({
    required String sponsor,
    required String country,
    String? paymentPhone,
    String? receivePhone,
    String? firstName,
    String? lastName,
  }) async => ZawapayMember.fromJson(
    (await _authorized(
          'POST',
          '/v1/zawapay/join',
          body: {
            'sponsor': sponsor,
            'country': country,
            'paymentPhone': ?paymentPhone,
            'receivePhone': ?receivePhone,
            'firstName': ?firstName,
            'lastName': ?lastName,
          },
        ))['member']
        as Map<String, dynamic>,
  );

  /// Settings → "Phone numbers": the payment number and the withdrawal
  /// number (where every transfer received arrives). A withdrawal number
  /// belongs to one account only.
  Future<ZawapayMember> savePhones({
    required String? paymentPhone,
    required String? receivePhone,
  }) async {
    final member = ZawapayMember.fromJson(
      (await _authorized(
            'PUT',
            '/v1/zawapay/me/phones',
            body: {'paymentPhone': paymentPhone, 'receivePhone': receivePhone},
          ))['member']
          as Map<String, dynamic>,
    );
    final now = current.value;
    if (now != null) {
      final updated = SignedIn(
        member: member,
        firstName: now.firstName,
        lastName: now.lastName,
        email: now.email,
        photoPath: photo.value ?? now.photoPath,
      );
      current.value = updated;
      await _save(updated, updated.photoPath);
    }
    return member;
  }

  // ---------- Transfers (real money, through zawapay.com) ----------

  /// "Pay": the server recomputes everything and sends the USSD request to
  /// the sender's PAYMENT number. [amount] is what the recipient receives.
  Future<Map<String, dynamic>> createTransfer({
    required String recipient,
    required String currency,
    required String amount,
    String? note,
  }) async =>
      (await _authorized(
            'POST',
            '/v1/zawapay/transfers',
            body: {
              'recipient': recipient,
              'currency': currency,
              'amount': amount,
              if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            },
          ))['transfer']
          as Map<String, dynamic>;

  /// Before "Pay": what the sender pays (in their own currency, fee
  /// included) for what the recipient receives. Nothing is created.
  Future<Map<String, dynamic>> quote({
    required String recipient,
    required String currency,
    required String amount,
  }) async =>
      (await _authorized(
            'POST',
            '/v1/zawapay/quote',
            body: {
              'recipient': recipient,
              'currency': currency,
              'amount': amount,
            },
          ))['quote']
          as Map<String, dynamic>;

  /// « Gagner ensemble » : the real percentages and the examples computed
  /// with them (texts and example hypotheses set in the admin dashboard).
  Future<Map<String, dynamic>> earnPage() async =>
      (await _authorized('GET', '/v1/zawapay/earn'))['earn']
          as Map<String, dynamic>;

  /// « Historique des commissions »: every line of my balance and where it
  /// comes from (transfer, person, level, real percentage), and withdrawals.
  Future<Map<String, dynamic>> commissionHistory() async =>
      (await _authorized('GET', '/v1/zawapay/me/commissions'))['history']
          as Map<String, dynamic>;

  /// My daily limit (null when verified) and what I sent today, in dollars.
  Future<Map<String, dynamic>> myLimit() async =>
      (await _authorized('GET', '/v1/zawapay/me/limit'))['limit']
          as Map<String, dynamic>;

  /// Opens an identity check at Didit: the address to show IN the app.
  Future<String> startKyc() async =>
      '${((await _authorized('POST', '/v1/zawapay/me/kyc'))['kyc'] as Map)['url']}';

  /// The alerts I want (transfers, commissions, news).
  Future<Map<String, dynamic>> notificationPrefs() async =>
      (await _authorized('GET', '/v1/zawapay/me/notifications'))['prefs']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> saveNotificationPrefs(
    Map<String, bool> prefs,
  ) async =>
      (await _authorized(
            'PUT',
            '/v1/zawapay/me/notifications',
            body: prefs,
          ))['prefs']
          as Map<String, dynamic>;

  /// « Appareils connectés »: my open sessions (this phone is marked).
  Future<List<Map<String, dynamic>>> devices() async =>
      ((await _authorized(
                'POST',
                '/v1/zawapay/me/devices',
                body: {'refreshToken': ?await _readToken()},
              ))['devices']
              as List)
          .cast<Map<String, dynamic>>();

  /// Signs another phone out (not this one: that is "Sign out").
  Future<void> revokeDevice(String id) async => _authorized(
    'POST',
    '/v1/zawapay/me/devices/$id/revoke',
    body: {'refreshToken': ?await _readToken()},
  );

  /// My commissions balance: one, in dollars (available and pending).
  Future<Map<String, dynamic>> myBalance() async =>
      (await _authorized('GET', '/v1/zawapay/me/balance'))['balance']
          as Map<String, dynamic>;

  /// Before a withdrawal: what I receive on my withdrawal number, in
  /// [currency] (RD Congo: USD or CDF), for [amount] dollars.
  Future<Map<String, dynamic>> quoteWithdrawal({
    required String amount,
    required String currency,
  }) async =>
      (await _authorized(
            'POST',
            '/v1/zawapay/withdrawals/quote',
            body: {'amount': amount, 'currency': currency},
          ))['quote']
          as Map<String, dynamic>;

  /// Withdraws [amount] dollars to my withdrawal number, paid in [currency].
  Future<Map<String, dynamic>> createWithdrawal({
    required String amount,
    required String currency,
  }) async =>
      (await _authorized(
            'POST',
            '/v1/zawapay/withdrawals',
            body: {'amount': amount, 'currency': currency},
          ))['withdrawal']
          as Map<String, dynamic>;

  /// All my transfers, sent and received, whatever their status (newest
  /// first, at most 100).
  Future<List<Map<String, dynamic>>> myTransfers() async =>
      ((await _authorized('GET', '/v1/zawapay/transfers'))['transfers'] as List)
          .cast<Map<String, dynamic>>();

  /// Where a transfer stands now (status from the server).
  Future<Map<String, dynamic>> transfer(String id) async =>
      (await _authorized('GET', '/v1/zawapay/transfers/$id'))['transfer']
          as Map<String, dynamic>;

  // ---------- Personal information ----------

  /// First and last name (the display name follows; the @ never changes).
  Future<void> saveName(String firstName, String lastName) async {
    final json = await _authorized(
      'PUT',
      '/v1/zawapay/me/name',
      body: {'firstName': firstName, 'lastName': lastName},
    );
    final member = ZawapayMember.fromJson(
      json['member'] as Map<String, dynamic>,
    );
    await updateSaved(member: member, firstName: firstName, lastName: lastName);
  }

  /// Changing the e-mail, step 1: a code goes to the CURRENT address.
  /// Returns that address.
  Future<String> startEmailChange(String newEmail) async =>
      (await _authorized(
            'POST',
            '/v1/me/email/start',
            body: {'newEmail': newEmail, 'lang': lang},
          ))['sentTo']
          as String? ??
      '';

  /// Step 2: the current address's code → a code goes to the NEW address.
  Future<String> confirmCurrentEmail(String code) async =>
      (await _authorized(
            'POST',
            '/v1/me/email/verify-current',
            body: {'code': code, 'lang': lang},
          ))['sentTo']
          as String? ??
      '';

  /// Step 3: the new address's code → the account's e-mail changes.
  Future<void> confirmNewEmail(String newEmail, String code) async {
    await _authorized(
      'POST',
      '/v1/me/email/verify-new',
      body: {'newEmail': newEmail, 'code': code},
    );
    await updateSaved(email: newEmail);
  }

  /// Keeps what the home page shows in step with a change.
  Future<void> updateSaved({
    ZawapayMember? member,
    String? firstName,
    String? lastName,
    String? email,
    String? photoPath,
  }) async {
    final now = current.value;
    if (now == null) return;
    final updated = SignedIn(
      member: member ?? now.member,
      firstName: firstName ?? now.firstName,
      lastName: lastName ?? now.lastName,
      email: email ?? now.email,
      photoPath: photoPath ?? photo.value ?? now.photoPath,
    );
    current.value = updated;
    await _save(updated, updated.photoPath);
  }

  /// New profile photo (front camera): sent, then shown at once.
  Future<void> changePhoto(String path) async {
    final member = await uploadPhoto(await File(path).readAsBytes());
    final file = await _photoFile();
    await File(path).copy(file.path);
    await FileImage(file).evict();
    // Same file name: cleared first, so the pages draw the new picture.
    photo.value = null;
    photo.value = file.path;
    await updateSaved(member: member, photoPath: file.path);
  }

  Future<ZawapayMember> uploadPhoto(Uint8List jpeg) async =>
      ZawapayMember.fromJson(
        (await _authorized('PUT', '/v1/zawapay/me/photo', raw: jpeg))['member']
            as Map<String, dynamic>,
      );

  // ---------- Session kept on the phone ----------

  /// At start-up: what was saved at the last sign-in (no network needed).
  Future<SignedIn?> saved() async {
    try {
      if (await _storage.read(key: _refreshKey) == null) return null;
      final raw = await _storage.read(key: _cacheKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final photo = json['photoPath'] as String?;
      final signedIn = SignedIn(
        member: ZawapayMember.fromJson(json['member'] as Map<String, dynamic>),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoPath: photo != null && File(photo).existsSync() ? photo : null,
      );
      current.value = signedIn;
      // Photo lost (app reinstalled): downloaded again in the background.
      if (signedIn.photoPath == null && signedIn.member.hasPhoto) {
        unawaited(_downloadPhoto(signedIn));
      }
      return signedIn;
    } catch (_) {
      return null;
    }
  }

  /// Saves what the home page needs, at once. [photo]: the photo just
  /// taken. Without it, the photo is downloaded in the background (the home
  /// page opens straight away with the initials, then shows it).
  Future<SignedIn> remember(ZawapayMember member, {String? photo}) async {
    String? photoPath;
    if (photo != null) {
      try {
        final file = await _photoFile();
        await File(photo).copy(file.path);
        photoPath = file.path;
      } catch (_) {
        // No photo: the initials are shown.
      }
    }
    this.photo.value = photoPath;
    final signedIn = SignedIn(
      member: member,
      firstName: _user['firstName'] as String? ?? '',
      lastName: _user['lastName'] as String? ?? '',
      email: _user['email'] as String? ?? '',
      photoPath: photoPath,
    );
    current.value = signedIn;
    await _save(signedIn, photoPath);
    if (photo == null && member.hasPhoto) {
      unawaited(_downloadPhoto(signedIn));
    }
    return signedIn;
  }

  Future<File> _photoFile() async => File(
    '${(await getApplicationSupportDirectory()).path}/profile_photo.jpg',
  );

  Future<void> _downloadPhoto(SignedIn signedIn) async {
    try {
      final response = await _client
          .get(Uri.parse(signedIn.member.photoUrl))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) return;
      final file = await _photoFile();
      await file.writeAsBytes(response.bodyBytes);
      // A fresh file name each time would be needed for Image.file to see a
      // new picture at the same path: evict the old one instead.
      await FileImage(file).evict();
      photo.value = file.path;
      // The latest member (the numbers may have changed meanwhile).
      await _save(current.value ?? signedIn, file.path);
    } catch (_) {
      // Tried again at the next sign-in.
    }
  }

  Future<void> _save(SignedIn signedIn, String? photoPath) => _storage.write(
    key: _cacheKey,
    value: jsonEncode({
      'member': signedIn.member.toJson(),
      'firstName': signedIn.firstName,
      'lastName': signedIn.lastName,
      'email': signedIn.email,
      'photoPath': photoPath,
    }),
  );

  /// Closes the session on the server; nothing stays on the phone, even if
  /// the server does not answer.
  Future<void> signOut() async {
    final token = await _readToken();
    try {
      if (token != null) {
        await _request(
          'POST',
          '/v1/auth/logout',
          body: {'refreshToken': token},
        );
      }
    } on AccountException {
      // Signed out on the phone anyway.
    } finally {
      _accessToken = null;
      _user = const {};
      photo.value = null;
      current.value = null;
      await _storage.delete(key: _refreshKey);
      await _storage.delete(key: _cacheKey);
    }
  }

  // ---------- Internals ----------

  static final String _userAgent = () {
    String os;
    try {
      final version =
          RegExp(r'[0-9]+(\.[0-9]+)*')
              .firstMatch(Platform.operatingSystemVersion)
              ?.group(0) ??
          '';
      os = Platform.isIOS
          ? 'iOS $version'
          : Platform.isAndroid
          ? 'Android $version'
          : Platform.operatingSystem;
    } catch (_) {
      os = 'web';
    }
    return 'Zawapay App/1.0.0 ($os)';
  }();

  Future<void> _signIn(String path, Map<String, dynamic> body) async =>
      _keepSession(await _request('POST', path, body: body));

  Future<void> _keepSession(Map<String, dynamic> json) async {
    final access = json['accessToken'];
    final refresh = json['refreshToken'];
    if (access is! String || refresh is! String) {
      throw const AccountException('');
    }
    await _storage.write(key: _refreshKey, value: refresh);
    _accessToken = access;
    final seconds = (json['accessTokenExpiresIn'] as num?)?.toInt() ?? 900;
    _accessExpiresAt = DateTime.now().add(Duration(seconds: seconds - 30));
    final user = json['user'];
    if (user is Map<String, dynamic>) _user = user;
  }

  Future<String?> _readToken() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    final token = await _readToken();
    if (token == null) throw const AccountException('', status: 401);
    await _keepSession(
      await _request('POST', '/v1/auth/refresh', body: {'refreshToken': token}),
    );
  }

  /// With the access token, renewed before it expires; a 401 renews it once
  /// and sends the request again.
  Future<Map<String, dynamic>> _authorized(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Uint8List? raw,
  }) async {
    final expiresAt = _accessExpiresAt;
    if (_accessToken == null ||
        (expiresAt != null && !DateTime.now().isBefore(expiresAt))) {
      await _refresh();
    }
    try {
      return await _request(
        method,
        path,
        body: body,
        raw: raw,
        token: _accessToken,
      );
    } on AccountException catch (e) {
      if (e.status != 401) rethrow;
      await _refresh();
      return _request(method, path, body: body, raw: raw, token: _accessToken);
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Uint8List? raw,
    String? token,
  }) async {
    final http.Response response;
    try {
      final request = http.Request(method, _base.resolve(path))
        ..headers.addAll({
          'Accept': 'application/json',
          // « Zawapay App/1.0.0 (iOS 27.0.1) » : shown in « Appareils connectés ».
          'User-Agent': _userAgent,
          if (body != null) 'Content-Type': 'application/json',
          if (raw != null) 'Content-Type': 'image/jpeg',
          if (token != null) 'Authorization': 'Bearer $token',
        });
      if (body != null) request.body = jsonEncode(body);
      if (raw != null) request.bodyBytes = raw;
      response = await http.Response.fromStream(
        await _client.send(request).timeout(_timeout),
      ).timeout(_timeout);
    } catch (_) {
      throw const AccountException('');
    }
    final json = _decode(response);
    if (response.statusCode >= 300) {
      final error = json['error'];
      final message = error is Map ? error['message'] : null;
      final code = error is Map ? error['code'] : null;
      throw AccountException(
        message is String ? message.trim() : '',
        status: response.statusCode,
        code: code is String ? code : null,
      );
    }
    return json;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json is Map<String, dynamic> ? json : const {};
    } catch (_) {
      return const {};
    }
  }
}

final zawapayAccount = ZawapayAccount();
