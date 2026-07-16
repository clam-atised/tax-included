import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/screens/insert.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:taxed/screens/receipt_capture_screen.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/screens/receipt_upload_screen.dart';
import 'package:taxed/services/receipt_upload_mapper.dart';
import 'package:taxed/screens/setting.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/platform_capabilities.dart';
import 'package:taxed/widgets/app_content_width.dart';
import 'package:taxed/widgets/home_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.theme,
    required this.store,
  });

  final AppThemeController theme;
  final InsertStore store;

  Future<void> _openCaptureReceipt(BuildContext context) async {
    final receipt = await Navigator.of(context).push<RecognizedReceipt>(
      MaterialPageRoute(
        builder: (_) => const ReceiptCaptureScreen(),
      ),
    );
    if (!context.mounted || receipt == null) return;

    final batch = ReceiptUploadMapper.mapReceiptToBatch(receipt);
    if (batch == null || batch.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find any line items in this receipt. Try again.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPreviewScreen(
          theme: theme,
          batches: [batch],
          fromUpload: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: AppContentWidth(
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
                    onTap: () => _openCaptureReceipt(context),
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
                    if (store.savedBatches.isNotEmpty &&
                        store.editingBatchIndex == null) {
                      store.loadBatch(0);
                    }
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
          ),
        );
      },
    );
  }
}
