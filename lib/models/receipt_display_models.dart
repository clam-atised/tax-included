import 'package:taxed/services/receipt_calculator.dart';

class ReceiptDisplayExtra {
  const ReceiptDisplayExtra({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

class ReceiptDisplayLine {
  const ReceiptDisplayLine({
    required this.title,
    required this.amount,
    required this.subtitle,
    this.extra,
  });

  final String title;
  final double amount;
  final List<String> subtitle;
  final ReceiptDisplayExtra? extra;
}

extension ReceiptSummaryDisplay on ReceiptSummary {
  List<ReceiptDisplayLine> toDisplayLines(ReceiptSortMode mode) {
    if (mode == ReceiptSortMode.byItem) {
      if (itemsByItem.isEmpty) {
        return const [ReceiptDisplayLine(title: '', amount: 0, subtitle: [])];
      }
      return itemsByItem
          .map(
            (item) => ReceiptDisplayLine(
              title: item.name,
              amount: item.amount,
              subtitle: item.personNames,
            ),
          )
          .toList();
    }

    if (itemsByPerson.isEmpty) {
      return const [ReceiptDisplayLine(title: '', amount: 0, subtitle: [])];
    }
    return itemsByPerson
        .map(
          (person) => ReceiptDisplayLine(
            title: person.name,
            amount: person.amount,
            subtitle: person.itemNames,
          ),
        )
        .toList();
  }
}

extension TaxedReceiptSummaryDisplay on TaxedReceiptSummary {
  List<ReceiptDisplayLine> toDisplayLines(ReceiptSortMode mode) {
    if (mode == ReceiptSortMode.byItem) {
      if (itemsByItem.isEmpty) {
        return const [ReceiptDisplayLine(title: '', amount: 0, subtitle: [])];
      }
      return itemsByItem
          .map(
            (item) => ReceiptDisplayLine(
              title: item.name,
              amount: item.amountWithTax - item.itemTax,
              subtitle: item.personNames,
              extra: item.itemTax > 0
                  ? ReceiptDisplayExtra(
                      label: 'Tax',
                      amount: item.itemTax,
                    )
                  : null,
            ),
          )
          .toList();
    }

    if (itemsByPerson.isEmpty) {
      return const [ReceiptDisplayLine(title: '', amount: 0, subtitle: [])];
    }
    return itemsByPerson
        .map(
          (person) => ReceiptDisplayLine(
            title: person.name,
            amount: person.baseAmount,
            subtitle: person.itemNames,
            extra: person.taxAmount > 0
                ? ReceiptDisplayExtra(
                    label: 'Tax',
                    amount: person.taxAmount,
                  )
                : null,
          ),
        )
        .toList();
  }
}

String emptyReceiptMessage(ReceiptSortMode mode) {
  return mode == ReceiptSortMode.byItem ? 'No items' : 'No persons';
}

bool isEmptyPlaceholder(ReceiptDisplayLine line) {
  return line.title.isEmpty && line.amount == 0 && line.subtitle.isEmpty;
}
