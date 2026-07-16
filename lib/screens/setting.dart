import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/widgets/mode_toggle.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key, required this.theme});

  final AppThemeController theme;

  void _close(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _toggleMode(BuildContext context) async {
    await theme.setNightMode(!theme.isNightMode);
    if (context.mounted) {
      _close(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return Material(
          color: theme.settingsBackground,
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _close(context),
                  child: const SizedBox.expand(),
                ),
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24, right: 24),
                        child: Text(
                          'Change mode',
                          style: GoogleFonts.firaCode(
                            fontSize: 28,
                            color: theme.settingsDialogText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Switch mode',
                      style: GoogleFonts.firaCode(
                        fontSize: 20,
                        color: theme.settingsDialogText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ModeToggle(
                      isNightMode: theme.isNightMode,
                      onChanged: (_) => _toggleMode(context),
                    ),
                    const Spacer(),
                    Text(
                      'Tax Included!\ncreated by\nclam.atised',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaCode(
                        fontSize: 16,
                        color: theme.settingsDialogText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    IconButton(
                      onPressed: () => _close(context),
                      icon: SvgPicture.asset(
                        'assets/icons/settings.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.taxText,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void openSettingsDialog(BuildContext context, AppThemeController theme) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close settings',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SettingScreen(theme: theme);
    },
  );
}
