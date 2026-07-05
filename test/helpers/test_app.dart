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

Future<void> openTaxInsert(WidgetTester tester) async {
  await tester.tap(find.text('Manual insert'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'Coffee');
  await tester.enterText(find.byType(TextField).at(1), '10');
  await tester.enterText(find.byType(TextField).at(4), 'Alex');
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
