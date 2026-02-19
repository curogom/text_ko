import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../rich_text_ko.dart';
import '../stable_underline_painter.dart';
import '../text_ko_common.dart';
import '../word_break.dart';

/// A Korean-friendly `Text` widget with opt-in word-break and underline options.
class TextKo extends Text {
  /// Creates a plain text [TextKo].
  const TextKo(
    super.data, {
    super.key,
    this.wordBreak = TextKoWordBreak.none,
    this.joiner = TextKoJoiner.wordJoiner,
    this.stableUnderline = false,
    this.skipEmojiTokens = true,
    this.preserveSemantics = true,
    this.stableUnderlineColor,
    this.stableUnderlineThickness,
    this.stableUnderlineOffset,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    @Deprecated(
      'Use textScaler instead. '
      'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
      'This feature was deprecated after v3.12.0-2.0.pre.',
    )
    super.textScaleFactor,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.semanticsIdentifier,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  /// Creates a rich text [TextKo] from an [InlineSpan] tree.
  // ignore: use_super_parameters
  const TextKo.rich(
    InlineSpan textSpan, {
    super.key,
    this.wordBreak = TextKoWordBreak.none,
    this.joiner = TextKoJoiner.wordJoiner,
    this.stableUnderline = false,
    this.skipEmojiTokens = true,
    this.preserveSemantics = true,
    this.stableUnderlineColor,
    this.stableUnderlineThickness,
    this.stableUnderlineOffset,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    @Deprecated(
      'Use textScaler instead. '
      'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
      'This feature was deprecated after v3.12.0-2.0.pre.',
    )
    super.textScaleFactor,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.semanticsIdentifier,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : super.rich(textSpan);

  /// Word-break behavior applied to rendered text.
  final TextKoWordBreak wordBreak;

  /// Joiner character used when [wordBreak] is [TextKoWordBreak.keepAll].
  final TextKoJoiner joiner;

  /// Draws underline using custom painter for more stable visual output.
  final bool stableUnderline;

  /// Skips keep-all transformation for tokens that look like emoji sequences.
  final bool skipEmojiTokens;

  /// Keeps the original, untransformed text for semantics labels by default.
  final bool preserveSemantics;

  /// Overrides underline color when [stableUnderline] is enabled.
  final Color? stableUnderlineColor;

  /// Overrides underline thickness when [stableUnderline] is enabled.
  final double? stableUnderlineThickness;

  /// Adjusts underline Y offset when [stableUnderline] is enabled.
  final double? stableUnderlineOffset;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      assert(() {
        if (stableUnderline) {
          throw FlutterError(
            'TextKo.rich does not support stableUnderline yet. '
            'Use RichTextKo (or disable stableUnderline) for rich text spans.',
          );
        }
        return true;
      }());

      return RichTextKo(
        textSpan!,
        key: key,
        style: style,
        wordBreak: wordBreak,
        joiner: joiner,
        skipEmojiTokens: skipEmojiTokens,
        preserveSemantics: preserveSemantics,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        // ignore: deprecated_member_use, deprecated_member_use_from_same_package
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        maxLines: maxLines,
        strutStyle: strutStyle,
        semanticsLabel: semanticsLabel,
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return _buildPlainText(context, data!);
  }

  Widget _buildPlainText(BuildContext context, String sourceText) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final TextStyle? effectiveTextStyle = resolveTextKoEffectiveTextStyle(
      context,
      style,
    );

    final bool hasUnderline = hasTextKoUnderlineDecoration(
      effectiveTextStyle?.decoration,
    );
    final String renderedText = applyTextKoTransforms(
      sourceText,
      wordBreak: wordBreak,
      joiner: joiner,
      skipEmojiTokens: skipEmojiTokens,
    );

    final String? resolvedSemanticsLabel =
        semanticsLabel ??
        (preserveSemantics && renderedText != sourceText ? sourceText : null);

    if (!stableUnderline) {
      return Text(
        renderedText,
        key: key,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        // ignore: deprecated_member_use
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: resolvedSemanticsLabel,
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    final TextStyle stableStyle = (effectiveTextStyle ?? const TextStyle())
        .copyWith(
          decoration: removeTextKoUnderline(effectiveTextStyle?.decoration),
        );

    final TextAlign resolvedTextAlign =
        textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final TextDirection resolvedTextDirection =
        textDirection ?? Directionality.of(context);
    final bool resolvedSoftWrap = softWrap ?? defaultTextStyle.softWrap;
    final TextOverflow resolvedOverflow =
        overflow ?? stableStyle.overflow ?? defaultTextStyle.overflow;
    final TextWidthBasis resolvedTextWidthBasis =
        textWidthBasis ?? defaultTextStyle.textWidthBasis;
    final ui.TextHeightBehavior? resolvedTextHeightBehavior =
        textHeightBehavior ??
        defaultTextStyle.textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
    final int? resolvedMaxLines = maxLines ?? defaultTextStyle.maxLines;

    Widget result = StableUnderlineText(
      text: renderedText,
      style: stableStyle,
      textAlign: resolvedTextAlign,
      textDirection: resolvedTextDirection,
      textScaler: resolveTextKoTextScaler(
        context,
        textScaler: textScaler,
        // ignore: deprecated_member_use
        textScaleFactor: textScaleFactor,
      ),
      maxLines: resolvedMaxLines,
      locale: locale,
      strutStyle: strutStyle,
      softWrap: resolvedSoftWrap,
      overflow: resolvedOverflow,
      textWidthBasis: resolvedTextWidthBasis,
      textHeightBehavior: resolvedTextHeightBehavior,
      underlineColor:
          stableUnderlineColor ??
          effectiveTextStyle?.decorationColor ??
          effectiveTextStyle?.color,
      underlineThickness:
          stableUnderlineThickness ?? effectiveTextStyle?.decorationThickness,
      underlineOffset: stableUnderlineOffset,
      drawUnderline: hasUnderline,
    );

    if (resolvedSemanticsLabel != null || semanticsIdentifier != null) {
      result = Semantics(
        textDirection: textDirection,
        label: resolvedSemanticsLabel,
        identifier: semanticsIdentifier,
        child: ExcludeSemantics(
          excluding: resolvedSemanticsLabel != null,
          child: result,
        ),
      );
    }

    return result;
  }
}
