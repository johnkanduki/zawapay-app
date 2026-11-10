import '../../l10n/app_localizations.dart';

/// A country where Zawapay App is available.
class Country {
  const Country({
    required this.isoCode,
    required this.dialCode,
    required this.currencies,
  });

  /// ISO 3166-1 alpha-2 code, e.g. "CD".
  final String isoCode;

  /// International dialling code, e.g. "+243".
  final String dialCode;

  /// Currencies of the balance, in display order (RD Congo uses two).
  final List<String> currencies;

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
  Country(isoCode: 'CD', dialCode: '+243', currencies: ['USD', 'CDF']),
  Country(isoCode: 'BJ', dialCode: '+229', currencies: ['XOF']),
  Country(isoCode: 'CM', dialCode: '+237', currencies: ['XAF']),
  Country(isoCode: 'CG', dialCode: '+242', currencies: ['XAF']),
  Country(isoCode: 'CI', dialCode: '+225', currencies: ['XOF']),
  Country(isoCode: 'GA', dialCode: '+241', currencies: ['XAF']),
  Country(isoCode: 'SN', dialCode: '+221', currencies: ['XOF']),
  Country(isoCode: 'KE', dialCode: '+254', currencies: ['KES']),
  Country(isoCode: 'UG', dialCode: '+256', currencies: ['UGX']),
  Country(isoCode: 'SL', dialCode: '+232', currencies: ['SLE']),
  Country(isoCode: 'ZM', dialCode: '+260', currencies: ['ZMW']),
  Country(isoCode: 'RW', dialCode: '+250', currencies: ['RWF']),
];
