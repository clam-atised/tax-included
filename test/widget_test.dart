import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/theme/app_theme_controller.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('Home screen shows title and manual insert', (tester) async {
    await pumpApp(tester);

    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Included'), findsOneWidget);
    expect(find.text('Manual insert'), findsOneWidget);
    expect(find.text('Capture receipt'), findsNothing);
    expect(find.text('Upload image'), findsOneWidget);
  });

  testWidgets('Upload image opens upload screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Upload image'));
    await tester.pumpAndSettle();

    expect(find.text('Drag and drop PNG, JPG, or PDF here'), findsOneWidget);
    expect(find.byKey(const Key('receipt_drop_zone')), findsOneWidget);
  });

  testWidgets('Settings dialog opens and closes on outside tap', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Change mode'), findsOneWidget);
    expect(find.text('Switch mode'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Change mode'), findsNothing);
  });

  testWidgets('Toggling mode closes settings and persists night mode',
      (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mode_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Change mode'), findsNothing);
    expect(deps.theme.isNightMode, isTrue);

    final reloadedTheme = AppThemeController();
    await reloadedTheme.load();
    expect(reloadedTheme.isNightMode, isTrue);
  });

  testWidgets('Manual insert screen opens from home', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    expect(find.text('from:'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
    expect(find.text('Add Person'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_0')), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_1')), findsOneWidget);
  });

  testWidgets('Add Item adds another row', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_item_row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('insert_item_row_2')), findsOneWidget);
  });

  testWidgets('Bottom Add item saves batch and resets form', (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bottom_add_item')));
    await tester.pumpAndSettle();

    expect(deps.store.savedBatches.length, 1);
    expect(find.byKey(const Key('insert_item_row_0')), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_1')), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_2')), findsNothing);
  });

  testWidgets('Confirm opens receipt preview', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Coffee');
    await tester.enterText(find.byType(TextField).at(1), '12.50');
    await tester.enterText(find.byType(TextField).at(4), 'Alex');

    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('By Item'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('12.50'), findsWidgets);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('Receipt preview toggles sort mode', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Tea');
    await tester.enterText(find.byType(TextField).at(1), '5');
    await tester.enterText(find.byType(TextField).at(4), 'Sam');

    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sort_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('By Person'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
  });

  testWidgets('Edit returns to insert screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Manual insert'), findsOneWidget);
    expect(find.text('from:'), findsOneWidget);
  });

  testWidgets('Receipt preview confirm opens tax insert', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    expect(find.text('Tax Insert'), findsOneWidget);
    expect(find.text('Tax Amount'), findsNWidgets(2));
    expect(find.text('%'), findsNWidgets(2));
  });

  testWidgets('Add Item adds another tax field', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('add_tax_row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tax_amount_field_2')), findsOneWidget);
  });

  testWidgets('Tax confirm opens taxed receipt preview', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.text('Total (with tax)'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('11.00'), findsWidgets);
  });

  testWidgets('Taxed preview edit returns to tax insert', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Tax Insert'), findsOneWidget);
  });

  testWidgets('Print opens editable dialog with copy', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('print_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('print_text_field')), findsOneWidget);

    await tester.tap(find.byKey(const Key('print_copy_button')));
    await tester.pumpAndSettle();

    expect(find.text('Copied to clipboard'), findsOneWidget);
  });

  testWidgets('Copy after print clears saved insert batches', (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_add_item')));
    await tester.pumpAndSettle();
    expect(deps.store.savedBatches.length, 1);

    await tester.enterText(find.byType(TextField).at(0), 'Coffee');
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.enterText(find.byType(TextField).at(4), 'Alex');
    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview_confirm_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('print_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('print_copy_button')));
    await tester.pumpAndSettle();

    expect(deps.store.savedBatches, isEmpty);
  });

  testWidgets('Taxed preview toggles sort mode', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sort_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('By Person'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('Tax edit returns to receipt preview', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('tax_edit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
  });
}
