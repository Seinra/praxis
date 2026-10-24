/// Rune-aware text helpers over [String], layered on `dart:core`.
///
/// Reach for these when the count means runes, not UTF-16 code units: a
/// whitespace split with an empty-means-empty contract, fixed-rune chunks,
/// a rune-budget cut, rune-safe ends, or an ellipsis cut that still lands
/// on a rune boundary. Reach for the SDK directly when it already names
/// the operation (`split`, `substring`, `trim`, `padLeft`, `toUpperCase`
/// and case converters): this package never reimplements SDK-owned
/// surface. Every helper is pure: inputs are never mutated and outputs
/// are fresh values (`String` is immutable, so cuts return fresh strings
/// and splits return fresh lists).
///
/// Which function?
///
/// | When you want to ...                  | Reach for ...          |
/// | ------------------------------------- | ---------------------- |
/// | Split on whitespace into words        | [splitWords]           |
/// | Split into fixed-rune chunks          | [chunkString]          |
/// | Cut to a rune budget, no suffix       | [truncateRunes]        |
/// | Keep the first runes                  | [takeRunes]            |
/// | Drop the first runes                  | [dropRunes]            |
/// | Cut to a rune budget with an ellipsis | [truncateWithEllipsis] |
///
/// Grapheme clusters beyond runes need the external `characters` package
/// and stay out of scope on purpose (SDK-first: zero runtime
/// dependencies). Emoji made of several code points (flags, keycaps,
/// zero-width-joiner sequences) count as several runes here; what stays
/// whole is one rune (one code point), never one UTF-16 code unit.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

/// The default ellipsis mark used by [truncateWithEllipsis].
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a default ellipsis mark to reuse or replace | [defaultEllipsisMark] |
///
/// Stdlib gap (DART-SDK): `dart:core` names no ellipsis constant, so call
/// sites retype the literal wherever a rune-budget cut needs one.
/// [defaultEllipsisMark] names the single-character mark so the budget
/// math stays rune-based. Fidelity note (AXIOM-SISTER): Axiom keeps
/// ellipsis variants out entirely; this package names the mark because
/// the ellipsis cut is an explicit scope item here.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final String mark = defaultEllipsisMark;
/// // mark.runes.length == 1
/// ```
const String defaultEllipsisMark = '…';

/// Splits [sourceText] on Unicode whitespace into words.
///
/// | When you want to ...           | Reach for ... |
/// | ------------------------------ | ------------- |
/// | Split on whitespace into words | [splitWords]  |
///
/// `dart:core` answers splitting with [String.split], which needs a
/// caller-built pattern for whitespace runs and reports empty input as
/// `['']` instead of an empty list (DART-SDK). [splitWords] fills that
/// gap with one trimmed Unicode-whitespace split that pins the
/// empty-means-empty contract, mirroring the Axiom `strings` Words
/// precedent where blank input yields an empty non-nil slice
/// (AXIOM-SISTER). Words keep their multibyte runes intact because the
/// split never cuts inside a word.
///
/// Returns a fresh empty list when [sourceText] is empty or blank.
/// Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final List<String> words = splitWords('  go   rust\tzig\n');
/// print(words); // [go, rust, zig]
/// ```
List<String> splitWords(String sourceText) {
  if (sourceText.trim().isEmpty) {
    return <String>[];
  }
  return sourceText.trim().split(RegExp(r'\s+', unicode: true));
}

/// Splits [sourceText] into chunks of at most [chunkSize] runes.
///
/// | When you want to ...         | Reach for ... |
/// | ---------------------------- | ------------- |
/// | Split into fixed-rune chunks | [chunkString] |
///
/// `dart:core` has no chunk helper: [String.substring] carves one
/// UTF-16 range per call and tears surrogate pairs when the range lands
/// inside a multibyte rune (DART-SDK). [chunkString] fills that gap with
/// one eager pass cut on rune boundaries, mirroring the Axiom `strings`
/// ChunkString precedent and the `lists` [chunkElements] fresh-chunk
/// contract (AXIOM-SISTER).
///
/// Throws an [ArgumentError] when [chunkSize] is below `1`: a
/// non-positive chunk size is a programmer error, not a domain outcome.
/// Returns a fresh empty list when [sourceText] is empty. A [chunkSize]
/// at or beyond the rune length yields one chunk holding a copy of
/// [sourceText]. Every chunk is fresh, so mutating the result never
/// affects [sourceText]. Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final List<String> chunks = chunkString('héllo', 2);
/// print(chunks); // [hé, ll, o]
/// ```
List<String> chunkString(String sourceText, int chunkSize) {
  if (chunkSize < 1) {
    throw ArgumentError.value(chunkSize, 'chunkSize', 'needs size >= 1');
  }
  final List<int> sourceRunes = sourceText.runes.toList();
  if (sourceRunes.isEmpty) {
    return <String>[];
  }
  final List<String> chunkParts = <String>[];
  for (
    int chunkStart = 0;
    chunkStart < sourceRunes.length;
    chunkStart += chunkSize
  ) {
    int chunkEnd = chunkStart + chunkSize;
    if (chunkEnd > sourceRunes.length) {
      chunkEnd = sourceRunes.length;
    }
    chunkParts.add(
      String.fromCharCodes(sourceRunes.sublist(chunkStart, chunkEnd)),
    );
  }
  return chunkParts;
}

/// Cuts [sourceText] to at most [maxRunes] runes, with no suffix added.
///
/// | When you want to ...            | Reach for ...   |
/// | ------------------------------- | --------------- |
/// | Cut to a rune budget, no suffix | [truncateRunes] |
///
/// `dart:core` cuts with [String.substring], which counts UTF-16 code
/// units and tears surrogate pairs when the cut lands inside a multibyte
/// rune (DART-SDK). [truncateRunes] fills that gap with a rune-boundary
/// cut that returns [sourceText] unchanged when it already fits,
/// mirroring the Axiom `strings` Truncate precedent where text within
/// budget returns unchanged (AXIOM-SISTER).
///
/// Throws an [ArgumentError] when [maxRunes] is negative: a negative
/// budget is a programmer error, not a domain outcome. A zero budget
/// yields an empty string. Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final String kept = truncateRunes('héllo', 2);
/// print(kept); // hé
/// ```
String truncateRunes(String sourceText, int maxRunes) {
  if (maxRunes < 0) {
    throw ArgumentError.value(maxRunes, 'maxRunes', 'needs maxRunes >= 0');
  }
  final List<int> sourceRunes = sourceText.runes.toList();
  if (sourceRunes.length <= maxRunes) {
    return sourceText;
  }
  return String.fromCharCodes(sourceRunes.sublist(0, maxRunes));
}

/// Keeps the first [runeCount] runes of [sourceText].
///
/// | When you want to ...   | Reach for ... |
/// | ---------------------- | ------------- |
/// | Keep the first runes   | [takeRunes]   |
///
/// `dart:core` takes a prefix with [String.substring], which counts
/// UTF-16 code units and tears surrogate pairs when the cut lands inside
/// a multibyte rune (DART-SDK). [takeRunes] fills that gap with a
/// rune-boundary prefix, the take half of the take/drop pair beside
/// [dropRunes].
///
/// Throws an [ArgumentError] when [runeCount] is negative: a negative
/// count is a programmer error, not a domain outcome. A zero count yields
/// an empty string. A count at or beyond the rune length returns
/// [sourceText] unchanged. Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final String kept = takeRunes('héllo', 2);
/// print(kept); // hé
/// ```
String takeRunes(String sourceText, int runeCount) {
  if (runeCount < 0) {
    throw ArgumentError.value(runeCount, 'runeCount', 'needs runeCount >= 0');
  }
  final List<int> sourceRunes = sourceText.runes.toList();
  if (sourceRunes.length <= runeCount) {
    return sourceText;
  }
  return String.fromCharCodes(sourceRunes.sublist(0, runeCount));
}

/// Drops the first [runeCount] runes of [sourceText].
///
/// | When you want to ...   | Reach for ... |
/// | ---------------------- | ------------- |
/// | Drop the first runes   | [dropRunes]   |
///
/// `dart:core` drops a prefix with [String.substring], which counts
/// UTF-16 code units and tears surrogate pairs when the cut lands inside
/// a multibyte rune (DART-SDK). [dropRunes] fills that gap with a
/// rune-boundary remainder, the drop half of the take/drop pair beside
/// [takeRunes].
///
/// Throws an [ArgumentError] when [runeCount] is negative: a negative
/// count is a programmer error, not a domain outcome. A zero count
/// returns [sourceText] unchanged. A count at or beyond the rune length
/// yields an empty string. Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final String rest = dropRunes('héllo', 2);
/// print(rest); // llo
/// ```
String dropRunes(String sourceText, int runeCount) {
  if (runeCount < 0) {
    throw ArgumentError.value(runeCount, 'runeCount', 'needs runeCount >= 0');
  }
  final List<int> sourceRunes = sourceText.runes.toList();
  if (runeCount >= sourceRunes.length) {
    return '';
  }
  if (runeCount == 0) {
    return sourceText;
  }
  return String.fromCharCodes(sourceRunes.sublist(runeCount));
}

/// Cuts [sourceText] to at most [maxRunes] runes with [ellipsis] appended.
///
/// | When you want to ...                  | Reach for ...          |
/// | ------------------------------------- | ---------------------- |
/// | Cut to a rune budget with an ellipsis | [truncateWithEllipsis] |
///
/// `dart:core` has no ellipsis cut: callers combine [String.substring]
/// with string concatenation, which counts UTF-16 code units, tears
/// surrogate pairs, and overruns the budget by the suffix length
/// (DART-SDK). [truncateWithEllipsis] fills that gap with one
/// rune-budget cut where the kept runes plus [ellipsis] total exactly
/// [maxRunes] runes. Text within budget returns unchanged with no suffix.
/// Axiom keeps ellipsis variants out entirely (AXIOM-SISTER); this
/// helper is the one deliberate Praxis addition because Flutter text
/// layouts budget by runes with a visible overflow mark.
///
/// Throws an [ArgumentError] when [maxRunes] is negative: a negative
/// budget is a programmer error, not a domain outcome. When [maxRunes]
/// holds no room for kept runes, the result is [ellipsis] cut to
/// [maxRunes] runes. An empty [ellipsis] behaves like [truncateRunes].
/// Never mutates [sourceText].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final String kept = truncateWithEllipsis('héllo world', 8);
/// print(kept); // héllo w…
/// ```
String truncateWithEllipsis(
  String sourceText,
  int maxRunes, [
  String ellipsis = defaultEllipsisMark,
]) {
  if (maxRunes < 0) {
    throw ArgumentError.value(maxRunes, 'maxRunes', 'needs maxRunes >= 0');
  }
  final List<int> sourceRunes = sourceText.runes.toList();
  if (sourceRunes.length <= maxRunes) {
    return sourceText;
  }
  final List<int> ellipsisRunes = ellipsis.runes.toList();
  if (maxRunes <= ellipsisRunes.length) {
    return String.fromCharCodes(ellipsisRunes.sublist(0, maxRunes));
  }
  final int keptCount = maxRunes - ellipsisRunes.length;
  return String.fromCharCodes(sourceRunes.sublist(0, keptCount)) + ellipsis;
}
