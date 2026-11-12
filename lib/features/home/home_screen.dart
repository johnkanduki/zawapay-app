import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/account/app_rules.dart';
import '../../core/account/destinations.dart';
import '../history/my_transfers.dart';
import '../commissions/commission_history_screen.dart';
import '../../core/account/withdraw_pin.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/countries/country.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/verified_badge.dart';
import '../../l10n/app_localizations.dart';
import '../invite/invite_screen.dart';
import '../scan/my_qr_screen.dart';
import '../scan/scan_screen.dart';
import '../send/recipient.dart';
import '../send/send_recipient_screen.dart';
import '../history/transfer.dart';
import '../history/transfer_detail_screen.dart';
import '../history/history_screen.dart';
import '../history/transfer_row.dart';
import 'balance_card.dart';
import 'scan_to_pay_button.dart';
import '../kyc/kyc_intro_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/phone_numbers_screen.dart';
import '../settings/settings_view.dart';
import '../settings/sign_out_dialog.dart';
import '../withdraw/withdraw_screen.dart';

/// Home page, reached after "Finish" (sign-up) or "Sign in".
///
/// Dark page, kept simple: profile at the top, the balance, the two
/// actions (Send, Withdraw), the history, and a floating bar at the bottom.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.firstName,
    this.lastName,
    this.username,
    this.photoPath,
    this.certified = false,
    this.email,
    this.countryCode,
    this.transfers,
    this.balances = const {},
    this.onRefresh,
    this.withdrawPhone,
    this.paymentPhone,
  });

  final String? firstName;
  final String? lastName;

  /// The user's own "@" username. Sign-up does not ask for one yet, so until
  /// then it is made from the first and last name (John Kanduki → johnkanduki).
  final String? username;

  /// Profile photo taken at sign-up. Without it, the initial is shown.
  final String? photoPath;

  /// True once the identity check (KYC) is done: the blue badge is shown
  /// next to the username. Until then, tapping the profile opens the check.
  final bool certified;

  /// Last transfers (from the server; none yet).
  final List<Transfer>? transfers;

  /// Balance per currency ("USD", "CDF"…). Empty for a new account.
  final Map<String, double> balances;

  final String? email;

  /// Country chosen on the first screen (ISO code, e.g. "CD").
  final String? countryCode;

  /// Called when the page is pulled down and released, to reload it.
  final Future<void> Function()? onRefresh;

  /// Where withdrawals go: the receiving number (the payment number when
  /// "same number" stayed ticked at sign-up).
  final String? withdrawPhone;

  /// Receives the USSD payment requests (shown in Settings).
  final String? paymentPhone;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Only the 3 latest transfers on the home page; History has them all.
  static List<Transfer> _last3(List<Transfer> all) => all.take(3).toList();

  /// How far the page must be pulled down to refresh it.
  static const double _refreshPull = 80;

  final _scroll = ScrollController();
  static const int _homeTab = 0;
  static const int _qrTab = 1;
  static const int _settingsTab = 2;

  bool _activityOpen = true;
  int _tab = _homeTab;

  /// The user as an account, for "My QR code".
  Recipient _me(Country country, String fullName, String username) => Recipient(
    username: username,
    fullName: fullName,
    countryCode: country.isoCode,
    phone: '',
    certified: widget.certified,
    // My own photo, shown on my payment QR code.
    photoFile: widget.photoPath,
  );

  /// The country of a number from Settings → Phone numbers ("+256…" →
  /// Uganda), or [fallback] when there is none yet.
  Country _countryOf(String? phone, Country fallback) =>
      splitPhone(phone).$1 ?? fallback;

  void _openScan(Country country, String fullName, String username) {
    final me = _me(country, fullName, username);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          // Paying: the country (and currency) of the PAYMENT number.
          senderCountry: _countryOf(widget.paymentPhone, country),
          me: me,
          balances: widget.balances,
        ),
      ),
    );
  }

  void _openKyc(String fullName, String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KycIntroScreen(
          fullName: fullName,
          username: username,
          photoPath: widget.photoPath,
        ),
      ),
    );
  }

  /// How far the page is pulled down right now (0 when at rest).
  /// Only the header and the spinner listen to it: pulling the page no
  /// longer rebuilds the whole home page on every pixel.
  final _pull = ValueNotifier<double>(0);
  bool _dragging = false;

  /// How far the page was pulled when the finger was lifted.
  double _releasePull = 0;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final pull = _scroll.hasClients
          ? math.max(0.0, -_scroll.position.pixels)
          : 0.0;
      _pull.value = pull;
    });
  }

  @override
  void dispose() {
    _pull.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Refreshes when the finger is lifted after a long enough pull down.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _dragging = notification.dragDetails != null;
      _releasePull = 0;
    } else if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) {
        // Still under the finger: remember how far it is pulled.
        _releasePull = -notification.metrics.pixels;
      } else if (_dragging) {
        // First move without the finger: it has just been lifted.
        _releaseDrag();
      }
    } else if (notification is ScrollEndNotification && _dragging) {
      _releaseDrag();
    }
    return false;
  }

  void _releaseDrag() {
    _dragging = false;
    if (_releasePull >= _refreshPull) _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    HapticFeedback.mediumImpact();
    setState(() => _refreshing = true);
    // The latest fees (admin dashboard → Tarifs), and the page's own refresh.
    await Future.wait([
      refreshAppRules(),
      refreshDestinations(),
      widget.onRefresh?.call() ??
          Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.firstName?.trim();
    final fullName = [widget.firstName, widget.lastName]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');
    final username = widget.username ?? usernameFromName(fullName);
    // Country chosen on the first screen: its flag and currencies.
    final isoCode =
        widget.countryCode ??
        AppSettingsScope.maybeOf(context)?.country?.isoCode;
    final country = supportedCountries.firstWhere(
      (c) => c.isoCode == isoCode,
      orElse: () => supportedCountries.first,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        extendBody: true,
        body: _tab == _qrTab
            // Middle tab: the user's own payment QR code.
            ? SafeArea(
                bottom: false,
                child: MyQrView(
                  me: _me(country, fullName, username),
                  bottomSpace: MediaQuery.paddingOf(context).bottom + 96,
                ),
              )
            : _tab == _settingsTab
            ? SafeArea(
                bottom: false,
                child: SettingsView(
                  fullName: fullName,
                  username: username,
                  email: widget.email,
                  photoPath: widget.photoPath,
                  certified: widget.certified,
                  // The flag follows the payment number (Settings → numbers).
                  countryCode:
                      splitPhone(widget.paymentPhone).$1?.isoCode ??
                      widget.countryCode,
                  phone: widget.paymentPhone,
                  onPhones: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PhoneNumbersScreen(
                        paymentPhone: widget.paymentPhone,
                        receivePhone: widget.withdrawPhone,
                        myUsername: username,
                      ),
                    ),
                  ),
                  // Room for the floating bar (72) and its margin, above
                  // the phone's own bottom area.
                  bottomSpace: MediaQuery.paddingOf(context).bottom + 96,
                  onCertify: () => _openKyc(fullName, username),
                  onInvite: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InviteScreen(username: username),
                    ),
                  ),
                  onSignOut: () async {
                    // Asked first, as at the reference.
                    if (!await confirmSignOut(context) || !context.mounted) {
                      return;
                    }
                    // Closed on the server and on the phone.
                    zawapayAccount.signOut();
                    withdrawPin.forget();
                    myTransfers.value = null;
                    myBalanceUsd.value = 0;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                      (_) => false,
                    );
                  },
                ),
              )
            : SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // The ONLY spinner: it fills up while the page is pulled
                    // down, then turns while the page reloads.
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: ValueListenableBuilder<double>(
                          valueListenable: _pull,
                          builder: (_, pull, _) => _PullSpinner(
                            progress: _refreshing
                                ? null
                                : (pull / _refreshPull).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                    // While reloading, the whole page stays a little lower
                    // so the spinner shows above the header; then it goes
                    // back up. The header itself never changes size.
                    AnimatedPadding(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(top: _refreshing ? 38 : 0),
                      child: Column(
                        children: [
                          // Pushing the page up: photo, name and username stay fixed and
                          // the rest scrolls underneath. Pulling it down: the header
                          // comes down with the whole page, to refresh it.
                          ValueListenableBuilder<double>(
                            valueListenable: _pull,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                14,
                              ),
                              child: _ProfileHeader(
                                onScan: () =>
                                    _openScan(country, fullName, username),
                                fullName: fullName,
                                username: username,
                                photoPath: widget.photoPath,
                                initialSource: name,
                                certified: widget.certified,
                                // Certified: the profile leads to Settings. Not yet:
                                // it opens the identity check (KYC).
                                onTap: widget.certified
                                    ? () => setState(() => _tab = _settingsTab)
                                    : () => _openKyc(fullName, username),
                              ),
                            ),
                            builder: (_, pull, child) => Transform.translate(
                              offset: Offset(0, pull),
                              child: child,
                            ),
                          ),
                          Expanded(
                            child: ClipRect(
                              child: NotificationListener<ScrollNotification>(
                                onNotification: _onScroll,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Room taken by the floating bar at the bottom.
                                    final barSpace =
                                        MediaQuery.paddingOf(context).bottom +
                                        12;
                                    // Balance, then the only two actions.
                                    final money = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BalanceCard(
                                          country: country,
                                          balances: widget.balances,
                                          // Where every dollar comes from.
                                          onTap: () => Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CommissionHistoryScreen(
                                                        username: username,
                                                      ),
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        SendWithdrawButtons(
                                          onSend: () => Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      SendRecipientScreen(
                                                        // The country and currency
                                                        // of the PAYMENT number.
                                                        senderCountry:
                                                            _countryOf(
                                                              widget
                                                                  .paymentPhone,
                                                              country,
                                                            ),
                                                        balances:
                                                            widget.balances,
                                                        recents: const [],
                                                        myUsername: username,
                                                      ),
                                                ),
                                              ),
                                          onWithdraw: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      WithdrawScreen(
                                                        // The flag, number and
                                                        // currency of the
                                                        // WITHDRAWAL number.
                                                        country: _countryOf(
                                                          widget.withdrawPhone,
                                                          country,
                                                        ),
                                                        phone: widget
                                                            .withdrawPhone,
                                                        balances:
                                                            widget.balances,
                                                      ),
                                                ),
                                              ),
                                        ),
                                      ],
                                    );
                                    final history = _ActivityCard(
                                      transfers: _last3(
                                        widget.transfers ?? const <Transfer>[],
                                      ),
                                      open: _activityOpen,
                                      onToggle: () => setState(
                                        () => _activityOpen = !_activityOpen,
                                      ),
                                      onSeeAll: () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => HistoryScreen(
                                                transfers:
                                                    widget.transfers ??
                                                    const <Transfer>[],
                                              ),
                                            ),
                                          ),
                                    );
                                    // The page can be pulled, but it always springs back,
                                    // so the history card stays just above the bottom bar.
                                    const physics = BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    );
                                    const padding = EdgeInsets.fromLTRB(
                                      16,
                                      10,
                                      16,
                                      0,
                                    );

                                    // Fills the screen when everything fits
                                    // (history just above the bar); on a
                                    // small phone the page simply scrolls.
                                    return SingleChildScrollView(
                                      controller: _scroll,
                                      physics: physics,
                                      padding: padding,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight:
                                              constraints.maxHeight -
                                              padding.top,
                                        ),
                                        // At least the screen height: the
                                        // free space goes between the buttons
                                        // and the history card.
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            money,
                                            Column(
                                              children: [
                                                const SizedBox(height: 14),
                                                history,
                                                SizedBox(height: barSpace + 12),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: _BottomBar(
          selected: _tab,
          onSelect: (index) => setState(() => _tab = index),
        ),
      ),
    );
  }
}

/// Photo, full name and "@" username (with the blue badge when certified).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.username,
    required this.photoPath,
    required this.initialSource,
    required this.certified,
    required this.onTap,
    required this.onScan,
  });

  final VoidCallback onScan;

  final String fullName;
  final String username;
  final String? photoPath;
  final String? initialSource;
  final bool certified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _Avatar(photoPath: photoPath, name: initialSource),
          const SizedBox(width: 14),
          Expanded(
            // Name and @ always shown in full, never cut with "…": a long
            // name gets a little smaller to fit on its line.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    fullName.isEmpty ? l10n.homeHello : fullName,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.zc.text,
                    ),
                  ),
                ),
                if (username.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '@$username',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: context.zc.soft,
                          ),
                        ),
                        // The certified username gets the blue badge.
                        if (certified) ...[
                          const SizedBox(width: 5),
                          const VerifiedBadge(size: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          ScanToPayButton(onTap: onScan),
        ],
      ),
    );
  }
}

/// Red ring that fills up as the page is pulled down; null: it turns
/// (the page is reloading).
class _PullSpinner extends StatelessWidget {
  const _PullSpinner({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: progress ?? 1,
        child: SizedBox.square(
          dimension: 26,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            color: AppColors.red,
            backgroundColor: context.zc.cardStrong,
          ),
        ),
      ),
    );
  }
}

/// "John Kanduki" → "johnkanduki": lower case, no accents, letters and
/// digits only (same characters as the sponsor invitation field).
String usernameFromName(String fullName) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'á': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'í': 'i',
    'ô': 'o',
    'ö': 'o',
    'ó': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ú': 'u',
    'ñ': 'n',
    'ÿ': 'y',
  };
  final buffer = StringBuffer();
  for (final char in fullName.toLowerCase().split('')) {
    final plain = accents[char] ?? char;
    if (RegExp('[a-z0-9]').hasMatch(plain)) buffer.write(plain);
  }
  return buffer.toString();
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoPath, required this.name});

  final String? photoPath;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final photo = photoPath;
    final initial = (name == null || name!.isEmpty)
        ? ''
        : name!.characters.first.toUpperCase();

    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.zc.cardStrong,
      ),
      child: ClipOval(
        child: photo != null
            ? Image.file(
                File(photo),
                fit: BoxFit.cover,
                // Decoded small: a full camera photo is never needed here.
                cacheWidth: 240,
              )
            : ColoredBox(
                color: context.zc.card,
                child: Center(
                  child: initial.isEmpty
                      ? const Icon(Icons.person_rounded, color: AppColors.red)
                      : Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.red,
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}

/// "Activity" card: last transfers, can be folded with "Hide".
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.transfers,
    required this.open,
    required this.onToggle,
    required this.onSeeAll,
  });

  final List<Transfer> transfers;
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.zc.card,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeActivity,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: context.zc.text,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
                    decoration: ShapeDecoration(
                      color: AppColors.red.withValues(alpha: 0.16),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          open ? l10n.homeHide : l10n.homeShow,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          open
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.red,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      Divider(
                        height: 1,
                        color: context.zc.isDark
                            ? context.zc.card
                            : context.zc.line,
                      ),
                      const SizedBox(height: 4),
                      if (transfers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          child: Text(
                            l10n.homeNoTransfers,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.zc.text,
                            ),
                          ),
                        )
                      else
                        for (final transfer in transfers)
                          TransferRow(
                            transfer: transfer,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransferDetailScreen(transfer: transfer),
                              ),
                            ),
                          ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: GestureDetector(
                          onTap: onSeeAll,
                          child: Text(
                            l10n.homeSeeAllTransfers.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Floating rounded bar: Home, Scan, Settings.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _icons = [
    Icons.home_rounded,
    Icons.qr_code_scanner_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [l10n.tabHome, l10n.tabScan, l10n.tabSettings];

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Center(
        heightFactor: 1,
        child: Container(
          width: 300,
          height: 72,
          decoration: ShapeDecoration(
            color: Color.alphaBlend(context.zc.cardStrong, context.zc.page),
            shape: const StadiumBorder(),
          ),
          // No inner margin: the selected pill fills the whole height and,
          // on the ends, follows the bar's own rounded edge.
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // The pill slides to the selected button.
              AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  -1 + selected * 2 / (_icons.length - 1),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / _icons.length,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: AppColors.red.withValues(alpha: 0.18),
                      shape: const StadiumBorder(
                        side: BorderSide(color: AppColors.red, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _icons.length; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == selected,
                        label: labels[i],
                        child: GestureDetector(
                          onTap: () => onSelect(i),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: i == selected ? 1.08 : 1,
                              child: Icon(
                                _icons[i],
                                size: 30,
                                color: i == selected
                                    ? AppColors.red
                                    : context.zc.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
