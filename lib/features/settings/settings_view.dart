import 'dart:io';

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/verified_badge.dart';
import '../../l10n/app_localizations.dart';
import '../support/contact_sheet.dart';
import 'appearance_sheet.dart';
import 'personal_info_sheet.dart';
import 'settings_sheet.dart';

/// "Settings" tab, shown inside the home page (the bottom bar stays).
///
/// One big dark card holding the account rows, then the Preferences,
/// Security and Help cards, and "Sign out" at the end.
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.fullName,
    required this.username,
    required this.certified,
    required this.onCertify,
    required this.onInvite,
    required this.onSignOut,
    this.onPhones,
    this.email,
    this.photoPath,
    this.countryCode,
    this.phone,
    this.bottomSpace = 0,
  });

  final String fullName;
  final String username;
  final String? email;
  final String? photoPath;
  final bool certified;

  /// Country of the Mobile Money number (ISO code, e.g. "CD") and the number.
  final String? countryCode;
  final String? phone;

  final VoidCallback onCertify;
  final VoidCallback onInvite;
  final VoidCallback onSignOut;

  /// Opens the payment / withdrawal numbers page.
  final VoidCallback? onPhones;

  /// Room to leave at the end for the floating bottom bar.
  final double bottomSpace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode == 'en'
        ? 'English'
        : 'Français';

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomSpace + 24),
      children: [
        _Section(
          title: l10n.settingsTitle,
          big: true,
          children: [
            _ProfileRow(
              fullName: fullName,
              username: username,
              email: email,
              photoPath: photoPath,
              certified: certified,
            ),
            if (!certified)
              _Row(
                leading: const _Circle(
                  child: Icon(
                    Icons.error_rounded,
                    color: AppColors.verified,
                    size: 26,
                  ),
                ),
                title: l10n.settingsNotCertified,
                trailing: _PillButton(
                  label: l10n.settingsCertify,
                  color: AppColors.verified,
                  onTap: onCertify,
                ),
                onTap: onCertify,
              )
            else
              _Row(
                leading: const _Circle(child: VerifiedBadge(size: 28)),
                title: l10n.settingsCertified,
                subtitle: '@$username',
              ),
            _Row(
              leading: _Circle(
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: context.zc.text,
                ),
              ),
              title: l10n.settingsInvite,
              subtitle: l10n.settingsInviteSubtitle,
              trailing: const _Chevron(),
              onTap: onInvite,
            ),
            _Row(
              leading: _Circle(
                child: Icon(Icons.smartphone_rounded, color: context.zc.text),
              ),
              title: l10n.settingsPhones,
              subtitleWidget: Row(
                children: [
                  if (countryCode != null) ...[
                    CircleFlag(countryCode!, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      phone ?? l10n.settingsPhonesHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, color: context.zc.soft),
                    ),
                  ),
                ],
              ),
              trailing: const _Chevron(),
              onTap: onPhones,
            ),
            _DailyLimitRow(
              title: l10n.settingsDailyLimit,
              value: l10n.settingsDailyLimitValue('0 \$', '100 \$'),
              used: 0,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.settingsPreferences,
          children: [
            _Row(
              leading: _Circle(
                child: Icon(Icons.language_rounded, color: context.zc.text),
              ),
              title: l10n.settingsLanguage,
              value: language,
              trailing: const _Chevron(),
              onTap: () => showLanguageSheet(context),
            ),
            _Row(
              leading: _Circle(
                child: Icon(Icons.contrast_rounded, color: context.zc.text),
              ),
              title: l10n.settingsAppearance,
              value: themeModeName(
                l10n,
                AppSettingsScope.maybeOf(context)?.themeMode ??
                    ThemeMode.system,
              ),
              trailing: const _Chevron(),
              onTap: () => showAppearanceSheet(context),
            ),
            _Row(
              leading: _Circle(
                child: Icon(
                  Icons.notifications_rounded,
                  color: context.zc.text,
                ),
              ),
              title: l10n.settingsNotifications,
              value: l10n.settingsNotificationsOn,
              trailing: Icon(
                Icons.arrow_outward_rounded,
                color: context.zc.soft,
                size: 22,
              ),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.settingsSecurity,
          children: [
            _Row(
              leading: _Circle(
                child: Icon(Icons.pin_outlined, color: context.zc.text),
              ),
              title: l10n.settingsPin,
              trailing: const _Chevron(),
              onTap: () {},
            ),
            _Row(
              leading: _Circle(
                child: Icon(Icons.phone_iphone_rounded, color: context.zc.text),
              ),
              title: l10n.settingsDevices,
              value: '1',
              trailing: const _Chevron(),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.settingsHelp,
          children: [
            _Row(
              leading: _Circle(
                child: Icon(Icons.headset_mic_rounded, color: context.zc.text),
              ),
              title: l10n.settingsSupport,
              trailing: const _Chevron(),
              onTap: () => showContactSheet(context),
            ),
            _Row(
              leading: _Circle(
                child: Icon(Icons.help_rounded, color: context.zc.text),
              ),
              title: l10n.settingsAbout,
              value: appVersion,
              trailing: const _Chevron(),
              onTap: () => showAboutSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Row(
          leading: const _Circle(
            child: Icon(Icons.logout_rounded, color: AppColors.red),
          ),
          title: l10n.settingsSignOut,
          titleColor: AppColors.red,
          onTap: onSignOut,
        ),
      ],
    );
  }
}

/// Rounded dark card with a title and its rows.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.big = false,
  });

  final String title;
  final List<Widget> children;

  /// The first card has a big page title and no divider.
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: (context.zc.isDark ? context.zc.frame : context.zc.card),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: context.zc.frame),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, big ? 22 : 20, 14, big ? 16 : 18),
            child: Text(
              title,
              style: TextStyle(
                fontSize: big ? 26 : 17,
                fontWeight: FontWeight.w700,
                letterSpacing: big ? -0.8 : -0.2,
                color: context.zc.text,
              ),
            ),
          ),
          if (!big) ...[
            Divider(height: 1, color: context.zc.card),
            const SizedBox(height: 12),
          ],
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One pill row: round icon, title (and subtitle), value and arrow.
class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.value,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String? value;
  final Widget? trailing;

  /// Null: the normal text colour.
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sub =
        subtitleWidget ??
        (subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: context.zc.soft),
              ));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: ShapeDecoration(
          color: (context.zc.isDark ? context.zc.card : context.zc.field),
          shape: StadiumBorder(),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Long titles shrink a little instead of being cut.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 17,
                        color: titleColor ?? context.zc.text,
                      ),
                    ),
                  ),
                  if (sub != null) ...[const SizedBox(height: 3), sub],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                style: TextStyle(fontSize: 16, color: context.zc.soft),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (context.zc.isDark ? context.zc.card : context.zc.raised),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right_rounded, color: context.zc.soft, size: 26);
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.zc.text,
          ),
        ),
      ),
    );
  }
}

/// Photo, name and "@" (badge when certified), with "Edit".
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.fullName,
    required this.username,
    required this.email,
    required this.photoPath,
    required this.certified,
  });

  final String fullName;
  final String username;
  final String? email;
  final String? photoPath;
  final bool certified;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = photoPath;
    final initial = fullName.isEmpty
        ? ''
        : fullName.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: ShapeDecoration(
        color: (context.zc.isDark ? context.zc.card : context.zc.field),
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox.square(
              dimension: 62,
              child: photo != null
                  ? Image.file(
                      File(photo),
                      fit: BoxFit.cover,
                      // Decoded small: a full camera photo is never needed here.
                      cacheWidth: 240,
                    )
                  : ColoredBox(
                      color: (context.zc.isDark
                          ? context.zc.card
                          : context.zc.raised),
                      child: Center(
                        child: Text(
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
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Never cut with "…": a long name gets a little smaller.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    fullName.isEmpty ? l10n.homeHello : fullName,
                    maxLines: 1,
                    style: TextStyle(fontSize: 17, color: context.zc.text),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username.isEmpty ? (email ?? '') : '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: context.zc.soft),
                      ),
                    ),
                    if (certified && username.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 16),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showPersonalInfoSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: ShapeDecoration(
                color: (context.zc.isDark
                    ? context.zc.card
                    : context.zc.raised),
                shape: StadiumBorder(),
              ),
              child: Text(
                l10n.settingsEdit,
                style: TextStyle(fontSize: 16, color: context.zc.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Daily limit" with the amount used and a row of growing bars.
class _DailyLimitRow extends StatelessWidget {
  const _DailyLimitRow({
    required this.title,
    required this.value,
    required this.used,
  });

  final String title;
  final String value;

  /// Share of the limit already used, from 0 to 1.
  final double used;

  static const int _bars = 28;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: ShapeDecoration(
          color: (context.zc.isDark ? context.zc.card : context.zc.field),
          shape: StadiumBorder(),
        ),
        child: Row(
          children: [
            _Circle(
              child: Icon(
                Icons.speed_rounded,
                color: context.zc.text,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 17,
                              color: context.zc.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(fontSize: 13, color: context.zc.soft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < _bars; i++)
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 2.5,
                                height: 5 + 13 * i / (_bars - 1),
                                decoration: BoxDecoration(
                                  color: i < (used * _bars).round()
                                      ? AppColors.red
                                      : const Color(0x33FFFFFF),
                                  borderRadius: BorderRadius.circular(2),
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
            const SizedBox(width: 10),
            const _Chevron(),
          ],
        ),
      ),
    );
  }
}
