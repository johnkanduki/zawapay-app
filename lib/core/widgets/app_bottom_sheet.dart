import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Opens a rounded bottom sheet in the app style.
/// With [showClose], a white round close button sits above the content
/// on a light grey background (as in "Forgot password").
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool showClose = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.scrim,
    backgroundColor: showClose ? AppColors.surface : AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showClose) ...[
                _CloseButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(height: 18),
              ],
              Flexible(child: builder(context)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.black,
          size: 28,
        ),
      ),
    );
  }
}
