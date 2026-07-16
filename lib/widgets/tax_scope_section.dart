import 'package:flutter/material.dart';
import 'package:taxed/theme/app_text_styles.dart';

class TaxScopeSection extends StatelessWidget {
  const TaxScopeSection({
    super.key,
    required this.personNames,
    required this.itemNames,
    required this.selectedPersons,
    required this.selectedItems,
    required this.onEveryoneToggled,
    required this.onEverythingToggled,
    required this.onPersonToggled,
    required this.onItemToggled,
    required this.labelColor,
  });

  final List<String> personNames;
  final List<String> itemNames;
  final Set<String> selectedPersons;
  final Set<String> selectedItems;
  final VoidCallback onEveryoneToggled;
  final VoidCallback onEverythingToggled;
  final ValueChanged<String> onPersonToggled;
  final ValueChanged<String> onItemToggled;
  final Color labelColor;

  bool get _everyoneChecked =>
      personNames.isNotEmpty &&
      personNames.every((name) => selectedPersons.contains(name));

  bool get _everythingChecked =>
      itemNames.isNotEmpty &&
      itemNames.every((name) => selectedItems.contains(name));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Apply tax to:',
          style: AppTextStyles.fira(size: 14, color: labelColor),
        ),
        const SizedBox(height: 12),
        if (personNames.isNotEmpty) ...[
          Text(
            'Persons',
            style: AppTextStyles.fira(
              size: 13,
              color: labelColor,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _ScopeCheckbox(
                key: const Key('tax_scope_everyone'),
                label: 'Everyone',
                checked: _everyoneChecked,
                labelColor: labelColor,
                onChanged: onEveryoneToggled,
              ),
              for (final name in personNames)
                _ScopeCheckbox(
                  key: Key('tax_scope_person_$name'),
                  label: name,
                  checked: selectedPersons.contains(name),
                  labelColor: labelColor,
                  onChanged: () => onPersonToggled(name),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (itemNames.isNotEmpty) ...[
          Text(
            'Items',
            style: AppTextStyles.fira(
              size: 13,
              color: labelColor,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _ScopeCheckbox(
                key: const Key('tax_scope_everything'),
                label: 'Everything',
                checked: _everythingChecked,
                labelColor: labelColor,
                onChanged: onEverythingToggled,
              ),
              for (final name in itemNames)
                _ScopeCheckbox(
                  key: Key('tax_scope_item_$name'),
                  label: name,
                  checked: selectedItems.contains(name),
                  labelColor: labelColor,
                  onChanged: () => onItemToggled(name),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScopeCheckbox extends StatelessWidget {
  const _ScopeCheckbox({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    required this.labelColor,
  });

  final String label;
  final bool checked;
  final VoidCallback onChanged;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: (_) => onChanged(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.fira(size: 13, color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
