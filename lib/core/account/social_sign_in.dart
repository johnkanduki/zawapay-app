import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Google client IDs of Zawapay App (public, not secrets; also declared in
/// ominimum-api/src/apps.ts). Empty until they are created in Google Cloud
/// Console: the Google button then says "Coming soon".
const googleIosClientId =
    '1002693321533-bmbg04fh8m6b5vqh6fm9lj31u5a81itp.apps.googleusercontent.com';

/// "Web" client ID: Android needs it to receive the Google proof.
const googleServerClientId =
    '1002693321533-v58cof53jccctqp75a4j207g41jrj7s7.apps.googleusercontent.com';

bool get googleReady => Platform.isIOS
    ? googleIosClientId.isNotEmpty
    : googleServerClientId.isNotEmpty;

/// What Apple sends back, ready for `POST /v1/auth/apple`.
class AppleCredential {
  const AppleCredential({
    required this.identityToken,
    required this.rawNonce,
    this.firstName,
    this.lastName,
  });

  final String identityToken;
  final String rawNonce;

  /// Given by Apple at the very first sign-in only.
  final String? firstName;
  final String? lastName;
}

/// The phone's Google and Apple windows. null when the person closes them.
class SocialSignIn {
  Future<void>? _googleReady;

  Future<void> _initGoogle() =>
      _googleReady ??= GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? googleIosClientId : null,
        serverClientId: googleServerClientId.isEmpty
            ? null
            : googleServerClientId,
      );

  Future<String?> googleIdToken() async {
    await _initGoogle();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<AppleCredential?> apple() async {
    final rawNonce = _nonce();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Apple receives the fingerprint; the server compares it to rawNonce.
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final token = credential.identityToken;
      if (token == null) return null;
      return AppleCredential(
        identityToken: token,
        rawNonce: rawNonce,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    if (_googleReady == null) return;
    await GoogleSignIn.instance.signOut();
  }

  static String _nonce() {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

final socialSignIn = SocialSignIn();
