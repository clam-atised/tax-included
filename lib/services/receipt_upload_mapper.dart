import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/services/receipt_calculator.dart';

abstract final class ReceiptUploadMapper {
  static bool debugRunSynchronously = false;

  static Future<InsertBatch?> mapTextToBatch(String rawText) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return null;

    final recognizedText = _toRecognizedText(trimmed);
    final previous = ReceiptTextProcessor.debugRunSynchronouslyForTests;
    ReceiptTextProcessor.debugRunSynchronouslyForTests = debugRunSynchronously;

    try {
      final receipt = await ReceiptTextProcessor.processText(
        recognizedText,
        ReceiptOptions.defaults(),
      );
      return _receiptToBatch(receipt);
    } finally {
      ReceiptTextProcessor.debugRunSynchronouslyForTests = previous;
    }
  }

  static InsertBatch? _receiptToBatch(RecognizedReceipt receipt) {
    final items = <ItemEntry>[];

    for (final position in receipt.positions) {
      final name = position.product.value.trim();
      final amount = position.price.value;
      if (name.isEmpty && amount == 0) continue;

      items.add(
        ItemEntry(
          name: name.isEmpty ? 'Item' : name,
          amount: ReceiptCalculator.formatAmount(amount),
        ),
      );
    }

    if (items.isEmpty) return null;
    return InsertBatch(items: _separateDuplicateItems(items), persons: []);
  }

  /// Same-name items become separate rows for paginated edit.
  static List<ItemEntry> _separateDuplicateItems(List<ItemEntry> items) {
    return items
        .map(
          (item) => ItemEntry(
            name: item.name,
            amount: item.amount,
            splitCount: item.splitCount,
          ),
        )
        .toList();
  }

  static List<String> registeredItemNames(List<ItemEntry> items) {
    return items.map((item) => item.name).toSet().toList()..sort();
  }

  static RecognizedText _toRecognizedText(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    final blocks = <TextBlock>[];
    var y = 0.0;

    for (final line in lines) {
      final textLine = _lineToTextLine(line, y);
      blocks.add(
        TextBlock(
          text: line,
          lines: [textLine],
          boundingBox: Rect.fromLTWH(0, y, 400, 16),
          recognizedLanguages: const ['en'],
          cornerPoints: const [],
        ),
      );
      y += 18;
    }

    return RecognizedText(text: text, blocks: blocks);
  }

  static TextLine _lineToTextLine(String line, double y) {
    return TextLine(
      text: line,
      confidence: y,
      angle: y,
      elements: [
        TextElement(
          text: line,
          boundingBox: Rect.fromLTWH(0, y, 400, 16),
          cornerPoints: const [],
          symbols: const [],
          recognizedLanguages: const [],
          confidence: y,
          angle: y
        ),
      ],
      boundingBox: Rect.fromLTWH(0, y, 400, 16),
      recognizedLanguages: const ['en'],
      cornerPoints: const [],
    );
  }
}
