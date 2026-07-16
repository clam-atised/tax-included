import 'package:flutter/material.dart';
import 'package:taxed/controllers/insert_store.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/models/tax_models.dart';
import 'package:taxed/screens/insert.dart';
import 'package:taxed/screens/receipt_preview.dart';
import 'package:taxed/services/receipt_calculator.dart';
import 'package:taxed/theme/app_theme_controller.dart';
import 'package:taxed/utils/amount_parser.dart';
import 'package:taxed/widgets/app_content_width.dart';
import 'package:taxed/widgets/dual_action_bar.dart';
import 'package:taxed/widgets/form_panel.dart';
import 'package:taxed/widgets/screen_title_header.dart';
import 'package:taxed/widgets/tax_amount_field.dart';
import 'package:taxed/widgets/tax_rule_tabs.dart';
import 'package:taxed/widgets/tax_scope_section.dart';

class _TaxDraft {
  _TaxDraft({
    this.rateText = '',
    Set<String>? selectedPersons,
    Set<String>? selectedItems,
  })  : selectedPersons = selectedPersons ?? {},
        selectedItems = selectedItems ?? {};

  String rateText;
  Set<String> selectedPersons;
  Set<String> selectedItems;

  factory _TaxDraft.blank({
    required Set<String> personNames,
    required Set<String> itemNames,
  }) {
    return _TaxDraft(
      selectedPersons: Set<String>.from(personNames),
      selectedItems: Set<String>.from(itemNames),
    );
  }

  factory _TaxDraft.fromRule(
    TaxRule rule, {
    required List<String> personNames,
    required List<String> itemNames,
  }) {
    return _TaxDraft(
      rateText: rule.rate == 0 ? '' : rule.rate.toString(),
      selectedPersons: rule.applyToAllPersons
          ? personNames.toSet()
          : Set<String>.from(rule.selectedPersons),
      selectedItems: rule.applyToAllItems
          ? itemNames.toSet()
          : Set<String>.from(rule.selectedItems),
    );
  }
}

class TaxInsertScreen extends StatefulWidget {
  const TaxInsertScreen({
    super.key,
    required this.theme,
    required this.batches,
    required this.store,
  });

  final AppThemeController theme;
  final List<InsertBatch> batches;
  final InsertStore store;

  @override
  State<TaxInsertScreen> createState() => _TaxInsertScreenState();
}

class _TaxInsertScreenState extends State<TaxInsertScreen> {
  late final TextEditingController _rateController;
  late final List<String> _personNames;
  late final List<String> _itemNames;
  late final List<_TaxDraft> _drafts;
  int _selectedIndex = 0;

  Set<String> get _selectedPersons => _drafts[_selectedIndex].selectedPersons;
  Set<String> get _selectedItems => _drafts[_selectedIndex].selectedItems;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController();
    _personNames = ReceiptCalculator.collectPersonNames(widget.batches).toList()
      ..sort();
    _itemNames = ReceiptCalculator.collectItemNames(widget.batches).toList()
      ..sort();
    _drafts = _hydrateDrafts();
    _selectedIndex = _drafts.length - 1;
    _loadSelectedIntoForm();
  }

  List<_TaxDraft> _hydrateDrafts() {
    final pending = widget.store.pendingTaxData;
    if (pending == null || pending.rules.isEmpty) {
      return [
        _TaxDraft.blank(
          personNames: _personNames.toSet(),
          itemNames: _itemNames.toSet(),
        ),
      ];
    }
    return [
      for (final rule in pending.rules)
        _TaxDraft.fromRule(
          rule,
          personNames: _personNames,
          itemNames: _itemNames,
        ),
    ];
  }

  void _loadSelectedIntoForm() {
    _rateController.text = _drafts[_selectedIndex].rateText;
  }

  void _flushFormIntoSelected() {
    _drafts[_selectedIndex].rateText = _rateController.text;
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  TaxRule _ruleFromDraft(_TaxDraft draft) {
    return TaxInsertData.parseRule(
      rawRate: draft.rateText,
      allPersons: _personNames.toSet(),
      allItems: _itemNames.toSet(),
      selectedPersons: draft.selectedPersons,
      selectedItems: draft.selectedItems,
    );
  }

  List<TaxRule> _rulesWithInput() {
    _flushFormIntoSelected();
    return [
      for (final draft in _drafts)
        if (AmountParser.parseRate(draft.rateText) > 0) _ruleFromDraft(draft),
    ];
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _flushFormIntoSelected();
      _selectedIndex = index;
      _loadSelectedIntoForm();
    });
  }

  void _addTax() {
    setState(() {
      _flushFormIntoSelected();
      _drafts.add(
        _TaxDraft.blank(
          personNames: _personNames.toSet(),
          itemNames: _itemNames.toSet(),
        ),
      );
      _selectedIndex = _drafts.length - 1;
      _loadSelectedIntoForm();
    });
  }

  void _confirm() {
    final rules = _rulesWithInput();
    final taxData = rules.isEmpty ? null : TaxInsertData(rules: rules);
    widget.store.setPendingTaxData(taxData);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPreviewScreen(
          theme: widget.theme,
          batches: widget.batches,
          taxData: taxData,
          store: widget.store,
        ),
      ),
    );
  }

  void _back() {
    widget.store.replaceBatches(widget.batches);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => InsertScreen(
          theme: widget.theme,
          store: widget.store,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _toggleEveryone() {
    setState(() {
      final allSelected =
          _personNames.every((name) => _selectedPersons.contains(name));
      _drafts[_selectedIndex].selectedPersons =
          allSelected ? {} : _personNames.toSet();
    });
  }

  void _toggleEverything() {
    setState(() {
      final allSelected =
          _itemNames.every((name) => _selectedItems.contains(name));
      _drafts[_selectedIndex].selectedItems =
          allSelected ? {} : _itemNames.toSet();
    });
  }

  void _togglePerson(String name) {
    setState(() {
      final selected = Set<String>.from(_selectedPersons);
      if (selected.contains(name)) {
        selected.remove(name);
      } else {
        selected.add(name);
      }
      _drafts[_selectedIndex].selectedPersons = selected;
    });
  }

  void _toggleItem(String name) {
    setState(() {
      final selected = Set<String>.from(_selectedItems);
      if (selected.contains(name)) {
        selected.remove(name);
      } else {
        selected.add(name);
      }
      _drafts[_selectedIndex].selectedItems = selected;
    });
  }

  List<String?> get _rateLabels {
    return [
      for (var i = 0; i < _drafts.length; i++)
        i == _selectedIndex
            ? (_rateController.text.trim().isEmpty
                ? null
                : _rateController.text.trim())
            : (_drafts[i].rateText.trim().isEmpty
                ? null
                : _drafts[i].rateText.trim()),
    ];
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
            child: AppContentWidth(
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
                            TaxRuleTabs(
                              count: _drafts.length,
                              selectedIndex: _selectedIndex,
                              labelColor: labelColor,
                              onSelected: _selectTab,
                              rateLabels: _rateLabels,
                            ),
                            const SizedBox(height: 16),
                            TaxAmountField(
                              key: const Key('tax_amount_field_0'),
                              controller: _rateController,
                              labelColor: labelColor,
                            ),
                            TaxScopeSection(
                              personNames: _personNames,
                              itemNames: _itemNames,
                              selectedPersons: _selectedPersons,
                              selectedItems: _selectedItems,
                              onEveryoneToggled: _toggleEveryone,
                              onEverythingToggled: _toggleEverything,
                              onPersonToggled: _togglePerson,
                              onItemToggled: _toggleItem,
                              labelColor: labelColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TripleActionBar(
                    left: DualActionBarAction(
                      key: const Key('tax_back_button'),
                      label: 'Back',
                      onTap: _back,
                    ),
                    middle: DualActionBarAction(
                      key: const Key('add_tax_button'),
                      label: 'Add tax',
                      onTap: _addTax,
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
          ),
        );
      },
    );
  }
}
