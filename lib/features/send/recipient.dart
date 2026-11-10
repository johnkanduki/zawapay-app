import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/verified_badge.dart';

/// A Zawapay account that can receive money. It is found by its "@"
/// username (shown as its name) or by its Mobile Money number.
class Recipient {
  const Recipient({
    required this.username,
    required this.fullName,
    required this.countryCode,
    required this.phone,
    this.certified = false,
  });

  /// Without the "@".
  final String username;
  final String fullName;
  final String countryCode;

  /// National number, without the dialling code ("975135801").
  final String phone;
  final bool certified;

  String get handle => '@$username';

  Country get country =>
      supportedCountries.firstWhere((c) => c.isoCode == countryCode);

  /// "+243 975 135 801".
  String get fullPhone {
    // 10 digits read best in pairs (07 01 02 03 04), others in threes.
    final step = phone.length == 10 ? 2 : 3;
    final groups = <String>[];
    for (var i = 0; i < phone.length; i += step) {
      groups.add(phone.substring(i, (i + step).clamp(0, phone.length)));
    }
    return '${country.dialCode} ${groups.join(' ')}';
  }

  String get initials => fullName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// Demo accounts, only for the UI. They will come from the Zawapay server.
const List<Recipient> demoRecipients = [
  Recipient(
    username: 'zawapay',
    fullName: 'Zawapay App',
    countryCode: 'CD',
    phone: '975135801',
    certified: true,
  ),
  Recipient(
    username: 'amina',
    fullName: 'Amina Diallo',
    countryCode: 'SN',
    phone: '771234567',
    certified: true,
  ),
  Recipient(
    username: 'kofi.mensah',
    fullName: 'Kofi Mensah',
    countryCode: 'CI',
    phone: '0701020304',
  ),
  Recipient(
    username: 'mireille.k',
    fullName: 'Mireille Kabeya',
    countryCode: 'CD',
    phone: '812345678',
  ),
];

/// Looks for an account by its exact username (no suggestions).
Recipient? findByUsername(String username) => demoRecipients
    .where((r) => r.username == username.toLowerCase())
    .firstOrNull;

/// Looks for an account by country and national number (spaces and a
/// leading 0 are ignored).
Recipient? findByPhone(String countryCode, String number) {
  String clean(String value) =>
      value.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0+'), '');
  final wanted = clean(number);
  if (wanted.isEmpty) return null;
  return demoRecipients
      .where((r) => r.countryCode == countryCode && clean(r.phone) == wanted)
      .firstOrNull;
}

/// Round initials with the country flag at the bottom right.
class RecipientAvatar extends StatelessWidget {
  const RecipientAvatar({super.key, required this.recipient, this.size = 50});

  final Recipient recipient;
  final double size;

  @override
  Widget build(BuildContext context) {
    final flag = size * 0.4;

    return SizedBox(
      width: size + flag * 0.35,
      height: size + flag * 0.25,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.red.withValues(alpha: 0.18),
            ),
            alignment: Alignment.center,
            child: Text(
              recipient.initials,
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.w800,
                color: AppColors.red,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.black,
              ),
              child: CircleFlag(recipient.countryCode, size: flag),
            ),
          ),
        ],
      ),
    );
  }
}

/// "@username" in bold with the blue badge when certified.
class RecipientHandle extends StatelessWidget {
  const RecipientHandle({
    super.key,
    required this.recipient,
    this.fontSize = 17,
  });

  final Recipient recipient;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            recipient.handle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
        if (recipient.certified) ...[
          const SizedBox(width: 5),
          VerifiedBadge(size: fontSize - 1),
        ],
      ],
    );
  }
}
