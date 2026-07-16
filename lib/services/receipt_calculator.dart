import 'package:taxed/models/insert_models.dart';
import 'package:taxed/utils/amount_parser.dart';

enum ReceiptSortMode { byItem, byPerson }

class ReceiptItemView {
  ReceiptItemView({
    required this.name,
    required this.amount,
    required this.personNames,
  });

  final String name;
  final double amount;
  final List<String> personNames;
}

class ReceiptPersonView {
  ReceiptPersonView({
    required this.name,
    required this.amount,
    required this.itemNames,
  });

  final String name;
  final double amount;
  final List<String> itemNames;
}

class ReceiptSummary {
  ReceiptSummary({
    required this.itemsByItem,
    required this.itemsByPerson,
    required this.total,
  });

  final List<ReceiptItemView> itemsByItem;
  final List<ReceiptPersonView> itemsByPerson;
  final double total;
}

class TaxedReceiptItemView {
  TaxedReceiptItemView({
    required this.name,
    required this.amountWithTax,
    required this.personNames,
    required this.itemTax,
  });

  final String name;
  final double amountWithTax;
  final List<String> personNames;
  final double itemTax;
}

class TaxedReceiptPersonView {
  TaxedReceiptPersonView({
    required this.name,
    required this.baseAmount,
    required this.taxAmount,
    required this.itemNames,
  });

  final String name;
  final double baseAmount;
  final double taxAmount;
  final List<String> itemNames;
}

class TaxedReceiptSummary {
  TaxedReceiptSummary({
    required this.itemsByItem,
    required this.itemsByPerson,
    required this.totalWithTax,
    required this.totalTax,
  });

  final List<TaxedReceiptItemView> itemsByItem;
  final List<TaxedReceiptPersonView> itemsByPerson;
  final double totalWithTax;
  final double totalTax;
}

class _ParsedItemRecord {
  _ParsedItemRecord({
    required this.name,
    required this.amount,
    required this.assignedPersons,
  });

  final String name;
  final double amount;
  final List<String> assignedPersons;
}

abstract final class ReceiptCalculator {
  static ReceiptSummary compute(List<InsertBatch> batches) {
    final taxed = computeWithTax(batches, const []);
    return ReceiptSummary(
      itemsByItem: taxed.itemsByItem
          .map(
            (item) => ReceiptItemView(
              name: item.name,
              amount: item.amountWithTax - item.itemTax,
              personNames: item.personNames,
            ),
          )
          .toList(),
      itemsByPerson: taxed.itemsByPerson
          .map(
            (person) => ReceiptPersonView(
              name: person.name,
              amount: person.baseAmount,
              itemNames: person.itemNames,
            ),
          )
          .toList(),
      total: taxed.totalWithTax - taxed.totalTax,
    );
  }

  static TaxedReceiptSummary computeWithTax(
    List<InsertBatch> batches,
    List<double> rates,
  ) {
    final itemViews = <TaxedReceiptItemView>[];
    final personBaseTotals = <String, double>{};
    final personTaxTotals = <String, double>{};
    final personItems = <String, List<String>>{};
    var totalBase = 0.0;
    var totalTax = 0.0;
    var itemIndex = 0;

    for (final record in _iterateItems(batches)) {
      final rate = itemIndex < rates.length ? rates[itemIndex] : 0.0;
      itemIndex++;

      final itemTax = taxForItem(record.amount, rate);
      final amountWithTax = record.amount + itemTax;
      totalBase += record.amount;
      totalTax += itemTax;

      itemViews.add(
        TaxedReceiptItemView(
          name: record.name,
          amountWithTax: amountWithTax,
          personNames: record.assignedPersons,
          itemTax: itemTax,
        ),
      );

      if (record.assignedPersons.isEmpty) continue;

      final baseShare = record.amount / record.assignedPersons.length;
      final taxShare = itemTax / record.assignedPersons.length;
      for (final person in record.assignedPersons) {
        personBaseTotals[person] = (personBaseTotals[person] ?? 0) + baseShare;
        personTaxTotals[person] = (personTaxTotals[person] ?? 0) + taxShare;
        personItems.putIfAbsent(person, () => []).add(record.name);
      }
    }

    final personViews = personBaseTotals.entries
        .map(
          (entry) => TaxedReceiptPersonView(
            name: entry.key,
            baseAmount: entry.value,
            taxAmount: personTaxTotals[entry.key] ?? 0,
            itemNames: personItems[entry.key] ?? [],
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return TaxedReceiptSummary(
      itemsByItem: itemViews,
      itemsByPerson: personViews,
      totalWithTax: totalBase + totalTax,
      totalTax: totalTax,
    );
  }

  static Iterable<_ParsedItemRecord> _iterateItems(List<InsertBatch> batches) {
    return batches.expand((batch) {
      final persons = batch.persons
          .map((person) => person.name.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      return batch.items.map((item) {
        final amount = AmountParser.parseAmount(item.amount);
        if (amount == 0 && item.name.trim().isEmpty) {
          return null;
        }

        final assignedPersons = _assignedPersons(persons, item.splitCount);
        final itemName =
            item.name.trim().isEmpty ? 'Item' : item.name.trim();

        return _ParsedItemRecord(
          name: itemName,
          amount: amount,
          assignedPersons: assignedPersons,
        );
      }).whereType<_ParsedItemRecord>();
    });
  }

  static String formatReceiptText(
    TaxedReceiptSummary summary,
    ReceiptSortMode sortMode,
  ) {
    final buffer = StringBuffer();

    if (sortMode == ReceiptSortMode.byItem) {
      for (final item in summary.itemsByItem) {
        buffer.writeln(_formatLine(item.name, item.amountWithTax));
        if (item.personNames.isNotEmpty) {
          buffer.writeln(item.personNames.join(', '));
        }
        buffer.writeln('---');
      }
    } else {
      for (final person in summary.itemsByPerson) {
        buffer.writeln(_formatLine(person.name, person.baseAmount));
        if (person.itemNames.isNotEmpty) {
          buffer.writeln(person.itemNames.join(', '));
        }
        if (person.taxAmount > 0) {
          buffer.writeln(_formatLine('Tax per person', person.taxAmount));
        }
        buffer.writeln('---');
      }
    }

    buffer.writeln(_formatLine('Total (with tax)', summary.totalWithTax));
    return buffer.toString().trimRight();
  }

  static String _formatLine(String label, double amount) {
    return '${label.padRight(20)}${formatAmount(amount)}';
  }

  static List<String> _assignedPersons(List<String> persons, int splitCount) {
    if (persons.isEmpty) return [];
    if (splitCount <= 0 || splitCount >= persons.length) return persons;
    return persons.take(splitCount).toList();
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  static double taxForItem(double itemAmount, double ratePercent) {
    return itemAmount * ratePercent / 100;
  }
}
