import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../countries/country.dart';
import '../theme/app_colors.dart';
import 'app_bottom_sheet.dart';
import 'app_text_field.dart';

/// Country selector (round flag + dialling code) next to a phone number field.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    this.controller,
    this.initialCountry,
    this.onCountryChanged,
  });

  final TextEditingController? controller;
  final Country? initialCountry;
  final ValueChanged<Country>? onCountryChanged;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late Country _country = widget.initialCountry ?? supportedCountries.first;

  Future<void> _pickCountry() async {
    final picked = await showAppBottomSheet<Country>(
      context,
      builder: (context) => _CountryList(selected: _country),
    );
    if (picked == null) return;
    setState(() => _country = picked);
    widget.onCountryChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _pickCountry,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 14),
              decoration: const ShapeDecoration(
                color: AppColors.surface,
                shape: StadiumBorder(),
              ),
              child: Row(
                children: [
                  RoundFlag(country: _country),
                  const SizedBox(width: 10),
                  Text(
                    _country.dialCode,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.black,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextField(
              hint: l10n.phoneNumberHint,
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
            ),
          ),
        ],
      ),
    );
  }
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

  final Country selected;

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
                  trailing: country.isoCode == selected.isoCode
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
