import 'package:flutter/material.dart';
import 'package:taxed/models/receipt_display_models.dart';
import 'package:taxed/services/receipt_calculator.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/widgets/receipt_paper.dart';

class ReceiptLineSection extends StatelessWidget {
  const ReceiptLineSection({
    super.key,
    required this.lines,
    required this.labelColor,
    required this.sortMode,
  });

  final List<ReceiptDisplayLine> lines;
  final Color labelColor;
  final ReceiptSortMode sortMode;

  @override
  Widget build(BuildContext context) {
    if (lines.length == 1 && isEmptyPlaceholder(lines.first)) {
      return Text(
        emptyReceiptMessage(sortMode),
        style: AppTextStyles.fira(size: 14, color: labelColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < lines.length; index++)
          ..._buildLineWidgets(lines[index], isLast: index == lines.length - 1),
      ],
    );
  }

  List<Widget> _buildLineWidgets(ReceiptDisplayLine line, {required bool isLast}) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              line.title,
              style: AppTextStyles.fira(size: 14, color: labelColor),
            ),
          ),
          Text(
            ReceiptCalculator.formatAmount(line.amount),
            style: AppTextStyles.fira(size: 14, color: labelColor),
          ),
        ],
      ),
      if (line.subtitle.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          line.subtitle.join(', '),
          style: AppTextStyles.fira(
            size: 12,
            color: labelColor.withValues(alpha: 0.8),
          ),
        ),
      ],
      if (line.extra != null) ...[
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              line.extra!.label,
              style: AppTextStyles.fira(
                size: 12,
                color: labelColor.withValues(alpha: 0.8),
              ),
            ),
            Text(
              ReceiptCalculator.formatAmount(line.extra!.amount),
              style: AppTextStyles.fira(
                size: 12,
                color: labelColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      if (!isLast) ...[
        DashedLine(color: labelColor.withValues(alpha: 0.4)),
        const SizedBox(height: 12),
      ],
    ];
  }
}
