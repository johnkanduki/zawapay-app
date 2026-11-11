import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/sponsor_invitation_field.dart';
import 'sign_up_numbers_screen.dart';

/// After "Continue with Google / Apple" for someone who is not a member yet:
/// the sponsor invitation (mandatory), the name when Apple did not give it,
/// and the terms. Then the numbers and the profile photo, like an e-mail
/// sign-up.
class SocialJoinScreen extends StatefulWidget {
  const SocialJoinScreen({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  /// Given by Google or Apple; empty when unknown (then asked here).
  final String firstName;
  final String lastName;

  @override
  State<SocialJoinScreen> createState() => _SocialJoinScreenState();
}

class _SocialJoinScreenState extends State<SocialJoinScreen> {
  late final _firstName = TextEditingController(text: widget.firstName);
  late final _lastName = TextEditingController(text: widget.lastName);
  late final bool _askName =
      widget.firstName.trim().isEmpty || widget.lastName.trim().isEmpty;
  Sponsor? _sponsor;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_firstName, _lastName]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _sponsor != null &&
      _termsAccepted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.socialJoinTitle,
      subtitle: l10n.socialJoinSubtitle,
      children: [
        if (_askName) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.firstNameLabel,
                  hint: l10n.firstNameHint,
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: l10n.lastNameLabel,
                  hint: l10n.lastNameHint,
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        SponsorInvitationField(
          onConfirmed: (sponsor) => setState(() => _sponsor = sponsor),
        ),
        const SizedBox(height: 22),
        AppCheckbox(
          value: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value),
          label: Text.rich(
            TextSpan(
              style: AppText.body(context),
              children: [
                TextSpan(text: l10n.acceptPrefix),
                linkSpan(l10n.acceptTerms, () {}),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: l10n.continueButton,
          onPressed: !_canContinue
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignUpNumbersScreen(
                      signedIn: true,
                      email: '',
                      password: '',
                      sponsor: _sponsor!.username,
                      firstName: _firstName.text.trim(),
                      lastName: _lastName.text.trim(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
