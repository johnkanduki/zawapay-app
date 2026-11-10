import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../l10n/app_localizations.dart';
import 'recipient.dart';
import 'send_amount_screen.dart';
import 'send_ui.dart';

/// "Send money", step 1: who receives the money.
///
/// The user chooses to search by "@" username or by phone number. As soon as
/// an account matches exactly, it shows with its "@" (and blue badge), name,
/// flag and number; tapping it goes to the amount. The 3 recent recipients
/// are listed under it.
class SendRecipientScreen extends StatefulWidget {
  const SendRecipientScreen({
    super.key,
    required this.senderCountry,
    this.recents = const [],
    this.balances = const {},
  });

  final Country senderCountry;
  final List<Recipient> recents;

  /// The user's Zawapay balance, to pay from it.
  final Map<String, double> balances;

  @override
  State<SendRecipientScreen> createState() => _SendRecipientScreenState();
}

enum _SearchBy { username, phone }

class _SendRecipientScreenState extends State<SendRecipientScreen> {
  final _input = TextEditingController();
  _SearchBy _by = _SearchBy.username;
  late Country _phoneCountry = widget.senderCountry;
  bool _recentsOpen = true;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Recipient? get _found => _by == _SearchBy.username
      ? findByUsername(_input.text)
      : findByPhone(_phoneCountry.isoCode, _input.text);

  /// A full phone number that matches no account.
  bool get _phoneNotFound =>
      _by == _SearchBy.phone &&
      _input.text.replaceAll(RegExp(r'\D'), '').length >= 9 &&
      _found == null;

  void _switchTo(_SearchBy by) {
    if (by == _by) return;
    setState(() {
      _by = by;
      _input.clear();
    });
  }

  void _open(Recipient recipient) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendAmountScreen(
          recipient: recipient,
          senderCountry: widget.senderCountry,
          balances: widget.balances,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final found = _found;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 22),
              FramedCard(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        l10n.sendTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SearchSwitch(by: _by, onChanged: _switchTo),
                    const SizedBox(height: 12),
                    if (_by == _SearchBy.username)
                      _InputBox(
                        prefix: const Text(
                          '@',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        child: _textField(
                          hint: l10n.sendUsernameHint,
                          keyboard: TextInputType.visiblePassword,
                          formatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9._]'),
                            ),
                            LengthLimitingTextInputFormatter(30),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          _CountryButton(
                            country: _phoneCountry,
                            onTap: () async {
                              final picked = await showCountryPicker(
                                context,
                                selected: _phoneCountry,
                              );
                              if (picked != null) {
                                setState(() => _phoneCountry = picked);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InputBox(
                              child: _textField(
                                hint: l10n.sendPhoneHint,
                                keyboard: TextInputType.phone,
                                formatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9 ]'),
                                  ),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    // The account appears only when it matches exactly.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: found != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _FoundAccount(
                                recipient: found,
                                onTap: () => _open(found),
                              ),
                            )
                          : _phoneNotFound
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
                              child: Text(
                                l10n.sendPhoneNotFound,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: SendColors.soft,
                                ),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
              if (widget.recents.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Recents(
                  recents: widget.recents,
                  open: _recentsOpen,
                  onToggle: () => setState(() => _recentsOpen = !_recentsOpen),
                  onSelect: _open,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required String hint,
    required TextInputType keyboard,
    required List<TextInputFormatter> formatters,
  }) {
    return TextField(
      // Tapping anywhere outside the field closes the keyboard.
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: _input,
      autofocus: false,
      onChanged: (_) => setState(() {}),
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: keyboard,
      inputFormatters: formatters,
      cursorColor: AppColors.red,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: Color(0x66FFFFFF),
        ),
      ),
    );
  }
}

/// "Username | Phone number" choice.
class _SearchSwitch extends StatelessWidget {
  const _SearchSwitch({required this.by, required this.onChanged});

  final _SearchBy by;
  final ValueChanged<_SearchBy> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget option(_SearchBy value, String label, IconData icon) {
      final selected = value == by;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: ShapeDecoration(
              color: selected ? AppColors.red : Colors.transparent,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.white : SendColors.soft,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.white : SendColors.soft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const ShapeDecoration(
        color: SendColors.field,
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          option(
            _SearchBy.username,
            l10n.sendByUsername,
            Icons.alternate_email_rounded,
          ),
          option(_SearchBy.phone, l10n.sendByPhone, Icons.phone_rounded),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child, this.prefix});

  final Widget child;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: SendColors.field,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (prefix != null) ...[prefix!, const SizedBox(width: 2)],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        decoration: BoxDecoration(
          color: SendColors.field,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleFlag(country.isoCode, size: 30),
            const SizedBox(width: 8),
            Text(
              country.dialCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: SendColors.soft,
            ),
          ],
        ),
      ),
    );
  }
}

/// The matching account: "@" (badge), name, flag and number.
class _FoundAccount extends StatelessWidget {
  const _FoundAccount({required this.recipient, required this.onTap});

  final Recipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        decoration: BoxDecoration(
          color: SendColors.field,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.red, width: 1.5),
        ),
        child: Row(
          children: [
            RecipientAvatar(recipient: recipient),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecipientHandle(recipient: recipient),
                  const SizedBox(height: 2),
                  Text(
                    recipient.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    recipient.fullPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SendColors.soft,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Recent (3)" card that can be folded.
class _Recents extends StatelessWidget {
  const _Recents({
    required this.recents,
    required this.open,
    required this.onToggle,
    required this.onSelect,
  });

  final List<Recipient> recents;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<Recipient> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: ColoredBox(
        color: SendColors.card,
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: SendColors.field,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sendRecents(recents.length),
                        style: const TextStyle(
                          fontSize: 16,
                          color: SendColors.soft,
                        ),
                      ),
                    ),
                    Icon(
                      open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: SendColors.soft,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              alignment: Alignment.topCenter,
              child: !open
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      children: [
                        for (var i = 0; i < recents.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: SendColors.card),
                          GestureDetector(
                            onTap: () => onSelect(recents[i]),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                12,
                              ),
                              child: Row(
                                children: [
                                  RecipientAvatar(recipient: recents[i]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RecipientHandle(recipient: recents[i]),
                                        const SizedBox(height: 2),
                                        Text(
                                          recents[i].fullPhone,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: SendColors.soft,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
