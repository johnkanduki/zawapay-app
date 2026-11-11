import 'package:flutter/material.dart';

import '../theme/zawapay_colors.dart';
import '../theme/app_theme.dart';

/// Grey label above a rounded grey field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text, style: AppText.label(context)),
    );
  }
}

/// Rounded grey input used across the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final String hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      // Tapping anywhere outside the field closes the keyboard.
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      obscuringCharacter: '•',
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      style: TextStyle(fontSize: 16, color: context.zc.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 16, color: context.zc.soft),
        filled: true,
        fillColor: context.zc.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 19,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [FieldLabel(label!), field],
    );
  }
}

/// [AppTextField] with an eye button to show or hide the password.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final String hint;
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      obscureText: _hidden,
      autofillHints: const [AutofillHints.password],
      suffix: IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: context.zc.soft,
        ),
      ),
    );
  }
}
