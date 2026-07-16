import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:taxed/controllers/insert_form_rows.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/models/batch_person_ref.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/screens/home_screen.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/widgets/app_content_width.dart';
import 'package:taxed/widgets/dual_action_bar.dart';
import 'package:taxed/widgets/form_panel.dart';
import 'package:taxed/widgets/insert_add_row_button.dart';
import 'package:taxed/widgets/insert_item_row.dart';
import 'package:taxed/widgets/insert_person_row.dart';
import 'package:taxed/widgets/screen_title_header.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({
    super.key,
    required this.theme,
    required this.store,
  });

  final AppThemeController theme;
  final InsertStore store;

  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final List<ItemRowState> _itemRows = [];
  late final PersonRowState _personRow;

  @override
  void initState() {
    super.initState();
    _personRow = PersonRowState();
    _loadFromStore();
  }

  void _loadFromStore() {
    for (final row in _itemRows) {
      row.dispose();
    }
    _itemRows.clear();

    final editingIndex = widget.store.editingBatchIndex;
    final batch = editingIndex != null ? widget.store.batchAt(editingIndex) : null;

    if (batch != null) {
      for (final item in batch.items) {
        final row = _createItemRow();
        row.nameController.text = item.name;
        row.amountController.text = item.amount;
        row.quantity = item.quantity;
        _itemRows.add(row);
      }
      if (batch.persons.isNotEmpty) {
        _personRow.nameController.text = batch.persons.first.name;
      } else {
        _personRow.nameController.clear();
      }
    } else {
      _personRow.nameController.clear();
    }

    if (_itemRows.isEmpty) {
      _itemRows.addAll([_createItemRow(), _createItemRow()]);
    }
  }

  ItemRowState _createItemRow() {
    final row = ItemRowState();
    _attachItemRowListeners(row);
    return row;
  }

  void _attachItemRowListeners(ItemRowState row) {
    row.attachNameListener(() {
      final name = row.nameController.text.trim();
      if (name.isNotEmpty && row.quantity == 0) {
        setState(() => row.quantity = 1);
      }
    });
  }

  void _removeItemRow(int index) {
    if (_itemRows.length <= 1) return;
    setState(() {
      _itemRows[index].dispose();
      _itemRows.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final row in _itemRows) {
      row.dispose();
    }
    _personRow.dispose();
    super.dispose();
  }

  void _addItemRow() {
    setState(() => _itemRows.add(_createItemRow()));
  }

  InsertBatch _buildBatch() {
    final name = _personRow.nameController.text.trim();
    return InsertBatch(
      items: _itemRows.map((row) => row.toEntry()).toList(),
      persons: name.isEmpty ? [] : [_personRow.toEntry()],
    );
  }

  List<InsertBatch> _allBatches() {
    final current = _buildBatch();
    final saved = widget.store.savedBatches;
    final editingIndex = widget.store.editingBatchIndex;

    if (editingIndex != null &&
        editingIndex >= 0 &&
        editingIndex < saved.length) {
      return [
        for (var i = 0; i < saved.length; i++)
          if (i == editingIndex) current else saved[i],
      ];
    }

    return [...saved, current];
  }

  void _saveCurrentBatch() {
    widget.store.saveCurrentBatch(_buildBatch());
  }

  void _goHome() {
    _saveCurrentBatch();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          theme: widget.theme,
          store: widget.store,
        ),
      ),
      (route) => false,
    );
  }

  void _startNewBatch() {
    _saveCurrentBatch();
    widget.store.startNewBatch();
    setState(_loadFromStore);
  }

  void _addPersonBatch() {
    final name = _personRow.nameController.text.trim();
    if (name.isEmpty) return;
    _startNewBatch();
  }

  void _selectPerson(BatchPersonRef ref) {
    final currentIndex =
        widget.store.editingBatchIndex ?? widget.store.savedBatches.length;
    if (ref.batchIndex == currentIndex) return;

    _saveCurrentBatch();
    if (ref.batchIndex < widget.store.savedBatches.length) {
      widget.store.loadBatch(ref.batchIndex);
      setState(_loadFromStore);
    }
  }

  void _confirm() {
    _saveCurrentBatch();
    final batches = _allBatches();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPreviewScreen(
          theme: widget.theme,
          batches: batches,
        ),
      ),
    );
  }

  Future<void> _openEmojiPicker() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: 320,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() {
                final text = _personRow.nameController.text;
                final selection = _personRow.nameController.selection;
                final cursor = selection.isValid ? selection.start : text.length;
                final newText = text.replaceRange(cursor, cursor, emoji.emoji);
                _personRow.nameController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: cursor + emoji.emoji.length,
                  ),
                );
              });
              Navigator.of(context).pop();
            },
            config: const Config(
              height: 320,
              checkPlatformCompatibility: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: widget.theme,
          builder: (context, _) {
            final labelColor = widget.theme.buttonLabel;
            final chromeColor = widget.theme.includedText;
            final panelColor = widget.theme.buttonFill;
            final personRefs = widget.store.listBatchPersons();

            return Scaffold(
              backgroundColor: widget.theme.background,
              body: SafeArea(
                child: AppContentWidth(
                  child: Column(
                    children: [
                      ScreenTitleHeader(
                        title: 'Manual insert',
                        labelColor: labelColor,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              FormPanel(
                                color: panelColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (var index = 0;
                                        index < _itemRows.length;
                                        index++)
                                      InsertItemRow(
                                        key: Key('insert_item_row_$index'),
                                        itemIndex: index,
                                        nameController:
                                            _itemRows[index].nameController,
                                        amountController:
                                            _itemRows[index].amountController,
                                        quantity: _itemRows[index].quantity,
                                        onQuantityChanged: (value) {
                                          setState(
                                            () => _itemRows[index].quantity =
                                                value,
                                          );
                                        },
                                        labelColor: labelColor,
                                        canRemove: _itemRows.length > 1,
                                        onRemove: () => _removeItemRow(index),
                                      ),
                                    Center(
                                      child: InsertAddRowButton(
                                        key: const Key('add_item_row'),
                                        label: 'Add Item',
                                        labelColor: labelColor,
                                        onTap: _addItemRow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'from:',
                                style: AppTextStyles.fira(
                                  size: 16,
                                  color: labelColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FormPanel(
                                color: panelColor,
                                child: InsertPersonRow(
                                  key: const Key('insert_person_row'),
                                  nameController: _personRow.nameController,
                                  onEmojiTap: _openEmojiPicker,
                                  labelColor: labelColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'People',
                                  style: AppTextStyles.fira(
                                    size: 14,
                                    color: chromeColor,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final ref in personRefs)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _PersonIndexChip(
                                          key: Key(
                                            'person_index_${ref.batchIndex}_${ref.personIndex}',
                                          ),
                                          ref: ref,
                                          labelColor: chromeColor,
                                          isSelected: widget.store
                                                  .editingBatchIndex ==
                                              ref.batchIndex,
                                          onTap: () => _selectPerson(ref),
                                        ),
                                      ),
                                    InsertAddRowButton(
                                      key: const Key('add_person_batch'),
                                      label: 'person',
                                      labelColor: chromeColor,
                                      onTap: _addPersonBatch,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DualActionBar(
                        left: DualActionBarAction(
                          key: const Key('bottom_home_button'),
                          label: 'Home',
                          onTap: _goHome,
                        ),
                        right: DualActionBarAction(
                          key: const Key('confirm_button'),
                          label: 'Confirm',
                          onTap: _confirm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PersonIndexChip extends StatelessWidget {
  const _PersonIndexChip({
    super.key,
    required this.ref,
    required this.labelColor,
    required this.isSelected,
    required this.onTap,
  });

  final BatchPersonRef ref;
  final Color labelColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: isSelected ? AppColors.accentOrange : null,
      label: Text(
        ref.name,
        style: AppTextStyles.fira(
          size: 13,
          color: labelColor,
        ),
      ),
      onPressed: onTap,
    );
  }
}
