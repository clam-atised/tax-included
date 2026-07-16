import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/screens/receipt_items_edit_screen.dart';
import 'package:taxed/theme/app_theme_controller.dart';

void main() {
  testWidgets('Receipt items edit shows one page per item with dots', (
    tester,
  ) async {
    final theme = AppThemeController();

    await tester.pumpWidget(
      MaterialApp(
        home: ReceiptItemsEditScreen(
          theme: theme,
          batch: InsertBatch(
            items: [
              ItemEntry(name: 'Coffee', amount: '3.50'),
              ItemEntry(name: 'Coffee', amount: '3.50'),
              ItemEntry(name: 'Tea', amount: '2.00'),
            ],
            persons: [],
          ),
        ),
      ),
    );

    expect(find.text('Item 1 of 3'), findsOneWidget);
    expect(find.text('Manual insert'), findsOneWidget);
    expect(find.byKey(const Key('item_name_dropdown_0')), findsOneWidget);
    expect(find.byKey(const Key('items_edit_confirm')), findsOneWidget);
  });
}
