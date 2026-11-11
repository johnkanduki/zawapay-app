import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';

/// White "Zawapay" balance card: one line per currency of the user's country
/// (USD and CDF for RD Congo), the last update time, a button to hide the
/// amounts and the country flag.
class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.country,
    this.balances = const {},
    this.updatedAt,
  });

  final Country country;

  /// Amount per currency code. A missing currency shows 0.
  final Map<String, double> balances;
  final DateTime? updatedAt;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final amount = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final time = DateFormat.Hm(locale)
        .format(widget.updatedAt ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      // Stands out: white on the dark page, black on the light one.
      decoration: BoxDecoration(
        color: context.zc.inverse,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Zawapay',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final currency in widget.country.currencies)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$currency ',
                          style: const TextStyle(color: AppColors.red),
                        ),
                        TextSpan(
                          text: _hidden
                              ? '••••••'
                              : amount.format(widget.balances[currency] ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: context.zc.onInverse,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 19, height: 1.25),
                  ),
                const SizedBox(height: 4),
                Text(
                  l10n.balanceUpdatedAt(time),
                  style: TextStyle(
                    fontSize: 13,
                    color: context.zc.isDark
                        ? AppColors.grey
                        : const Color(0x99FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Hide / show button, with the country flag next to it.
          Semantics(
            button: true,
            label: _hidden ? l10n.balanceShow : l10n.balanceHide,
            child: GestureDetector(
              onTap: () => setState(() => _hidden = !_hidden),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red,
                ),
                child: Icon(
                  _hidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.zc.isDark
                  ? AppColors.surface
                  : const Color(0x33FFFFFF),
            ),
            child: CircleFlag(widget.country.isoCode, size: 42),
          ),
        ],
      ),
    );
  }
}

/// The two main actions of the app: Send (red) and Withdraw.
class SendWithdrawButtons extends StatelessWidget {
  const SendWithdrawButtons({
    super.key,
    required this.onSend,
    required this.onWithdraw,
  });

  final VoidCallback onSend;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: l10n.homeSend,
            icon: Icons.arrow_outward_rounded,
            color: AppColors.red,
            iconBackground: const Color(0x33FFFFFF),
            foreground: AppColors.white,
            onTap: onSend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: l10n.homeWithdraw,
            icon: Icons.south_west_rounded,
            color: context.zc.cardStrong,
            // Grey circle inside the white button (light mode).
            iconBackground: context.zc.isDark
                ? context.zc.card
                : context.zc.field,
            foreground: context.zc.text,
            onTap: onWithdraw,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconBackground,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color iconBackground;

  /// Icon and label colour.
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
          decoration: ShapeDecoration(
            color: color,
            shape: const StadiumBorder(),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackground,
                ),
                child: Icon(icon, color: foreground, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
