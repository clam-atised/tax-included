import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taxed/services/receipt_calculator.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';

Future<void> showReceiptPrintDialog(
  BuildContext context, {
  required TaxedReceiptSummary summary,
  required ReceiptSortMode initialSortMode,
  VoidCallback? onCompleted,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return _ReceiptPrintDialog(
        summary: summary,
        initialSortMode: initialSortMode,
        onCompleted: onCompleted,
      );
    },
  );
}

class _ReceiptPrintDialog extends StatefulWidget {
  const _ReceiptPrintDialog({
    required this.summary,
    required this.initialSortMode,
    this.onCompleted,
  });

  final TaxedReceiptSummary summary;
  final ReceiptSortMode initialSortMode;
  final VoidCallback? onCompleted;

  @override
  State<_ReceiptPrintDialog> createState() => _ReceiptPrintDialogState();
}

class _ReceiptPrintDialogState extends State<_ReceiptPrintDialog> {
  late ReceiptSortMode _sortMode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _sortMode = widget.initialSortMode;
    _controller = TextEditingController(text: _buildText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildText() {
    return ReceiptCalculator.formatReceiptText(widget.summary, _sortMode);
  }

  void _toggleSort() {
    setState(() {
      _sortMode = _sortMode == ReceiptSortMode.byItem
          ? ReceiptSortMode.byPerson
          : ReceiptSortMode.byItem;
      _controller.text = _buildText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      content: SizedBox(
        width: 400,
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                key: const Key('print_sort_toggle'),
                onTap: _toggleSort,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/arrow-up-down.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.accentOrange,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sortMode == ReceiptSortMode.byItem
                            ? 'By Item'
                            : 'By Person',
                        style: AppTextStyles.fira(size: 14, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                key: const Key('print_text_field'),
                controller: _controller,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: AppTextStyles.fira(size: 13, color: AppColors.navy),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: AppTextStyles.fira(size: 14, color: AppColors.navy),
          ),
        ),
        TextButton(
          key: const Key('print_copy_button'),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            final text = _controller.text;
            Navigator.of(context).pop();
            widget.onCompleted?.call();
            unawaited(
              Clipboard.setData(ClipboardData(text: text)),
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Copied to clipboard',
                  style: AppTextStyles.fira(size: 14, color: Colors.white),
                ),
              ),
            );
          },
          child: Text(
            'Copy',
            style: AppTextStyles.fira(size: 14, color: AppColors.accentOrange),
          ),
        ),
      ],
    );
  }
}
