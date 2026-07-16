import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/app/app_scope.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/screens/home_screen.dart';
import 'package:taxed/theme/app_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = AppThemeController();
  await theme.load();
  final store = InsertStore();
  runApp(
    AppScope(
      theme: theme,
      store: store,
      child: TaxIncludedApp(theme: theme, store: store),
    ),
  );
}

class TaxIncludedApp extends StatelessWidget {
  const TaxIncludedApp({
    super.key,
    required this.theme,
    required this.store,
  });

  final AppThemeController theme;
  final InsertStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tax Included',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: theme.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.includedText,
              surface: theme.background,
            ),
            textTheme: GoogleFonts.firaCodeTextTheme(),
          ),
          home: HomeScreen(theme: theme, store: store),
        );
      },
    );
  }
}
