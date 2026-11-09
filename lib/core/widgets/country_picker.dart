import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../countries/country.dart';
import '../theme/app_colors.dart';
import 'app_bottom_sheet.dart';

/// Opens the list of the 12 countries and returns the one tapped.
Future<Country?> showCountryPicker(BuildContext context, {Country? selected}) {
  return showAppBottomSheet<Country>(
    context,
    builder: (context) => _CountryList(selected: selected),
  );
}

/// Country flag cropped into a circle.
class RoundFlag extends StatelessWidget {
  const RoundFlag({super.key, required this.country, this.size = 34});

  final Country country;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        // The emoji is drawn larger than the circle so the flag fills it.
        child: OverflowBox(
          maxWidth: size * 3,
          maxHeight: size * 3,
          child: Text(
            country.flag,
            style: TextStyle(fontSize: size * 1.55, height: 1),
          ),
        ),
      ),
    );
  }
}

class _CountryList extends StatelessWidget {
  const _CountryList({required this.selected});

  final Country? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Text(
            l10n.chooseCountry,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final country in supportedCountries)
                ListTile(
                  onTap: () => Navigator.of(context).pop(country),
                  leading: RoundFlag(country: country),
                  title: Text(
                    country.name(l10n),
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Text(
                    country.dialCode,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  trailing: country.isoCode == selected?.isoCode
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.red,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
