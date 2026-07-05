import 'package:taxed/utils/input_limits.dart';

abstract final class AmountParser {
  static double parseAmount(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized) ?? 0;
    if (parsed > InputLimits.maxItemAmount) {
      return InputLimits.maxItemAmount;
    }
    return parsed;
  }

  static double parseRate(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    final parsed = double.tryParse(normalized) ?? 0;
    if (parsed > InputLimits.maxTaxRate) {
      return InputLimits.maxTaxRate;
    }
    return parsed;
  }

  static List<double> parseRates(List<String> rawRates) {
    return rawRates.map(parseRate).toList();
  }
}
