import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/zawapay_colors.dart';
import '../theme/app_theme.dart';

const double _buttonHeight = 60;

/// Red full-width button for the main action of a screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Waiting for the server: a small white spinner instead of the label.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: busy
              ? AppColors.red
              : AppColors.red.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.white,
          shape: const StadiumBorder(),
          textStyle: AppText.button,
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Light grey button for secondary actions, with an optional leading icon.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.bold = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.zc.field,
          foregroundColor: context.zc.text,
          shape: const StadiumBorder(),
          textStyle: AppText.button.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        // On a narrow button the label gets a little smaller, never cut.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
