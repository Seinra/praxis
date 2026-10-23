/// Typed map helpers over [Map], layered on `dart:core` instead of replacing it.
///
/// Reach for these when the SDK names the parts but not the outcome: a
/// grouped inversion, a key-set projection, a single-channel transform, or
/// an entry grouping. Reach for the SDK directly when it already names the
/// operation (`map`, `keys`, `values`, `containsKey`, `update`,
/// `putIfAbsent`, `addAll`, `remove`). Every helper is pure: inputs are
/// never mutated and outputs are fresh maps with fresh collections.
///
/// Which function?
///
/// | When you want to ...                   | Reach for ...   |
/// | --------------------------------------- | --------------- |
/// | Group keys sharing one value           | [invertEntries] |
/// | Keep only the requested keys            | [pickEntries]   |
/// | Drop the listed keys                    | [omitEntries]   |
/// | Transform every value, keep keys        | [mapValues]     |
/// | Remap every key, keep values            | [mapKeys]       |
/// | Group values by a derived key           | [groupEntriesBy] |
///
/// An empty map is a normal outcome here, never an error: every helper is
/// empty-safe, and the grouping helpers return fresh empty maps without
/// calling the caller's function. Never trust a grouped list to stay put:
/// every list inside [invertEntries] and [groupEntriesBy] is fresh, so
/// mutating it never affects the input.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

/// Groups keys sharing one value into fresh lists.
///
/// | When you want to ...         | Reach for ...   |
/// | ----------------------------- | --------------- |
/// | Group keys sharing one value | [invertEntries] |
///
/// `dart:core` has no inversion helper: spelling it with the SDK takes an
/// entries loop plus `putIfAbsent` plus a fresh list per unseen value, and
/// the grouping intent hides inside the composition (DART-SDK).
/// [invertEntries] fills that gap with one pass into fresh lists,
/// mirroring the Axiom `mapx` Invert precedent of collecting collisions
/// instead of overwriting them (AXIOM-SISTER).
///
/// Reversible only when values are unique: shared values collect into one
/// list, so a plain reverse would need a rule for which key wins. Groups
/// preserve encounter order, following [Map] insertion order.
///
/// Returns a fresh empty map when [entries] is empty. Every list is fresh,
/// so mutating the result never affects [entries]. Never mutates [entries].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final grouped = invertEntries(<String, int>{'ann': 1, 'bob': 2, 'cid': 1});
/// print(grouped[1]!.contains('ann')); // true
/// ```
Map<Value, List<Key>> invertEntries<Key, Value>(Map<Key, Value> entries) {
  final Map<Value, List<Key>> groupedEntries = <Value, List<Key>>{};
  for (final MapEntry<Key, Value> candidateEntry in entries.entries) {
    groupedEntries
        .putIfAbsent(candidateEntry.value, () => <Key>[])
        .add(candidateEntry.key);
  }
  return groupedEntries;
}

/// Keeps only the requested keys that are present.
///
/// | When you want to ...        | Reach for ... |
/// | ---------------------------- | ------------- |
/// | Keep only the requested keys | [pickEntries] |
///
/// `dart:core` has no key-set projection: spelling it with the SDK takes a
/// `containsKey` probe plus `[]` per wanted key, and the selection intent
/// hides inside the loop (DART-SDK). [pickEntries] fills that gap with one
/// pass over [wantedKeys] into a fresh map, mirroring the Axiom `mapx`
/// Pick precedent where missing keys are ignored (AXIOM-SISTER). It is the
/// complement of [omitEntries].
///
/// Missing keys are ignored. Returns a fresh empty map when [entries] is
/// empty, when [wantedKeys] is empty, or when no wanted key is present.
/// Never mutates [entries] or [wantedKeys].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final picked = pickEntries(<String, int>{'ann': 1, 'bob': 2}, <String>['ann', 'missing']);
/// print(picked); // {ann: 1}
/// ```
Map<Key, Value> pickEntries<Key, Value>(
  Map<Key, Value> entries,
  Iterable<Key> wantedKeys,
) {
  final Map<Key, Value> pickedEntries = <Key, Value>{};
  for (final Key wantedKey in wantedKeys) {
    if (entries.containsKey(wantedKey)) {
      pickedEntries[wantedKey] = entries[wantedKey] as Value;
    }
  }
  return pickedEntries;
}

/// Drops the listed keys, keeping the rest.
///
/// | When you want to ... | Reach for ... |
/// | --------------------- | ------------- |
/// | Drop the listed keys  | [omitEntries] |
///
/// `dart:core` answers removal with [Map.remove], which mutates in place,
/// so a pure drop needs a fresh copy that the SDK never names (DART-SDK).
/// [omitEntries] fills that gap with one pass into a fresh map, mirroring
/// the Axiom `mapx` Omit precedent where missing keys are ignored
/// (AXIOM-SISTER). It is the complement of [pickEntries].
///
/// Missing keys are ignored. Returns a fresh empty map when [entries] is
/// empty, and a fresh copy of [entries] when [excludedKeys] is empty.
/// Never mutates [entries] or [excludedKeys].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final kept = omitEntries(<String, int>{'ann': 1, 'bob': 2}, <String>['ann']);
/// print(kept); // {bob: 2}
/// ```
Map<Key, Value> omitEntries<Key, Value>(
  Map<Key, Value> entries,
  Iterable<Key> excludedKeys,
) {
  final Set<Key> excludedLookups = Set<Key>.of(excludedKeys);
  final Map<Key, Value> keptEntries = <Key, Value>{};
  for (final MapEntry<Key, Value> candidateEntry in entries.entries) {
    if (!excludedLookups.contains(candidateEntry.key)) {
      keptEntries[candidateEntry.key] = candidateEntry.value;
    }
  }
  return keptEntries;
}

/// Transforms every value, keeping keys unchanged.
///
/// | When you want to ...            | Reach for ... |
/// | -------------------------------- | ------------- |
/// | Transform every value, keep keys | [mapValues]   |
///
/// `dart:core` [Map.map] remaps whole entries in one callback, forcing
/// callers to rebuild a [MapEntry] even when only the value changes
/// (DART-SDK). [mapValues] fills that gap with a value-only transform that
/// keeps every key, mirroring the Axiom `mapx` MapValues precedent
/// (AXIOM-SISTER).
///
/// Returns a fresh empty map without calling [transformValue] when
/// [entries] is empty. Never mutates [entries].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final doubled = mapValues(<String, int>{'ann': 1}, (score) => score * 2);
/// print(doubled); // {ann: 2}
/// ```
Map<Key, TransformedValue> mapValues<Key, Value, TransformedValue>(
  Map<Key, Value> entries,
  TransformedValue Function(Value) transformValue,
) {
  final Map<Key, TransformedValue> mappedEntries = <Key, TransformedValue>{};
  for (final MapEntry<Key, Value> candidateEntry in entries.entries) {
    mappedEntries[candidateEntry.key] = transformValue(candidateEntry.value);
  }
  return mappedEntries;
}

/// Remaps every key, keeping values unchanged.
///
/// | When you want to ...          | Reach for ... |
/// | ------------------------------ | ------------- |
/// | Remap every key, keep values   | [mapKeys]     |
///
/// `dart:core` [Map.map] remaps whole entries in one callback, forcing
/// callers to rebuild a [MapEntry] even when only the key changes
/// (DART-SDK). [mapKeys] fills that gap with a key-only remap that keeps
/// every value, mirroring the Axiom `mapx` MapKeys precedent
/// (AXIOM-SISTER).
///
/// On collision the last encountered key wins: colliding inputs collapse
/// into a single entry holding one of the colliding values, never a merge.
/// Encounter order follows [Map] insertion order. Returns a fresh empty map
/// without calling [keyOf] when [entries] is empty. Never mutates [entries].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final upper = mapKeys(<String, int>{'ann': 1}, (name) => name.toUpperCase());
/// print(upper); // {ANN: 1}
/// ```
Map<NewKey, Value> mapKeys<Key, Value, NewKey>(
  Map<Key, Value> entries,
  NewKey Function(Key) keyOf,
) {
  final Map<NewKey, Value> remappedEntries = <NewKey, Value>{};
  for (final MapEntry<Key, Value> candidateEntry in entries.entries) {
    remappedEntries[keyOf(candidateEntry.key)] = candidateEntry.value;
  }
  return remappedEntries;
}

/// Groups entry values by a derived key.
///
/// | When you want to ...         | Reach for ...   |
/// | ----------------------------- | --------------- |
/// | Group values by a derived key | [groupEntriesBy] |
///
/// `dart:core` has no group-by helper: spelling it with the SDK takes an
/// entries loop plus `putIfAbsent` plus a fresh list per unseen group, and
/// the grouping intent hides inside the composition (DART-SDK).
/// [groupEntriesBy] fills that gap with one pass into fresh lists,
/// mirroring the Axiom `mapx` GroupByMapped precedent but over entries
/// rather than slices (AXIOM-SISTER).
///
/// Each group list preserves encounter order, following [Map] insertion
/// order. Returns a fresh empty map without calling [groupOf] when
/// [entries] is empty. Every list is fresh, so mutating the result never
/// affects [entries]. Never mutates [entries].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final grouped = groupEntriesBy(<String, int>{'ann': 91, 'bob': 72}, (name, score) => score >= 80 ? 'pass' : 'fail');
/// print(grouped['pass']); // [91]
/// ```
Map<GroupKey, List<Value>> groupEntriesBy<Key, Value, GroupKey>(
  Map<Key, Value> entries,
  GroupKey Function(Key, Value) groupOf,
) {
  final Map<GroupKey, List<Value>> groupedEntries = <GroupKey, List<Value>>{};
  for (final MapEntry<Key, Value> candidateEntry in entries.entries) {
    final GroupKey groupKey = groupOf(candidateEntry.key, candidateEntry.value);
    groupedEntries
        .putIfAbsent(groupKey, () => <Value>[])
        .add(candidateEntry.value);
  }
  return groupedEntries;
}
