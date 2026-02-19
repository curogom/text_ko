import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show SelectionRegistrar;
import 'package:flutter/widgets.dart';

import 'text_ko_common.dart';
import 'word_break.dart';

/// A Korean-friendly rich text widget that transforms [InlineSpan] trees.
class RichTextKo extends StatelessWidget {
  /// Creates a [RichTextKo] with optional word-break transforms.
  const RichTextKo(
    this.text, {
    super.key,
    this.style,
    this.wordBreak = TextKoWordBreak.none,
    this.joiner = TextKoJoiner.wordJoiner,
    this.skipEmojiTokens = true,
    this.preserveSemantics = true,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    @Deprecated(
      'Use textScaler instead. '
      'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
      'This feature was deprecated after v3.12.0-2.0.pre.',
    )
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.strutStyle,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// Root rich span to render.
  final InlineSpan text;

  /// Base style merged with rich span styles.
  final TextStyle? style;

  /// Word-break behavior applied to all text spans.
  final TextKoWordBreak wordBreak;

  /// Joiner character used when [wordBreak] is [TextKoWordBreak.keepAll].
  final TextKoJoiner joiner;

  /// Skips keep-all transformation for tokens that look like emoji sequences.
  final bool skipEmojiTokens;

  /// Keeps original rich text as semantics label when transformed.
  final bool preserveSemantics;

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;

  @Deprecated(
    'Use textScaler instead. '
    'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
    'This feature was deprecated after v3.12.0-2.0.pre.',
  )
  final double? textScaleFactor;

  final TextScaler? textScaler;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final TextStyle? effectiveTextStyle = resolveTextKoEffectiveTextStyle(
      context,
      style,
    );

    final InlineSpan transformedSpan = transformTextKoInlineSpan(
      text,
      inheritedStyle: effectiveTextStyle,
      wordBreak: wordBreak,
      joiner: joiner,
      skipEmojiTokens: skipEmojiTokens,
    );

    final TextSpan rootSpan = TextSpan(
      style: effectiveTextStyle,
      locale: locale,
      children: <InlineSpan>[transformedSpan],
    );

    final String sourceText = text.toPlainText(includeSemanticsLabels: false);
    final String renderedText = rootSpan.toPlainText(
      includeSemanticsLabels: false,
    );

    final String? resolvedSemanticsLabel =
        semanticsLabel ??
        (preserveSemantics && sourceText != renderedText ? sourceText : null);

    final TextAlign resolvedTextAlign =
        textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final bool resolvedSoftWrap = softWrap ?? defaultTextStyle.softWrap;
    final TextOverflow resolvedOverflow =
        overflow ?? effectiveTextStyle?.overflow ?? defaultTextStyle.overflow;
    final TextWidthBasis resolvedTextWidthBasis =
        textWidthBasis ?? defaultTextStyle.textWidthBasis;
    final ui.TextHeightBehavior? resolvedTextHeightBehavior =
        textHeightBehavior ??
        defaultTextStyle.textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
    final int? resolvedMaxLines = maxLines ?? defaultTextStyle.maxLines;
    final TextScaler resolvedTextScaler = resolveTextKoTextScaler(
      context,
      textScaler: textScaler,
      // ignore: deprecated_member_use_from_same_package
      textScaleFactor: textScaleFactor,
    );
    final SelectionRegistrar? selectionRegistrar = SelectionContainer.maybeOf(
      context,
    );
    final Color resolvedSelectionColor =
        selectionColor ??
        DefaultSelectionStyle.of(context).selectionColor ??
        DefaultSelectionStyle.defaultColor;

    Widget result = RichText(
      text: rootSpan,
      textAlign: resolvedTextAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: resolvedSoftWrap,
      overflow: resolvedOverflow,
      textScaler: resolvedTextScaler,
      maxLines: resolvedMaxLines,
      strutStyle: strutStyle,
      textWidthBasis: resolvedTextWidthBasis,
      textHeightBehavior: resolvedTextHeightBehavior,
      selectionRegistrar: selectionRegistrar,
      selectionColor: resolvedSelectionColor,
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

/// Recursively transforms [TextSpan] nodes for TextKo behavior.
InlineSpan transformTextKoInlineSpan(
  InlineSpan span, {
  required TextStyle? inheritedStyle,
  required TextKoWordBreak wordBreak,
  required TextKoJoiner joiner,
  required bool skipEmojiTokens,
}) {
  if (span is! TextSpan) {
    return span;
  }

  final TextStyle? resolvedStyle = resolveTextKoChildStyle(
    inheritedStyle,
    span.style,
  );

  final List<InlineSpan>? originalChildren = span.children;
  final bool hasChildren =
      originalChildren != null && originalChildren.isNotEmpty;

  final String? transformedText;
  if (span.text == null) {
    transformedText = null;
  } else {
    transformedText = applyTextKoTransforms(
      span.text!,
      wordBreak: wordBreak,
      joiner: joiner,
      skipEmojiTokens: skipEmojiTokens,
    );
  }

  final List<InlineSpan>? transformedChildren;
  if (!hasChildren) {
    transformedChildren = originalChildren;
  } else {
    transformedChildren = List<InlineSpan>.generate(
      originalChildren.length,
      (int index) => transformTextKoInlineSpan(
        originalChildren[index],
        inheritedStyle: resolvedStyle,
        wordBreak: wordBreak,
        joiner: joiner,
        skipEmojiTokens: skipEmojiTokens,
      ),
      growable: false,
    );
  }

  return TextSpan(
    text: transformedText,
    children: transformedChildren,
    style: span.style,
    recognizer: span.recognizer,
    mouseCursor: span.mouseCursor,
    onEnter: span.onEnter,
    onExit: span.onExit,
    semanticsLabel: span.semanticsLabel,
    locale: span.locale,
    spellOut: span.spellOut,
  );
}
