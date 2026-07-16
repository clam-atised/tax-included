Duration debugReceiptReadTimeout = const Duration(minutes: 1);

Future<T> withReceiptReadTimeout<T>(
  Future<T> future, {
  required bool enabled,
}) {
  if (!enabled) return future;
  return future.timeout(debugReceiptReadTimeout);
}
