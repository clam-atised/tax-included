import 'package:flutter/material.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/theme/app_theme_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.theme,
    required this.store,
    required super.child,
  });

  final AppThemeController theme;
  final InsertStore store;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return theme != oldWidget.theme || store != oldWidget.store;
  }
}
