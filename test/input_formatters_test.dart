import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/utils/amount_parser.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';

TextEditingValue _format(
  TextInputFormatter formatter,
  String oldText,
  String newText,
) {
  return formatter.formatEditUpdate(
    TextEditingValue(text: oldText),
    TextEditingValue(text: newText),
  );
}

void main() {
  group('MaxDecimalAmountFormatter', () {
    final formatter = MaxDecimalAmountFormatter();

    test('accepts values up to max item amount', () {
      expect(_format(formatter, '', '9999.99').text, '9999.99');
      expect(_format(formatter, '', '10000').text, '10000');
    });

    test('rejects values above max item amount', () {
      expect(_format(formatter, '10000', '10000.01').text, '10000');
      expect(_format(formatter, '', '10001').text, '');
    });

    test('tax formatter accepts up to 100 percent', () {
      final taxFormatter = MaxDecimalAmountFormatter(max: InputLimits.maxTaxRate);
      expect(_format(taxFormatter, '', '100').text, '100');
      expect(_format(taxFormatter, '100', '100.1').text, '100');
    });
  });

  group('MaxIntFormatter', () {
    final formatter = MaxIntFormatter();

    test('accepts values up to 100', () {
      expect(_format(formatter, '', '100').text, '100');
      expect(_format(formatter, '', '42').text, '42');
    });

    test('rejects values above 100', () {
      expect(_format(formatter, '100', '101').text, '100');
    });

    test('clampParsed clamps out of range values', () {
      expect(formatter.clampParsed(''), InputLimits.minSplitCount);
      expect(formatter.clampParsed('50'), 50);
      expect(formatter.clampParsed('150'), InputLimits.maxSplitCount);
    });
  });

  group('AmountParser', () {
    test('parseAmount clamps to max item amount', () {
      expect(AmountParser.parseAmount('99999'), InputLimits.maxItemAmount);
      expect(AmountParser.parseAmount('500'), 500);
    });

    test('parseRate clamps to max tax rate', () {
      expect(AmountParser.parseRate('150'), InputLimits.maxTaxRate);
      expect(AmountParser.parseRate('10'), 10);
    });
  });
}
