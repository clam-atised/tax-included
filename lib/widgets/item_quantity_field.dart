import 'package:flutter/material.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/utils/input_limits.dart';

class ItemQuantityField extends StatelessWidget {
  const ItemQuantityField({
    super.key,
    required this.itemIndex,
    required this.quantity,
    required this.onQuantityChanged,
    required this.labelColor,
  });

  final int itemIndex;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final value = quantity.clamp(
      InputLimits.minItemQuantity,
      InputLimits.maxItemQuantity,
    );

    return SizedBox(
      width: 72,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            key: Key('item_quantity_field_$itemIndex'),
            value: value,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.accentOrange,
            ),
            style: AppTextStyles.fira(size: 14, color: labelColor),
            items: List.generate(
              InputLimits.maxItemQuantity + 1,
              (index) => DropdownMenuItem(
                value: index,
                child: Text('$index'),
              ),
            ),
            onChanged: (newValue) {
              if (newValue != null) {
                onQuantityChanged(newValue);
              }
            },
          ),
        ),
      ),
    );
  }
}
