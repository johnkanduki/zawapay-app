import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Light grey page with a white rounded card holding a title, a subtitle and a form.
class AuthCardScaffold extends StatelessWidget {
  const AuthCardScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.subtitleTrailing,
  });

  final String title;
  final String? subtitle;

  /// Optional bold line under the subtitle (an email address, for example).
  final String? subtitleTrailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: AuthCard(
                  title: title,
                  subtitle: subtitle,
                  subtitleTrailing: subtitleTrailing,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white rounded card itself, also used inside bottom sheets.
class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.subtitleTrailing,
  });

  final String title;
  final String? subtitle;
  final String? subtitleTrailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 34, 26, 30),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.screenTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(subtitle!, style: AppText.body),
          ],
          if (subtitleTrailing != null)
            Text(
              subtitleTrailing!,
              style: AppText.body.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}
