import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';

/// "Contact us": white sheet coming up from the bottom, with Sapotti
/// (recommended, the fastest way) and E-mail. All logos are black.
///
/// Opened by every "Contact support" button (transfer detail, Settings,
/// Sign in). Opening
/// Sapotti or the mail app comes later (it needs a package to open links).
Future<void> showContactSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context,
    builder: (_) => const ContactSheet(),
  );
}

class ContactSheet extends StatelessWidget {
  const ContactSheet({super.key});

  static const Color _row = AppColors.surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.of(context).pop()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.contactTitle,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _ContactRow(
          icon: Image.asset(
            'assets/images/sapotti_logo.png',
            width: 30,
            height: 30,
            // The Sapotti "@" in black, like every logo of this page.
            color: AppColors.black,
          ),
          title: 'Sapotti',
          subtitle: l10n.contactSapottiText,
          badge: l10n.contactRecommended,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _ContactRow(
          icon: const CustomPaint(
            size: Size.square(28),
            painter: _MailMarkPainter(),
          ),
          title: l10n.contactEmailTitle,
          subtitle: l10n.contactEmailText,
          onTap: () {},
        ),
        const SizedBox(height: 22),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.contactReplyTime,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// White round button with a thin border and a soft shadow.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.surface, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
      ),
    );
  }
}

/// Grey pill: black logo in a white circle, title, line, optional red
/// "Recommended" tag, and an arrow.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          decoration: BoxDecoration(
            color: ContactSheet._row,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: const ShapeDecoration(
                              color: AppColors.red,
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bold black "M" mail mark, drawn in code (same shape as in Sapotti).
class _MailMarkPainter extends CustomPainter {
  const _MailMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 24 × 24 grid, then scaled to the size.
    final s = size.width / 24;
    Offset p(double x, double y) => Offset(x * s, y * s);
    const r = Radius.circular(1);
    final scaledR = Radius.circular(r.x * s);

    final path = Path()
      ..moveTo(p(2, 6.6).dx, p(2, 6.6).dy)
      ..cubicTo(2 * s, 5.2 * s, 3.6 * s, 4.4 * s, 4.7 * s, 5.2 * s)
      ..lineTo(p(12, 10.6).dx, p(12, 10.6).dy)
      ..lineTo(p(19.3, 5.2).dx, p(19.3, 5.2).dy)
      ..cubicTo(20.4 * s, 4.4 * s, 22 * s, 5.2 * s, 22 * s, 6.6 * s)
      ..lineTo(p(22, 18).dx, p(22, 18).dy)
      ..arcToPoint(p(21, 19), radius: scaledR)
      ..lineTo(p(18.4, 19).dx, p(18.4, 19).dy)
      ..arcToPoint(p(17.4, 18), radius: scaledR)
      ..lineTo(p(17.4, 11.2).dx, p(17.4, 11.2).dy)
      ..lineTo(p(12, 15.3).dx, p(12, 15.3).dy)
      ..lineTo(p(6.6, 11.2).dx, p(6.6, 11.2).dy)
      ..lineTo(p(6.6, 18).dx, p(6.6, 18).dy)
      ..arcToPoint(p(5.6, 19), radius: scaledR)
      ..lineTo(p(3, 19).dx, p(3, 19).dy)
      ..arcToPoint(p(2, 18), radius: scaledR)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.black
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_MailMarkPainter oldDelegate) => false;
}
