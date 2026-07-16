import 'package:flutter/foundation.dart';
import 'package:taxed/models/insert_models.dart';

class InsertStore extends ChangeNotifier {
  final List<InsertBatch> _savedBatches = [];

  List<InsertBatch> get savedBatches => List.unmodifiable(_savedBatches);

  void saveBatch(InsertBatch batch) {
    _savedBatches.add(batch);
    notifyListeners();
  }

  void clear() {
    if (_savedBatches.isEmpty) return;
    _savedBatches.clear();
    notifyListeners();
  }
}
