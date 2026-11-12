import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';

/// Reads the « Gagner ensemble » numbers from the server; tests replace it.
Future<Map<String, dynamic>> Function() loadEarnPage = zawapayAccount.earnPage;

/// « Gagner ensemble » (Invite friends): a long, very simple page that sells
/// the app with REAL numbers. The percentages are the real ones of the admin
/// dashboard (Tarifs); the title, the sentence and the example hypotheses
/// are set in the admin dashboard (Gagner ensemble). Nothing is invented on
/// the phone: every amount comes from the server.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key, required this.username});

  final String username;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  Map<String, dynamic>? _page;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await loadEarnPage();
      if (mounted) setState(() => (_page = page, _failed = false));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _share(BuildContext button) async {
    final l10n = AppLocalizations.of(context);
    final box = button.findRenderObject() as RenderBox?;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: l10n.earnShareMessage('@${widget.username}'),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      Clipboard.setData(ClipboardData(text: '@${widget.username}'));
      if (mounted) showTopNotice(context, l10n.inviteCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final page = _page;
    String money(Object? v) {
      final n = v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
      return '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2).format(n)} \$';
    }

    String number(Object? v) {
      final n = v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
      return NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: n == n.roundToDouble() ? 0 : 2,
      ).format(n);
    }

    String percent(Object? v) => '${number(v)} %';
    String text(Object? map) =>
        map is Map ? '${map[lang] ?? map['fr'] ?? ''}' : '';

    final children = <Widget>[
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
            child: Icon(Icons.arrow_back_rounded, color: context.zc.text),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];

    if (page == null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: _failed
                ? Text(
                    l10n.earnLoadFailed,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.zc.soft),
                  )
                : const CircularProgressIndicator(color: AppColors.red),
          ),
        ),
      );
    } else {
      final ex = page['example'] as Map<String, dynamic>;
      final rules = page['rules'] as Map<String, dynamic>;
      final per = page['perSend'] as Map<String, dynamic>;
      final one = page['oneFriend'] as Map<String, dynamic>;
      final team = page['team'] as Map<String, dynamic>;
      final levels = (team['levels'] as List).cast<Map<String, dynamic>>();
      final up = (rules['up'] as List).cast<num>();
      final down = (rules['down'] as List).cast<num>();
      final above = ((per['above'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();
      final where = (page['where'] as Map<String, dynamic>?) ?? const {};
      final direct = (ex['directFriends'] as num? ?? 1);
      final each = (ex['eachInvites'] as num? ?? 0);
      // How many invitees share each level above (same example team).
      final aboveCount = [direct, direct * each, direct * each * each];
      final amount = money(ex['sendAmountUsd']);
      final times = number(ex['sendsPerWeek']);

      children.addAll([
        // 1. The promise, in big.
        _Hero(
          title: text(page['title']),
          subtitle: text(page['subtitle']),
          big: l10n.earnPerMonth(money(team['month'])),
          note: l10n.earnBigNote(number(team['people'])),
        ),
        const SizedBox(height: 16),
        _ShareCard(handle: '@${widget.username}'),
        const SizedBox(height: 30),

        // 2. How it works.
        _SectionTitle(l10n.earnStepsTitle),
        const SizedBox(height: 14),
        _Step(
          number: 1,
          text: l10n.earnStep1,
          icon: Icons.alternate_email_rounded,
        ),
        _Step(number: 2, text: l10n.earnStep2, icon: Icons.send_rounded),
        _Step(number: 3, text: l10n.earnStep3, icon: Icons.savings_rounded),
        const SizedBox(height: 30),

        // 2b. The 6 levels in one picture: 3 above, YOU, 3 below.
        _SectionTitle(l10n.earnSixTitle),
        const SizedBox(height: 10),
        Text(
          l10n.earnSixIntro(amount),
          style: TextStyle(fontSize: 16, height: 1.45, color: context.zc.soft),
        ),
        const SizedBox(height: 14),
        _SixLevels(
          rows: [
            (l10n.earnSixAbove3, percent(down[2]), money(above[2]['perSend'])),
            (l10n.earnSixAbove2, percent(down[1]), money(above[1]['perSend'])),
            (l10n.earnSixAbove1, percent(down[0]), money(above[0]['perSend'])),
            (l10n.earnSixYou, '', ''),
            (l10n.earnSixBelow1, percent(up[0]), money(per['gen1'])),
            (l10n.earnSixBelow2, percent(up[1]), money(per['gen2'])),
            (l10n.earnSixBelow3, percent(up[2]), money(per['gen3'])),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.earnSixTotal(
            percent([...up, ...down].fold<num>(0, (a, b) => a + b)),
          ),
          style: TextStyle(fontSize: 13, height: 1.4, color: context.zc.soft),
        ),
        const SizedBox(height: 30),

        // 2c. Where the money of one transfer goes (full transparency).
        _SectionTitle(l10n.earnWhereTitle(amount)),
        const SizedBox(height: 14),
        _Card(
          children: [
            _Line(l10n.earnWhereReceived, money(where['received'])),
            _Line(l10n.earnWherePaid, money(where['paid'])),
            Divider(height: 20, color: context.zc.field),
            _Line(l10n.earnWhereFee, money(where['fee']), strong: true),
            _Line(l10n.earnWhereNetwork, money(where['toNetwork'])),
            _Line(l10n.earnWhereZawapay, money(where['toZawapay'])),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.earnWhereNote,
          style: TextStyle(fontSize: 13, height: 1.4, color: context.zc.soft),
        ),
        const SizedBox(height: 30),

        // 3. On every transfer, who gets what (the real percentages).
        _SectionTitle(l10n.earnPerSendTitle(amount)),
        const SizedBox(height: 14),
        _Card(
          children: [
            _Line(
              l10n.earnFee(percent(rules['feePercent'])),
              money(per['fee']),
            ),
            _Line(
              l10n.earnPool(percent(rules['poolPercent'])),
              money(per['pool']),
              strong: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SectionTitle(l10n.earnWhoTitle),
        const SizedBox(height: 14),
        _Level(
          label: l10n.earnLevel1,
          percent: percent(up[0]),
          gets: l10n.earnYouGet(money(per['gen1'])),
          strong: true,
        ),
        _Level(
          label: l10n.earnLevel2,
          percent: percent(up[1]),
          gets: l10n.earnYouGet(money(per['gen2'])),
        ),
        _Level(
          label: l10n.earnLevel3,
          percent: percent(up[2]),
          gets: l10n.earnYouGet(money(per['gen3'])),
        ),
        _Level(
          label: l10n.earnLevelSponsor,
          percent: percent(down[0]),
          gets: l10n.earnYouGet(money(per['sponsor'])),
        ),
        const SizedBox(height: 30),

        // 3b. The 3 levels ABOVE: shared equally between the invitees.
        _SectionTitle(l10n.earnAboveTitle),
        const SizedBox(height: 10),
        Text(
          l10n.earnAboveIntro,
          style: TextStyle(fontSize: 16, height: 1.45, color: context.zc.soft),
        ),
        const SizedBox(height: 14),
        for (final (i, label) in [
          l10n.earnAbove1,
          l10n.earnAbove2,
          l10n.earnAbove3,
        ].indexed)
          _Level(
            label: label,
            percent: percent(above[i]['percent']),
            gets:
                '${l10n.earnAboveShared(money(above[i]['perSend']))}\n'
                '${l10n.earnAboveEach(number(aboveCount[i]), money(above[i]['each']))}',
          ),
        const SizedBox(height: 18),

        // 4. Simple examples: once, a week, a month, a year.
        _SectionTitle(l10n.earnExamplesTitle),
        const SizedBox(height: 14),
        _Example(text: l10n.earnEx1(amount), value: money(one['once'])),
        _Example(
          text: l10n.earnEx2(times),
          value: l10n.earnPerWeek(money(one['week'])),
        ),
        _Example(
          text: l10n.earnEx3,
          value: l10n.earnPerMonth(money(one['month'])),
        ),
        _Example(
          text: l10n.earnEx4,
          value: l10n.earnPerYear(money(one['year'])),
          strong: true,
        ),
        const SizedBox(height: 30),

        // 5. The team.
        _SectionTitle(l10n.earnTeamTitle),
        const SizedBox(height: 10),
        Text(
          l10n.earnTeamIntro(
            number(ex['directFriends']),
            number(ex['eachInvites']),
            amount,
            times,
          ),
          style: TextStyle(fontSize: 16, height: 1.45, color: context.zc.soft),
        ),
        const SizedBox(height: 14),
        _Card(
          children: [
            for (final l in levels)
              _Line(
                l10n.earnTeamLevel(
                  number(l['level']),
                  number(l['people']),
                  percent(l['percent']),
                ),
                l10n.earnPerMonth(money(l['perMonth'])),
              ),
            Divider(height: 24, color: context.zc.field),
            _Line(
              l10n.earnTeamTotal(number(team['people'])),
              l10n.earnPerMonth(money(team['month'])),
              strong: true,
            ),
            _Line('', l10n.earnPerWeek(money(team['week']))),
            _Line('', l10n.earnPerYear(money(team['year']))),
          ],
        ),
        const SizedBox(height: 30),

        // 6. The money.
        _SectionTitle(l10n.earnMoneyTitle),
        const SizedBox(height: 12),
        _Point(text: l10n.earnMoney1),
        _Point(text: l10n.earnMoney2),
        _Point(text: l10n.earnMoney3(money(rules['withdrawMinimumUsd']))),
        _Point(
          text: (rules['withdrawFeePercent'] as num? ?? 0) == 0
              ? l10n.earnMoneyFree
              : l10n.earnMoneyFee(percent(rules['withdrawFeePercent'])),
        ),
        const SizedBox(height: 30),

        // 7. Questions.
        _SectionTitle(l10n.earnFaqTitle),
        const SizedBox(height: 12),
        _Faq(q: l10n.earnQ1, a: l10n.earnA1),
        _Faq(q: l10n.earnQ2, a: l10n.earnA2),
        _Faq(q: l10n.earnQ3, a: l10n.earnA3),
        _Faq(q: l10n.earnQ4, a: l10n.earnA4),
        const SizedBox(height: 24),
        Text(
          l10n.earnHonest,
          style: TextStyle(fontSize: 13, height: 1.45, color: context.zc.soft),
        ),
        const SizedBox(height: 30),

        // 7b. How to check it is true.
        _SectionTitle(l10n.earnProofTitle),
        const SizedBox(height: 10),
        _Point(text: l10n.earnProof),
        const SizedBox(height: 30),

        // 8. Start now.
        _SectionTitle(l10n.earnShareTitle),
        const SizedBox(height: 10),
        Text(
          l10n.earnShareText,
          style: TextStyle(fontSize: 16, height: 1.45, color: context.zc.soft),
        ),
        const SizedBox(height: 14),
        Builder(
          builder: (button) => SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () => _share(button),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(l10n.earnShareButton),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ]);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.red,
            onRefresh: _load,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// The big red card at the top: the title, the sentence, and the monthly
/// amount of the team example.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.title,
    required this.subtitle,
    required this.big,
    required this.note,
  });

  final String title;
  final String subtitle;
  final String big;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: context.zc.card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: context.zc.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 17,
              height: 1.45,
              color: context.zc.soft,
            ),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              big,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: AppColors.red,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(fontSize: 14, height: 1.4, color: context.zc.soft),
          ),
        ],
      ),
    );
  }
}

/// A numbered step with an icon.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, required this.icon});

  final int number;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.zc.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: context.zc.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
    decoration: BoxDecoration(
      color: context.zc.card,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(children: children),
  );
}

/// "Label ............ value", big enough to read easily.
class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                color: context.zc.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: strong ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: strong ? AppColors.red : context.zc.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// One level: who sends, the real percentage, and what you get.
class _Level extends StatelessWidget {
  const _Level({
    required this.label,
    required this.percent,
    required this.gets,
    this.strong = false,
  });

  final String label;
  final String percent;
  final String gets;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.zc.card,
          borderRadius: BorderRadius.circular(22),
          border: strong ? Border.all(color: AppColors.red, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                percent,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.red,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: context.zc.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gets,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.zc.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Your friend sends 100 $ once." → "0,78 $".
class _Example extends StatelessWidget {
  const _Example({
    required this.text,
    required this.value,
    this.strong = false,
  });

  final String text;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: strong ? AppColors.red : context.zc.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: strong ? AppColors.white : context.zc.soft,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: strong ? AppColors.white : context.zc.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: context.zc.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.q, required this.a});

  final String q;
  final String a;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.zc.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.zc.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              a,
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: context.zc.soft,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

/// The 6 levels in one column: 3 above, YOU in red, 3 below — each with its
/// real percentage and what that level gets on one transfer.
class _SixLevels extends StatelessWidget {
  const _SixLevels({required this.rows});

  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.zc.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          for (final (i, (label, percent, amount)) in rows.indexed) ...[
            if (i > 0)
              Icon(Icons.more_vert_rounded, size: 16, color: context.zc.faint),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: percent.isEmpty ? AppColors.red : context.zc.field,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: percent.isEmpty ? 18 : 15,
                        fontWeight: percent.isEmpty
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: percent.isEmpty
                            ? AppColors.white
                            : context.zc.text,
                      ),
                    ),
                  ),
                  if (percent.isNotEmpty) ...[
                    Text(
                      percent,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 64,
                      child: Text(
                        amount,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.zc.text,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
