import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_card_scaffold.dart';
import '../../core/widgets/country_picker.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/onboarding_screen.dart';

/// Very first screen, shown once: the user picks a country and a language.
/// The language changes the whole app right away.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Language names are always written in their own language.
  static const _languages = [
    (Locale('fr'), 'Français'),
    (Locale('en'), 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.of(context);
    // No language is ticked until the user picks one (no default).
    final chosenLanguage = settings.locale?.languageCode;
    final country = settings.country;

    return AuthCardScaffold(
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeSubtitle,
      children: [
        FieldLabel(l10n.countryLabel),
        _SelectorTile(
          onTap: () async {
            final picked = await showCountryPicker(context, selected: country);
            if (picked != null) settings.setCountry(picked);
          },
          leading: country == null
              ? Icon(Icons.public_rounded, color: context.zc.soft, size: 28)
              : RoundFlag(country: country),
          text: country == null ? l10n.countryHint : country.name(l10n),
          isPlaceholder: country == null,
          trailing: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.zc.text,
          ),
        ),
        const SizedBox(height: 22),
        FieldLabel(l10n.languageLabel),
        for (final (locale, name) in _languages) ...[
          _SelectorTile(
            onTap: () => settings.setLocale(locale),
            text: name,
            selected: chosenLanguage == locale.languageCode,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 18),
        PrimaryButton(
          label: l10n.continueButton,
          onPressed: country == null || chosenLanguage == null
              ? null
              : () {
                  settings.completeSetup();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  );
                },
        ),
      ],
    );
  }
}

/// Rounded grey row used for the country selector and the language choices.
/// When [selected] is not null, a round red check shows the current choice.
class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.onTap,
    required this.text,
    this.leading,
    this.trailing,
    this.selected,
    this.isPlaceholder = false,
  });

  final VoidCallback onTap;
  final String text;
  final Widget? leading;
  final Widget? trailing;
  final bool? selected;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: ShapeDecoration(
          color: context.zc.field,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppColors.red : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isPlaceholder ? context.zc.soft : context.zc.text,
                ),
              ),
            ),
            ?trailing,
            if (selected != null) _RadioDot(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.red : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: context.zc.soft, width: 1.6),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 16, color: context.zc.raised)
          : null,
    );
  }
}
