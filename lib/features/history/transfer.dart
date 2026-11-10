import 'package:intl/intl.dart';

import '../send/recipient.dart';

/// Where a transfer stands.
///
/// A transfer is complete only once the Mobile Money payment is confirmed
/// AND the other person confirms it in the app.
enum TransferStatus { success, pending, failed }

/// One transfer of the history (sent or received).
class Transfer {
  const Transfer({
    required this.id,
    required this.reference,
    required this.other,
    required this.outgoing,
    required this.received,
    required this.fee,
    required this.currency,
    required this.status,
    required this.sentAt,
    this.paidAt,
    this.failedAt,
    this.confirmedAt,
  });

  final String id;
  final String reference;

  /// The other person: the recipient (sent) or the sender (received).
  final Recipient other;
  final bool outgoing;

  /// What the recipient gets, and the service fee on top.
  final double received;
  final double fee;
  final String currency;
  final TransferStatus status;

  final DateTime sentAt;

  /// Mobile Money payment confirmed.
  final DateTime? paidAt;

  /// Payment refused (not approved in time or wrong PIN).
  final DateTime? failedAt;

  /// Confirmed by the recipient: the transfer is complete.
  final DateTime? confirmedAt;

  /// What the sender paid: amount received + fee.
  double get paid => received + fee;

  int get daysAgo => DateTime.now().difference(sentAt).inDays;

  /// "-77,29 $" (sent) or "+2 000 FC" (received).
  String signedAmount(String locale) =>
      '${outgoing ? '-' : '+'}${formatMoney(received, currency, locale)}';
}

/// "77,29 $", "2 000 FC", "1 500 XOF": two decimals only when needed.
String formatMoney(double value, String currency, String locale) {
  final whole = value == value.roundToDouble();
  final number = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: whole ? 0 : 2,
  ).format(value);
  final symbol = switch (currency) {
    'USD' => '\$',
    'CDF' => 'FC',
    _ => currency,
  };
  return '$number $symbol';
}

DateTime _ago(int days, {int hours = 0, int minutes = 0}) => DateTime.now()
    .subtract(Duration(days: days, hours: hours, minutes: minutes));

/// Demo transfers, only for the UI. They will come from the Zawapay server.
final List<Transfer> demoTransfers = [
  Transfer(
    id: '526180a4c19e692553',
    reference: 'f42aa3b7e051d8f603',
    other: demoRecipients[0],
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
    other: demoRecipients[3],
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
    other: demoRecipients[0],
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
    other: demoRecipients[1],
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
    other: demoRecipients[2],
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
    other: demoRecipients[3],
    outgoing: true,
    received: 24.15,
    fee: 1.45,
    currency: 'USD',
    status: TransferStatus.failed,
    sentAt: _ago(75),
    failedAt: _ago(75),
  ),
];
