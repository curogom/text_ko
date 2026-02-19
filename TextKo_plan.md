# TextKo 라이브러리 기획서 (v0.1)

> 업데이트(2026-02-19): `UnderlineWorkaround`/`trailingSpaceZWSP`는 의도한 동작 안정성을 확보하지 못해 현재 스코프에서 제외합니다. 밑줄 관련 옵션은 `stableUnderline`만 유지합니다.

## 0. 명칭 결정: TextKo vs TextKR
- **권장: TextKo**
  - 목적이 “한국어(언어)” 지원이므로 **언어 코드 `ko`** 기반 네이밍이 더 정확합니다.
  - Flutter/Dart 생태계에서도 locale, i18n, 글꼴/입력기 등 “언어 단위”를 다룰 때 보통 `ko`를 씁니다.
- TextKR은 “대한민국(국가)” 느낌이 강해서, 한국어(ko) 이외의 한국 관련(지역/국가) 범위로 오해될 여지가 있습니다.

따라서 **패키지명 `text_ko` / 위젯 `TextKo`**로 진행합니다.  
(원하면 `TextKR`은 v0.x에서 alias로 제공 후 v1.0에서 제거하는 방향도 가능)

---

## 1) 한 줄 요약
Flutter에서 한국어 텍스트 UX를 깨는 대표 이슈(어절 단위 줄바꿈, underline 안정성)를 “패키지/위젯” 레벨에서 즉시 해결하는 경량 라이브러리.

---

## 2) 배경 / 문제정의

### P1. 한국어 어절(단어) 단위 줄바꿈 불가
- Web(CSS)에서는 `word-break: keep-all`류로 “공백 기준 줄바꿈”을 만들 수 있는데,
- Flutter `Text`는 한국어에서 어절 내부(음절 사이)에서 줄바꿈되는 경우가 있어 UI가 어색해짐.
- Flutter 이슈 트래킹:
  - Text widget incorrectly wraps Korean text (#59284)  
    https://github.com/flutter/flutter/issues/59284
  - No word-breaks for CJK locales (#19584)  
    https://github.com/flutter/flutter/issues/19584

### P2. Underline이 공백/혼합 폰트 구간에서 안정적이지 않음
- trailing spaces(문장 끝 공백)에서 underline이 누락되는 이슈가 트래킹됨.
- 워크어라운드로 `\u200b`(ZWSP) 삽입이 언급됨.
- Flutter 이슈 트래킹:
  - Line decorations are not drawing with end spaces (#107725)  
    https://github.com/flutter/flutter/issues/107725
  - (duplicate) #176163  
    https://github.com/flutter/flutter/issues/176163

---

## 3) 목표 / 비목표

### 목표
1. 한국어 텍스트를 “어절 단위”로 줄바꿈 가능하게 만든다(옵트인).
2. underline이 공백/끝 공백에서 끊기거나 시각적으로 불안정한 문제를 완화한다(옵트인).
3. 기존 `Text`/`RichText`의 사용성을 최대한 유지하면서 적용 비용을 낮춘다.

### 비목표(이번 패키지에서 안 함)
- Flutter 엔진/Skia/ICU 자체 수정(업스트림 PR은 별도 트랙).
- 플랫폼 IME(한글 입력기) 엔진 버그 자체 해결(다만 앱 코드 레벨 예방 유틸은 후속 옵션).

---

## 4) 제품 포지셔닝
- 패키지명: `text_ko`
- 위젯/엔트리 포인트: `TextKo`
- 슬로건: “Korean-friendly text for Flutter”

---

## 5) MVP 범위 (v0.1)

### 5.1 WordBreak: keep-all(어절 기준 줄바꿈)
옵션으로 활성화:
- 공백을 기준으로 토큰을 분리하고,
- 토큰(어절) 내부에 “줄바꿈 방지” zero-width 문자를 삽입해 어절 내부 줄바꿈을 억제.

레퍼런스(커뮤니티 구현 아이디어):
- 단어 내부에 U+200D 삽입으로 wrap 문제를 완화하는 방식  
  https://gist.github.com/AndrewDongminYoo/e326c8060c4fb0a3396ad9e6d39c0277

### 5.2 Underline: trailing spaces 보정
- `TextStyle.decoration`에 underline 포함 + 텍스트가 공백으로 끝나면, 렌더용 문자열에 `\u200b`를 자동 덧붙이는 옵션 제공.
- 관련 이슈: #107725  
  https://github.com/flutter/flutter/issues/107725

### 5.3 StableUnderline(선택 기능은 제한)
- 표준 underline을 끄고(Custom painter 방식),
- `TextPainter`로 텍스트를 paint한 뒤 `computeLineMetrics()`로 줄별 underline을 “한 줄당 하나의 직선”으로 그리는 옵션.
- 목적: 공백/혼합 폰트 구간에서 underline이 요철처럼 보이는 케이스를 시각적으로 안정화.
- 단, `SelectableText` 수준의 선택/복사 UX는 MVP에서 보장하지 않음(표시용 텍스트 중심).

---

## 6) 공개 API 설계(초안)

### 6.1 TextKo 위젯
```dart
TextKo(
  '새로운 메시지가 도착했습니다. 지금 확인해보세요!',
  style: const TextStyle(decoration: TextDecoration.underline),
  wordBreak: TextKoWordBreak.keepAll,
  joiner: TextKoJoiner.wordJoiner, // U+2060 기본 추천, 필요 시 ZWJ(U+200D)
  decorationFix: TextKoDecorationFix.trailingSpaceZWSP,
  stableUnderline: false,

  // Text와 동일한 주요 파라미터들 노출
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
  textAlign: TextAlign.start,
  textScaleFactor: 1.0,
);
```

### 6.2 Enums
```dart
enum TextKoWordBreak { none, keepAll }
enum TextKoJoiner { wordJoiner /* U+2060 */, zeroWidthJoiner /* U+200D */ }
enum TextKoDecorationFix { none, trailingSpaceZWSP }
```

### 6.3 String 확장(선택)
```dart
extension TextKoExt on String {
  String textKoKeepAll({TextKoJoiner joiner = TextKoJoiner.wordJoiner});
  String textKoTrailingZWSPIfNeeded({bool enabled = true});
}
```

---

## 7) 동작 상세(구현 가이드)

### 7.1 keepAll 변환 알고리즘(권장 구현)
목표: “공백 기준 줄바꿈”만 허용하고, 어절 내부 줄바꿈을 막는다.

- 입력 텍스트를 `\n` 기준으로 라인 분리(개행 보존)
- 각 라인을 정규식 `(\s+)`로 splitMapJoin하여 whitespace 토큰은 그대로 유지
- non-whitespace 토큰 중 “한글 포함 토큰”만 대상으로 변환:
  - `characters` 패키지로 grapheme cluster 단위 분해
  - cluster 사이에 joiner 삽입하여 결과 생성
- 이모지/조합 문자(특히 ZWJ 시퀀스) 깨짐 방지:
  - (MVP) 토큰에 이모지/복합 조합이 감지되면 변환 스킵(옵션)

주의:
- joiner 삽입은 “렌더용 문자열” 변경이다.
  - 접근성/복사/검색 품질을 위해 `semanticsLabel`(원문)과 렌더링 문자열(가공본)을 분리하는 옵션 제공 권장.

대안(비교용):
- `word_break_text`는 Wrap + Text 조합으로 CJK word break를 우회 구현  
  https://pub.dev/packages/word_break_text
- `line_change_text`는 TextPainter로 폭을 재서 “특정 구분자에서만 줄바꿈”을 구현  
  https://pub.dev/packages/line_change_text

TextKo는 “문장 구조를 가능한 한 single Text로 유지”하는 Joiner 방식이 기본이고, 후속 버전에서 Wrap 기반 모드도 고려.

### 7.2 trailing spaces underline 보정
- 조건:
  - style.decoration에 underline 포함
  - 텍스트가 정규식 `[ \t]+$`로 끝남
- 처리:
  - 렌더용 문자열 끝에 `\u200b` 추가(옵션 활성 시)
- 근거:
  - trailing spaces에서 decoration이 안 그려지는 이슈: #107725  
    https://github.com/flutter/flutter/issues/107725

### 7.3 stableUnderline (CustomPaint 방식)
- `TextPainter`로 텍스트를 직접 paint
- `computeLineMetrics()`로 line별 baseline/y를 계산
- underline thickness:
  - `style.decorationThickness` 우선
  - 없으면 `fontSize * k`(예: 0.08)로 추정(옵션화)
- underline y offset:
  - `baseline + underlineOffset` (옵션 파라미터로 튜닝 가능)
- underline 길이:
  - 기본: lineMetrics.width 사용
  - trailing spaces 포함 보장 옵션: 해당 라인 substring이 공백으로 끝나면 `\u200b` 추가한 별도 측정으로 width 재계산(비용 있으니 옵션)

제약:
- `SelectableText` 호환은 MVP 범위 밖(후속 버전에서 RenderObject/selection API 연동 필요)

---

## 8) 테스트 전략

### 8.1 변환 로직 단위 테스트
- keepAll:
  - 한글 포함/미포함 토큰 혼합
  - 개행 포함
  - 연속 공백/탭 포함
  - 이모지 포함 토큰(변환 스킵 여부)
- trailing ZWSP:
  - “끝 공백 있는 텍스트”에만 붙는지
  - underline 없을 때는 안 붙는지

### 8.2 위젯 테스트 / 골든 테스트
- 폰트 고정(테스트 번들에 NotoSansKR 등 포함)하여 플랫폼별 렌더 차이 최소화
- 시나리오:
  - keepAll on/off 비교(줄바꿈 위치)
  - underline trailing spaces 누락 케이스 재현 및 보정 확인
  - stableUnderline on/off 비교(공백 포함 문장)

---

## 9) 성능 / 부작용 관리
- keepAll은 문자열 변환 O(n). 긴 텍스트에 반복 적용되면 GC 부담 가능:
  - 캐시(입력 문자열 + 옵션 해시 → 변환 결과) 옵션 제공 고려
- stableUnderline은 TextPainter + line metrics + (옵션 시) 라인별 재측정이 들어가 비용 증가:
  - 기본은 off, 필요한 화면에서만 사용하도록 문서화

---

## 10) 작업 분해(Codex 실행용)

### T0. 스캐폴딩
- `text_ko/`
  - `lib/text_ko.dart` (public exports)
  - `lib/src/word_break.dart`
  - `lib/src/decoration_fix.dart`
  - `lib/src/stable_underline_painter.dart`
  - `lib/src/widgets/text_ko.dart`
  - `example/`
  - `test/`

Acceptance:
- `flutter test` 통과
- example 앱에서 3가지 모드 데모(plain / keepAll / underlineFix)

### T1. keepAll 변환 + TextKoWordBreak.keepAll
Acceptance:
- 공백 기준으로만 줄바꿈되는 것을 최소 3개 시나리오로 검증
- 이모지 포함 토큰은 기본 스킵(옵션으로 변경 가능)

레퍼런스:
- 단어 내 U+200D 삽입 방식(아이디어 참고)  
  https://gist.github.com/AndrewDongminYoo/e326c8060c4fb0a3396ad9e6d39c0277

### T2. trailingSpaceZWSP
Acceptance:
- underline + trailing spaces → `\u200b` 자동 부착
- underline 없으면 부착 안 함
- README에 이슈 링크 포함: #107725  
  https://github.com/flutter/flutter/issues/107725

### T3. stableUnderline(CustomPaint)
Acceptance:
- 동일 텍스트에서 기본 underline 대비 “줄 단위 직선 underline”이 출력됨
- maxLines/ellipsis 적용 시 깨지지 않음(최소 케이스 테스트)

### T4. 문서/README
- “왜 필요한가”에 Flutter 이슈/레퍼런스 링크 포함:
  - #59284, #19584, #107725
- 기존 유사 패키지 비교(짧게):
  - `word_break_text` https://pub.dev/packages/word_break_text
  - `line_change_text` https://pub.dev/packages/line_change_text

---

## 11) 향후 로드맵(v0.2+)
- RichText(Span) 지원(부분 스타일에서도 keepAll 적용)
- SelectableText 호환(가능하면 RenderObject 기반)
- “너무 긴 단어” fallback 정책(측정 기반 옵션)
- 업스트림 PR 트랙:
  - 줄바꿈(옵트인 wordBreak) 및 underline 공백 처리 개선을 Flutter/SkParagraph로 제안

---

## 12) 라이선스/배포
- MIT 권장
- pub.dev 배포 전 체크:
  - `dart format`, `dart analyze`, `pana`
  - example 및 스크린샷 첨부
