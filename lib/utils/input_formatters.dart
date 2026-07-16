import 'package:flutter/services.dart';
import 'package:taxed/utils/amount_parser.dart';
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

    final parsed = AmountParser.parseAmount(text);
    if (parsed > max) return oldValue;

    return newValue;
  }
}

class MaxIntFormatter extends TextInputFormatter {
  MaxIntFormatter({
    this.min = 0,
    this.max = InputLimits.maxSplitCount,
  });

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d+$').hasMatch(text)) return oldValue;

    final value = int.tryParse(text);
    if (value == null || value > max) return oldValue;

    return newValue;
  }

  int clampParsed(String text) {
    if (text.isEmpty) return min;
    final value = int.tryParse(text) ?? min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
