import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:taxed/services/receipt_file_service.dart';
import 'package:taxed/theme/app_text_styles.dart';

class ReceiptDropZone extends StatefulWidget {
  const ReceiptDropZone({
    super.key,
    required this.panelColor,
    required this.labelColor,
    required this.onFileSelected,
    required this.onInvalidFile,
    required this.onTapBrowse,
  });

  final Color panelColor;
  final Color labelColor;
  final Future<void> Function(XFile file) onFileSelected;
  final void Function(String message) onInvalidFile;
  final VoidCallback onTapBrowse;

  @override
  State<ReceiptDropZone> createState() => _ReceiptDropZoneState();
}

class _ReceiptDropZoneState extends State<ReceiptDropZone> {
  bool _dragging = false;

  Future<void> _handleDrop(XFile file) async {
    if (!ReceiptFileService.isAllowed(file.name)) {
      widget.onInvalidFile('Only PNG, JPG, and PDF files are supported.');
      return;
    }
    await widget.onFileSelected(file);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        if (details.files.isEmpty) return;
        await _handleDrop(details.files.first);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('receipt_drop_zone'),
          onTap: widget.onTapBrowse,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            decoration: BoxDecoration(
              color: widget.panelColor.withValues(
                alpha: _dragging ? 0.85 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.labelColor.withValues(alpha: _dragging ? 0.6 : 0.3),
                width: _dragging ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: widget.labelColor.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drag and drop PNG, JPG, or PDF here',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fira(size: 16, color: widget.labelColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'or click to browse',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.fira(
                    size: 14,
                    color: widget.labelColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
