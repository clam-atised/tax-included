import 'package:flutter/services.dart';
import 'package:taxed/utils/input_limits.dart';

class MaxDecimalAmountFormatter extends TextInputFormatter {
  MaxDecimalAmountFormatter({this.max = InputLimits.maxItemAmount});

  final double max;

  static final _pattern = RegExp(r'^\d*[.,]?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!_pattern.hasMatch(text)) return oldValue;

    final normalized = text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed > max) return oldValue;

    return newValue;
  }
}
