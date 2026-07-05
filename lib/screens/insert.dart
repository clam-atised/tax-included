import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:taxed/controllers/insert_form_rows.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/theme/app_theme_controller.dart';
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
  final List<PersonRowState> _personRows = [];

  @override
  void initState() {
    super.initState();
    _itemRows.addAll([ItemRowState(), ItemRowState()]);
    _personRows.add(PersonRowState());
  }

  @override
  void dispose() {
    for (final row in _itemRows) {
      row.dispose();
    }
    for (final row in _personRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addItemRow() {
    setState(() => _itemRows.add(ItemRowState()));
  }

  void _addPersonRow() {
    setState(() => _personRows.add(PersonRowState()));
  }

  InsertBatch _buildBatch() {
    return InsertBatch(
      items: _itemRows.map((row) => row.toEntry()).toList(),
      persons: _personRows.map((row) => row.toEntry()).toList(),
    );
  }

  void _saveAndOpenFresh() {
    widget.store.saveBatch(_buildBatch());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => InsertScreen(
          theme: widget.theme,
          store: widget.store,
        ),
      ),
    );
  }

  void _confirm() {
    final batches = [...widget.store.savedBatches, _buildBatch()];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPreviewScreen(
          theme: widget.theme,
          batches: batches,
        ),
      ),
    );
  }

  Future<void> _openEmojiPicker(int personIndex) async {
    FocusScope.of(context).unfocus();
    final row = _personRows[personIndex];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: 320,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() => row.emoji = emoji.emoji);
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
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        FormPanel(
                          color: panelColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  itemCount: _itemRows.length,
                                  itemBuilder: (context, index) {
                                    final row = _itemRows[index];
                                    return InsertItemRow(
                                      key: Key('insert_item_row_$index'),
                                      itemIndex: index,
                                      nameController: row.nameController,
                                      amountController: row.amountController,
                                      splitCount: row.splitCount,
                                      onSplitCountChanged: (value) {
                                        setState(() => row.splitCount = value);
                                      },
                                      labelColor: labelColor,
                                    );
                                  },
                                ),
                              ),
                              InsertAddRowButton(
                                key: const Key('add_item_row'),
                                label: 'Add Item',
                                labelColor: labelColor,
                                onTap: _addItemRow,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'from:',
                          style: AppTextStyles.fira(size: 16, color: labelColor),
                        ),
                        const SizedBox(height: 16),
                        FormPanel(
                          color: panelColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  itemCount: _personRows.length,
                                  itemBuilder: (context, index) {
                                    final row = _personRows[index];
                                    return InsertPersonRow(
                                      key: Key('insert_person_row_$index'),
                                      nameController: row.nameController,
                                      emoji: row.emoji,
                                      onEmojiTap: () => _openEmojiPicker(index),
                                      labelColor: labelColor,
                                    );
                                  },
                                ),
                              ),
                              InsertAddRowButton(
                                label: 'Add Person',
                                labelColor: labelColor,
                                onTap: _addPersonRow,
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
                    key: const Key('bottom_add_item'),
                    label: 'Add item',
                    onTap: _saveAndOpenFresh,
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
        );
      },
    );
  }
}
