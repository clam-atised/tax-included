import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taxed/app/app_scope.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/models/receipt_display_models.dart';
import 'package:taxed/models/tax_models.dart';
import 'package:taxed/screens/receipt_items_edit_screen.dart';
import 'package:taxed/screens/tax_insert.dart';
import 'package:taxed/services/receipt_calculator.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/widgets/dual_action_bar.dart';
import 'package:taxed/widgets/receipt_line_section.dart';
import 'package:taxed/widgets/receipt_paper.dart';
import 'package:taxed/widgets/receipt_print_dialog.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  const ReceiptPreviewScreen({
    super.key,
    required this.theme,
    required this.batches,
    this.taxData,
    this.fromUpload = false,
  });

  final AppThemeController theme;
  final List<InsertBatch> batches;
  final TaxInsertData? taxData;
  final bool fromUpload;

  bool get isTaxed => taxData != null;

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  ReceiptSortMode _sortMode = ReceiptSortMode.byItem;

  late List<InsertBatch> _batches;
  ReceiptSummary? _summary;
  TaxedReceiptSummary? _taxedSummary;

  bool get _isTaxed => widget.isTaxed;

  @override
  void initState() {
    super.initState();
    _batches = widget.batches;
    _recomputeSummaries();
  }

  void _recomputeSummaries() {
    if (_isTaxed) {
      _taxedSummary = ReceiptCalculator.computeWithTax(
        _batches,
        widget.taxData!.rates,
      );
      _summary = null;
    } else {
      _summary = ReceiptCalculator.compute(_batches);
      _taxedSummary = null;
    }
  }

  void _toggleSort() {
    setState(() {
      _sortMode = _sortMode == ReceiptSortMode.byItem
          ? ReceiptSortMode.byPerson
          : ReceiptSortMode.byItem;
    });
  }

  List<ReceiptDisplayLine> get _displayLines {
    if (_isTaxed) {
      return _taxedSummary!.toDisplayLines(_sortMode);
    }
    return _summary!.toDisplayLines(_sortMode);
  }

  double get _total {
    if (_isTaxed) return _taxedSummary!.totalWithTax;
    return _summary!.total;
  }

  void _openPrintDialog() {
    if (_taxedSummary == null) return;
    showReceiptPrintDialog(
      context,
      initialText: ReceiptCalculator.formatReceiptText(
        _taxedSummary!,
        _sortMode,
      ),
      onCompleted: () => AppScope.of(context).store.clear(),
    );
  }

  Future<void> _onEdit() async {
    if (widget.fromUpload && !_isTaxed && _batches.isNotEmpty) {
      final updated = await Navigator.of(context).push<InsertBatch>(
        MaterialPageRoute(
          builder: (_) => ReceiptItemsEditScreen(
            theme: widget.theme,
            batch: _batches.first,
          ),
        ),
      );
      if (updated != null && mounted) {
        setState(() {
          _batches = [updated];
          _recomputeSummaries();
        });
      }
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.theme,
      builder: (context, _) {
        final labelColor = widget.theme.buttonLabel;

        return Scaffold(
          backgroundColor: widget.theme.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      InkWell(
                        key: const Key('sort_toggle'),
                        onTap: _toggleSort,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/arrow-up-down.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.accentOrange,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _sortMode == ReceiptSortMode.byItem
                                    ? 'By Item'
                                    : 'By Person',
                                style: AppTextStyles.fira(
                                  size: 16,
                                  color: labelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Receipt Preview',
                        style: AppTextStyles.fira(
                          size: 20,
                          color: labelColor,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ClipPath(
                      clipper: const ReceiptPaperClipper(),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ReceiptLineSection(
                                lines: _displayLines,
                                labelColor: labelColor,
                                sortMode: _sortMode,
                              ),
                              const SizedBox(height: 16),
                              if (_isTaxed)
                                DoubleReceiptDivider(color: labelColor)
                              else
                                Container(height: 1, color: labelColor),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isTaxed ? 'Total (with tax)' : 'Total',
                                    style: AppTextStyles.fira(
                                      size: 16,
                                      color: labelColor,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    ReceiptCalculator.formatAmount(_total),
                                    style: AppTextStyles.fira(
                                      size: 16,
                                      color: labelColor,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DualActionBar(
                  left: DualActionBarAction(
                    key: const Key('edit_button'),
                    label: 'Edit',
                    onTap: _onEdit,
                  ),
                  right: DualActionBarAction(
                    key: _isTaxed
                        ? const Key('print_button')
                        : const Key('preview_confirm_button'),
                    label: _isTaxed ? 'Print' : 'Confirm',
                    onTap: _isTaxed
                        ? _openPrintDialog
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TaxInsertScreen(
                                  theme: widget.theme,
                                  batches: _batches,
                                ),
                              ),
                            );
                          },
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
