import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_recognition/receipt_recognition.dart';

class ReceiptScanController extends ChangeNotifier {
  ReceiptScanController() : _lastReceipt = RecognizedReceipt.empty() {
    _recognizer = ReceiptRecognizer(
      nearlyCompleteThreshold: _nearlyCompleteThreshold,
      onScanUpdate: _onScanUpdate,
      onScanComplete: _onScanComplete,
      onScanTimeout: _onScanTimeout,
    );
  }

  static const _nearlyCompleteThreshold = 90;

  late final ReceiptRecognizer _recognizer;
  RecognizedScanProgress _progress = RecognizedScanProgress.empty();
  RecognizedReceipt _lastReceipt;
  int _bestPercent = 0;
  bool _busy = false;
  bool _manuallyAccepted = false;

  RecognizedReceipt get receipt => _lastReceipt;

  List<RecognizedPosition> get positions =>
      _progress.addedPositions + _progress.updatedPositions;

  int get nearlyCompleteThreshold => _nearlyCompleteThreshold;

  int get bestPercent => _bestPercent;

  bool get isBusy => _busy;

  bool get isAccepted =>
      (receipt.isValid && receipt.isConfirmed) || _manuallyAccepted;

  void resetBestPercent() {
    _bestPercent = 0;
    notifyListeners();
  }

  Future<void> processImage(InputImage image) async {
    if (isBusy || isAccepted) return;

    _busy = true;
    try {
      _lastReceipt = await _recognizer.processImage(image);
      notifyListeners();
    } catch (_) {
      return;
    } finally {
      _busy = false;
    }
  }

  Future<void> acceptCurrent() async {
    _lastReceipt = _recognizer.acceptReceipt(_lastReceipt);
    _bestPercent = 100;
    _manuallyAccepted = true;
    _busy = false;
    notifyListeners();
  }

  Future<void> disposeAsync() => _recognizer.close();

  void _onScanUpdate(RecognizedScanProgress progress) {
    if (isAccepted) return;
    _progress = progress;
    _bestPercent = progress.estimatedPercentage > _bestPercent
        ? progress.estimatedPercentage
        : _bestPercent;
    _lastReceipt = progress.mergedReceipt;
    notifyListeners();
  }

  void _onScanComplete(RecognizedReceipt receipt) {
    if (isAccepted) return;
    _lastReceipt = receipt;
    if (_bestPercent < 100) _bestPercent = 100;
    notifyListeners();
  }

  void _onScanTimeout(RecognizedReceipt receipt) {
    if (isAccepted) return;
    _lastReceipt = receipt;
    acceptCurrent();
  }
}
