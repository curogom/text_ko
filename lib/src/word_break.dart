import 'package:characters/characters.dart';

/// Controls how Korean text is transformed before rendering.
enum TextKoWordBreak { none, keepAll }

/// Joiner character inserted between grapheme clusters for [TextKoWordBreak.keepAll].
enum TextKoJoiner {
  wordJoiner('\u2060'),
  zeroWidthJoiner('\u200D');

  const TextKoJoiner(this.value);

  final String value;
}

final RegExp _whitespaceTokenPattern = RegExp(r'(\s+)');

/// Applies Korean word-break transformation to [text].
///
/// When [wordBreak] is [TextKoWordBreak.keepAll], Korean tokens are split by
/// grapheme cluster and joined with [joiner] so wrapping prefers whitespace.
String applyTextKoWordBreak(
  String text, {
  TextKoWordBreak wordBreak = TextKoWordBreak.none,
  TextKoJoiner joiner = TextKoJoiner.wordJoiner,
  bool skipEmojiTokens = true,
}) {
  if (text.isEmpty || wordBreak == TextKoWordBreak.none) {
    return text;
  }

  return text
      .split('\n')
      .map(
        (String line) => line.splitMapJoin(
          _whitespaceTokenPattern,
          onMatch: (Match match) => match.group(0)!,
          onNonMatch: (String token) => _transformToken(
            token,
            joiner: joiner,
            skipEmojiTokens: skipEmojiTokens,
          ),
        ),
      )
      .join('\n');
}

String _transformToken(
  String token, {
  required TextKoJoiner joiner,
  required bool skipEmojiTokens,
}) {
  if (token.isEmpty || !_containsHangul(token)) {
    return token;
  }

  if (skipEmojiTokens && _containsLikelyEmoji(token)) {
    return token;
  }

  final List<String> clusters = token.characters.toList(growable: false);
  if (clusters.length < 2) {
    return token;
  }

  return clusters.join(joiner.value);
}

bool _containsHangul(String token) {
  for (final int rune in token.runes) {
    if ((rune >= 0x1100 && rune <= 0x11FF) ||
        (rune >= 0x3130 && rune <= 0x318F) ||
        (rune >= 0xA960 && rune <= 0xA97F) ||
        (rune >= 0xAC00 && rune <= 0xD7AF) ||
        (rune >= 0xD7B0 && rune <= 0xD7FF)) {
      return true;
    }
  }

  return false;
}

bool _containsLikelyEmoji(String token) {
  for (final int rune in token.runes) {
    if ((rune >= 0x1F000 && rune <= 0x1FAFF) ||
        (rune >= 0x1F1E6 && rune <= 0x1F1FF) ||
        (rune >= 0x2600 && rune <= 0x27BF) ||
        rune == 0xFE0F ||
        rune == 0x200D) {
      return true;
    }
  }

  return false;
}

/// String helpers for TextKo word-break behavior.
extension TextKoWordBreakStringExt on String {
  /// Returns a transformed string that prefers whitespace-based wrapping for Korean text.
  String textKoKeepAll({
    TextKoJoiner joiner = TextKoJoiner.wordJoiner,
    bool skipEmojiTokens = true,
  }) {
    return applyTextKoWordBreak(
      this,
      wordBreak: TextKoWordBreak.keepAll,
      joiner: joiner,
      skipEmojiTokens: skipEmojiTokens,
    );
  }
}
