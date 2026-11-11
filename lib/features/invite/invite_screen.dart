import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';

/// Example rates shown on the page. The real rates will be admin settings
/// on the server (they can change at any time): these are only an example.
abstract final class _ExampleRates {
  /// Service fee: 6 % of the amount received.
  static const double fee = 0.06;

  /// Share of the fee given back as commissions: 10 %.
  static const double pool = 0.10;

  /// Example transfer amount, in dollars.
  static const double amount = 100;
}

/// "Invite friends": the user's "@" to share, and how commissions work:
/// on every real, confirmed transfer, 3 levels above and 3 levels below
/// the person who sends earn a share of the service fee.
class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final handle = '@$username';
    const fees = _ExampleRates.amount * _ExampleRates.fee;
    const pool = fees * _ExampleRates.pool;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.zc.field,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: context.zc.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.inviteTitle,
                style: TextStyle(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: context.zc.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.inviteSubtitle,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: context.zc.soft,
                ),
              ),
              const SizedBox(height: 22),
              _ShareCard(handle: handle),
              const SizedBox(height: 26),
              _SectionTitle(l10n.inviteHowTitle),
              const SizedBox(height: 14),
              const _LevelsChain(),
              const SizedBox(height: 26),
              _SectionTitle(l10n.inviteExampleTitle),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.zc.card,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    _ExampleLine(
                      label: l10n.inviteExampleSent,
                      value: _money(_ExampleRates.amount),
                    ),
                    _ExampleLine(
                      label: l10n.inviteExampleFees(
                        _percent(_ExampleRates.fee),
                      ),
                      value: _money(fees),
                    ),
                    Divider(height: 22, color: context.zc.field),
                    _ExampleLine(
                      label: l10n.inviteExamplePool(
                        _percent(_ExampleRates.pool),
                      ),
                      value: _money(pool),
                      strong: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.inviteExampleNote,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.zc.soft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _SectionTitle(l10n.inviteRulesTitle),
              const SizedBox(height: 12),
              _Rule(text: l10n.inviteRuleFree),
              _Rule(text: l10n.inviteRuleRealTransfers),
              _Rule(text: l10n.inviteRuleConfirmed),
              _Rule(text: l10n.inviteRuleFees),
            ],
          ),
        ),
      ),
    );
  }

  static String _money(double value) =>
      '${value.toStringAsFixed(2).replaceAll('.', ',')} \$';

  static String _percent(double rate) => '${(rate * 100).round()} %';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: context.zc.text,
    ),
  );
}

/// The user's "@" with Copy: it is what friends type when they sign up.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.handle});

  final String handle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 10, 16),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.inviteYourHandle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: context.zc.text,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: handle));
              // Messages always come down from the top.
              showTopNotice(context, l10n.inviteCopied);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: ShapeDecoration(
                color: context.zc.text,
                shape: StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.inviteCopy,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 levels above, "You" in the middle, 3 levels below.
class _LevelsChain extends StatelessWidget {
  const _LevelsChain();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: context.zc.card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          _GroupLabel(l10n.inviteAbove),
          _LevelNode(level: 3, text: l10n.inviteAbove3),
          _LevelNode(level: 2, text: l10n.inviteAbove2),
          _LevelNode(level: 1, text: l10n.inviteAbove1),
          const _YouNode(),
          _LevelNode(level: 1, text: l10n.inviteBelow1),
          _LevelNode(level: 2, text: l10n.inviteBelow2),
          _LevelNode(level: 3, text: l10n.inviteBelow3, last: true),
          _GroupLabel(l10n.inviteBelow),
          const SizedBox(height: 12),
          Text(
            l10n.inviteChainNote,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: context.zc.soft),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: context.zc.soft,
      ),
    ),
  );
}

/// One level of the chain, linked to the next one by a thin line.
class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.text,
    this.last = false,
  });

  final int level;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.zc.field,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.zc.text,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: SizedBox(
                      width: 2,
                      child: ColoredBox(color: context.zc.field),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 16),
              child: Text(
                text,
                style: TextStyle(fontSize: 15, color: context.zc.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YouNode extends StatelessWidget {
  const _YouNode();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      decoration: const ShapeDecoration(
        color: AppColors.red,
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.zc.text,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.inviteYou,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleLine extends StatelessWidget {
  const _ExampleLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: strong ? 17 : 16,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
      color: strong ? context.zc.text : context.zc.soft,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style.copyWith(color: context.zc.text)),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: AppColors.red,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: context.zc.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
