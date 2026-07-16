import 'package:flutter/material.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';

class TaxRuleTabs extends StatelessWidget {
  const TaxRuleTabs({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.labelColor,
    required this.onSelected,
    this.rateLabels,
  });

  final int count;
  final int selectedIndex;
  final Color labelColor;
  final ValueChanged<int> onSelected;
  final List<String?>? rateLabels;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < count; i++)
            _TaxTabChip(
              key: Key('tax_tab_$i'),
              label: _labelFor(i),
              labelColor: labelColor,
              isSelected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }

  String _labelFor(int index) {
    final rate = rateLabels != null && index < rateLabels!.length
        ? rateLabels![index]
        : null;
    if (rate != null && rate.isNotEmpty) {
      return 'Tax ${index + 1} ($rate%)';
    }
    return 'Tax ${index + 1}';
  }
}

class _TaxTabChip extends StatelessWidget {
  const _TaxTabChip({
    super.key,
    required this.label,
    required this.labelColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color labelColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: isSelected ? AppColors.accentOrange : null,
      label: Text(
        label,
        style: AppTextStyles.fira(
          size: 13,
          color: isSelected ? Colors.white : labelColor,
        ),
      ),
      onPressed: onTap,
    );
  }
}
