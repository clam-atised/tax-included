import 'package:flutter/material.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';
import 'package:taxed/widgets/app_text_field.dart';

class TaxAmountField extends StatelessWidget {
  const TaxAmountField({
    super.key,
    required this.controller,
    required this.labelColor,
  });

  final TextEditingController controller;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTextField(
        controller: controller,
        hint: 'Tax Amount',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        labelColor: labelColor,
        suffixText: '%',
        inputFormatters: [
          MaxDecimalAmountFormatter(max: InputLimits.maxTaxRate),
        ],
      ),
    );
  }
}
