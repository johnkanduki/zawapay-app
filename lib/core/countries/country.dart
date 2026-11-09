import '../../l10n/app_localizations.dart';

/// A country where Zawapay App is available.
class Country {
  const Country({required this.isoCode, required this.dialCode});

  /// ISO 3166-1 alpha-2 code, e.g. "CD".
  final String isoCode;

  /// International dialling code, e.g. "+243".
  final String dialCode;

  /// Flag emoji built from the ISO code.
  String get flag => String.fromCharCodes(
    isoCode.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41),
  );

  String name(AppLocalizations l10n) => switch (isoCode) {
    'CD' => l10n.countryCD,
    'BJ' => l10n.countryBJ,
    'CM' => l10n.countryCM,
    'CG' => l10n.countryCG,
    'CI' => l10n.countryCI,
    'GA' => l10n.countryGA,
    'SN' => l10n.countrySN,
    'KE' => l10n.countryKE,
    'UG' => l10n.countryUG,
    'SL' => l10n.countrySL,
    'ZM' => l10n.countryZM,
    'RW' => l10n.countryRW,
    _ => isoCode,
  };
}

/// The 12 countries where Zawapay App operates.
const List<Country> supportedCountries = [
  Country(isoCode: 'CD', dialCode: '+243'),
  Country(isoCode: 'BJ', dialCode: '+229'),
  Country(isoCode: 'CM', dialCode: '+237'),
  Country(isoCode: 'CG', dialCode: '+242'),
  Country(isoCode: 'CI', dialCode: '+225'),
  Country(isoCode: 'GA', dialCode: '+241'),
  Country(isoCode: 'SN', dialCode: '+221'),
  Country(isoCode: 'KE', dialCode: '+254'),
  Country(isoCode: 'UG', dialCode: '+256'),
  Country(isoCode: 'SL', dialCode: '+232'),
  Country(isoCode: 'ZM', dialCode: '+260'),
  Country(isoCode: 'RW', dialCode: '+250'),
];
