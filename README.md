# text_ko

Korean-friendly text rendering helpers for Flutter.

`TextKo` extends Flutter's `Text` and adds opt-in behavior for Korean text UX issues that are still open upstream.

## Links

- pub.dev: https://pub.dev/packages/text_ko
- GitHub: https://github.com/curogom/text_ko

## Why this exists

- Korean word wrapping can break inside a word/syllable in Flutter:
  - [flutter/flutter#59284](https://github.com/flutter/flutter/issues/59284)
  - [flutter/flutter#19584](https://github.com/flutter/flutter/issues/19584)
- Underline can be unstable with trailing spaces:
  - [flutter/flutter#107725](https://github.com/flutter/flutter/issues/107725)

## Features

- `wordBreak: TextKoWordBreak.keepAll`
  - Keeps wrapping on whitespace boundaries by inserting zero-width joiners inside Korean tokens.
- `stableUnderline: true`
  - Draws underlines line-by-line using `CustomPaint` for more stable visuals.

## Getting started

From pub.dev:

```yaml
dependencies:
  text_ko: ^0.1.2
```

For local development:

```yaml
dependencies:
  text_ko:
    path: ../text_ko
```

## Example

![text_ko example](https://raw.githubusercontent.com/curogom/text_ko/main/example.jpeg)

## Usage

```dart
import 'package:text_ko/text_ko.dart';

TextKo(
  '새로운 메시지가 도착했습니다. 지금 확인해보세요!',
  style: const TextStyle(decoration: TextDecoration.underline),
  wordBreak: TextKoWordBreak.keepAll,
  joiner: TextKoJoiner.wordJoiner,
  stableUnderline: true,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
);
```

`TextKo.rich` for styled spans:

```dart
TextKo.rich(
  const TextSpan(
    text: '새로운 ',
    children: <InlineSpan>[
      TextSpan(
        text: '메시지',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '가 도착했습니다.'),
    ],
  ),
  wordBreak: TextKoWordBreak.keepAll,
);
```

or use `RichTextKo` directly:

```dart
RichTextKo(
  const TextSpan(
    text: '새로운 ',
    children: <InlineSpan>[TextSpan(text: '메시지')],
  ),
  wordBreak: TextKoWordBreak.keepAll,
);
```

## API notes

- `TextKo` keeps the original string in semantics by default when render-time transforms are applied.
- `stableUnderline` is display-focused and currently supported for plain `TextKo(String ...)`.
- `stableUnderline` does not provide `SelectableText`-level selection behavior.

---

## 한국어 문서

Flutter에서 한국어 텍스트 렌더링 UX를 개선하기 위한 유틸리티입니다.

`TextKo`는 Flutter 기본 `Text`를 확장해서, 아직 upstream에서 완전히 해결되지 않은 한국어 텍스트 이슈를 옵션 형태로 보완합니다.

### 왜 필요한가

- Flutter에서 한국어가 어절 내부(음절 사이)에서 줄바꿈될 수 있습니다:
  - [flutter/flutter#59284](https://github.com/flutter/flutter/issues/59284)
  - [flutter/flutter#19584](https://github.com/flutter/flutter/issues/19584)
- trailing space가 있는 구간에서 밑줄 렌더링이 불안정할 수 있습니다:
  - [flutter/flutter#107725](https://github.com/flutter/flutter/issues/107725)

### 주요 기능

- `wordBreak: TextKoWordBreak.keepAll`
  - 한국어 토큰 내부에 zero-width joiner를 삽입해 공백 경계 중심으로 줄바꿈되도록 유도합니다.
- `stableUnderline: true`
  - `CustomPaint`로 줄 단위 밑줄을 그려 더 안정적인 시각 결과를 제공합니다.

### 시작하기

pub.dev에서 설치:

```yaml
dependencies:
  text_ko: ^0.1.2
```

로컬 개발 경로를 사용할 때:

```yaml
dependencies:
  text_ko:
    path: ../text_ko
```

### 예시

![text_ko example](https://raw.githubusercontent.com/curogom/text_ko/main/example.jpeg)

### 사용법

```dart
import 'package:text_ko/text_ko.dart';

TextKo(
  '새로운 메시지가 도착했습니다. 지금 확인해보세요!',
  style: const TextStyle(decoration: TextDecoration.underline),
  wordBreak: TextKoWordBreak.keepAll,
  joiner: TextKoJoiner.wordJoiner,
  stableUnderline: true,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
);
```

스타일이 섞인 텍스트는 `TextKo.rich`를 사용할 수 있습니다:

```dart
TextKo.rich(
  const TextSpan(
    text: '새로운 ',
    children: <InlineSpan>[
      TextSpan(
        text: '메시지',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '가 도착했습니다.'),
    ],
  ),
  wordBreak: TextKoWordBreak.keepAll,
);
```

또는 `RichTextKo`를 직접 사용할 수 있습니다:

```dart
RichTextKo(
  const TextSpan(
    text: '새로운 ',
    children: <InlineSpan>[TextSpan(text: '메시지')],
  ),
  wordBreak: TextKoWordBreak.keepAll,
);
```

### API 노트

- 변환이 적용되더라도 `TextKo`는 기본적으로 semantics에 원문 문자열을 유지합니다.
- `stableUnderline`은 표시 품질 개선용 옵션이며 현재 plain `TextKo(String ...)` 중심으로 지원됩니다.
- `stableUnderline`은 `SelectableText` 수준의 선택 동작을 제공하지 않습니다.
