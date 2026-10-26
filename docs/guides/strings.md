# strings — split and cut text by runes, never UTF-16 units

You split and cut text by runes (code points) so multibyte characters stay
whole: `splitWords` splits on whitespace runs, `chunkString` cuts
fixed-rune chunks, `truncateRunes` cuts to a rune budget, `takeRunes` and
`dropRunes` take or drop a rune prefix, and `truncateWithEllipsis` cuts to
a budget with an ellipsis that still lands on a rune boundary. Every helper
is pure — inputs are never mutated, outputs are fresh values.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';`. You hold the source
text and, for cuts, the rune budget.

## Quick path

1. Split on whitespace: `splitWords('  go   rust\tzig\n')`.
2. Cut to a budget: `truncateRunes(sourceText, 2)`.
3. Cut with an overflow mark: `truncateWithEllipsis(sourceText, 8)`.
4. Take or drop a prefix: `takeRunes(sourceText, 2)`, `dropRunes(sourceText, 2)`.

## Which function?

The package doc (`lib/src/strings.dart`) is the source; this table mirrors
its "Which function?" table, plus the `defaultEllipsisMark` row from that
symbol's own doc:

| When you want to ...                  | Reach for ...          |
| ------------------------------------- | ---------------------- |
| Split on whitespace into words        | [splitWords]           |
| Split into fixed-rune chunks          | [chunkString]          |
| Cut to a rune budget, no suffix       | [truncateRunes]        |
| Keep the first runes                  | [takeRunes]            |
| Drop the first runes                  | [dropRunes]            |
| Cut to a rune budget with an ellipsis | [truncateWithEllipsis] |
| A default ellipsis mark to reuse or replace | [defaultEllipsisMark] |

## Example

```dart
final List<String> words = splitWords('  go   rust\tzig\n');
print(words); // [go, rust, zig]

final List<String> chunks = chunkString('héllo', 2);
print(chunks); // [hé, ll, o]

print(truncateRunes('héllo', 2)); // hé
print(takeRunes('héllo', 2)); // hé
print(dropRunes('héllo', 2)); // llo

final String kept = truncateWithEllipsis('héllo world', 8);
print(kept); // héllo w…
print(defaultEllipsisMark); // …
```

Blank input to `splitWords` yields an empty list (empty-means-empty, never
`['']`). Text within budget returns unchanged with no suffix. Negative
budgets and chunk sizes below `1` throw `ArgumentError` — those are
programmer errors, not domain outcomes.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Cuts land on rune boundaries | No cut ever tears a surrogate pair: `truncateRunes`, `takeRunes`, `dropRunes`, and `truncateWithEllipsis` count runes, never UTF-16 code units. |
| Empty-means-empty | `splitWords` over empty or blank input returns a fresh empty list; `chunkString` over empty input returns a fresh empty list; zero budgets yield empty strings. |
| Ellipsis stays inside the budget | `truncateWithEllipsis` keeps `maxRunes - ellipsis` runes plus the mark, so the result totals exactly `maxRunes` runes. An empty mark behaves like `truncateRunes`. |
| Invalid budgets throw `ArgumentError` | Negative counts and chunk sizes below `1` fail fast at the call site. |
| Pure helpers, fresh outputs | Inputs are never mutated; splits return fresh lists and cuts return fresh strings. |

> [!WARNING]
> Runes are code points, not grapheme clusters: emoji built from several code
> points (flags, keycaps, zero-width-joiner sequences) count as several runes
> here. When one visible character must stay whole, you reach for the external
> `characters` package instead — this package stays dependency-free on
> purpose and never claims cluster safety.

## When to use the stdlib directly

You stay with `dart:core` when it already names the operation: `split`,
`substring`, `trim`, `padLeft`, `toUpperCase`, and the case converters are
SDK-owned surface this package never reimplements. You reach for `strings`
when the count means runes — whitespace splitting with an empty-means-empty
contract, fixed-rune chunks, rune-budget cuts, and ellipsis cuts the SDK
cannot express without tearing surrogate pairs.

## Next step

When rune-safe words feed bounded parallel work, hand the split words to
`flowMap` with an in-flight cap — see `docs/guides/flow.md`.
