import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/countries/country.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
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
import '../settings/settings_view.dart';

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

  /// Last transfers; the demo ones when not given.
  final List<Transfer>? transfers;

  /// Balance per currency ("USD", "CDF"…). Empty for a new account.
  final Map<String, double> balances;

  final String? email;

  /// Country chosen on the first screen (ISO code, e.g. "CD").
  final String? countryCode;

  /// Called when the page is pulled down and released, to reload it.
  final Future<void> Function()? onRefresh;

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
  );

  void _openScan(Country country, String fullName, String username) {
    final me = _me(country, fullName, username);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          senderCountry: country,
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
  double _pull = 0;
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
      if (pull != _pull) setState(() => _pull = pull);
    });
  }

  @override
  void dispose() {
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
    // No server yet: the page simply waits a moment.
    await (widget.onRefresh?.call() ??
        Future<void>.delayed(const Duration(milliseconds: 1200)));
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
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
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
                  countryCode: widget.countryCode,
                  // Room for the floating bar (72) and its margin, above
                  // the phone's own bottom area.
                  bottomSpace: MediaQuery.paddingOf(context).bottom + 96,
                  onCertify: () => _openKyc(fullName, username),
                  onInvite: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InviteScreen(username: username),
                    ),
                  ),
                  onSignOut: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (_) => false,
                  ),
                ),
              )
            : SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Spinner revealed above the header while pulling down.
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: _PullSpinner(
                          progress: (_pull / _refreshPull).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        // Pushing the page up: photo, name and username stay fixed and
                        // the rest scrolls underneath. Pulling it down: the header
                        // comes down with the whole page, to refresh it.
                        Transform.translate(
                          offset: Offset(0, _pull),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                            child: _ProfileHeader(
                              refreshing: _refreshing,
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
                        ),
                        Expanded(
                          child: ClipRect(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: _onScroll,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Room taken by the floating bar at the bottom.
                                  final barSpace =
                                      MediaQuery.paddingOf(context).bottom + 12;
                                  // Balance, then the only two actions.
                                  final money = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BalanceCard(
                                        country: country,
                                        balances: widget.balances,
                                      ),
                                      const SizedBox(height: 12),
                                      SendWithdrawButtons(
                                        onSend: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SendRecipientScreen(
                                                      senderCountry: country,
                                                      balances: widget.balances,
                                                      recents: demoRecipients
                                                          .take(3)
                                                          .toList(),
                                                    ),
                                              ),
                                            ),
                                        onWithdraw: () {},
                                      ),
                                    ],
                                  );
                                  final history = _ActivityCard(
                                    transfers: _last3(
                                      widget.transfers ?? demoTransfers,
                                    ),
                                    open: _activityOpen,
                                    onToggle: () => setState(
                                      () => _activityOpen = !_activityOpen,
                                    ),
                                    onSeeAll: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HistoryScreen(
                                          transfers:
                                              widget.transfers ?? demoTransfers,
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
                                            constraints.maxHeight - padding.top,
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
    this.refreshing = false,
  });

  final VoidCallback onScan;

  final bool refreshing;
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
            child: LayoutBuilder(
              builder: (context, box) {
                // The "@" line sets the width: the name never goes past
                // the end of the username (and its badge).
                const handleStyle = TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0x99FFFFFF),
                );
                final painter = TextPainter(
                  text: TextSpan(text: '@$username', style: handleStyle),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                  maxLines: 1,
                )..layout();
                final handleWidth = username.isEmpty
                    ? box.maxWidth
                    : (painter.width + (certified ? 21 : 0)).clamp(
                        0.0,
                        box.maxWidth,
                      );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: handleWidth),
                      child: Text(
                        fullName.isEmpty ? l10n.homeHello : fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '@$username',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: handleStyle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          // The certified username gets the blue badge.
                          if (certified) const VerifiedBadge(size: 16),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Shown only while the page reloads after a pull down.
          if (refreshing) ...[
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.red,
              ),
            ),
            const SizedBox(width: 10),
          ],
          ScanToPayButton(onTap: onScan),
        ],
      ),
    );
  }
}

/// Red ring that fills up as the page is pulled down.
class _PullSpinner extends StatelessWidget {
  const _PullSpinner({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: progress,
        child: SizedBox.square(
          dimension: 26,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            color: AppColors.red,
            backgroundColor: const Color(0x1FFFFFFF),
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

/// Translucent white used for the dark cards (the palette stays the same).
const Color _card = Color(0x14FFFFFF);
const Color _cardStrong = Color(0x1FFFFFFF);

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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _cardStrong,
      ),
      child: ClipOval(
        child: photo != null
            ? Image.file(File(photo), fit: BoxFit.cover)
            : ColoredBox(
                color: _card,
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
        color: _card,
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
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
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
                      const Divider(height: 1, color: _card),
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.surface,
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
          padding: const EdgeInsets.all(6),
          decoration: ShapeDecoration(
            color: Color.alphaBlend(_cardStrong, AppColors.black),
            shape: const StadiumBorder(),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _icons.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: labels[i],
                    child: GestureDetector(
                      onTap: () => onSelect(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: ShapeDecoration(
                          color: i == selected
                              ? AppColors.black
                              : Colors.transparent,
                          shape: const StadiumBorder(),
                        ),
                        child: Icon(
                          _icons[i],
                          size: 30,
                          color: i == selected
                              ? AppColors.red
                              : AppColors.white,
                        ),
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
