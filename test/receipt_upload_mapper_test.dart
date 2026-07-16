import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:taxed/models/insert_models.dart';
import 'package:taxed/services/receipt_file_service.dart';
import 'package:taxed/services/receipt_upload_mapper.dart';

void main() {
  setUp(() {
    ReceiptUploadMapper.debugRunSynchronously = true;
    ReceiptTextProcessor.debugRunSynchronouslyForTests = true;
  });

  group('ReceiptFileService', () {
    test('allows png, jpg, jpeg, and pdf extensions', () {
      expect(ReceiptFileService.isAllowed('receipt.png'), isTrue);
      expect(ReceiptFileService.isAllowed('receipt.JPG'), isTrue);
      expect(ReceiptFileService.isAllowed('receipt.jpeg'), isTrue);
      expect(ReceiptFileService.isAllowed('receipt.pdf'), isTrue);
      expect(ReceiptFileService.isAllowed('receipt.gif'), isFalse);
      expect(ReceiptFileService.isAllowed('receipt'), isFalse);
    });
  });

  group('ReceiptUploadMapper', () {
    test('returns null for empty text', () async {
      final batch = await ReceiptUploadMapper.mapTextToBatch('   ');
      expect(batch, isNull);
    });

    test('maps receipt-like text to item entries', () async {
      const sample = '''
STORE NAME
Item A    12.50
Item B     5.00
Total     17.50
''';

      final batch = await ReceiptUploadMapper.mapTextToBatch(sample);
      expect(batch, isNotNull);
      expect(batch!.persons, isEmpty);
      expect(batch.items, isNotEmpty);
    });

    test('registeredItemNames returns unique sorted names', () {
      final names = ReceiptUploadMapper.registeredItemNames([
        ItemEntry(name: 'Coffee', amount: '3'),
        ItemEntry(name: 'Tea', amount: '2'),
        ItemEntry(name: 'Coffee', amount: '3'),
      ]);

      expect(names, ['Coffee', 'Tea']);
    });
  });
}
