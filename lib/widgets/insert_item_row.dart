import 'package:flutter/material.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';
import 'package:taxed/widgets/app_text_field.dart';
import 'package:taxed/widgets/item_quantity_field.dart';

class InsertItemRow extends StatelessWidget {
  const InsertItemRow({
    super.key,
    required this.itemIndex,
    required this.nameController,
    required this.amountController,
    required this.quantity,
    required this.onQuantityChanged,
    required this.labelColor,
    required this.canRemove,
    required this.onRemove,
  });

  final int itemIndex;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final Color labelColor;
  final bool canRemove;
  final VoidCallback onRemove;

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
          ItemQuantityField(
            itemIndex: itemIndex,
            quantity: quantity,
            onQuantityChanged: onQuantityChanged,
            labelColor: labelColor,
          ),
          if (canRemove) ...[
            const SizedBox(width: 4),
            IconButton(
              key: Key('remove_item_row_$itemIndex'),
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                color: labelColor,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
