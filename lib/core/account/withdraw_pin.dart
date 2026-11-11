import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The 4-digit withdrawal PIN, created at the first withdrawal.
///
/// For now it is kept only on this phone, in the Keychain / Keystore, as a
/// salted fingerprint (never the code itself). It moves to the server with
/// the real withdrawals.
class WithdrawPin {
  WithdrawPin({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'zawapay.withdraw_pin';
  final FlutterSecureStorage _storage;

  Future<bool> exists() async {
    try {
      return await _storage.read(key: _key) != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> create(String pin) async {
    final salt = base64Url.encode(
      List.generate(16, (_) => Random.secure().nextInt(256)),
    );
    await _storage.write(key: _key, value: '$salt.${_hash(salt, pin)}');
  }

  Future<bool> check(String pin) async {
    final saved = await _storage.read(key: _key);
    if (saved == null) return false;
    final dot = saved.indexOf('.');
    return _hash(saved.substring(0, dot), pin) == saved.substring(dot + 1);
  }

  Future<void> forget() => _storage.delete(key: _key);

  static String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}

final withdrawPin = WithdrawPin();
