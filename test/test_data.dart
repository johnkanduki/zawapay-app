// Test-only accounts and transfers. They live in test/ and are never part
// of the app: the app itself starts with no account at all.
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/auth/widgets/sponsor_invitation_field.dart';
import 'package:zawapay_app/features/history/transfer.dart';
import 'package:zawapay_app/features/send/recipient.dart';

const List<Recipient> testAccounts = [
  Recipient(
    username: 'zawapay',
    fullName: 'Zawapay App',
    countryCode: 'CD',
    phone: '975135801',
    certified: true,
  ),
  Recipient(
    username: 'amina',
    fullName: 'Amina Diallo',
    countryCode: 'SN',
    phone: '771234567',
    certified: true,
  ),
  Recipient(
    username: 'kofi.mensah',
    fullName: 'Kofi Mensah',
    countryCode: 'CI',
    phone: '0701020304',
  ),
  Recipient(
    username: 'mireille.k',
    fullName: 'Mireille Kabeya',
    countryCode: 'CD',
    phone: '812345678',
  ),
];

Country _country(String iso) =>
    supportedCountries.firstWhere((c) => c.isoCode == iso);

DateTime _ago(int days, {int hours = 0, int minutes = 0}) => DateTime.now()
    .subtract(Duration(days: days, hours: hours, minutes: minutes));

final List<Transfer> testTransfers = [
  Transfer(
    id: '526180a4c19e692553',
    reference: 'f42aa3b7e051d8f603',
    other: testAccounts[0],
    outgoing: true,
    received: 77.29,
    fee: 4.64,
    currency: 'USD',
    status: TransferStatus.success,
    sentAt: _ago(1, minutes: 20),
    paidAt: _ago(1, minutes: 19),
    confirmedAt: _ago(1),
  ),
  Transfer(
    id: '7d02be33a1f4c0917e',
    reference: '0c9e41d2b87a33e5aa',
    other: testAccounts[3],
    outgoing: false,
    received: 2000,
    fee: 120,
    currency: 'CDF',
    status: TransferStatus.pending,
    sentAt: _ago(21),
    paidAt: _ago(21),
  ),
  Transfer(
    id: 'ea49e7f0d2c614328e0',
    reference: '813e75a9b04c1ce0ffa',
    other: testAccounts[0],
    outgoing: true,
    received: 134.63,
    fee: 8.08,
    currency: 'USD',
    status: TransferStatus.failed,
    sentAt: _ago(60, hours: 1),
    failedAt: _ago(60),
  ),
  Transfer(
    id: '91c3e5a0bb24f7d611',
    reference: '5fa20c7d94e1b8a3c2',
    other: testAccounts[1],
    outgoing: true,
    received: 50,
    fee: 3,
    currency: 'USD',
    status: TransferStatus.success,
    sentAt: _ago(64),
    paidAt: _ago(64),
    confirmedAt: _ago(63),
  ),
  Transfer(
    id: '3b7f0e2a6c59d1e84a',
    reference: 'c18d47e2a0f93b6d55',
    other: testAccounts[2],
    outgoing: false,
    received: 15000,
    fee: 900,
    currency: 'CDF',
    status: TransferStatus.success,
    sentAt: _ago(70),
    paidAt: _ago(70),
    confirmedAt: _ago(70),
  ),
  Transfer(
    id: 'e05a9c13d7f2b6408c',
    reference: '7a2e5b0c91d4f3e86b',
    other: testAccounts[3],
    outgoing: true,
    received: 24.15,
    fee: 1.45,
    currency: 'USD',
    status: TransferStatus.failed,
    sentAt: _ago(75),
    failedAt: _ago(75),
  ),
];

/// Fills the app's account lists with the test accounts (tests only).
void useTestAccounts() {
  knownAccounts
    ..clear()
    ..addAll(testAccounts);
  knownSponsors
    ..clear()
    ..addAll([
      Sponsor(
        username: 'zawapay',
        fullName: 'Zawapay App',
        country: _country('CD'),
      ),
      Sponsor(
        username: 'amina',
        fullName: 'Amina Diallo',
        country: _country('SN'),
      ),
    ]);
}
