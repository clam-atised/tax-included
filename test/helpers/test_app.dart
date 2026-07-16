import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxed/app/app_scope.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/main.dart';
import 'package:taxed/theme/app_theme_controller.dart';

typedef TestAppDeps = ({AppThemeController theme, InsertStore store});

Future<TestAppDeps> createTestApp() async {
  SharedPreferences.setMockInitialValues({});
  final theme = AppThemeController();
  await theme.load();
  final store = InsertStore();
  return (theme: theme, store: store);
}

Future<TestAppDeps> pumpApp(WidgetTester tester) async {
  final deps = await createTestApp();
  await pumpWithDeps(tester, deps);
  return deps;
}

Future<void> pumpWithDeps(WidgetTester tester, TestAppDeps deps) async {
  await tester.pumpWidget(
    AppScope(
      theme: deps.theme,
      store: deps.store,
      child: TaxIncludedApp(theme: deps.theme, store: deps.store),
    ),
  );
}

Finder insertItemTextField(int rowIndex, int fieldIndex) {
  return find
      .descendant(
        of: find.byKey(Key('insert_item_row_$rowIndex')),
        matching: find.byType(TextField),
      )
      .at(fieldIndex);
}

Future<void> enterInsertItem(
  WidgetTester tester, {
  int rowIndex = 0,
  required String name,
  required String amount,
}) async {
  await tester.enterText(insertItemTextField(rowIndex, 0), name);
  await tester.enterText(insertItemTextField(rowIndex, 1), amount);
}

Future<void> enterInsertPerson(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(const Key('insert_person_row')), name);
}

Future<void> openTaxInsert(WidgetTester tester) async {
  await tester.tap(find.text('Manual insert'));
  await tester.pumpAndSettle();
  await enterInsertItem(tester, name: 'Coffee', amount: '10');
  await enterInsertPerson(tester, 'Alex');
  await tester.tap(find.byKey(const Key('confirm_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('preview_confirm_button')));
  await tester.pumpAndSettle();
}

Future<void> completePrintFlow(WidgetTester tester) async {
  await openTaxInsert(tester);
  await tester.enterText(find.byKey(const Key('tax_amount_field_0')), '10');
  await tester.tap(find.byKey(const Key('tax_confirm_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('print_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('print_copy_button')));
  await tester.pumpAndSettle();
}
