import 'package:flutter/foundation.dart';

import 'zawapay_account.dart';

/// A country (and currency) open in the admin dashboard: its members can
/// send AND receive between the 12 countries. RD Congo is always open (USD
/// and CDF). The server alone knows the rates and fees: the amount page asks
/// it for a quote ([fetchQuote]).
class Destination {
  const Destination({
    required this.country,
    required this.currency,
    required this.min,
    required this.max,
    this.decimals = 0,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return Destination(
      country: '${json['country']}',
      currency: '${json['currency']}',
      min: n(json['min']),
      max: n(json['max']),
      decimals: json['decimals'] is int ? json['decimals'] as int : 0,
    );
  }

  final String country;
  final String currency;

  /// What the recipient may receive in one send, in [currency].
  final double min;
  final double max;

  /// 0 (UGX, XOF…) or 2 (USD, ZMW…).
  final int decimals;
}

/// Open countries, refreshed from the server; empty without network.
final destinations = ValueNotifier<List<Destination>>(const []);

/// The first open currency of a country (null: closed).
Destination? destinationFor(String country) =>
    destinations.value.where((d) => d.country == country).firstOrNull;

/// Every open currency of a country (RD Congo: USD and CDF).
List<Destination> destinationsFor(String country) =>
    destinations.value.where((d) => d.country == country).toList();

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

/// What the server answers before "Pay": the sender pays [paid] (fee
/// included) in [currency], the recipient gets [destAmount] [destCurrency].
class Quote {
  const Quote({
    required this.currency,
    required this.fee,
    required this.paid,
    required this.destCurrency,
    required this.destAmount,
    required this.rate,
  });

  factory Quote.fromJson(Map<String, dynamic> j) {
    double n(Object? v) => double.tryParse('${v ?? ''}') ?? 0;
    return Quote(
      currency: '${j['currency']}',
      fee: n(j['fee']),
      paid: n(j['paid']),
      destCurrency: '${j['destCurrency']}',
      destAmount: n(j['destAmount']),
      rate: n(j['rate']),
    );
  }

  final String currency;
  final double fee;
  final double paid;
  final String destCurrency;
  final double destAmount;

  /// What the recipient gets for 1 unit paid (fee left out).
  final double rate;
}

/// Asks the server for a quote; tests replace it.
Future<Quote> Function({
  required String recipient,
  required String currency,
  required String amount,
})
fetchQuote = ({required recipient, required currency, required amount}) async =>
    Quote.fromJson(
      await zawapayAccount.quote(
        recipient: recipient,
        currency: currency,
        amount: amount,
      ),
    );
