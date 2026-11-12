import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/countries/country.dart';
import '../../core/account/account_error.dart';
import '../../core/account/app_rules.dart';
import '../../core/account/zawapay_account.dart';
import '../history/my_transfers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_amount_screen.dart';
import '../send/send_ui.dart';
import 'pin_sheet.dart';
import 'withdraw_pending_screen.dart';
import 'withdraw_rules.dart';

/// The server calls of a withdrawal; tests replace them.
class WithdrawalApi {
  const WithdrawalApi({required this.quote, required this.create});

  final Future<Map<String, dynamic>> Function(String amount, String currency)
  quote;
  final Future<Map<String, dynamic>> Function(
    String amount,
    String currency,
    String pin,
  )
  create;
}

WithdrawalApi withdrawalApi = WithdrawalApi(
  quote: (amount, currency) =>
      zawapayAccount.quoteWithdrawal(amount: amount, currency: currency),
  create: (amount, currency, pin) => zawapayAccount.createWithdrawal(
    amount: amount,
    currency: currency,
    pin: pin,
  ),
);

/// "Withdraw": money from the Zawapay balance — ONE balance, in dollars —
/// to the withdrawal number. The amount is typed in dollars; the member gets
/// the currency of their withdrawal number (RD Congo: USD or CDF, chosen
/// here), at the week's rate given by the server. The fee, if any, is taken
/// on top; the 4-digit PIN confirms.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({
    super.key,
    required this.country,
    required this.phone,
    this.balances = const {},
    this.rules,
  });

  final Country country;

  /// "+243812345678"; null when no number was given yet.
  final String? phone;
  final Map<String, double> balances;

  /// Null: the rules set in the admin dashboard.
  final WithdrawRules? rules;

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amount = TextEditingController();
  late final WithdrawRules _rules = widget.rules ?? currentWithdrawRules;

  /// The currency received on the withdrawal number (RD Congo: USD or CDF).
  late String _currency = widget.country.currencies.first;

  /// What the server says will arrive, in [_currency] (null: not asked yet).
  Map<String, dynamic>? _quote;
  String? _quoteError;
  Timer? _quoteTimer;
  int _quoteSeq = 0;
  bool _busy = false;

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _amount.dispose();
    super.dispose();
  }

  /// Asks the server what arrives on the number, once the user stops typing.
  void _askQuote() {
    _quoteTimer?.cancel();
    final seq = ++_quoteSeq;
    setState(() {
      _quote = null;
      _quoteError = null;
    });
    // Even when the balance is too small, show what WOULD arrive (the
    // button stays off).
    if (_value <= 0 || _belowMinimum) return;
    final amount = _value.toStringAsFixed(2);
    _quoteTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final q = await withdrawalApi.quote(amount, _currency);
        if (mounted && seq == _quoteSeq) setState(() => _quote = q);
      } catch (error) {
        if (mounted && seq == _quoteSeq) {
          setState(() => _quoteError = accountErrorText(context, error));
        }
      }
    });
  }

  double get _value =>
      double.tryParse(_amount.text.replaceAll(',', '.').replaceAll(' ', '')) ??
      0;
  // Everything is counted in dollars (rule "tout en dollars").
  double get _balance => widget.balances['USD'] ?? 0;
  double get _fee => _rules.feeFor(_value);
  double get _minimum => _rules.minimumFor('USD');

  bool get _belowMinimum => _value > 0 && _value < _minimum;
  bool get _tooMuch => _value > 0 && _value + _fee > _balance;
  bool get _canWithdraw =>
      widget.phone != null && _value > 0 && !_belowMinimum && !_tooMuch;

  /// Changing the currency starts the amount again from 0.
  void _selectCurrency(String currency) {
    if (currency == _currency) return;
    setState(() => _currency = currency);
    _askQuote();
  }

  /// The whole balance, minus the fee taken on top.
  void _withdrawAll() {
    final rate = _rules.feeRate;
    final all = (_balance / (1 + rate) * 100).floorToDouble() / 100;
    setState(() => _amount.text = all <= 0 ? '' : _plain(all));
    _askQuote();
  }

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _withdraw() async {
    FocusManager.instance.primaryFocus?.unfocus();
    // The PIN is checked by the server, then sent with the withdrawal.
    final pin = await askWithdrawPin(context);
    if (pin == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final w = await withdrawalApi.create(
        _value.toStringAsFixed(2),
        _currency,
        pin,
      );
      refreshMyTransfers(); // the balance goes down at once
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WithdrawPendingScreen(
            amount: double.tryParse('${w['receive']}') ?? _value,
            fee: 0,
            currency: '${w['receiveCurrency'] ?? _currency}',
            phone: widget.phone!,
          ),
        ),
      );
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    // The balance, the amount and the fee are in dollars.
    String amount(double v) => '${money.format(v)} USD';
    final receive = _currency == 'USD'
        ? (_value > 0 ? '${money.format(_value)} USD' : null)
        : _quote == null
        ? null
        : '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 0).format(double.tryParse('${_quote!['receive']}') ?? 0)} $_currency';
    final warning = _tooMuch
        ? l10n.sendInsufficient
        : _belowMinimum
        ? l10n.withdrawMinimum(amount(_minimum))
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.withdrawTitle,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: context.zc.text,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Where the money goes: the receiving number.
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.zc.field,
                              ),
                              child: RoundFlag(
                                country: widget.country,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.withdrawTo,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.zc.soft,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.phone ?? l10n.withdrawNoNumber,
                                      style: TextStyle(
                                        fontSize: widget.phone == null
                                            ? 15
                                            : 18,
                                        fontWeight: FontWeight.w600,
                                        color: context.zc.text,
                                      ),
                                    ),
                                  ),
                                  if (widget.phone != null)
                                    Text(
                                      l10n.withdrawToHelp,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.zc.soft,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: FramedCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.country.currencies.length > 1) ...[
                                CurrencySwitch(
                                  currencies: widget.country.currencies,
                                  selected: _currency,
                                  onChanged: _selectCurrency,
                                ),
                                const SizedBox(height: 12),
                              ],
                              AmountBox(
                                label: l10n.withdrawAmount,
                                symbol: 'USD',
                                child: TextField(
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  controller: _amount,
                                  autofocus: true,
                                  onChanged: (_) => _askQuote(),
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
                                  style: bigAmountStyle(context),
                                  decoration: InputDecoration.collapsed(
                                    hintText: '0',
                                    hintStyle: bigAmountStyle(context)
                                        .copyWith(color: context.zc.faint),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // What is available, and "Withdraw all".
                              Row(
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.withdrawAvailable(
                                          amount(_balance),
                                        ),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: context.zc.soft,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _balance > 0 ? _withdrawAll : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 9,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: AppColors.red.withValues(
                                          alpha: _balance > 0 ? 0.18 : 0.08,
                                        ),
                                        shape: const StadiumBorder(),
                                      ),
                                      child: Text(
                                        l10n.withdrawAll,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _balance > 0
                                              ? AppColors.red
                                              : context.zc.soft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: context.zc.field,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        feeLabel(
                                          context,
                                          send: false,
                                          fallback: l10n.withdrawFee,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: context.zc.text,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _rules.feeRate == 0
                                          ? l10n.withdrawFree
                                          : amount(_fee),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: context.zc.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // What arrives on the number (week's rate), then
                              // "Solde insuffisant" or the minimum, in red.
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (receive != null)
                                      Text(
                                        l10n.withdrawYouReceive(receive),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: context.zc.text,
                                        ),
                                      ),
                                    // The week's rate used (other currencies).
                                    if (_currency != 'USD' && _quote != null)
                                      Text(
                                        l10n.withdrawRate(
                                          NumberFormat.decimalPatternDigits(
                                            locale: locale,
                                            decimalDigits: 0,
                                          ).format(
                                            double.tryParse(
                                                  '${_quote!['rate']}',
                                                ) ??
                                                0,
                                          ),
                                          _currency,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.zc.soft,
                                        ),
                                      ),
                                    Text(
                                      warning ??
                                          _quoteError ??
                                          (receive == null
                                              ? l10n.withdrawMinimum(
                                                  amount(_minimum),
                                                )
                                              : ''),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            warning == null &&
                                                _quoteError == null
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                        color:
                                            warning == null &&
                                                _quoteError == null
                                            ? context.zc.soft
                                            : AppColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 60,
                                child: FilledButton(
                                  onPressed:
                                      _canWithdraw &&
                                          !_busy &&
                                          _quoteError == null &&
                                          (_currency == 'USD' || _quote != null)
                                      ? _withdraw
                                      : null,
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
                                      fontFamily: 'Inter',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: Text(
                                    // The button shows what ARRIVES on the
                                    // number, in the chosen currency.
                                    _value <= 0
                                        ? l10n.homeWithdraw
                                        : _currency == 'USD'
                                        ? l10n.withdrawButton(
                                            amount(_value + _fee),
                                          )
                                        : receive != null
                                        ? l10n.withdrawButton(receive)
                                        : l10n.homeWithdraw,
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
