import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/zawapay_account.dart';
import 'package:zawapay_app/features/send/recipient.dart';

void main() {
  test('A member is reached in the country of their WITHDRAWAL number', () {
    // Signed up in RD Congo, withdrawal number now in Uganda.
    final r = Recipient.fromMember(
      const ZawapayMember(
        handle: 'johnkanduki',
        name: 'John Kanduki',
        country: 'CD',
        receivePhone: '+256771234567',
      ),
    );
    expect(r.countryCode, 'UG');
    expect(r.phone, '771234567');
    expect(r.fullPhone, '+256 771 234 567');

    // Still in RD Congo: unchanged.
    final c = Recipient.fromMember(
      const ZawapayMember(
        handle: 'amina',
        name: 'Amina',
        country: 'CD',
        receivePhone: '+243975135801',
      ),
    );
    expect(c.countryCode, 'CD');
  });
}
