import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/services/receipt_file_service.dart';
import 'package:taxed/services/receipt_read_timeout.dart';
import 'package:taxed/services/receipt_upload_mapper.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/platform_capabilities.dart';
import 'package:taxed/widgets/app_content_width.dart';
import 'package:taxed/widgets/receipt_drop_zone.dart';
import 'package:taxed/widgets/screen_title_header.dart';

class ReceiptUploadScreen extends StatefulWidget {
  const ReceiptUploadScreen({
    super.key,
    required this.theme,
  });

  final AppThemeController theme;

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  bool _processing = false;
  String? _errorMessage;

  Future<InsertBatch?> _readReceiptFromFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final text = await ReceiptFileService.extractText(bytes, file.name);
    return ReceiptUploadMapper.mapTextToBatch(text);
  }

  void _returnToHomeWithError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _processFile(XFile file) async {
    if (_processing) return;

    if (!ReceiptFileService.isAllowed(file.name)) {
      setState(() {
        _errorMessage = 'Only PNG, JPG, and PDF files are supported.';
      });
      return;
    }

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final batch = await withReceiptReadTimeout(
        _readReceiptFromFile(file),
        enabled: supportsReceiptReadTimeout,
      );

      if (!mounted) return;

      if (batch == null || batch.items.isEmpty) {
        setState(() {
          _processing = false;
          _errorMessage =
              'Could not find any line items in this receipt. Try another file.';
        });
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ReceiptPreviewScreen(
            theme: widget.theme,
            batches: [batch],
            fromUpload: true,
          ),
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      _returnToHomeWithError(
        'Receipt reading timed out after 1 minute. Please try again.',
      );
    } on ReceiptFileException catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _errorMessage = 'Something went wrong while processing the file.';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final picked = await ReceiptFileService.pickFile();
      if (picked == null || !mounted) return;
      await _processFile(XFile.fromData(picked.bytes, name: picked.name));
    } on ReceiptFileException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.theme,
      builder: (context, _) {
        final labelColor = widget.theme.buttonLabel;
        final panelColor = widget.theme.buttonFill;

        return Scaffold(
          backgroundColor: widget.theme.background,
          body: SafeArea(
            child: AppContentWidth(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back, color: labelColor),
                        ),
                      ),
                      ScreenTitleHeader(
                        title: 'Upload image',
                        labelColor: labelColor,
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Expanded(
                                child: ReceiptDropZone(
                                  panelColor: panelColor,
                                  labelColor: labelColor,
                                  onTapBrowse: _pickFile,
                                  onInvalidFile: (message) {
                                    setState(() => _errorMessage = message);
                                  },
                                  onFileSelected: _processFile,
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.fira(
                                    size: 14,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_processing)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Reading receipt...',
                              style: AppTextStyles.fira(
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
