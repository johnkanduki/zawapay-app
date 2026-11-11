import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../send/recipient.dart';
import '../send/send_ui.dart';
import 'pay_qr.dart';
import 'share_qr_image.dart';
import 'zawapay_qr.dart';

/// "My QR code" as its own page (from the scanner), with a back button.
class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key, required this.me});

  final Recipient me;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(child: MyQrView(me: me, showBack: true)),
      ),
    );
  }
}

/// The user's own payment code: "Scan to pay", the name and "@", the QR
/// code with the Zawapay logo in the middle, "Copy" and "Add an amount".
///
/// The code always points to the user's fixed "@": it can never be changed.
/// Adding an amount only adds the amount asked for to it.
/// Used by the middle tab of the home page and by "My QR code".
class MyQrView extends StatefulWidget {
  const MyQrView({
    super.key,
    required this.me,
    this.showBack = false,
    this.bottomSpace = 0,
  });

  final Recipient me;
  final bool showBack;

  /// Room to leave at the end (for the floating bottom bar).
  final double bottomSpace;

  @override
  State<MyQrView> createState() => _MyQrViewState();
}

class _MyQrViewState extends State<MyQrView> {
  double? _amount;
  late String _currency = widget.me.country.currencies.first;

  bool _sharing = false;

  /// "100 USD", or null when no amount is asked for.
  String? _amountLabel() {
    final amount = _amount;
    if (amount == null) return null;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    ).format(amount);
    return '$text $_currency';
  }

  /// Opens the phone's share menu with the QR code as an image (WhatsApp,
  /// Facebook, "Save image"…).
  Future<void> _share(String data) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _sharing = true);
    try {
      final file = await buildShareQrImage(
        data: data,
        handle: widget.me.handle,
        scanLabel: l10n.scanToPay,
        amountLabel: _amountLabel(),
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l10n.myQrShareText(widget.me.handle),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        showTopNotice(context, l10n.myQrShareFailed, icon: Icons.error_rounded);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _askAmount() async {
    final result = await showModalBottomSheet<(double, String)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.scrim,
      backgroundColor: Colors.transparent,
      builder: (_) => _AmountSheet(
        currencies: widget.me.country.currencies,
        currency: _currency,
        amount: _amount,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        // 0 means "remove the amount": the code goes back to a free amount.
        _amount = result.$1 > 0 ? result.$1 : null;
        _currency = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final me = widget.me;
    final qrSize = MediaQuery.sizeOf(context).width * 0.56;
    final data = PayQr.forUsername(
      me.username,
      amount: _amount,
      currency: _currency,
    );
    final amount = _amount;

    // The back button stays fixed at the top; only the card scrolls.
    // A large space is left at the bottom so the page feels open.
    final list = ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        widget.showBack ? 10 : 18,
        16,
        widget.bottomSpace + 120,
      ),
      children: [
        FramedCard(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          child: Column(
            children: [
              Text(
                l10n.scanToPay,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: context.zc.text,
                ),
              ),
              const SizedBox(height: 18),
              // Photo with the country flag, then the "@" and the name.
              RecipientAvatar(recipient: me, size: 64),
              const SizedBox(height: 10),
              RecipientHandle(recipient: me, fontSize: 21),
              const SizedBox(height: 2),
              Text(
                me.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: context.zc.soft),
              ),
              const SizedBox(height: 18),
              // Light frame, white card, round dots, logo in the middle.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ZawapayQr(data: data, size: qrSize),
                ),
              ),
              if (amount != null) ...[
                const SizedBox(height: 14),
                _AmountChip(
                  text: l10n.myQrAsked(
                    '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: amount == amount.roundToDouble() ? 0 : 2).format(amount)} $_currency',
                  ),
                  onClear: () => setState(() => _amount = null),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _sharing ? null : () => _share(data),
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                  label: Text(l10n.myQrShare),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.zc.field,
                    foregroundColor: context.zc.text,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _askAmount,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    amount == null
                        ? l10n.myQrRequestMoney
                        : l10n.myQrEditRequest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Back only when there is a page to go back to (never a black screen).
    if (!widget.showBack || !Navigator.of(context).canPop()) return list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RoundIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        Expanded(child: list),
      ],
    );
  }
}

/// "10 USD asked" with a cross to remove the amount.
class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.text, required this.onClear});

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: ShapeDecoration(
        color: AppColors.red.withValues(alpha: 0.16),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.red,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.cancel_rounded,
              size: 22,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small sheet: currency (USD / CDF) and the amount to ask for.
class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.currencies,
    required this.currency,
    required this.amount,
  });

  final List<String> currencies;
  final String currency;
  final double? amount;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late String _currency = widget.currency;
  late final _input = TextEditingController(
    text: widget.amount == null
        ? ''
        : widget.amount!.toStringAsFixed(
            widget.amount! == widget.amount!.roundToDouble() ? 0 : 2,
          ),
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  double get _value =>
      double.tryParse(_input.text.replaceAll(',', '.').replaceAll(' ', '')) ??
      0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.zc.page,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          18,
          16,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.myQrRequestMoney,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.zc.text,
                    ),
                  ),
                ),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  size: 46,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.currencies.length > 1) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: context.zc.field,
                  shape: StadiumBorder(),
                ),
                child: Row(
                  children: [
                    for (final c in widget.currencies)
                      Expanded(
                        child: GestureDetector(
                          // A new currency starts the amount from 0 again.
                          onTap: () => setState(() {
                            if (c != _currency) _input.clear();
                            _currency = c;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 42,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: c == _currency
                                  ? AppColors.red
                                  : Colors.transparent,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: c == _currency
                                    ? AppColors.white
                                    : context.zc.soft,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: context.zc.field,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      cursorColor: AppColors.red,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: context.zc.text,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: context.zc.faint,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _currency,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.zc.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: _value > 0
                    ? () => Navigator.of(context).pop((_value, _currency))
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  disabledBackgroundColor: AppColors.red.withValues(
                    alpha: 0.35,
                  ),
                  foregroundColor: AppColors.white,
                  disabledForegroundColor: context.zc.soft,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(l10n.myQrRequestAmount),
              ),
            ),
            // Only when a request already exists.
            if (widget.amount != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 58,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop((0.0, _currency)),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.zc.field,
                    foregroundColor: context.zc.text,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.myQrRemoveAmount),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
