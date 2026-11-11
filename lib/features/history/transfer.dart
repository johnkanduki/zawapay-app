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
