import 'package:flutter/widgets.dart';

import 'zawapay_account.dart';

/// Fees set in the admin dashboard (admin.zawapay.com → Tarifs), read from
/// the server. Until they arrive (or without network), the starting values:
/// 6 % service fee on sending, free withdrawals, at least 1 USD / 2 000 CDF.
/// The server always computes the real amounts itself.
class AppRules {
  const AppRules({
    this.serviceFeeRate = 0.06,
    this.withdrawFeeRate = 0,
    this.withdrawMinimums = const {'USD': 1, 'CDF': 2000},
    this.sendFeeLabels = const {},
    this.withdrawFeeLabels = const {},
  });

  factory AppRules.fromJson(Map<String, dynamic> json) {
    double rate(Object? v, double fallback) =>
        v is num ? v.toDouble() / 100 : fallback;
    final minimums = json['withdrawMinimum'];
    final labels = json['labels'];
    Map<String, String> words(Object? v) => v is Map
        ? {
            for (final e in v.entries)
              if (e.value is String && (e.value as String).trim().isNotEmpty)
                '${e.key}': (e.value as String).trim(),
          }
        : const {};
    return AppRules(
      serviceFeeRate: rate(json['serviceFeePercent'], 0.06),
      withdrawFeeRate: rate(json['withdrawFeePercent'], 0),
      withdrawMinimums: minimums is Map
          ? {
              for (final e in minimums.entries)
                if (e.value is num) '${e.key}': (e.value as num).toDouble(),
            }
          : const {'USD': 1, 'CDF': 2000},
      sendFeeLabels: words(labels is Map ? labels['sendFee'] : null),
      withdrawFeeLabels: words(labels is Map ? labels['withdrawFee'] : null),
    );
  }

  /// On sending: share of what the recipient receives, paid on top.
  final double serviceFeeRate;

  /// On withdrawing commissions: share of the amount, taken on top.
  final double withdrawFeeRate;
  final Map<String, double> withdrawMinimums;

  /// The word before the fee amount, per language ("fr", "en"), set in the
  /// admin dashboard; empty: the app's own "Frais" / "Fee".
  final Map<String, String> sendFeeLabels;
  final Map<String, String> withdrawFeeLabels;
}

/// The fee word for the current language, or [fallback] (the app's own).
String feeLabel(
  BuildContext context, {
  required bool send,
  required String fallback,
}) {
  final lang = Localizations.localeOf(context).languageCode;
  final labels = send
      ? appRules.value.sendFeeLabels
      : appRules.value.withdrawFeeLabels;
  return labels[lang] ?? fallback;
}

final appRules = ValueNotifier<AppRules>(const AppRules());

/// Reads the latest fees; keeps the last known ones without network.
Future<void> refreshAppRules() async {
  try {
    appRules.value = AppRules.fromJson(await zawapayAccount.fetchRules());
  } catch (_) {
    // Offline: the last known fees stay.
  }
}
