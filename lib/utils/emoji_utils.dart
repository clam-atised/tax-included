/// Returns the leading emoji grapheme from [text], or null if none.
String? leadingEmoji(String text) {
  final trimmed = text.trimLeft();
  if (trimmed.isEmpty) return null;

  final runes = trimmed.runes.toList();
  if (!_isEmojiCodePoint(runes.first)) return null;

  var end = 1;
  while (end < runes.length) {
    final next = runes[end];
    if (next == 0x200D || // ZWJ
        next == 0xFE0F || // variation selector-16
        (next >= 0x1F3FB && next <= 0x1F3FF) || // skin tones
        _isEmojiCodePoint(next)) {
      end++;
      continue;
    }
    break;
  }

  return String.fromCharCodes(runes.take(end));
}

bool _isEmojiCodePoint(int codePoint) {
  return (codePoint >= 0x1F300 && codePoint <= 0x1FAFF) ||
      (codePoint >= 0x2600 && codePoint <= 0x26FF) ||
      (codePoint >= 0x2700 && codePoint <= 0x27BF) ||
      (codePoint >= 0x1F600 && codePoint <= 0x1F64F) ||
      (codePoint >= 0x1F680 && codePoint <= 0x1F6FF) ||
      (codePoint >= 0x1F900 && codePoint <= 0x1F9FF) ||
      codePoint == 0x00A9 ||
      codePoint == 0x00AE ||
      codePoint == 0x2122 ||
      codePoint == 0x3030;
}
