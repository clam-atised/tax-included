import 'package:flutter/foundation.dart';

TargetPlatform? debugTargetPlatformForTests;

TargetPlatform get _platform =>
    debugTargetPlatformForTests ?? defaultTargetPlatform;

bool get supportsCameraCapture {
  if (kIsWeb) return false;
  switch (_platform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    default:
      return false;
  }
}

bool get supportsFileUpload {
  if (kIsWeb) return true;
  switch (_platform) {
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return true;
    default:
      return false;
  }
}

bool get supportsReceiptReadTimeout {
  if (kIsWeb) return true;
  return _platform == TargetPlatform.windows;
}
