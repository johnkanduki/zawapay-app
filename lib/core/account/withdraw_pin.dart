import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'zawapay_account.dart';

/// The 4-digit PIN, checked by the SERVER (since 12/11/2026): needed to
/// withdraw and to change numbers. The server counts wrong attempts (5 →
/// blocked 15 minutes) and never keeps the code itself. Each call answers
/// null when it worked, otherwise the message to show.
class WithdrawPin {
  const WithdrawPin();

  Future<String?> _try(Future<void> Function() call) async {
    try {
      await call();
      return null;
    } on AccountException catch (e) {
      return e.message.isEmpty ? 'Pas de connexion internet.' : e.message;
    }
  }

  Future<bool> exists() async {
    try {
      return await zawapayAccount.pinExists();
    } catch (_) {
      return true; // offline: ask for the PIN, the server decides
    }
  }

  Future<String?> check(String pin) => _try(() => zawapayAccount.checkPin(pin));
  Future<String?> create(String pin) => _try(() => zawapayAccount.setPin(pin));
  Future<String?> change(String current, String pin) =>
      _try(() => zawapayAccount.setPin(pin, currentPin: current));

  /// « Code PIN oublié »: sends a code by e-mail; the address, or null.
  Future<String?> startReset() async {
    try {
      return await zawapayAccount.startPinReset();
    } catch (_) {
      return null;
    }
  }

  Future<String?> confirmReset(String code, String pin) =>
      _try(() => zawapayAccount.confirmPinReset(code, pin));

  /// The old PIN kept on the phone (before 12/11/2026) is removed.
  Future<void> forget() async {
    try {
      await const FlutterSecureStorage().delete(key: 'zawapay.withdraw_pin');
    } catch (_) {}
  }
}

/// Tests replace it with a fake one.
WithdrawPin withdrawPin = const WithdrawPin();
