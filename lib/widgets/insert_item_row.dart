import 'package:flutter/material.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';
import 'package:taxed/widgets/app_text_field.dart';
import 'package:taxed/widgets/split_count_field.dart';

class InsertItemRow extends StatelessWidget {
  const InsertItemRow({
    super.key,
    required this.itemIndex,
    required this.nameController,
    required this.amountController,
    required this.splitCount,
    required this.onSplitCountChanged,
    required this.labelColor,
  });

  final int itemIndex;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final int splitCount;
  final ValueChanged<int> onSplitCountChanged;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              controller: nameController,
              hint: 'Item Name',
              keyboardType: TextInputType.text,
              labelColor: labelColor,
              maxLength: InputLimits.maxItemNameLength,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: AppTextField(
              controller: amountController,
              hint: 'Amount',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelColor: labelColor,
              inputFormatters: [MaxDecimalAmountFormatter()],
            ),
          ),
          const SizedBox(width: 8),
          SplitCountField(
            key: Key('split_count_field_$itemIndex'),
            splitCount: splitCount,
            onSplitCountChanged: onSplitCountChanged,
            labelColor: labelColor,
          ),
        ],
      ),
    );
  }
}
