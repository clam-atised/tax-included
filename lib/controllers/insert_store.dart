import 'package:flutter/foundation.dart';
import 'package:taxed/models/batch_person_ref.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/models/tax_models.dart';

class InsertStore extends ChangeNotifier {
  final List<InsertBatch> _savedBatches = [];
  int? _editingBatchIndex;
  final List<TaxRule> _savedTaxRules = [];
  TaxInsertData? _pendingTaxData;

  List<InsertBatch> get savedBatches => List.unmodifiable(_savedBatches);
  int? get editingBatchIndex => _editingBatchIndex;
  List<TaxRule> get savedTaxRules => List.unmodifiable(_savedTaxRules);
  TaxInsertData? get pendingTaxData => _pendingTaxData;

  InsertBatch? batchAt(int index) {
    if (index < 0 || index >= _savedBatches.length) return null;
    return _savedBatches[index];
  }

  void saveBatch(InsertBatch batch) {
    _savedBatches.add(batch);
    _editingBatchIndex = _savedBatches.length - 1;
    notifyListeners();
  }

  void saveCurrentBatch(InsertBatch batch) {
    if (_editingBatchIndex != null &&
        _editingBatchIndex! >= 0 &&
        _editingBatchIndex! < _savedBatches.length) {
      _savedBatches[_editingBatchIndex!] = batch;
    } else {
      _savedBatches.add(batch);
      _editingBatchIndex = _savedBatches.length - 1;
    }
    notifyListeners();
  }

  void loadBatch(int index) {
    if (index < 0 || index >= _savedBatches.length) return;
    _editingBatchIndex = index;
    notifyListeners();
  }

  void startNewBatch() {
    _editingBatchIndex = null;
    notifyListeners();
  }

  List<BatchPersonRef> listBatchPersons({InsertBatch? currentBatch}) {
    final refs = <BatchPersonRef>[];

    for (var batchIndex = 0; batchIndex < _savedBatches.length; batchIndex++) {
      final batch = _savedBatches[batchIndex];
      if (batch.persons.isEmpty) continue;
      final person = batch.persons.first;
      final name = person.name.trim();
      if (name.isEmpty) continue;
      refs.add(
        BatchPersonRef(
          batchIndex: batchIndex,
          personIndex: 0,
          name: name,
        ),
      );
    }

    if (currentBatch != null && currentBatch.persons.isNotEmpty) {
      final currentIndex = _editingBatchIndex ?? _savedBatches.length;
      final person = currentBatch.persons.first;
      final name = person.name.trim();
      if (name.isNotEmpty) {
        final alreadyListed = refs.any(
          (ref) => ref.batchIndex == currentIndex,
        );
        if (!alreadyListed) {
          refs.add(
            BatchPersonRef(
              batchIndex: currentIndex,
              personIndex: 0,
              name: name,
            ),
          );
        }
      }
    }

    return refs;
  }

  void addTaxRule(TaxRule rule) {
    _savedTaxRules.add(rule);
    notifyListeners();
  }

  void setPendingTaxData(TaxInsertData? data) {
    _pendingTaxData = data;
    notifyListeners();
  }

  void replaceBatches(List<InsertBatch> batches) {
    _savedBatches
      ..clear()
      ..addAll(batches);
    _editingBatchIndex = batches.isEmpty ? null : batches.length - 1;
    notifyListeners();
  }

  void clearTaxRules() {
    _savedTaxRules.clear();
    _pendingTaxData = null;
    notifyListeners();
  }

  void clear() {
    if (_savedBatches.isEmpty &&
        _savedTaxRules.isEmpty &&
        _pendingTaxData == null &&
        _editingBatchIndex == null) {
      return;
    }
    _savedBatches.clear();
    _editingBatchIndex = null;
    _savedTaxRules.clear();
    _pendingTaxData = null;
    notifyListeners();
  }
}
