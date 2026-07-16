import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/models/tax_models.dart';
import 'package:taxed/services/receipt_calculator.dart';

void main() {
  group('ReceiptCalculator', () {
    test('assigns all batch items to the single person', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [
            ItemEntry(name: 'Item A', amount: '60'),
            ItemEntry(name: 'Item B', amount: '5'),
          ],
          persons: [PersonEntry(name: 'Person A')],
        ),
      ]);

      expect(summary.total, 65);
      expect(summary.itemsByItem.length, 2);
      expect(summary.itemsByItem.first.personNames, ['Person A']);
      expect(summary.itemsByItem.last.personNames, ['Person A']);

      final personA = summary.itemsByPerson
          .firstWhere((person) => person.name == 'Person A');
      expect(personA.amount, 65);
      expect(personA.itemNames, ['Item A', 'Item B']);
    });

    test('multiplies amount by quantity for line total', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [
            ItemEntry(name: 'Coffee', amount: '5', quantity: 2),
          ],
          persons: [PersonEntry(name: 'Alex')],
        ),
      ]);

      expect(summary.total, 10);
      expect(summary.itemsByItem.single.amount, 10);
    });

    test('combines multiple batches', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [ItemEntry(name: 'Item A', amount: '60')],
          persons: [PersonEntry(name: 'Person A')],
        ),
        InsertBatch(
          items: [ItemEntry(name: 'Item B', amount: '5')],
          persons: [PersonEntry(name: 'Person C')],
        ),
      ]);

      expect(summary.total, 65);
      expect(summary.itemsByItem.length, 2);
      expect(summary.itemsByPerson.length, 2);
    });

    test('taxForItem calculates percentage of item amount', () {
      expect(ReceiptCalculator.taxForItem(60, 10), 6);
      expect(ReceiptCalculator.taxForItem(100, 0), 0);
    });

    test('computeWithTax splits tax among persons across batches', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '20')],
            persons: [PersonEntry(name: 'Person A')],
          ),
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '20')],
            persons: [PersonEntry(name: 'Person B')],
          ),
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '20')],
            persons: [PersonEntry(name: 'Person C')],
          ),
        ],
        [TaxRule(rate: 10)],
      );

      expect(summary.totalWithTax, 66);
      expect(summary.totalTax, 6);

      final personA = summary.itemsByPerson
          .firstWhere((person) => person.name == 'Person A');
      expect(personA.taxAmount, closeTo(2, 0.001));
      expect(personA.baseAmount, closeTo(20, 0.001));
    });

    test('computeWithTax uses zero rate when no rules', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '10')],
            persons: [PersonEntry(name: 'Alex')],
          ),
        ],
        const [],
      );

      expect(summary.totalWithTax, 10);
      expect(summary.totalTax, 0);
    });

    test('computeWithTax applies scoped tax to selected item only', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [
              ItemEntry(name: 'Coffee', amount: '10'),
              ItemEntry(name: 'Tea', amount: '5'),
            ],
            persons: [PersonEntry(name: 'Alex')],
          ),
        ],
        [
          TaxRule(
            rate: 10,
            selectedItems: {'Coffee'},
            applyToAllItems: false,
            applyToAllPersons: true,
          ),
        ],
      );

      expect(summary.totalWithTax, closeTo(16, 0.001));
      expect(summary.totalTax, closeTo(1, 0.001));
      final coffee = summary.itemsByItem
          .firstWhere((item) => item.name == 'Coffee');
      final tea =
          summary.itemsByItem.firstWhere((item) => item.name == 'Tea');
      expect(coffee.itemTax, closeTo(1, 0.001));
      expect(tea.itemTax, 0);
    });

    test('computeWithTax applies scoped tax to selected person only', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Coffee', amount: '60')],
            persons: [PersonEntry(name: 'Alex')],
          ),
          InsertBatch(
            items: [ItemEntry(name: 'Coffee', amount: '60')],
            persons: [PersonEntry(name: 'Sam')],
          ),
        ],
        [
          TaxRule(
            rate: 10,
            selectedPersons: {'Alex'},
            applyToAllPersons: false,
            applyToAllItems: true,
          ),
        ],
      );

      final alex =
          summary.itemsByPerson.firstWhere((person) => person.name == 'Alex');
      final sam =
          summary.itemsByPerson.firstWhere((person) => person.name == 'Sam');
      expect(alex.taxAmount, closeTo(6, 0.001));
      expect(sam.taxAmount, 0);
    });

    test('formatReceiptText includes total line', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Coffee', amount: '10')],
            persons: [PersonEntry(name: 'Alex')],
          ),
        ],
        [TaxRule(rate: 10)],
      );

      final text = ReceiptCalculator.formatReceiptText(
        summary,
        ReceiptSortMode.byItem,
      );

      expect(text, contains('Coffee'));
      expect(text, contains('Alex'));
      expect(text, contains('Total (with tax)'));
      expect(text, contains('11.00'));
    });
  });
}
