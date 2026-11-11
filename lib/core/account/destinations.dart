import 'package:flutter/foundation.dart';

import 'zawapay_account.dart';

/// A country the sender (in RD Congo) can send to: the recipient gets its
/// currency, the sender pays in dollars with the fee included. Opened and
/// priced in the admin dashboard (Pays et taux); the server always computes
/// the real amounts itself.
class Destination {
  const Destination({
    required this.country,
    required this.currency,
    required this.clientRate,
    required this.feePercent,
    required this.minFeeUsd,
    required this.min,
    required this.max,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return Destination(
      country: '${json['country']}',
      currency: '${json['currency']}',
      clientRate: n(json['clientRate']),
      feePercent: n(json['feePercent']),
      minFeeUsd: n(json['minFeeUsd']),
      min: n(json['min']),
      max: n(json['max']),
    );
  }

  final String country;
  final String currency;

  /// Local currency for 1 USD, as given to the customer.
  final double clientRate;
  final double feePercent;
  final double minFeeUsd;

  /// What the recipient may receive in one send, in the local currency.
  final double min;
  final double max;

  /// The recipient receives [received] (local currency): what the sender
  /// pays in USD, as the server computes it (cents rounded up).
  ({double value, double fee, double paid}) quote(double received) {
    double cents(double usd) => (usd * 100 - 1e-9).ceil() / 100;
    final value = cents(received / clientRate);
    final fee = [
      cents(minFeeUsd),
      cents(value * feePercent / 100),
    ].reduce((a, b) => a > b ? a : b);
    return (value: value, fee: fee, paid: ((value + fee) * 100).round() / 100);
  }
}

/// Open countries, refreshed from the server; empty without network.
final destinations = ValueNotifier<List<Destination>>(const []);

Destination? destinationFor(String country) =>
    destinations.value.where((d) => d.country == country).firstOrNull;

Future<void> refreshDestinations() async {
  // Only for a signed-in member (the list is not public).
  if (zawapayAccount.current.value == null) return;
  try {
    destinations.value = (await zawapayAccount.fetchDestinations())
        .map(Destination.fromJson)
        .toList();
  } catch (_) {
    // Offline or signed out: the last known list stays.
  }
}
