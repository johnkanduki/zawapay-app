import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../support/contact_sheet.dart';

/// Version shown in Settings and in "About" (same as pubspec.yaml).
const appVersion = '1.0.0';

/// Tall sheet of the Settings pages (as at the reference): round close button
/// at the top right, then one framed card holding pill rows. Light: grey
/// sheet, white card, grey pills. Dark: black sheet, see-through cards.
Future<void> showSettingsSheet(
  BuildContext context, {
  required WidgetBuilder card,
  WidgetBuilder? below,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.scrim,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: context.zc.page,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        // Scrolls when the keyboard is open (forms).
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.zc.isDark
                          ? context.zc.field
                          : context.zc.raised,
                    ),
                    child: Icon(Icons.close_rounded, color: context.zc.text),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: context.zc.frame),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: context.zc.card,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: card(context),
                ),
              ),
              if (below != null) below(context),
            ],
          ),
        ),
      ),
    ),
  );
}

/// One rounded pill: title (and grey subtitle), and a radio or an arrow.
class SheetPill extends StatelessWidget {
  const SheetPill({
    super.key,
    required this.title,
    this.subtitle,
    this.selected,
    this.titleColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;

  /// Radio when not null; otherwise an arrow.
  final bool? selected;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final zc = context.zc;
    final radio = selected;

    return Semantics(
      button: true,
      selected: radio ?? false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.fromLTRB(22, 14, 18, 14),
          decoration: ShapeDecoration(
            color: zc.field,
            shape: const StadiumBorder(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: radio == null
                            ? FontWeight.w400
                            : FontWeight.w700,
                        color: titleColor ?? zc.text,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 14, color: zc.soft),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (radio == null)
                Icon(Icons.chevron_right_rounded, color: zc.soft, size: 26)
              else
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: radio ? AppColors.red : zc.soft,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: radio
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.red,
                          ),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings → Language: Français (always first), then English.
Future<void> showLanguageSheet(BuildContext context) => showSettingsSheet(
  context,
  card: (context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.maybeOf(context);
    final current = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            l10n.languageIntro,
            style: TextStyle(fontSize: 16, color: context.zc.soft),
          ),
        ),
        for (final (code, name) in [('fr', 'Français'), ('en', 'English')]) ...[
          SheetPill(
            title: name,
            selected: current == code,
            onTap: () => settings?.setLocale(Locale(code)),
          ),
          if (code == 'fr') const SizedBox(height: 10),
        ],
      ],
    );
  },
);

/// Settings → About: privacy policy, terms, delete the account, version.
Future<void> showAboutSheet(BuildContext context) => showSettingsSheet(
  context,
  card: (context) {
    final l10n = AppLocalizations.of(context);
    void soon() =>
        showTopNotice(context, l10n.contactSoon, icon: Icons.info_rounded);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 18),
          child: Text(
            l10n.aboutTitle,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: context.zc.text,
            ),
          ),
        ),
        SheetPill(title: l10n.aboutPrivacy, onTap: soon),
        const SizedBox(height: 10),
        SheetPill(title: l10n.aboutTerms, onTap: soon),
        const SizedBox(height: 10),
        // Deleting goes through the support for now (it needs a decision
        // for the sponsor tree: who takes the filleuls).
        SheetPill(
          title: l10n.aboutDeleteAccount,
          titleColor: AppColors.red,
          onTap: () => showContactSheet(context),
        ),
      ],
    );
  },
  below: (context) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      children: [
        Text(
          AppLocalizations.of(context).aboutVersion,
          style: TextStyle(fontSize: 16, color: context.zc.soft),
        ),
        const SizedBox(height: 4),
        Text(
          appVersion,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.zc.text,
          ),
        ),
      ],
    ),
  ),
);
