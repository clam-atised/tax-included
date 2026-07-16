import 'package:taxed/utils/amount_parser.dart';

class TaxRule {
  TaxRule({
    required this.rate,
    Set<String>? selectedPersons,
    Set<String>? selectedItems,
    this.applyToAllPersons = true,
    this.applyToAllItems = true,
  })  : selectedPersons = selectedPersons ?? {},
        selectedItems = selectedItems ?? {};

  final double rate;
  final Set<String> selectedPersons;
  final Set<String> selectedItems;
  final bool applyToAllPersons;
  final bool applyToAllItems;

  bool appliesToItem(String itemName) {
    return applyToAllItems || selectedItems.contains(itemName);
  }

  bool appliesToPerson(String personName) {
    return applyToAllPersons || selectedPersons.contains(personName);
  }

  TaxRule copyWith({
    double? rate,
    Set<String>? selectedPersons,
    Set<String>? selectedItems,
    bool? applyToAllPersons,
    bool? applyToAllItems,
  }) {
    return TaxRule(
      rate: rate ?? this.rate,
      selectedPersons: selectedPersons ?? this.selectedPersons,
      selectedItems: selectedItems ?? this.selectedItems,
      applyToAllPersons: applyToAllPersons ?? this.applyToAllPersons,
      applyToAllItems: applyToAllItems ?? this.applyToAllItems,
    );
  }
}

class TaxInsertData {
  TaxInsertData({
    required this.rules,
  });

  final List<TaxRule> rules;

  List<double> get rates => rules.map((rule) => rule.rate).toList();

  static TaxRule parseRule({
    required String rawRate,
    required Set<String> allPersons,
    required Set<String> allItems,
    required Set<String> selectedPersons,
    required Set<String> selectedItems,
  }) {
    return TaxRule(
      rate: AmountParser.parseRate(rawRate),
      selectedPersons: selectedPersons,
      selectedItems: selectedItems,
      applyToAllPersons:
          selectedPersons.length == allPersons.length && allPersons.isNotEmpty,
      applyToAllItems:
          selectedItems.length == allItems.length && allItems.isNotEmpty,
    );
  }
}
