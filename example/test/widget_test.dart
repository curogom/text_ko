import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_ko_example/main.dart';

void main() {
  testWidgets('renders diverse scenario playground sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TextKoExampleApp());
    final Finder playgroundScrollable = find.descendant(
      of: find.byKey(const ValueKey<String>('playground_list')),
      matching: find.byType(Scrollable),
    );

    Future<void> expectAfterScroll(String text) async {
      await tester.scrollUntilVisible(
        find.text(text),
        200,
        scrollable: playgroundScrollable,
      );
      expect(find.text(text), findsOneWidget);
    }

    expect(find.text('text_ko playground'), findsOneWidget);
    expect(find.text('Preview Controls'), findsOneWidget);
    expect(find.text('기본 알림 + 끝 공백'), findsOneWidget);

    await expectAfterScroll('한/영 혼합 + URL');
    await expectAfterScroll('이모지 혼합 문장');
    await expectAfterScroll('긴 어절(무공백) 테스트');
    await expectAfterScroll('연속 공백/탭 포함');
    await expectAfterScroll('개행 포함 문단');
    await expectAfterScroll('RichText Scenarios');
    await expectAfterScroll('상태 배지 + 밑줄 끝 공백');
    await expectAfterScroll('WidgetSpan + 이모지');
    expect(find.text('TextKo.rich keepAll'), findsWidgets);
    expect(find.text('RichTextKo keepAll'), findsWidgets);
  });
}
