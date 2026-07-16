import 'package:flutter/material.dart';
import 'package:taxed/controllers/insert_form_rows.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/services/receipt_upload_mapper.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';
import 'package:taxed/widgets/app_text_field.dart';
import 'package:taxed/widgets/dual_action_bar.dart';
import 'package:taxed/widgets/form_panel.dart';
import 'package:taxed/widgets/screen_title_header.dart';

class ReceiptItemsEditScreen extends StatefulWidget {
  const ReceiptItemsEditScreen({
    super.key,
    required this.theme,
    required this.batch,
  });

  final AppThemeController theme;
  final InsertBatch batch;

  @override
  State<ReceiptItemsEditScreen> createState() => _ReceiptItemsEditScreenState();
}

class _ReceiptItemsEditScreenState extends State<ReceiptItemsEditScreen> {
  late final List<ItemRowState> _itemRows;
  late final List<String> _registeredNames;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _registeredNames = ReceiptUploadMapper.registeredItemNames(widget.batch.items);
    _itemRows = widget.batch.items.map((item) {
      final row = ItemRowState();
      row.nameController.text = item.name;
      row.amountController.text = item.amount;
      return row;
    }).toList();
  }

  @override
  void dispose() {
    for (final row in _itemRows) {
      row.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  InsertBatch _buildBatch() {
    return InsertBatch(
      items: _itemRows.map((row) => row.toEntry()).toList(),
      persons: const [],
    );
  }

  void _confirm() {
    Navigator.of(context).pop(_buildBatch());
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
            child: Column(
              children: [
                ScreenTitleHeader(
                  title: 'Manual insert',
                  labelColor: labelColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Item ${_currentPage + 1} of ${_itemRows.length}',
                  style: AppTextStyles.fira(size: 14, color: labelColor),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _itemRows.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final row = _itemRows[index];
                      final selectedName = row.nameController.text.trim().isEmpty
                          ? (_registeredNames.isNotEmpty
                              ? _registeredNames.first
                              : '')
                          : row.nameController.text.trim();
                      final dropdownValue = _registeredNames.contains(selectedName)
                          ? selectedName
                          : (_registeredNames.isNotEmpty
                              ? _registeredNames.first
                              : null);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FormPanel(
                          color: panelColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item name',
                                style: AppTextStyles.fira(
                                  size: 14,
                                  color: labelColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_registeredNames.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      key: Key('item_name_dropdown_$index'),
                                      value: dropdownValue,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.accentOrange,
                                      ),
                                      items: _registeredNames
                                          .map(
                                            (name) => DropdownMenuItem(
                                              value: name,
                                              child: Text(name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          row.nameController.text = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: row.nameController,
                                hint: 'Item Name',
                                labelColor: labelColor,
                                maxLength: InputLimits.maxItemNameLength,
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: row.amountController,
                                hint: 'Amount',
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                labelColor: labelColor,
                                inputFormatters: [MaxDecimalAmountFormatter()],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_itemRows.length, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 10 : 8,
                        height: active ? 10 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.accentOrange
                              : labelColor.withValues(alpha: 0.35),
                        ),
                      );
                    }),
                  ),
                ),
                DualActionBar(
                  left: DualActionBarAction(
                    label: 'Back',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  right: DualActionBarAction(
                    key: const Key('items_edit_confirm'),
                    label: 'Confirm',
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
