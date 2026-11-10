import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/countries/country.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/country_picker.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';

/// A Zawapay account that can be used as a sponsor.
class Sponsor {
  const Sponsor({
    required this.username,
    required this.fullName,
    required this.country,
    this.photoUrl,
  });

  /// Unique username, written without the "@".
  final String username;
  final String fullName;
  final Country country;

  /// Profile photo. When missing, the initials are shown instead.
  final String? photoUrl;

  String get initials => fullName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// Demo accounts, only for the UI. They will be replaced by a search on the
/// Zawapay server once it exists.
final List<Sponsor> demoSponsors = [
  Sponsor(
    username: 'zawapay',
    fullName: 'Zawapay App',
    country: _country('CD'),
  ),
  Sponsor(username: 'amina', fullName: 'Amina Diallo', country: _country('SN')),
  Sponsor(
    username: 'kofi.mensah',
    fullName: 'Kofi Mensah',
    country: _country('CI'),
  ),
];

Country _country(String isoCode) =>
    supportedCountries.firstWhere((country) => country.isoCode == isoCode);

/// "Invitation parrain ou marraine": the username of the person who invited
/// the user (never called a "referral code" in the app), always starting with "@".
///
/// No suggestion is shown while typing. Only when the username is written
/// exactly does the sponsor appear: photo on the left, before the "@", and
/// country flag on the right. The user then taps "Confirm" to say it is the
/// right person.
class SponsorInvitationField extends StatefulWidget {
  const SponsorInvitationField({super.key, this.onConfirmed});

  /// Called with the sponsor once confirmed, and with null when it is undone.
  final ValueChanged<Sponsor?>? onConfirmed;

  @override
  State<SponsorInvitationField> createState() => _SponsorInvitationFieldState();
}

class _SponsorInvitationFieldState extends State<SponsorInvitationField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Sponsor? _found;
  bool _confirmed = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String username) {
    final match = demoSponsors
        .where((sponsor) => sponsor.username == username)
        .firstOrNull;
    setState(() => _found = match);
  }

  void _confirm() {
    _focusNode.unfocus();
    setState(() => _confirmed = true);
    widget.onConfirmed?.call(_found);
  }

  void _change() {
    setState(() => _confirmed = false);
    widget.onConfirmed?.call(null);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sponsor = _found;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l10n.sponsorInvitationLabel),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          padding: EdgeInsets.only(left: sponsor == null ? 22 : 12, right: 12),
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: _confirmed ? AppColors.red : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              if (sponsor != null) ...[
                _SponsorPhoto(sponsor: sponsor),
                const SizedBox(width: 10),
              ],
              const Text(
                '@',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: TextField(
                  // Tapping anywhere outside the field closes the keyboard.
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: _confirmed,
                  onChanged: _onChanged,
                  // No keyboard suggestions or corrections on a username.
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9._]')),
                    LengthLimitingTextInputFormatter(30),
                    const _LowerCaseFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.sponsorInvitationHint,
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              if (sponsor != null) ...[
                const SizedBox(width: 8),
                RoundFlag(country: sponsor.country, size: 30),
              ],
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: sponsor == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _confirmed
                      ? _ConfirmedLine(sponsor: sponsor, onChange: _change)
                      : _ConfirmCard(sponsor: sponsor, onConfirm: _confirm),
                ),
        ),
      ],
    );
  }
}

/// "Is this your sponsor?" with the name, country and a Confirm button.
class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.sponsor, required this.onConfirm});

  final Sponsor sponsor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sponsorQuestion,
                  style: AppText.label.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  sponsor.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  sponsor.country.name(l10n),
                  style: AppText.label.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                textStyle: AppText.button.copyWith(fontSize: 15),
              ),
              child: Text(l10n.sponsorConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown once the sponsor is confirmed, with a link to change it.
class _ConfirmedLine extends StatelessWidget {
  const _ConfirmedLine({required this.sponsor, required this.onChange});

  final Sponsor sponsor;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.sponsorConfirmed(sponsor.fullName),
              style: AppText.label.copyWith(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ),
          UnderlinedLink(text: l10n.sponsorChange, onTap: onChange),
        ],
      ),
    );
  }
}

/// Round profile photo of the sponsor, or the initials on red.
class _SponsorPhoto extends StatelessWidget {
  const _SponsorPhoto({required this.sponsor});

  final Sponsor sponsor;

  @override
  Widget build(BuildContext context) {
    final photo = sponsor.photoUrl;

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.red,
      foregroundImage: photo == null ? null : NetworkImage(photo),
      child: Text(
        sponsor.initials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _LowerCaseFormatter extends TextInputFormatter {
  const _LowerCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}
