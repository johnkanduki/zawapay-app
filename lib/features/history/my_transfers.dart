import 'package:flutter/foundation.dart';

import '../../core/account/zawapay_account.dart';
import '../../core/countries/country.dart';
import '../send/recipient.dart';
import 'transfer.dart';

/// The signed-in member's real transfers, from the server: sent and
/// received, successful, pending AND failed — they all stay in the history.
final myTransfers = ValueNotifier<List<Transfer>?>(null);

/// The commissions balance, in dollars (rule "tout en dollars").
final myBalanceUsd = ValueNotifier<double>(0);

/// Reads them again (and the balance); keeps the last ones without network.
Future<void> refreshMyTransfers() async {
  if (zawapayAccount.current.value == null) return;
  try {
    final list = await zawapayAccount.myTransfers();
    myTransfers.value = list.map(transferFromServer).toList();
  } catch (_) {
    // Offline: the last known history stays.
  }
  try {
    final b = await zawapayAccount.myBalance();
    myBalanceUsd.value = double.tryParse('${b['available']}') ?? 0;
  } catch (_) {
    // Offline: the last known balance stays.
  }
}

/// Server status → what the history shows. Paid but not delivered yet
/// (decided by Zawapay) stays "pending"; refused, expired or refunded:
/// "failed".
TransferStatus statusOf(String status) => switch (status) {
  'confirmed' => TransferStatus.success,
  'collect_failed' || 'refunded' => TransferStatus.failed,
  _ => TransferStatus.pending,
};

/// "+256771234567" → ("UG", "771234567").
(String, String) _splitPhone(String phone, String fallbackCountry) {
  for (final c in supportedCountries) {
    if (phone.startsWith(c.dialCode)) {
      return (c.isoCode, phone.substring(c.dialCode.length));
    }
  }
  return (fallbackCountry, phone.replaceFirst('+', ''));
}

Transfer transferFromServer(Map<String, dynamic> j) {
  double n(Object? v) => double.tryParse('${v ?? ''}') ?? 0;
  DateTime? at(Object? v) =>
      v == null ? null : DateTime.tryParse('$v')?.toLocal();
  final outgoing = j['outgoing'] == true;
  final status = '${j['status']}';
  final abroad = j['destCurrency'] != null && j['destAmount'] != null;
  final (country, national) = _splitPhone(
    '${j['receivePhone'] ?? ''}',
    '${j['destCountry'] ?? 'CD'}',
  );

  // The other person: who received (sent by me), or who sent (to me).
  final Recipient other;
  if (!outgoing) {
    other = Recipient(
      username: '${j['sender'] ?? ''}',
      fullName: '${j['senderName'] ?? ''}',
      countryCode: 'CD',
      phone: '',
    );
  } else if (j['recipient'] != null) {
    other = Recipient(
      username: '${j['recipient']}',
      fullName: '${j['recipientName'] ?? ''}',
      countryCode: country,
      phone: national,
    );
  } else {
    other = Recipient.number(country, national);
  }

  final failed = statusOf(status) == TransferStatus.failed;
  return Transfer(
    id: '${j['id']}',
    reference: '${j['reference'] ?? ''}',
    other: other,
    outgoing: outgoing,
    received: abroad ? n(j['destAmount']) : n(j['received']),
    fee: n(j['fee']),
    currency: abroad ? '${j['destCurrency']}' : '${j['currency']}',
    payCurrency: abroad ? '${j['currency']}' : null,
    paidAmount: n(j['paid']),
    status: statusOf(status),
    sentAt: at(j['createdAt']) ?? DateTime.now(),
    paidAt: at(j['collectedAt']),
    failedAt: failed ? at(j['updatedAt']) : null,
    confirmedAt: at(j['confirmedAt']),
  );
}
