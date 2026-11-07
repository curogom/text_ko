import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_ko/text_ko.dart';

void main() {
  group('word break transform', () {
    test('inserts joiners for Korean tokens', () {
      const String source = '새로운 메시지가 도착했습니다';

      final String transformed = source.textKoKeepAll();

      expect(transformed.contains('\u2060'), isTrue);
      expect(transformed.replaceAll('\u2060', ''), source);
    });

    test('preserves whitespace and new lines', () {
      const String source = '안녕   하세요\n다시\t만나요';

      final String transformed = source.textKoKeepAll();

      expect(transformed.replaceAll('\u2060', ''), source);
    });

    test('is idempotent with the default word joiner', () {
      const String source = '새로운 메시지가 도착했습니다';

      final String once = source.textKoKeepAll();

      expect(once.textKoKeepAll(), once);
      expect(once.contains('\u2060\u2060'), isFalse);
    });

    test('skips tokens that contain emoji by default', () {
      const String source = '안녕 😀테스트 반가워';

      final String transformed = source.textKoKeepAll();

      expect(transformed.contains('안\u2060녕'), isTrue);
      expect(transformed.contains('😀\u2060테'), isFalse);
      expect(transformed.contains('반\u2060가\u2060워'), isTrue);
    });
  });

  group('TextKo widget', () {
    testWidgets('transforms rendered text for keepAll mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: TextKo('새로운 메시지가 도착했습니다', wordBreak: TextKoWordBreak.keepAll),
        ),
      );

      final Iterable<Text> renderedTexts = tester
          .widgetList<Text>(
            find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget is! TextKo,
            ),
          )
          .cast<Text>();

      expect(renderedTexts.length, 1);
      expect(renderedTexts.single.data, isNotNull);
      expect(renderedTexts.single.data!.contains('\u2060'), isTrue);
    });

    testWidgets('keeps trailing spaces unchanged when underline is enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: TextKo(
            '밑줄 테스트  ',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      );

      final Iterable<Text> renderedTexts = tester
          .widgetList<Text>(
            find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget is! TextKo,
            ),
          )
          .cast<Text>();

      expect(renderedTexts.length, 1);
      expect(renderedTexts.single.data, '밑줄 테스트  ');
    });

    testWidgets('can render stable underline mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 140,
            child: TextKo(
              '안정적인 밑줄 표현 테스트',
              style: TextStyle(decoration: TextDecoration.underline),
              stableUnderline: true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('keeps semantics as source text after transform', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: TextKo(
              '새로운 메시지가 도착했습니다',
              wordBreak: TextKoWordBreak.keepAll,
            ),
          ),
        );

        expect(find.bySemanticsLabel('새로운 메시지가 도착했습니다'), findsOneWidget);
      } finally {
        semanticsHandle.dispose();
      }
    });

    testWidgets('TextKo.rich transforms rich span text in keepAll mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: TextKo.rich(
            TextSpan(
              text: '새로운 ',
              children: <InlineSpan>[TextSpan(text: '메시지가 도착했습니다')],
            ),
            wordBreak: TextKoWordBreak.keepAll,
          ),
        ),
      );

      expect(find.byType(RichTextKo), findsOneWidget);
      final RichText richText = tester.widget<RichText>(find.byType(RichText));
      expect(
        richText.text
            .toPlainText(includeSemanticsLabels: false)
            .contains('\u2060'),
        isTrue,
      );
    });
  });

  group('RichTextKo widget', () {
    testWidgets('keeps terminal trailing spaces unchanged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: RichTextKo(
            TextSpan(
              style: TextStyle(decoration: TextDecoration.underline),
              children: <InlineSpan>[
                TextSpan(text: '앞쪽  '),
                TextSpan(text: '끝쪽  '),
              ],
            ),
          ),
        ),
      );

      final RichText richText = tester.widget<RichText>(find.byType(RichText));
      final String plain = richText.text.toPlainText(
        includeSemanticsLabels: false,
      );

      expect(plain, '앞쪽  끝쪽  ');
    });

    testWidgets('keeps semantics as source text when transformed', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RichTextKo(
              TextSpan(
                text: '새로운 ',
                children: <InlineSpan>[TextSpan(text: '메시지가 도착했습니다')],
              ),
              wordBreak: TextKoWordBreak.keepAll,
            ),
          ),
        );

        expect(find.bySemanticsLabel('새로운 메시지가 도착했습니다'), findsOneWidget);
      } finally {
        semanticsHandle.dispose();
      }
    });
  });
}
