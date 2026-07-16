import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxed/services/receipt_read_timeout.dart';
import 'package:taxed/utils/platform_capabilities.dart';

void main() {
  tearDown(() {
    debugReceiptReadTimeout = const Duration(minutes: 1);
    debugTargetPlatformForTests = null;
  });

  group('withReceiptReadTimeout', () {
    test('returns result when future completes in time', () async {
      debugReceiptReadTimeout = const Duration(milliseconds: 100);

      final result = await withReceiptReadTimeout(
        Future.value(42),
        enabled: true,
      );

      expect(result, 42);
    });

    test('throws TimeoutException when future exceeds limit', () async {
      debugReceiptReadTimeout = const Duration(milliseconds: 50);

      await expectLater(
        withReceiptReadTimeout(
          Future<void>.delayed(const Duration(milliseconds: 200)),
          enabled: true,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('does not apply timeout when disabled', () async {
      debugReceiptReadTimeout = const Duration(milliseconds: 50);

      await expectLater(
        withReceiptReadTimeout(
          Future<void>.delayed(const Duration(milliseconds: 100)),
          enabled: false,
        ),
        completes,
      );
    });
  });

  group('supportsReceiptReadTimeout', () {
    test('is true on Windows', () {
      debugTargetPlatformForTests = TargetPlatform.windows;
      expect(supportsReceiptReadTimeout, isTrue);
    });

    test('is false on linux', () {
      debugTargetPlatformForTests = TargetPlatform.linux;
      expect(supportsReceiptReadTimeout, isFalse);
    });

    test('is false on macOS', () {
      debugTargetPlatformForTests = TargetPlatform.macOS;
      expect(supportsReceiptReadTimeout, isFalse);
    });
  });
}
