import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'recipient.dart';
import 'send_success_screen.dart';
import 'send_ui.dart';

/// Example service fee (6 % of the amount received). The real rate will be
/// an admin setting on the server; this value is only for the UI.
const double exampleServiceFee = 0.06;

/// Fee on top of what the recipient gets: the sender pays
/// received + fee, the recipient gets exactly what was typed.
double feeFor(double received, double rate) => received * rate;

/// "Send money", step 2: the user types what the other person RECEIVES;
/// the fee is added on top and the total to pay shows in the "Pay" button.
class SendAmountScreen extends StatefulWidget {
  const SendAmountScreen({
    super.key,
    required this.recipient,
    required this.senderCountry,
    this.initialAmount,
    this.initialCurrency,
    this.balances = const {},
  });

  final Recipient recipient;
  final Country senderCountry;

  /// Filled in from a QR code that asks for an amount.
  final double? initialAmount;
  final String? initialCurrency;

  /// The sender's Zawapay balance per currency, to pay from it.
  final Map<String, double> balances;

  /// An amount asked for by a QR code cannot be changed by the payer.
  bool get isRequest => initialAmount != null && initialAmount! > 0;

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  late final _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : (widget.initialAmount! == widget.initialAmount!.roundToDouble()
              ? widget.initialAmount!.toStringAsFixed(0)
              : widget.initialAmount!.toStringAsFixed(2)),
  );
  final _note = TextEditingController();

  /// Pay with the Zawapay balance instead of Mobile Money.
  bool _fromBalance = false;
  late String _currency =
      widget.senderCountry.currencies.contains(widget.initialCurrency)
      ? widget.initialCurrency!
      : widget.senderCountry.currencies.first;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// What the other person receives: the only amount the user types.
  double get _received =>
      double.tryParse(_amount.text.replaceAll(',', '.').replaceAll(' ', '')) ??
      0;

  double get _balance => widget.balances[_currency] ?? 0;

  /// Enough Zawapay balance for the amount and the fee.
  bool get _balanceEnough {
    final paid = _received + feeFor(_received, exampleServiceFee);
    return paid > 0 && _balance >= paid;
  }

  /// Changing the currency starts the amount again from 0.
  void _selectCurrency(String currency) {
    if (currency == _currency) return;
    setState(() {
      _currency = currency;
      _amount.clear();
    });
  }

  void _send() {
    final fee = feeFor(_received, exampleServiceFee);
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendSuccessScreen(
          fromBalance: _fromBalance && _balanceEnough,
          recipient: widget.recipient,
          paid: _received + fee,
          received: _received,
          fee: fee,
          currency: _currency,
          note: _note.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final fee = feeFor(_received, exampleServiceFee);
    final paid = _received + fee;
    final symbol = _currency;
    final canSend = _received > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          // Fills the screen; when the keyboard is open the page scrolls,
          // so the fields and "Send" stay reachable.
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          RoundIconButton(
                            icon: Icons.close_rounded,
                            onTap: () =>
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Who receives, with a pencil to change the person.
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          children: [
                            RecipientAvatar(recipient: widget.recipient),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RecipientHandle(recipient: widget.recipient),
                                  Text(
                                    '${widget.recipient.fullName} · '
                                    '${widget.recipient.fullPhone}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: SendColors.soft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // A request is tied to its person: no change.
                            if (!widget.isRequest)
                              RoundIconButton(
                                icon: Icons.edit_rounded,
                                size: 46,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: FramedCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              // The money always comes from Mobile Money:
                              // only the currency is chosen (USD / CDF).
                              // A requested amount keeps its currency.
                              if (!widget.isRequest &&
                                  widget.senderCountry.currencies.length >
                                      1) ...[
                                _CurrencySwitch(
                                  currencies: widget.senderCountry.currencies,
                                  selected: _currency,
                                  onChanged: _selectCurrency,
                                ),
                                const SizedBox(height: 12),
                              ],
                              // The only amount you type: what the
                              // other person receives. The sender pays
                              // every fee on top.
                              _AmountBox(
                                label: widget.isRequest
                                    ? l10n.sendRequested
                                    : l10n.sendReceives,
                                locked: widget.isRequest,
                                symbol: symbol,
                                child: TextField(
                                  // Tapping anywhere outside the field closes the keyboard.
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  controller: _amount,
                                  // Requested: shown, but never editable.
                                  readOnly: widget.isRequest,
                                  enableInteractiveSelection: !widget.isRequest,
                                  showCursor: !widget.isRequest,
                                  autofocus: !widget.isRequest,
                                  onChanged: (_) => setState(() {}),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'),
                                    ),
                                    LengthLimitingTextInputFormatter(12),
                                  ],
                                  cursorColor: AppColors.red,
                                  style: _bigNumber,
                                  decoration: InputDecoration.collapsed(
                                    hintText: '0',
                                    hintStyle: _bigNumber.copyWith(
                                      color: const Color(0x4DFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: SendColors.field,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.sendFee,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            l10n.sendFeePaidByYou,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: SendColors.soft,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${money.format(fee)} $symbol',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Pay with Mobile Money or the Zawapay balance.
                              _SourcePicker(
                                currency: _currency,
                                balance: _balance,
                                balanceEnough: _balanceEnough,
                                hasAmount: canSend,
                                fromBalance: _fromBalance && _balanceEnough,
                                onChanged: (v) =>
                                    setState(() => _fromBalance = v),
                              ),
                              const Spacer(),
                              const SizedBox(height: 16),
                              Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                decoration: const ShapeDecoration(
                                  color: SendColors.field,
                                  shape: StadiumBorder(),
                                ),
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                  // Tapping anywhere outside the field closes the keyboard.
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  controller: _note,
                                  maxLength: 60,
                                  cursorColor: AppColors.red,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                  decoration: InputDecoration.collapsed(
                                    hintText: l10n.sendNoteHint,
                                    hintStyle: const TextStyle(
                                      fontSize: 16,
                                      color: SendColors.soft,
                                    ),
                                  ).copyWith(counterText: ''),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // The total sent to the Mobile Money (USSD)
                              // request is shown right in the button.
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: FilledButton(
                                  onPressed: canSend ? _send : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    disabledBackgroundColor: AppColors.red
                                        .withValues(alpha: 0.35),
                                    foregroundColor: AppColors.white,
                                    disabledForegroundColor: const Color(
                                      0x99FFFFFF,
                                    ),
                                    shape: const StadiumBorder(),
                                    textStyle: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: Text(
                                    canSend
                                        ? l10n.sendPayAmount(
                                            '${money.format(paid)} $symbol',
                                          )
                                        : l10n.sendPay,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

const TextStyle _bigNumber = TextStyle(
  fontSize: 34,
  fontWeight: FontWeight.w700,
  letterSpacing: -1,
  color: AppColors.white,
);

/// "$" for USD, the code for the other currencies.
String currencySymbol(String code) => code == 'USD' ? '\$' : code;

/// "Dollars", "Francs congolais", or the code.
String currencyName(AppLocalizations l10n, String code) => switch (code) {
  'USD' => l10n.currencyUsd,
  'CDF' => l10n.currencyCdf,
  _ => code,
};

/// "USD | CDF" choice, for countries with two currencies.
class _CurrencySwitch extends StatelessWidget {
  const _CurrencySwitch({
    required this.currencies,
    required this.selected,
    required this.onChanged,
  });

  final List<String> currencies;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const ShapeDecoration(
        color: SendColors.field,
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          for (final currency in currencies)
            Expanded(
              child: Semantics(
                button: true,
                selected: currency == selected,
                child: GestureDetector(
                  onTap: () => onChanged(currency),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 42,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: currency == selected
                          ? AppColors.red
                          : Colors.transparent,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      currency,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: currency == selected
                            ? AppColors.white
                            : SendColors.soft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "You pay" / "Receives" box: big number on the left, currency on the right.
class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.label,
    required this.symbol,
    required this.child,
    this.locked = false,
  });

  /// Shows a lock: the amount was asked for and cannot be changed.
  final bool locked;
  final String label;
  final String symbol;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      decoration: BoxDecoration(
        color: SendColors.field,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 10, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      color: SendColors.soft,
                    ),
                  ),
                ),
                if (locked)
                  const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: SendColors.soft,
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: SendColors.field,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 84,
                height: 70,
                decoration: BoxDecoration(
                  color: SendColors.field,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Pay with": Mobile Money (always possible) or the Zawapay balance, which
/// is greyed out with "Insufficient balance" when it does not cover the
/// amount and the fee.
class _SourcePicker extends StatelessWidget {
  const _SourcePicker({
    required this.currency,
    required this.balance,
    required this.balanceEnough,
    required this.hasAmount,
    required this.fromBalance,
    required this.onChanged,
  });

  final String currency;
  final double balance;
  final bool balanceEnough;
  final bool hasAmount;
  final bool fromBalance;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(balance);
    // Without enough balance, only Mobile Money can be picked.
    final balanceBlocked = hasAmount && !balanceEnough;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SendColors.field,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SourceOption(
              icon: Icons.phone_android_rounded,
              title: l10n.sendMobileMoney,
              subtitle: l10n.sendViaUssd,
              selected: !fromBalance,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SourceOption(
              icon: Icons.account_balance_wallet_rounded,
              title: l10n.sendZawapayBalance,
              subtitle: balanceBlocked
                  ? l10n.sendInsufficient
                  : '$money $currency',
              warning: balanceBlocked,
              selected: fromBalance,
              onTap: balanceBlocked || !hasAmount
                  ? null
                  : () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool warning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !selected;

    return Semantics(
      button: true,
      selected: selected,
      enabled: !disabled,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.red.withValues(alpha: 0.16) : null,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.red : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: disabled && !warning ? 0.5 : 1,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.red : AppColors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: disabled ? SendColors.soft : AppColors.white,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: warning
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: warning ? AppColors.red : SendColors.soft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
