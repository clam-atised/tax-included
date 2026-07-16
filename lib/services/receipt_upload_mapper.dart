import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/services/receipt_calculator.dart';

abstract final class ReceiptUploadMapper {
  static bool debugRunSynchronously = false;

  static InsertBatch? mapReceiptToBatch(RecognizedReceipt receipt) {
    return _receiptToBatch(receipt);
  }

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
          quantity: 1,
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
            quantity: item.quantity,
          ),
        )
        .toList();
  }

  static List<String> registeredItemNames(List<ItemEntry> items) {
    return items.map((item) => item.name).toSet().toList()..sort();
  }

  static RecognizedText plainTextToRecognizedText(String text) =>
      _toRecognizedText(text);

  static RecognizedText _toRecognizedText(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final textLines = <TextLine>[];
    var y = 10.0;
    const lineHeight = 30.0;
    const amountPattern = r'^(?<label>.+?)\s+(?<amount>\d+[.,]\d{2})\s*$';

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final match = RegExp(amountPattern).firstMatch(line);
      if (match != null) {
        final label = match.namedGroup('label')!.trim();
        final amount = match.namedGroup('amount')!;
        textLines.add(
          _ocrLine(label, Rect.fromLTWH(50, y, 180, lineHeight)),
        );
        textLines.add(
          _ocrLine(amount, Rect.fromLTWH(280, y, 80, lineHeight)),
        );
      } else {
        textLines.add(
          _ocrLine(line, Rect.fromLTWH(50, y, 200, lineHeight)),
        );
      }
      y += lineHeight;
    }

    if (textLines.isEmpty) {
      return RecognizedText(text: text, blocks: const []);
    }

    final block = TextBlock(
      text: lines.join('\n'),
      lines: textLines,
      boundingBox: Rect.fromLTWH(50, 10, 310, y),
      recognizedLanguages: const ['en'],
      cornerPoints: const [],
    );

    return RecognizedText(text: text, blocks: [block]);
  }

  static TextLine _ocrLine(String text, Rect box) {
    return TextLine(
      text: text,
      elements: const [],
      boundingBox: box,
      recognizedLanguages: const [],
      cornerPoints: const [],
      confidence: null,
      angle: null,
    );
  }
}
