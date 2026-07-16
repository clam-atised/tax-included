import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/services/receipt_calculator.dart';

void main() {
  group('ReceiptCalculator', () {
    test('computes by-item total and equal person splits', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [
            ItemEntry(name: 'Item A', amount: '60'),
            ItemEntry(name: 'Item B', amount: '5'),
          ],
          persons: [
            PersonEntry(name: 'Person A', emoji: ''),
            PersonEntry(name: 'Person B', emoji: ''),
            PersonEntry(name: 'Person C', emoji: ''),
          ],
        ),
      ]);

      expect(summary.total, 65);
      expect(summary.itemsByItem.length, 2);
      expect(summary.itemsByItem.first.personNames,
          ['Person A', 'Person B', 'Person C']);

      final personA = summary.itemsByPerson
          .firstWhere((person) => person.name == 'Person A');
      expect(personA.amount, closeTo(21.666666, 0.001));
      expect(personA.itemNames, ['Item A', 'Item B']);
    });

    test('respects splitCount when assigning persons', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [
            ItemEntry(name: 'Item B', amount: '5', splitCount: 2),
          ],
          persons: [
            PersonEntry(name: 'Person A', emoji: ''),
            PersonEntry(name: 'Person B', emoji: ''),
            PersonEntry(name: 'Person C', emoji: ''),
          ],
        ),
      ]);

      expect(summary.itemsByItem.single.personNames,
          ['Person A', 'Person B']);
      expect(summary.itemsByPerson.length, 2);
      expect(summary.total, 5);
    });

    test('combines multiple batches', () {
      final summary = ReceiptCalculator.compute([
        InsertBatch(
          items: [ItemEntry(name: 'Item A', amount: '60')],
          persons: [PersonEntry(name: 'Person A', emoji: '')],
        ),
        InsertBatch(
          items: [ItemEntry(name: 'Item B', amount: '5')],
          persons: [PersonEntry(name: 'Person C', emoji: '')],
        ),
      ]);

      expect(summary.total, 65);
      expect(summary.itemsByItem.length, 2);
    });

    test('taxForItem calculates percentage of item amount', () {
      expect(ReceiptCalculator.taxForItem(60, 10), 6);
      expect(ReceiptCalculator.taxForItem(100, 0), 0);
    });

    test('computeWithTax splits tax among persons', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '60')],
            persons: [
              PersonEntry(name: 'Person A', emoji: ''),
              PersonEntry(name: 'Person B', emoji: ''),
              PersonEntry(name: 'Person C', emoji: ''),
            ],
          ),
        ],
        [10],
      );

      expect(summary.totalWithTax, 66);
      expect(summary.totalTax, 6);

      final personA = summary.itemsByPerson
          .firstWhere((person) => person.name == 'Person A');
      expect(personA.taxAmount, closeTo(2, 0.001));
      expect(personA.baseAmount, closeTo(20, 0.001));
    });

    test('computeWithTax uses zero rate when index missing', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Item A', amount: '10')],
            persons: [PersonEntry(name: 'Alex', emoji: '')],
          ),
        ],
        [],
      );

      expect(summary.totalWithTax, 10);
      expect(summary.totalTax, 0);
    });

    test('formatReceiptText includes total line', () {
      final summary = ReceiptCalculator.computeWithTax(
        [
          InsertBatch(
            items: [ItemEntry(name: 'Coffee', amount: '10')],
            persons: [PersonEntry(name: 'Alex', emoji: '')],
          ),
        ],
        [10],
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
