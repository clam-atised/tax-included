import 'package:flutter/material.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/models/tax_models.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/widgets/dual_action_bar.dart';
import 'package:taxed/widgets/form_panel.dart';
import 'package:taxed/widgets/insert_add_row_button.dart';
import 'package:taxed/widgets/screen_title_header.dart';
import 'package:taxed/widgets/tax_amount_field.dart';

class TaxInsertScreen extends StatefulWidget {
  const TaxInsertScreen({
    super.key,
    required this.theme,
    required this.batches,
  });

  final AppThemeController theme;
  final List<InsertBatch> batches;

  @override
  State<TaxInsertScreen> createState() => _TaxInsertScreenState();
}

class _TaxInsertScreenState extends State<TaxInsertScreen> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers.addAll([
      TextEditingController(),
      TextEditingController(),
    ]);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTaxRow() {
    setState(() => _controllers.add(TextEditingController()));
  }

  TaxInsertData _buildTaxData() {
    return TaxInsertData(
      rates: TaxInsertData.parseRates(
        _controllers.map((controller) => controller.text).toList(),
      ),
    );
  }

  void _confirm() {
    final taxData = _buildTaxData();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPreviewScreen(
          theme: widget.theme,
          batches: widget.batches,
          taxData: taxData,
        ),
      ),
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
                  title: 'Tax Insert',
                  labelColor: labelColor,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FormPanel(
                      color: panelColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              itemCount: _controllers.length,
                              itemBuilder: (context, index) {
                                return TaxAmountField(
                                  key: Key('tax_amount_field_$index'),
                                  controller: _controllers[index],
                                  labelColor: labelColor,
                                );
                              },
                            ),
                          ),
                          InsertAddRowButton(
                            key: const Key('add_tax_row'),
                            label: 'Add Item',
                            labelColor: labelColor,
                            onTap: _addTaxRow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DualActionBar(
                  left: DualActionBarAction(
                    key: const Key('tax_edit_button'),
                    label: 'Edit',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  right: DualActionBarAction(
                    key: const Key('tax_confirm_button'),
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
