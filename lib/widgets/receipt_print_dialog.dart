import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';

Future<void> showReceiptPrintDialog(
  BuildContext context, {
  required String initialText,
  VoidCallback? onCompleted,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final controller = TextEditingController(text: initialText);

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        content: SizedBox(
          width: MediaQuery.of(dialogContext).size.width,
          child: TextField(
            key: const Key('print_text_field'),
            controller: controller,
            autofocus: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: AppTextStyles.fira(size: 13, color: AppColors.navy),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: AppTextStyles.fira(size: 14, color: AppColors.navy),
            ),
          ),
          TextButton(
            key: const Key('print_copy_button'),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: controller.text),
              );
              onCompleted?.call();
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Copied to clipboard',
                      style: AppTextStyles.fira(size: 14, color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Copy',
              style: AppTextStyles.fira(size: 14, color: AppColors.accentOrange),
            ),
          ),
        ],
      );
    },
  );
}
