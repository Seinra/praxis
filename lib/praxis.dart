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
/// | distinct values to combine or compare | `set` ([symmetricDifference], [isSubsetOf], [isSupersetOf], [isDisjointFrom], [hasSameMembers]) |
/// | a builtin map to reshape | `mapx` ([invertEntries], [pickEntries], [omitEntries], [mapValues], [mapKeys], [groupEntriesBy]) |
///
/// Skeleton ships `result` + `opt` + lists, the set slice ships `set`, and
/// the mapx slice ships `mapx`; everything else is declared future scope, never stubbed (see `README.md`).
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
library;

export 'src/lists.dart';
export 'src/mapx.dart';
export 'src/opt.dart';
export 'src/result.dart';
export 'src/set.dart';
