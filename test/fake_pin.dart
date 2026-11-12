import 'package:zawapay_app/core/account/withdraw_pin.dart';

/// A PIN kept in memory, answering like the server (tests only).
class FakePin extends WithdrawPin {
  FakePin([this.pin]);

  String? pin;
  final calls = <String>[];

  @override
  Future<bool> exists() async => pin != null;

  @override
  Future<String?> check(String value) async {
    calls.add('check $value');
    return value == pin ? null : 'Code PIN incorrect.';
  }

  @override
  Future<String?> create(String value) async {
    calls.add('create $value');
    pin = value;
    return null;
  }

  @override
  Future<String?> change(String current, String value) async {
    calls.add('change $current $value');
    if (current != pin) return 'Code PIN incorrect.';
    pin = value;
    return null;
  }

  @override
  Future<String?> startReset() async => 'john@exemple.test';

  @override
  Future<String?> confirmReset(String code, String value) async {
    if (code != '123456') return 'Code incorrect.';
    pin = value;
    return null;
  }
}
