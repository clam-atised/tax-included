import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxed/theme/app_colors.dart';

enum AppThemeMode { bright, night }

class AppThemeController extends ChangeNotifier {
  AppThemeController();

  static const _prefsKey = 'isNightMode';

  AppThemeMode _mode = AppThemeMode.bright;

  AppThemeMode get mode => _mode;

  bool get isNightMode => _mode == AppThemeMode.night;

  Color get background =>
      isNightMode ? AppColors.navy : AppColors.background;

  Color get includedText =>
      isNightMode ? AppColors.buttonFill : AppColors.navy;

  Color get taxText => AppColors.accentOrange;

  Color get buttonFill => AppColors.buttonFill;

  Color get buttonLabel => AppColors.navy;

  Color get settingsBackground => AppColors.settingsBackground;

  Color get settingsDialogText => Colors.white;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isNight = prefs.getBool(_prefsKey) ?? false;
    _mode = isNight ? AppThemeMode.night : AppThemeMode.bright;
    notifyListeners();
  }

  Future<void> setNightMode(bool value) async {
    final nextMode = value ? AppThemeMode.night : AppThemeMode.bright;
    if (_mode == nextMode) return;

    _mode = nextMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}
