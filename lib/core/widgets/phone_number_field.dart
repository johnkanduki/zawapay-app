import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../countries/country.dart';
import '../theme/app_colors.dart';
import '../settings/app_settings.dart';
import 'country_picker.dart';
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
  // Defaults to the country chosen on the first screen.
  late Country _country =
      widget.initialCountry ??
      AppSettingsScope.of(context).country ??
      supportedCountries.first;

  Future<void> _pickCountry() async {
    final picked = await showCountryPicker(context, selected: _country);
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
