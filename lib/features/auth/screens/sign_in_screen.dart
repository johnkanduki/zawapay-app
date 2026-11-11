import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/account/zawapay_account.dart';
import '../../../core/theme/zawapay_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import '../../support/contact_sheet.dart';
import '../widgets/forgot_password_sheet.dart';
import '../open_home.dart';
import '../widgets/social_logos.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_identifier, _password]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSignIn =>
      _identifier.text.trim().length >= 3 && _password.text.isNotEmpty;

  /// E-mail (or @username) + password, then the home page.
  Future<void> _signIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    try {
      await zawapayAccount.signIn(_identifier.text, _password.text);
      if (mounted) await finishSignIn(context);
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _social({required bool google}) async {
    setState(() => _busy = true);
    try {
      await continueWith(context, google: google);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.signIn,
      subtitle: l10n.authSubtitle,
      children: [
        AppTextField(
          // E-mail + password, or @username + password: the app tells them
          // apart (something before the "@" = an e-mail).
          label: l10n.signInIdLabel,
          hint: l10n.signInIdHint,
          controller: _identifier,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email, AutofillHints.username],
        ),
        const SizedBox(height: 18),
        PasswordField(
          label: l10n.passwordLabel,
          hint: l10n.passwordHint,
          controller: _password,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: l10n.signIn,
          busy: _busy,
          onPressed: _canSignIn && !_busy ? _signIn : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.apple,
                bold: false,
                leading: Icon(Icons.apple, size: 30, color: context.zc.text),
                onPressed: _busy ? null : () => _social(google: false),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SecondaryButton(
                label: l10n.google,
                bold: false,
                leading: const GoogleLogo(size: 24),
                onPressed: _busy ? null : () => _social(google: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              Text(
                l10n.noAccountYet,
                textAlign: TextAlign.center,
                style: AppText.body(context),
              ),
              const SizedBox(height: 2),
              UnderlinedLink(
                text: l10n.signUp,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Each link may go on two lines on a narrow phone, never off screen.
            Flexible(
              child: UnderlinedLink(
                text: l10n.forgotPasswordLink,
                onTap: () => showForgotPasswordSheet(context),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: UnderlinedLink(
                text: l10n.contactSupportLink,
                textAlign: TextAlign.end,
                onTap: () => showContactSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
