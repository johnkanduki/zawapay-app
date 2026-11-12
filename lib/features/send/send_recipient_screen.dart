import 'dart:async';

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/account/account_error.dart';
import '../../core/account/app_rules.dart';
import '../../core/account/destinations.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../l10n/app_localizations.dart';
import 'recipient.dart';
import 'send_amount_screen.dart';
import 'send_ui.dart';

/// "Send money", step 1: who receives the money.
///
/// By "@" username: the account must exist; it shows with its photo, "@"
/// (and blue badge), name and the withdrawal number where the money will
/// arrive. By NUMBER: no account is looked up at all, the money goes straight
/// to the typed Mobile Money number (the recipient needs no Zawapay account).
/// "Confirm" opens the amount. The 3 recent recipients are listed under it.
class SendRecipientScreen extends StatefulWidget {
  const SendRecipientScreen({
    super.key,
    required this.senderCountry,
    this.recents = const [],
    this.balances = const {},
    this.myUsername,
  });

  /// The sender's own "@": sending to oneself is not offered.
  final String? myUsername;

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

  /// The account found for what is typed, and what to say otherwise.
  Recipient? _found;
  String? _message;
  Timer? _debounce;

  /// What was searched last: an answer for older text is dropped.
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Opens the connection to the server now, so the first search does not
    // pay for it (and refreshes the fees on the way).
    refreshAppRules();
    refreshDestinations();
    // The open countries arrive a moment later: look again.
    destinations.addListener(_search);
  }

  @override
  void dispose() {
    destinations.removeListener(_search);
    _debounce?.cancel();
    _input.dispose();
    super.dispose();
  }

  /// "+243975135801" from the country and the typed number (spaces and a
  /// leading 0 left out); null when too short.
  String? get _fullPhone {
    final typed = _input.text.replaceAll(RegExp(r'\D'), '');
    // In Côte d'Ivoire, Benin, Congo and Gabon the leading 0 is part of the
    // number (07…, 01…, 06…); elsewhere it is the national 0.
    final digits = keepsLeadingZero.contains(_phoneCountry.isoCode)
        ? typed
        : typed.replaceFirst(RegExp('^0+'), '');
    return digits.length < 8 ? null : '${_phoneCountry.dialCode}$digits';
  }

  /// Looks the @ or the withdrawal number up once the user stops typing.
  void _search() {
    _debounce?.cancel();
    final byName = _by == _SearchBy.username;
    final query = byName ? _input.text.trim().toLowerCase() : _fullPhone;
    setState(() {
      _found = null;
      _message = null;
    });
    if (query == null || query.length < 3) {
      _query = '';
      return;
    }
    _query = query;
    // By number: no search, the money goes to this number.
    if (!byName) {
      final digits = query.substring(_phoneCountry.dialCode.length);
      final home = _phoneCountry.isoCode == widget.senderCountry.isoCode;
      if (digits.length >= (home ? 9 : 8)) {
        _show(Recipient.number(_phoneCountry.isoCode, digits));
      }
      return;
    }
    // Accounts known without the server (tests only).
    final local = byName
        ? findByUsername(query)
        : findByPhone(_phoneCountry.isoCode, _input.text);
    if (local != null) {
      _show(local);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final l10n = AppLocalizations.of(context);
      Recipient? match;
      String? message;
      // By @, the photo's address is known already: it downloads at the
      // same time as the search, not after it.
      final photoEarly = _loadPhoto(ZawapayAccount.photoUrlOf(query));
      try {
        final member = await zawapayAccount.findMember(query);
        if (member != null) {
          match = Recipient.fromMember(member);
          // The card waits for the photo at most 1 s; a late photo comes in
          // on its own afterwards.
          final photo = match.photoUrl;
          if (photo != null && mounted) {
            await photoEarly.timeout(
              const Duration(seconds: 1),
              onTimeout: () {},
            );
          }
        } else {
          message = l10n.sendUsernameNotFound;
        }
      } catch (error) {
        if (mounted) message = accountErrorText(context, error);
      }
      if (!mounted || _query != query) return;
      if (match != null) {
        _show(match);
      } else {
        setState(() => _message = message);
      }
    });
  }

  /// Downloads a photo into the image cache; never fails.
  Future<void> _loadPhoto(String url) =>
      precacheImage(NetworkImage(url), context, onError: (_, _) {});

  void _show(Recipient recipient) {
    final l10n = AppLocalizations.of(context);
    final own =
        !recipient.isNumber &&
        widget.myUsername != null &&
        recipient.username == widget.myUsername;
    // Between the 12 countries: only the ones opened in the admin
    // dashboard (RD Congo → RD Congo always works).
    final home =
        recipient.countryCode == 'CD' && widget.senderCountry.isoCode == 'CD';
    final closed = !home && destinationFor(recipient.countryCode) == null;
    setState(() {
      _found = own || closed ? null : recipient;
      _message = own
          ? l10n.sendOwnAccount
          : closed
          ? l10n.sendCountryClosed
          : null;
    });
  }

  void _switchTo(_SearchBy by) {
    if (by == _by) return;
    setState(() {
      _by = by;
      _input.clear();
    });
    _search();
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
    final message = _message;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: context.zc.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SearchSwitch(by: _by, onChanged: _switchTo),
                    const SizedBox(height: 12),
                    if (_by == _SearchBy.username)
                      _InputBox(
                        prefix: Text(
                          '@',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: context.zc.text,
                          ),
                        ),
                        child: _textField(
                          hint: l10n.sendUsernameHint,
                          keyboard: TextInputType.visiblePassword,
                          formatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9_-]'),
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
                                _search();
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InputBox(
                              child: _textField(
                                hint: l10n.sendWithdrawNumberHint,
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
                                onConfirm: () => _open(found),
                              ),
                            )
                          : message != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.zc.soft,
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
      onChanged: (_) => _search(),
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: keyboard,
      inputFormatters: formatters,
      cursorColor: AppColors.red,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: context.zc.text,
      ),
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: context.zc.faint,
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
                  color: selected ? AppColors.white : context.zc.soft,
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
                      color: selected ? AppColors.white : context.zc.soft,
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
      decoration: ShapeDecoration(
        color: context.zc.field,
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
        color: context.zc.field,
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
          color: context.zc.field,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleFlag(country.isoCode, size: 30),
            const SizedBox(width: 8),
            Text(
              country.dialCode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.zc.text,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: context.zc.soft),
          ],
        ),
      ),
    );
  }
}

/// The matching account, as for the sponsor at sign-up: photo, "@"
/// (badge), name, the withdrawal number where the money will arrive, and
/// "Confirm", which opens the amount page.
class _FoundAccount extends StatefulWidget {
  const _FoundAccount({required this.recipient, required this.onConfirm});

  final Recipient recipient;
  final VoidCallback onConfirm;

  @override
  State<_FoundAccount> createState() => _FoundAccountState();
}

/// Tapping the photo (or the name) enlarges it, still round, to make sure it
/// is the right person; tapping again makes it small. The "Confirm" button
/// stays right under it and is scrolled into view: never hidden.
class _FoundAccountState extends State<_FoundAccount> {
  bool _big = false;
  final _confirmKey = GlobalKey();

  void _toggle() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _big = !_big);
    if (_big) {
      // Once the photo has grown, bring "Confirm" into view if needed.
      Future.delayed(const Duration(milliseconds: 260), () {
        final target = _confirmKey.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(
            target,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipient = widget.recipient;
    // Big, but always leaving room for the name and "Confirm".
    final bigSize = (MediaQuery.sizeOf(context).width * 0.5).clamp(
      140.0,
      200.0,
    );

    final details = Column(
      crossAxisAlignment: _big
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        RecipientHandle(recipient: recipient),
        const SizedBox(height: 2),
        if (recipient.isNumber)
          Text(
            l10n.sendStraightToNumber,
            style: TextStyle(fontSize: 14, color: context.zc.soft),
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: _big ? Alignment.center : Alignment.centerLeft,
            child: Text(
              recipient.fullName,
              maxLines: 1,
              style: TextStyle(
                fontSize: _big ? 17 : 15,
                fontWeight: _big ? FontWeight.w600 : FontWeight.w400,
                color: context.zc.text,
              ),
            ),
          ),
        if (!recipient.isNumber && recipient.fullPhone.isNotEmpty)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: _big ? Alignment.center : Alignment.centerLeft,
            child: Text(
              l10n.sendReceivesOn(recipient.fullPhone),
              maxLines: 1,
              style: TextStyle(fontSize: 14, color: context.zc.soft),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.zc.field,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.red, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _big
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        children: [
                          RecipientAvatar(recipient: recipient, size: bigSize),
                          const SizedBox(height: 10),
                          details,
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        RecipientAvatar(recipient: recipient),
                        const SizedBox(width: 12),
                        Expanded(child: details),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            key: _confirmKey,
            height: 48,
            child: FilledButton(
              onPressed: widget.onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.sendConfirm),
            ),
          ),
        ],
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
        color: context.zc.card,
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: context.zc.field,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sendRecents(recents.length),
                        style: TextStyle(fontSize: 16, color: context.zc.soft),
                      ),
                    ),
                    Icon(
                      open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: context.zc.soft,
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
                          if (i > 0) Divider(height: 1, color: context.zc.card),
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
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: context.zc.soft,
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
