import '../../core/account/app_rules.dart';

/// Withdrawal fee and minimum (withdrawals concern commissions only), set in
/// the admin dashboard (admin.zawapay.com → Tarifs). Starting values: free,
/// and at least 1 USD or 2 000 CDF.
class WithdrawRules {
  const WithdrawRules({this.feeRate = 0, this.minimums = const {}});

  /// Share of the amount taken as a fee (0.02 = 2 %), on top of the amount.
  final double feeRate;

  /// Smallest amount per currency.
  final Map<String, double> minimums;

  double feeFor(double amount) => amount * feeRate;
  double minimumFor(String currency) => minimums[currency] ?? 0;
}

const startingWithdrawRules = WithdrawRules(minimums: {'USD': 1, 'CDF': 2000});

/// The rules set in the admin dashboard (Tarifs), as last read.
WithdrawRules get currentWithdrawRules => WithdrawRules(
  feeRate: appRules.value.withdrawFeeRate,
  minimums: appRules.value.withdrawMinimums,
);
