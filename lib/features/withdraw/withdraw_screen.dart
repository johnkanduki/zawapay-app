import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/countries/country.dart';
import '../../core/account/app_rules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_amount_screen.dart';
import '../send/send_ui.dart';
import 'pin_sheet.dart';
import 'withdraw_pending_screen.dart';
import 'withdraw_rules.dart';

/// "Withdraw": money from the Zawapay balance to the receiving Mobile Money
/// number given at sign-up (the payment number when the box "same number"
/// stayed ticked). The fee, if any, is taken on top of the amount, like for
/// sending; the 4-digit PIN confirms.
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
  late String _currency = widget.country.currencies.first;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double get _value =>
      double.tryParse(_amount.text.replaceAll(',', '.').replaceAll(' ', '')) ??
      0;
  double get _balance => widget.balances[_currency] ?? 0;
  double get _fee => _rules.feeFor(_value);
  double get _minimum => _rules.minimumFor(_currency);

  bool get _belowMinimum => _value > 0 && _value < _minimum;
  bool get _tooMuch => _value > 0 && _value + _fee > _balance;
  bool get _canWithdraw =>
      widget.phone != null && _value > 0 && !_belowMinimum && !_tooMuch;

  /// Changing the currency starts the amount again from 0.
  void _selectCurrency(String currency) {
    if (currency == _currency) return;
    setState(() {
      _currency = currency;
      _amount.clear();
    });
  }

  /// The whole balance, minus the fee taken on top.
  void _withdrawAll() {
    final rate = _rules.feeRate;
    final all = (_balance / (1 + rate) * 100).floorToDouble() / 100;
    setState(() => _amount.text = all <= 0 ? '' : _plain(all));
  }

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _withdraw() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!await askWithdrawPin(context) || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WithdrawPendingScreen(
          amount: _value,
          fee: _fee,
          currency: _currency,
          phone: widget.phone!,
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
    String amount(double v) => '${money.format(v)} $_currency';
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
                                symbol: _currency,
                                child: TextField(
                                  onTapOutside: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                  controller: _amount,
                                  autofocus: true,
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
                              // Not enough money, or below the minimum.
                              SizedBox(
                                height: 22,
                                child: Center(
                                  child: Text(
                                    warning ??
                                        l10n.withdrawMinimum(amount(_minimum)),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: warning == null
                                          ? FontWeight.w400
                                          : FontWeight.w600,
                                      color: warning == null
                                          ? context.zc.soft
                                          : AppColors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 60,
                                child: FilledButton(
                                  onPressed: _canWithdraw ? _withdraw : null,
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
                                    _value > 0
                                        ? l10n.withdrawButton(
                                            amount(_value + _fee),
                                          )
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
