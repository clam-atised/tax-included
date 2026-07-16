import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/platform_capabilities.dart';
import 'package:taxed/widgets/tax_amount_field.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() {
    debugTargetPlatformForTests = TargetPlatform.linux;
  });

  tearDown(() {
    debugTargetPlatformForTests = null;
  });

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
    expect(find.text('person'), findsOneWidget);
    expect(find.byKey(const Key('add_person_batch')), findsOneWidget);
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

  testWidgets('+ person saves current person and clears form', (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await enterInsertItem(tester, name: 'Mac & Cheese', amount: '10.90');
    await enterInsertPerson(tester, 'Devon');

    await tester.tap(find.byKey(const Key('add_person_batch')));
    await tester.pumpAndSettle();

    expect(deps.store.savedBatches.length, 1);
    expect(deps.store.savedBatches.first.persons.first.name, 'Devon');
    expect(find.byKey(const Key('person_index_0_0')), findsOneWidget);
    expect(find.text('Devon'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);

    final personField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('insert_person_row')),
        matching: find.byType(TextField),
      ),
    );
    expect(personField.controller!.text, isEmpty);

    final itemNameField = tester.widget<TextField>(
      insertItemTextField(0, 0),
    );
    expect(itemNameField.controller!.text, isEmpty);
  });

  testWidgets('Confirm shows all people after + person', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await enterInsertItem(tester, name: 'Mac & Cheese', amount: '10.90');
    await enterInsertPerson(tester, 'Devon');
    await tester.tap(find.byKey(const Key('add_person_batch')));
    await tester.pumpAndSettle();

    await enterInsertItem(tester, name: 'Garlic Pita', amount: '9.90');
    await enterInsertPerson(tester, 'Clarise');

    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();

    expect(find.text('Receipt Preview'), findsOneWidget);
    expect(find.text('Mac & Cheese'), findsOneWidget);
    expect(find.text('Garlic Pita'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sort_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('By Person'), findsOneWidget);
    expect(find.text('Devon'), findsOneWidget);
    expect(find.text('Clarise'), findsOneWidget);
  });

  testWidgets('Home button saves batch and returns home', (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await enterInsertItem(tester, name: 'Coffee', amount: '10');
    await enterInsertPerson(tester, 'Alex');

    await tester.tap(find.byKey(const Key('bottom_home_button')));
    await tester.pumpAndSettle();

    expect(deps.store.savedBatches.length, 1);
    expect(find.text('Manual insert'), findsOneWidget);
    expect(find.text('from:'), findsNothing);
  });

  testWidgets('Confirm opens receipt preview', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await enterInsertItem(tester, name: 'Coffee', amount: '12.50');
    await enterInsertPerson(tester, 'Alex');

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

    await enterInsertItem(tester, name: 'Tea', amount: '5');
    await enterInsertPerson(tester, 'Sam');

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
    expect(find.text('Tax Amount'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('Apply tax to:'), findsOneWidget);
  });

  testWidgets('Add tax creates blank tab and keeps prior editable',
      (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('add_tax_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tax_tab_0')), findsOneWidget);
    expect(find.byKey(const Key('tax_tab_1')), findsOneWidget);
    expect(
      tester
          .widget<TaxAmountField>(find.byKey(const Key('tax_amount_field_0')))
          .controller
          .text,
      isEmpty,
    );

    await tester.tap(find.byKey(const Key('tax_tab_0')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TaxAmountField>(find.byKey(const Key('tax_amount_field_0')))
          .controller
          .text,
      '10',
    );
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
    expect(find.text('Tax'), findsWidgets);
  });

  testWidgets('Tax confirm without rate opens untaxed receipt preview',
      (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Total (with tax)'), findsNothing);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Print'), findsNothing);
  });

  testWidgets('Taxed preview edit returns to tax insert', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Tax Insert'), findsOneWidget);
    expect(find.byKey(const Key('tax_amount_field_0')), findsOneWidget);
  });

  testWidgets('Print opens editable dialog with copy and sort', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('print_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('print_text_field')), findsOneWidget);
    expect(find.byKey(const Key('print_sort_toggle')), findsOneWidget);

    await tester.tap(find.byKey(const Key('print_sort_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('By Person'), findsOneWidget);

    await tester.tap(find.byKey(const Key('print_copy_button')));
    await tester.pumpAndSettle();

    expect(find.text('Copied to clipboard'), findsOneWidget);
  });

  testWidgets('Copy after print clears saved insert batches and tax data',
      (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();
    await enterInsertItem(tester, name: 'Coffee', amount: '10');
    await enterInsertPerson(tester, 'Alex');
    await tester.tap(find.byKey(const Key('confirm_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview_confirm_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();
    expect(deps.store.pendingTaxData, isNotNull);
    await tester.tap(find.byKey(const Key('print_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('print_copy_button')));
    await tester.pumpAndSettle();

    expect(deps.store.savedBatches, isEmpty);
    expect(deps.store.pendingTaxData, isNull);
  });

  testWidgets('Taxed preview toggles sort mode', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sort_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('By Person'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('Tax scope Everyone and Everything checked by default',
      (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    Checkbox checkboxFor(Key scopeKey) {
      return tester.widget<Checkbox>(
        find.descendant(
          of: find.byKey(scopeKey),
          matching: find.byType(Checkbox),
        ),
      );
    }

    expect(checkboxFor(const Key('tax_scope_everyone')).value, isTrue);
    expect(checkboxFor(const Key('tax_scope_everything')).value, isTrue);
    expect(checkboxFor(const Key('tax_scope_person_Alex')).value, isTrue);
    expect(checkboxFor(const Key('tax_scope_item_Coffee')).value, isTrue);
  });

  testWidgets('Everyone toggle controls all person checkboxes', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    Checkbox checkboxFor(Key scopeKey) {
      return tester.widget<Checkbox>(
        find.descendant(
          of: find.byKey(scopeKey),
          matching: find.byType(Checkbox),
        ),
      );
    }

    await tester.tap(find.byKey(const Key('tax_scope_everyone')));
    await tester.pumpAndSettle();

    expect(checkboxFor(const Key('tax_scope_everyone')).value, isFalse);
    expect(checkboxFor(const Key('tax_scope_person_Alex')).value, isFalse);

    await tester.tap(find.byKey(const Key('tax_scope_everyone')));
    await tester.pumpAndSettle();

    expect(checkboxFor(const Key('tax_scope_everyone')).value, isTrue);
    expect(checkboxFor(const Key('tax_scope_person_Alex')).value, isTrue);
  });

  testWidgets('Tax back returns to insert screen', (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    await tester.tap(find.byKey(const Key('tax_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Manual insert'), findsOneWidget);
    expect(find.text('from:'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });

  testWidgets('Switching tax tabs restores rate and scope for editing',
      (tester) async {
    await pumpApp(tester);
    await openTaxInsert(tester);

    Checkbox checkboxFor(Key scopeKey) {
      return tester.widget<Checkbox>(
        find.descendant(
          of: find.byKey(scopeKey),
          matching: find.byType(Checkbox),
        ),
      );
    }

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_scope_everyone')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_tax_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '5');
    await tester.tap(find.byKey(const Key('tax_tab_0')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TaxAmountField>(find.byKey(const Key('tax_amount_field_0')))
          .controller
          .text,
      '10',
    );
    expect(checkboxFor(const Key('tax_scope_everyone')).value, isFalse);
    expect(checkboxFor(const Key('tax_scope_person_Alex')).value, isFalse);

    await tester.tap(find.byKey(const Key('tax_tab_1')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TaxAmountField>(find.byKey(const Key('tax_amount_field_0')))
          .controller
          .text,
      '5',
    );
    expect(checkboxFor(const Key('tax_scope_everyone')).value, isTrue);
  });

  testWidgets('Taxed preview home button navigates to home', (tester) async {
    final deps = await createTestApp();
    await pumpWithDeps(tester, deps);

    await openTaxInsert(tester);
    await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
    await tester.tap(find.byKey(const Key('tax_confirm_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taxed_preview_home_button')));
    await tester.pumpAndSettle();

    expect(find.text('Manual insert'), findsOneWidget);
    expect(deps.store.pendingTaxData, isNotNull);
  });

  testWidgets('Typing item name auto-sets quantity to 1', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    final quantityDropdown = find.byKey(const Key('item_quantity_field_0'));
    expect(
      tester.widget<DropdownButton<int>>(quantityDropdown).value,
      0,
    );

    await tester.enterText(insertItemTextField(0, 0), 'Coffee');
    await tester.pumpAndSettle();

    expect(
      tester.widget<DropdownButton<int>>(quantityDropdown).value,
      1,
    );
  });

  testWidgets('Close icon removes item row when multiple rows exist',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('insert_item_row_0')), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_1')), findsOneWidget);
    expect(find.byKey(const Key('remove_item_row_0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('remove_item_row_0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('insert_item_row_0')), findsOneWidget);
    expect(find.byKey(const Key('insert_item_row_1')), findsNothing);
    expect(find.byKey(const Key('remove_item_row_0')), findsNothing);
  });

  testWidgets('Person chip shows single emoji from name field', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Manual insert'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('insert_person_row')), '😇 Alex');
    await tester.pumpAndSettle();

    expect(find.text('😇 Alex'), findsOneWidget);
    expect(find.text('😇 😇'), findsNothing);
  });
}
