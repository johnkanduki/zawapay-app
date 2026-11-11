import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

import '../../core/account/zawapay_account.dart';
import '../../core/countries/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
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
    this.photoUrl,
  });

  /// A member found on the server. [phone] is its WITHDRAWAL number: the
  /// money sent always arrives there, never on the payment number.
  factory Recipient.fromMember(ZawapayMember member) {
    final full = member.receivePhone ?? '';
    final dial = supportedCountries
        .where((c) => c.isoCode == member.country)
        .firstOrNull
        ?.dialCode;
    return Recipient(
      username: member.handle,
      fullName: member.name,
      countryCode: member.country,
      phone: dial != null && full.startsWith(dial)
          ? full.substring(dial.length)
          : full.replaceFirst('+', ''),
      certified: member.certified,
      photoUrl: member.hasPhoto ? member.photoUrl : null,
    );
  }

  /// A Mobile Money number typed by the sender: the money goes straight to
  /// it, with no Zawapay account needed (and none looked up).
  factory Recipient.number(String countryCode, String nationalNumber) =>
      Recipient(
        username: '',
        fullName: '',
        countryCode: countryCode,
        phone: nationalNumber,
      );

  /// Without the "@"; empty for a send to a number.
  final String username;
  final String fullName;
  final String countryCode;

  /// National number, without the dialling code ("975135801").
  final String phone;
  final bool certified;

  /// Profile photo; the initials are shown without it.
  final String? photoUrl;

  /// True when the money goes to a typed number, not to an account.
  bool get isNumber => username.isEmpty;

  /// "@username", or the number for a send to a number.
  String get handle => isNumber ? fullPhone : '@$username';

  /// What the server needs: the "@" or the full number ("+243975135801").
  String get address => isNumber ? '${country.dialCode}$phone' : username;

  Country get country => supportedCountries.firstWhere(
    (c) => c.isoCode == countryCode,
    orElse: () =>
        Country(isoCode: countryCode, dialCode: '', currencies: const []),
  );

  /// "+243 975 135 801".
  String get fullPhone {
    if (phone.isEmpty) return '';
    // 10 digits read best in pairs (07 01 02 03 04), others in threes.
    final step = phone.length == 10 ? 2 : 3;
    final groups = <String>[];
    for (var i = 0; i < phone.length; i += step) {
      groups.add(phone.substring(i, (i + step).clamp(0, phone.length)));
    }
    return '${country.dialCode} ${groups.join(' ')}';
  }

  /// Name and number on one line ("Zawapay App · +243 975 135 801"),
  /// leaving out what is not known yet.
  String get details => isNumber
      ? ''
      : [fullName, fullPhone].where((part) => part.isNotEmpty).join(' · ');

  /// Two letters for the avatar: from the name, or from the "@".
  String get initials => (fullName.isEmpty ? username : fullName)
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// Zawapay accounts the app knows about. Empty: real accounts will come
/// from the Zawapay server (no fake or demo account in the app).
final List<Recipient> knownAccounts = [];

/// Looks for an account by its exact username (no suggestions).
Recipient? findByUsername(String username) => knownAccounts
    .where((r) => r.username == username.toLowerCase())
    .firstOrNull;

/// Looks for an account by country and national number (spaces and a
/// leading 0 are ignored).
Recipient? findByPhone(String countryCode, String number) {
  String clean(String value) =>
      value.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0+'), '');
  final wanted = clean(number);
  if (wanted.isEmpty) return null;
  return knownAccounts
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
            clipBehavior: Clip.antiAlias,
            foregroundDecoration: recipient.photoUrl == null
                ? null
                : BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(recipient.photoUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
            child: recipient.isNumber
                ? Icon(
                    Icons.phone_rounded,
                    size: size * 0.45,
                    color: AppColors.red,
                  )
                : Text(
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.zc.page,
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
              color: context.zc.text,
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
