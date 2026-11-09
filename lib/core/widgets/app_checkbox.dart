import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded square checkbox (red when checked) followed by its label.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Usually a [Text] or a [Text.rich] containing a link.
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: value ? AppColors.red : AppColors.white,
              borderRadius: BorderRadius.circular(7),
              border: value
                  ? null
                  : Border.all(color: AppColors.grey, width: 1.8),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: label,
          ),
        ),
      ],
    );
  }
}
