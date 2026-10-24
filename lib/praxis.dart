/// Praxis — the Echo of Dart generics.
///
/// One small, dependable library that makes the hard parts of generics easy,
/// so apps like Catalyst teach and ship typed code instead of `dynamic` soup.
///
/// Which package?
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a success-or-failure outcome | `result` ([Result], [Ok], [Failure]) |
/// | a maybe-present value | `opt` ([Opt], [Some], [None]) |
/// | a list to transform, find, or fold | lists ([findElement], [minElement], [maxElement], [chunkElements], [partitionElements]) |
/// | a lazy `Iterable` pipeline to pull on demand | `iterx` ([zipIterables], [chunkedIterable], [windowedIterable], [cycleIterable], [repeatElement], [deduplicateAdjacent]) — reach for `iterx` when the source is an `Iterable` or the pipeline should stay lazy; reach for the eager `lists` helpers when the input is already a `List` and you want a finished value in one pass |
/// | distinct values to combine or compare | `set` ([symmetricDifference], [isSubsetOf], [isSupersetOf], [isDisjointFrom], [hasSameMembers]) |
/// | a builtin map to reshape | `mapx` ([invertEntries], [pickEntries], [omitEntries], [mapValues], [mapKeys], [groupEntriesBy]) |
/// | predicates to combine (And / Or / Not) | `valid` ([Predicate], [andPredicates], [orPredicates], [notPredicate], [alwaysTrue], [alwaysFalse]) |
/// | text to split or cut by runes | `strings` ([splitWords], [chunkString], [truncateRunes], [takeRunes], [dropRunes], [truncateWithEllipsis], [defaultEllipsisMark]) |
/// | whole numbers to test, divide, or combine | `mathx` ([isPrime], [primesUpTo], [lcm]) |
///
/// Skeleton ships `result` + `opt` + lists, the set slice ships `set`, the
/// mapx slice ships `mapx`, the iterx slice ships `iterx`, the valid slice
/// ships `valid`, the strings slice ships `strings`, and the mathx slice
/// ships `mathx`; everything else is declared future scope, never stubbed (see `README.md`).
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
library;

export 'src/iterx.dart';
export 'src/lists.dart';
export 'src/mapx.dart';
export 'src/mathx.dart';
export 'src/opt.dart';
export 'src/result.dart';
export 'src/set.dart';
export 'src/strings.dart';
export 'src/valid.dart';
