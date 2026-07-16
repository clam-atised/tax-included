import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:textify/textify.dart';
import 'package:textify/models/textify_config.dart';

class PickedReceiptFile {
  const PickedReceiptFile({
    required this.bytes,
    required this.name,
  });

  final Uint8List bytes;
  final String name;
}

class ReceiptFileException implements Exception {
  ReceiptFileException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class ReceiptFileService {
  static const allowedExtensions = ['png', 'jpg', 'jpeg', 'pdf'];

  static Textify? _textify;

  static bool isAllowed(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot >= fileName.length - 1) return false;
    final ext = fileName.substring(dot + 1).toLowerCase();
    return allowedExtensions.contains(ext);
  }

  static Future<PickedReceiptFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final name = file.name;
    if (!isAllowed(name)) {
      throw ReceiptFileException('Only PNG, JPG, and PDF files are supported.');
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw ReceiptFileException('Could not read the selected file.');
    }

    return PickedReceiptFile(bytes: bytes, name: name);
  }

  static Future<String> extractText(Uint8List bytes, String fileName) async {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return _extractPdfText(bytes);
    }
    return _extractImageText(bytes);
  }

  static Future<String> _extractPdfText(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final text = PdfTextExtractor(document).extractText().trim();
      if (text.isEmpty) {
        throw ReceiptFileException(
          'No text found in this PDF. Try a PNG or JPG image instead.',
        );
      }
      return text;
    } finally {
      document.dispose();
    }
  }

  static Future<void> _ensureTextify() async {
    _textify ??= Textify(
      config: TextifyConfig(applyDictionaryCorrection: true),
    );
    await _textify!.init();
  }

  static Future<String> _extractImageText(Uint8List bytes) async {
    await _ensureTextify();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final text = (await _textify!.getTextFromImage(image: frame.image)).trim();
    if (text.isEmpty) {
      throw ReceiptFileException('No text found in this image.');
    }
    return text;
  }
}
