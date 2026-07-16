import 'package:taxed/utils/amount_parser.dart';

class TaxInsertData {
  TaxInsertData({
    required this.rates,
  });

  final List<double> rates;

  static List<double> parseRates(List<String> rawRates) {
    return AmountParser.parseRates(rawRates);
  }
}
