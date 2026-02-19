import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

class StableUnderlineText extends StatelessWidget {
  const StableUnderlineText({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.softWrap,
    required this.overflow,
    required this.textWidthBasis,
    required this.drawUnderline,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textHeightBehavior,
    this.underlineColor,
    this.underlineThickness,
    this.underlineOffset,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final bool softWrap;
  final TextOverflow overflow;
  final TextWidthBasis textWidthBasis;
  final bool drawUnderline;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? underlineColor;
  final double? underlineThickness;
  final double? underlineOffset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double boxMaxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;
        final TextPainter textPainter = _createTextPainter(
          maxWidth: boxMaxWidth,
        );
        textPainter.layout(maxWidth: _layoutWidth(boxMaxWidth));

        final double paintWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : textPainter.width;

        return SizedBox(
          width: paintWidth,
          height: textPainter.height,
          child: CustomPaint(
            painter: StableUnderlinePainter(
              text: text,
              style: style,
              textAlign: textAlign,
              textDirection: textDirection,
              textScaler: textScaler,
              maxLines: maxLines,
              locale: locale,
              strutStyle: strutStyle,
              softWrap: softWrap,
              overflow: overflow,
              textWidthBasis: textWidthBasis,
              textHeightBehavior: textHeightBehavior,
              underlineColor: underlineColor,
              underlineThickness: underlineThickness,
              underlineOffset: underlineOffset,
              drawUnderline: drawUnderline,
            ),
          ),
        );
      },
    );
  }

  TextPainter _createTextPainter({required double maxWidth}) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  double _layoutWidth(double incomingMaxWidth) {
    if (!softWrap && overflow == TextOverflow.visible) {
      return double.infinity;
    }

    return incomingMaxWidth;
  }
}

class StableUnderlinePainter extends CustomPainter {
  StableUnderlinePainter({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.softWrap,
    required this.overflow,
    required this.textWidthBasis,
    required this.drawUnderline,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textHeightBehavior,
    this.underlineColor,
    this.underlineThickness,
    this.underlineOffset,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final bool softWrap;
  final TextOverflow overflow;
  final TextWidthBasis textWidthBasis;
  final bool drawUnderline;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? underlineColor;
  final double? underlineThickness;
  final double? underlineOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final TextPainter textPainter = _createTextPainter();
    textPainter.layout(maxWidth: _layoutWidth(size.width));

    final bool shouldClip = overflow != TextOverflow.visible;
    if (shouldClip) {
      canvas.save();
      canvas.clipRect(Offset.zero & size);
    }

    textPainter.paint(canvas, Offset.zero);

    if (drawUnderline) {
      final double strokeWidth = _resolvedUnderlineThickness();
      final Paint linePaint = Paint()
        ..color = _resolvedUnderlineColor()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square;

      final double yOffset = _resolvedUnderlineOffset();
      for (final ui.LineMetrics line in textPainter.computeLineMetrics()) {
        if (line.width <= 0) {
          continue;
        }

        final double startX = line.left;
        final double endX = line.left + line.width;
        final double y = line.baseline + yOffset;
        canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
      }
    }

    if (shouldClip) {
      canvas.restore();
    }
  }

  Color _resolvedUnderlineColor() {
    return underlineColor ??
        style.decorationColor ??
        style.color ??
        const Color(0xFF000000);
  }

  double _resolvedUnderlineThickness() {
    if (underlineThickness != null) {
      return underlineThickness!;
    }

    final double fallback = (style.fontSize ?? 14) * 0.08;
    return fallback.clamp(1.0, 4.0);
  }

  double _resolvedUnderlineOffset() {
    if (underlineOffset != null) {
      return underlineOffset!;
    }

    return (style.fontSize ?? 14) * 0.12;
  }

  TextPainter _createTextPainter() {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  double _layoutWidth(double incomingMaxWidth) {
    if (!softWrap && overflow == TextOverflow.visible) {
      return double.infinity;
    }

    return incomingMaxWidth;
  }

  @override
  bool shouldRepaint(covariant StableUnderlinePainter oldDelegate) {
    return text != oldDelegate.text ||
        style != oldDelegate.style ||
        textAlign != oldDelegate.textAlign ||
        textDirection != oldDelegate.textDirection ||
        textScaler != oldDelegate.textScaler ||
        maxLines != oldDelegate.maxLines ||
        locale != oldDelegate.locale ||
        strutStyle != oldDelegate.strutStyle ||
        softWrap != oldDelegate.softWrap ||
        overflow != oldDelegate.overflow ||
        textWidthBasis != oldDelegate.textWidthBasis ||
        textHeightBehavior != oldDelegate.textHeightBehavior ||
        underlineColor != oldDelegate.underlineColor ||
        underlineThickness != oldDelegate.underlineThickness ||
        underlineOffset != oldDelegate.underlineOffset ||
        drawUnderline != oldDelegate.drawUnderline;
  }
}
