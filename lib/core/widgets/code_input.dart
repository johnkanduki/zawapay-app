import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Row of digit boxes (6 for e-mail codes, 4 for the PIN).
/// The box waiting for the next digit has a red border and a red caret.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.length,
    this.obscure = false,
    this.onChanged,
    this.autofocus = false,
  });

  final int length;

  /// Shows dots instead of digits (for the PIN).
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.text;

    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _DigitBox(
                  digit: i < value.length ? value[i] : null,
                  obscure: widget.obscure,
                  active: _focusNode.hasFocus && i == value.length,
                ),
              ),
            ],
          ],
        ),
        // Transparent field laid over the boxes: it receives taps and keyboard input.
        Positioned.fill(
          child: TextField(
            // Tapping anywhere outside the field closes the keyboard.
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.number,
            showCursor: false,
            enableInteractiveSelection: false,
            expands: true,
            maxLines: null,
            style: const TextStyle(color: Colors.transparent),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            onChanged: (text) {
              setState(() {});
              widget.onChanged?.call(text);
            },
          ),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.obscure,
    required this.active,
  });

  final String? digit;
  final bool obscure;
  final bool active;

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (digit != null) {
      content = obscure
          ? Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
            )
          : Text(
              digit!,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            );
    } else if (active) {
      content = Container(width: 2, height: 30, color: AppColors.red);
    }

    return SizedBox(
      height: 64,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: content,
      ),
    );
  }
}
