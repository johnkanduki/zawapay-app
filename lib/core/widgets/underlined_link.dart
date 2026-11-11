import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/zawapay_colors.dart';

/// Black text with a thick red underline, used for every tappable link.
class UnderlinedLink extends StatelessWidget {
  const UnderlinedLink({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize = 16,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final VoidCallback onTap;
  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: context.zc.text,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.red,
          decorationThickness: 2.4,
        ),
      ),
    );
  }
}

/// A [WidgetSpan] holding an [UnderlinedLink], to place a link inside a sentence.
WidgetSpan linkSpan(String text, VoidCallback onTap, {double fontSize = 16}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: UnderlinedLink(text: text, onTap: onTap, fontSize: fontSize),
  );
}
