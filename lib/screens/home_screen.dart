import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/screens/insert.dart';
import 'package:taxed/screens/receipt_capture_screen.dart';
import 'package:taxed/screens/receipt_upload_screen.dart';
import 'package:taxed/screens/setting.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/platform_capabilities.dart';
import 'package:taxed/widgets/home_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
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
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tax',
                          style: GoogleFonts.firaCode(
                            fontSize: 36,
                            color: theme.taxText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Included',
                          style: GoogleFonts.firaCode(
                            fontSize: 36,
                            color: theme.includedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (supportsCameraCapture) ...[
                  HomeActionButton(
                    iconAsset: 'assets/icons/camera.svg',
                    label: 'Capture receipt',
                    buttonColor: theme.buttonFill,
                    labelColor: theme.buttonLabel,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ReceiptCaptureScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (supportsFileUpload) ...[
                  HomeActionButton(
                    iconAsset: 'assets/icons/image.svg',
                    label: 'Upload image',
                    buttonColor: theme.buttonFill,
                    labelColor: theme.buttonLabel,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReceiptUploadScreen(theme: theme),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                HomeActionButton(
                  iconAsset: 'assets/icons/square-pen.svg',
                  label: 'Manual insert',
                  buttonColor: theme.buttonFill,
                  labelColor: theme.buttonLabel,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => InsertScreen(
                          theme: theme,
                          store: store,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => openSettingsDialog(context, theme),
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
          ),
        );
      },
    );
  }
}
