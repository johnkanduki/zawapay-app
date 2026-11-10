import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// The five password rules, checked live.
class PasswordRules {
  PasswordRules(String password)
    : minLength = password.length >= 8,
      uppercase = password.contains(RegExp('[A-Z]')),
      lowercase = password.contains(RegExp('[a-z]')),
      digits = password.contains(RegExp('[0-9]')),
      symbols = password.contains(RegExp(r'[^A-Za-z0-9\s]'));

  final bool minLength;
  final bool uppercase;
  final bool lowercase;
  final bool digits;
  final bool symbols;

  int get passed => [
    minLength,
    uppercase,
    lowercase,
    digits,
    symbols,
  ].where((ok) => ok).length;

  /// 0 = empty, 1 = weak, 2 = medium, 3 = strong.
  int get level {
    if (passed == 0) return 0;
    if (passed == 5) return 3;
    if (passed >= 4) return 2;
    return 1;
  }
}

/// Three-bar strength meter followed by the checklist of rules.
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = PasswordRules(password);
    final levelLabel = switch (rules.level) {
      1 => l10n.strengthWeak,
      2 => l10n.strengthMedium,
      3 => l10n.strengthStrong,
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: i < rules.level ? AppColors.red : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
            SizedBox(
              width: 92,
              child: Text(
                levelLabel,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: rules.level == 3 ? AppColors.red : AppColors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _RuleRow(text: l10n.ruleMinLength, ok: rules.minLength),
        _RuleRow(text: l10n.ruleUppercase, ok: rules.uppercase),
        _RuleRow(text: l10n.ruleLowercase, ok: rules.lowercase),
        _RuleRow(text: l10n.ruleDigits, ok: rules.digits),
        _RuleRow(text: l10n.ruleSymbols, ok: rules.symbols),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? AppColors.red : Colors.transparent,
              border: ok ? null : Border.all(color: AppColors.grey, width: 1.6),
            ),
            child: ok
                ? const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.white,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: ok ? AppColors.black : AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
