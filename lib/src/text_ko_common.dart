import 'package:flutter/widgets.dart';

import 'word_break.dart';

TextStyle? resolveTextKoEffectiveTextStyle(
  BuildContext context,
  TextStyle? style,
) {
  final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

  TextStyle? effectiveTextStyle = style;
  if (style == null || style.inherit) {
    effectiveTextStyle = defaultTextStyle.style.merge(style);
  }

  if (MediaQuery.boldTextOf(context)) {
    effectiveTextStyle = (effectiveTextStyle ?? const TextStyle()).merge(
      const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  return effectiveTextStyle;
}

TextScaler resolveTextKoTextScaler(
  BuildContext context, {
  required TextScaler? textScaler,
  required double? textScaleFactor,
}) {
  return switch ((textScaler, textScaleFactor)) {
    (final TextScaler currentScaler, _) => currentScaler,
    (null, final double currentFactor) => TextScaler.linear(currentFactor),
    (null, null) => MediaQuery.textScalerOf(context),
  };
}

bool hasTextKoUnderlineDecoration(TextDecoration? decoration) {
  if (decoration == null) {
    return false;
  }

  return decoration.contains(TextDecoration.underline);
}

TextDecoration? removeTextKoUnderline(TextDecoration? decoration) {
  if (decoration == null || !decoration.contains(TextDecoration.underline)) {
    return decoration;
  }

  final List<TextDecoration> values = <TextDecoration>[];
  if (decoration.contains(TextDecoration.overline)) {
    values.add(TextDecoration.overline);
  }
  if (decoration.contains(TextDecoration.lineThrough)) {
    values.add(TextDecoration.lineThrough);
  }

  if (values.isEmpty) {
    return TextDecoration.none;
  }

  return TextDecoration.combine(values);
}

String applyTextKoTransforms(
  String source, {
  required TextKoWordBreak wordBreak,
  required TextKoJoiner joiner,
  required bool skipEmojiTokens,
}) {
  String transformed = source;

  if (wordBreak == TextKoWordBreak.keepAll) {
    transformed = applyTextKoWordBreak(
      transformed,
      wordBreak: wordBreak,
      joiner: joiner,
      skipEmojiTokens: skipEmojiTokens,
    );
  }

  return transformed;
}

TextStyle? resolveTextKoChildStyle(
  TextStyle? parentStyle,
  TextStyle? childStyle,
) {
  if (childStyle == null) {
    return parentStyle;
  }
  if (parentStyle == null || !childStyle.inherit) {
    return childStyle;
  }

  return parentStyle.merge(childStyle);
}
