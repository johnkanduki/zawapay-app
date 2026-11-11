import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/account/zawapay_account.dart';
import '../../../core/countries/country.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/zawapay_colors.dart';
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

/// Sponsors known without the server: always empty in the app (tests only).
/// Every other @ is looked up on the Zawapay App server.
final List<Sponsor> knownSponsors = [];

/// The member behind [username] on the server, or null.
Future<Sponsor?> findSponsor(String username) async {
  final member = await zawapayAccount.findMember(username);
  if (member == null) return null;
  final country = supportedCountries.firstWhere(
    (c) => c.isoCode == member.country,
    orElse: () =>
        Country(isoCode: member.country, dialCode: '', currencies: const []),
  );
  return Sponsor(
    username: member.handle,
    fullName: member.name,
    country: country,
    photoUrl: member.hasPhoto ? member.photoUrl : null,
  );
}

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
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Looks the @ up once the user stops typing; only the answer for the
  /// text still in the field is shown.
  void _onChanged(String username) {
    _debounce?.cancel();
    if (_found != null) setState(() => _found = null);
    if (username.length < 3) return;
    final local = knownSponsors
        .where((s) => s.username == username)
        .firstOrNull;
    if (local != null) {
      setState(() => _found = local);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      Sponsor? match;
      // The photo's address is known from the @: it downloads at the same
      // time as the search. The card waits for it at most 1 s; a late photo
      // comes in on its own afterwards.
      final photoEarly = precacheImage(
        NetworkImage(ZawapayAccount.photoUrlOf(username)),
        context,
        onError: (_, _) {},
      );
      try {
        match = await findSponsor(username);
        if (match?.photoUrl != null) {
          await photoEarly.timeout(
            const Duration(seconds: 1),
            onTimeout: () {},
          );
        }
      } catch (_) {
        // No network: nothing shown, the user can type again.
      }
      if (!mounted || _controller.text != username) return;
      setState(() => _found = match);
    });
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
            color: context.zc.field,
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
              Text(
                '@',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.zc.text,
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
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
                    LengthLimitingTextInputFormatter(30),
                    const _LowerCaseFormatter(),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.zc.text,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.sponsorInvitationHint,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: context.zc.soft,
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
        color: context.zc.field,
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
                  style: AppText.label(context).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  sponsor.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.zc.text,
                  ),
                ),
                Text(
                  sponsor.country.name(l10n),
                  style: AppText.label(context).copyWith(fontSize: 13),
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
              style: AppText.label(context)
                  .copyWith(fontSize: 14, color: context.zc.text),
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
