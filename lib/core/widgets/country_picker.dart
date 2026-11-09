import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../countries/country.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';

/// Opens the country list (search, current choice on top, all countries)
/// and returns the one tapped.
///
/// The list comes from [supportedCountries]; later it will come from the
/// countries enabled in the admin dashboard.
Future<Country?> showCountryPicker(BuildContext context, {Country? selected}) {
  return showAppBottomSheet<Country>(
    context,
    showClose: true,
    builder: (context) => _CountryPickerCard(selected: selected),
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

class _CountryPickerCard extends StatefulWidget {
  const _CountryPickerCard({required this.selected});

  final Country? selected;

  @override
  State<_CountryPickerCard> createState() => _CountryPickerCardState();
}

class _CountryPickerCardState extends State<_CountryPickerCard> {
  String _query = '';

  /// Matches the country name (accents ignored) or its dialling code.
  bool _matches(Country country, AppLocalizations l10n) {
    if (_query.isEmpty) return true;
    final query = _normalize(_query);
    return _normalize(country.name(l10n)).contains(query) ||
        country.dialCode.contains(query.replaceAll(' ', ''));
  }

  static String _normalize(String text) {
    const from = 'àâäáãçéèêëíìîïñóòôöõúùûüÿ’\'-';
    const to = 'aaaaaceeeeiiiinooooouuuuy   ';
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final index = from.indexOf(char);
      buffer.write(index == -1 ? char : to[index]);
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = widget.selected;
    final others =
        supportedCountries
            .where((c) => c.isoCode != selected?.isoCode && _matches(c, l10n))
            .toList()
          ..sort((a, b) => a.name(l10n).compareTo(b.name(l10n)));
    final showSelected = selected != null && _matches(selected, l10n);
    final nothingFound = others.isEmpty && !showSelected;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.74,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(l10n.chooseCountry, style: AppText.screenTitle),
          ),
          const SizedBox(height: 22),
          _SearchField(
            hint: l10n.searchCountryHint,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: nothingFound
                ? _NotAvailable(
                    title: l10n.countryNotAvailableTitle,
                    body: l10n.countryNotAvailableBody,
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (showSelected) ...[
                        _CountryRow(country: selected, isSelected: true),
                        if (others.isNotEmpty) _SectionLabel(l10n.allCountries),
                      ],
                      for (final country in others)
                        _CountryRow(country: country),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 16, color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, color: AppColors.grey),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 18, right: 10),
          child: Icon(Icons.search_rounded, color: AppColors.grey, size: 26),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 19),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// One country in a rounded horizontal pill: round flag, name, dialling code.
class _CountryRow extends StatelessWidget {
  const _CountryRow({required this.country, this.isSelected = false});

  final Country country;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(country),
        child: Container(
          height: 68,
          padding: const EdgeInsets.only(left: 8, right: 22),
          decoration: const ShapeDecoration(
            color: AppColors.surface,
            shape: StadiumBorder(),
          ),
          child: Row(
            children: [
              RoundFlag(country: country, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        country.name(l10n),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      country.dialCode,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.black,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "All countries" with a thin line after it.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),
      child: Row(
        children: [
          Text(text, style: AppText.label.copyWith(fontSize: 15)),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(color: AppColors.surface, thickness: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Shown when the search matches no available country.
class _NotAvailable extends StatelessWidget {
  const _NotAvailable({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 28, 12, 24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.public_rounded,
              size: 42,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.screenTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(body, textAlign: TextAlign.center, style: AppText.body),
        ],
      ),
    );
  }
}
