/// Insertion-ordered maps plus a bounded recency cache.
///
/// Reach for [OrderedMap] when lookup must replay first-insertion order:
/// [OrderedMap.put] adds or replaces, [OrderedMap.get] reads with a
/// presence flag, [OrderedMap.remove] drops by key, and [OrderedMap.keys]
/// plus [OrderedMap.values] replay that order as fresh lists. Reach for
/// [LruCache] when memory is bounded and every hit refreshes recency:
/// [LruCache.put] stores and evicts least-recently-used first, and
/// [LruCache.get] reads while refreshing. Reach for the SDK directly when
/// plain lookup is the job (`LinkedHashMap` iterates in insertion order;
/// `SplayTreeMap` iterates sorted) — these holders own only the ordered
/// record contract plus eviction.
///
/// Which function?
///
/// | When you want to ...                          | Reach for ...     |
/// | --------------------------------------------- | ----------------- |
/// | Remember insertion order alongside lookup     | [OrderedMap]      |
/// | Bound memory with least-recently-used eviction | [LruCache]       |
/// | Build an empty ordered map                    | [OrderedMap.new]  |
/// | Build a bounded recency cache                 | [LruCache.new]    |
/// | Add or replace an entry                       | [OrderedMap.put]  |
/// | Read an entry (cache: refreshes recency)      | [OrderedMap.get]  |
/// | Remove an entry                               | [OrderedMap.remove] |
/// | Count held entries                            | [OrderedMap.length] |
/// | Ask whether nothing is held                   | [OrderedMap.isEmpty] |
/// | Ask whether something is held                 | [OrderedMap.isNotEmpty] |
/// | Replay keys or values in insertion order      | [OrderedMap.keys] |
/// | Read a cached entry refreshing its recency    | [LruCache.get]    |
/// | Store a cached entry evicting when full       | [LruCache.put]    |
/// | Read the cache bound                          | [LruCache.capacity] |
/// | Count cached entries                          | [LruCache.length] |
///
/// The `(value, present)` record on [OrderedMap.get] and [LruCache.get] is
/// this package's OrNull: `present` reports presence and `value` is `null`
/// when absent. A missing key is a normal outcome here, never an error;
/// for failures with causes, see the result package, and for a wrapped
/// maybe, see opt. Never trust `value` without checking `present` first: a
/// map may itself hold `null` values, so only the flag tells a held `null`
/// from a missing key.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

/// Holds entries of [Value] keyed by [Key] in first-insertion order.
///
/// [OrderedMap.put] behaves like the builtin map except order is pinned:
/// an upsert keeps the key's first-insertion position, [OrderedMap.remove]
/// of a missing key is a no-op, and a re-put after remove takes the back.
/// [OrderedMap.keys] and [OrderedMap.values] replay that order as fresh
/// lists, so mutating a replay never disturbs the map. The holder mutates
/// only its own backing: constructors take no caller collections, so there
/// is no aliasing surface.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | entries to look up in insertion order | [OrderedMap] |
///
/// Stdlib gap (DART-SDK): `LinkedHashMap` iterates in key insertion order,
/// but `operator []` answers `null` both when the key is missing and when
/// the key holds a `null` value — absence needs a second `containsKey`
/// probe, and `keys`/`values` expose live views, never snapshots.
/// [OrderedMap] fills that gap with one-probe [OrderedMap.get] answering
/// the `(value, present)` OrNull record plus fresh-snapshot
/// [OrderedMap.keys]/[OrderedMap.values]. Fidelity note (AXIOM-SISTER):
/// mirrors Axiom `orderedmap` Map discipline (upsert keeps position,
/// missing delete is a no-op, re-put takes the back, fresh replays)
/// without Go signatures — records instead of `(V, bool)` pairs, methods
/// over a `LinkedHashMap` backing instead of a keys slice plus positions
/// map (SDK-first: the SDK already pins the order).
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
/// scoresByName.put('ann', 91);
/// scoresByName.put('bob', 72);
/// // scoresByName.keys() == const <String>['ann', 'bob']
/// ```
final class OrderedMap<Key, Value> {
  /// Creates an empty ordered map ready for [OrderedMap.put].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | nothing yet to hold in order | [OrderedMap.new] |
  ///
  /// Stdlib gap (DART-SDK): a map literal starts empty too, but answers
  /// absence with `null`; [OrderedMap.new] starts an empty holder whose
  /// reads answer presence-flagged records.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// // scoresByName.isEmpty == true
  /// ```
  OrderedMap();

  final Map<Key, Value> _entriesByKey = <Key, Value>{};

  /// Adds [mapKey] with [heldValue], or replaces the value when present.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an entry to store in order | [OrderedMap.put] |
  ///
  /// Stdlib gap (DART-SDK): `Map.[]=` stores too, but leaves the
  /// presence-flag read to a second probe; [put] stores the entry whose
  /// [OrderedMap.get] reads back as one record. An upsert keeps the key's
  /// first-insertion position.
  ///
  /// Never mutates caller inputs: the pair moves into the private backing,
  /// and no caller collection is read or written.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('ann', 91);
  /// // scoresByName.get('ann').value == 91
  /// ```
  void put(Key mapKey, Value heldValue) {
    _entriesByKey[mapKey] = heldValue;
  }

  /// Returns the value held for [mapKey] with a presence flag.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a key to read in one probe | [OrderedMap.get] |
  ///
  /// Stdlib gap (DART-SDK): `Map.[]` conflates a missing key with a held
  /// `null`, forcing a follow-up `containsKey` when the distinction
  /// matters; [get] answers `(value, present)` in one probe, so a held
  /// `null` reads `(value: null, present: true)`.
  ///
  /// A missing key yields `(value: null, present: false)`: never an
  /// error, never a throw. Never mutates the map.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('ann', 91);
  /// final ({int? value, bool present}) annScore = scoresByName.get('ann');
  /// // annScore.present == true
  /// ```
  ({Value? value, bool present}) get(Key mapKey) {
    if (!_entriesByKey.containsKey(mapKey)) {
      return (value: null, present: false);
    }
    // `as Value` (never `!`): preserves a held `null` [Value] instead of
    // throwing on it.
    return (value: _entriesByKey[mapKey] as Value, present: true);
  }

  /// Removes [mapKey]; a missing key is a no-op.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a key to drop keeping order | [OrderedMap.remove] |
  ///
  /// Stdlib gap (DART-SDK): `Map.remove` mutates in place and reports the
  /// removed value as nullable; [remove] owns the ordered-holder contract
  /// instead — the surviving keys keep their order and a missing key stays
  /// a normal outcome. A re-put after [remove] takes the back.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('ann', 91);
  /// scoresByName.put('bob', 72);
  /// scoresByName.remove('ann');
  /// // scoresByName.keys() == const <String>['bob']
  /// ```
  void remove(Key mapKey) {
    _entriesByKey.remove(mapKey);
  }

  /// Counts the entries currently held.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the entry count to read | [OrderedMap.length] |
  ///
  /// Stdlib gap (DART-SDK): `Map.length` counts unordered lookup storage;
  /// [length] counts the ordered holder, mirroring the SDK noun so callers
  /// keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('ann', 91);
  /// scoresByName.put('bob', 72);
  /// // scoresByName.length == 2
  /// ```
  int get length => _entriesByKey.length;

  /// Whether the map holds no entries.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the map to test for nothing held | [OrderedMap.isEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `Map.isEmpty` tests unordered lookup storage;
  /// [isEmpty] tests the ordered holder, mirroring the SDK predicate so
  /// callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// // scoresByName.isEmpty == true
  /// ```
  bool get isEmpty => _entriesByKey.isEmpty;

  /// Whether the map holds at least one entry.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the map to test for something held | [OrderedMap.isNotEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `Map.isNotEmpty` tests unordered lookup
  /// storage; [isNotEmpty] tests the ordered holder, mirroring the SDK
  /// predicate so callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// // scoresByName.isNotEmpty == false
  /// ```
  bool get isNotEmpty => _entriesByKey.isNotEmpty;

  /// Replays the keys in first-insertion order as a fresh list.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the keys to replay in order | [OrderedMap.keys] |
  ///
  /// Stdlib gap (DART-SDK): `Map.keys` exposes a live view — mutating the
  /// map invalidates iteration; [keys] answers a fresh list, so mutating
  /// the replay never affects the map and the map may keep evolving.
  ///
  /// Returns a fresh empty list when the map is empty. Never mutates the
  /// map.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('bob', 72);
  /// scoresByName.put('ann', 91);
  /// // scoresByName.keys() == const <String>['bob', 'ann']
  /// ```
  List<Key> keys() {
    return List<Key>.of(_entriesByKey.keys);
  }

  /// Replays the values in first-insertion key order as a fresh list.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the values to replay in key order | [OrderedMap.values] |
  ///
  /// Stdlib gap (DART-SDK): `Map.values` exposes a live view with the same
  /// invalidation rule as `keys`; [values] answers a fresh list aligned
  /// with [OrderedMap.keys], so mutating the replay never affects the map.
  ///
  /// Returns a fresh empty list when the map is empty. Never mutates the
  /// map.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  /// scoresByName.put('bob', 72);
  /// scoresByName.put('ann', 91);
  /// // scoresByName.values() == const <int>[72, 91]
  /// ```
  List<Value> values() {
    return List<Value>.of(_entriesByKey.values);
  }
}

/// Holds at most [capacity] entries with least-recently-used eviction.
///
/// Every [LruCache.get] hit and every [LruCache.put] refreshes the key's
/// recency, and a [LruCache.put] beyond [capacity] evicts the
/// least-recently-used entry first. The holder mutates only its own
/// backing: constructors take no caller collections, so there is no
/// aliasing surface.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | entries to bound with recency eviction | [LruCache] |
///
/// Stdlib gap (DART-SDK): neither `LinkedHashMap` nor `SplayTreeMap` names
/// eviction — a bounded cache over the SDK is a hand-rolled remove plus a
/// recency rule every caller re-derives. [LruCache] pins that lesson once:
/// fixed capacity, refresh-on-hit, evict-least-recently-used. Fidelity
/// note (AXIOM-SISTER): mirrors Axiom `orderedmap` LRU discipline
/// (hit refreshes recency, overflow evicts least-recently-used first,
/// non-positive capacity is a programmer error) without Go signatures —
/// [ArgumentError] instead of a panic, records instead of `(V, bool)`
/// pairs, recency over the insertion-ordered SDK backing instead of
/// `container/list`.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final LruCache<String, int> recentScores = LruCache<String, int>(2);
/// recentScores.put('ann', 91);
/// recentScores.put('bob', 72);
/// recentScores.put('cid', 85);
/// // recentScores.get('ann').present == false
/// ```
final class LruCache<Key, Value> {
  /// Creates an empty recency cache holding at most [capacity] entries.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a bound to hold recent entries under | [LruCache.new] |
  ///
  /// Stdlib gap (DART-SDK): no SDK constructor names a bounded recency
  /// set, so [LruCache.new] names the capacity together with the holder.
  ///
  /// Throws an [ArgumentError] when [capacity] is below `1`: capacity is
  /// fixed at construction, so a non-positive bound is a programmer error,
  /// never a runtime condition.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// // recentScores.capacity == 2
  /// ```
  LruCache(this.capacity) {
    if (capacity <= 0) {
      throw ArgumentError.value(
        capacity,
        'capacity',
        'Must hold at least one entry.',
      );
    }
  }

  /// The bound: at most this many entries stay cached.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the cache bound to read | [LruCache.capacity] |
  ///
  /// Stdlib gap (DART-SDK): `Map.length` reports storage, never a bound;
  /// [capacity] names the eviction bound the cache enforces on every
  /// [LruCache.put].
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// // recentScores.capacity == 2
  /// ```
  final int capacity;

  final Map<Key, Value> _entriesByKey = <Key, Value>{};

  /// Returns the value held for [mapKey], refreshing its recency.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a cached key to read refreshing recency | [LruCache.get] |
  ///
  /// Stdlib gap (DART-SDK): `Map.[]` conflates a missing key with a held
  /// `null`, and no SDK read refreshes recency; [get] answers
  /// `(value, present)` in one probe and moves hits to most-recent.
  ///
  /// A missing key yields `(value: null, present: false)` and leaves
  /// recency untouched: never an error, never a throw.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// recentScores.put('ann', 91);
  /// final ({int? value, bool present}) annScore = recentScores.get('ann');
  /// // annScore.value == 91
  /// ```
  ({Value? value, bool present}) get(Key mapKey) {
    if (!_entriesByKey.containsKey(mapKey)) {
      return (value: null, present: false);
    }
    // Same present-`null` spelling as [OrderedMap.get].
    final Value heldValue = _entriesByKey[mapKey] as Value;
    _entriesByKey.remove(mapKey);
    _entriesByKey[mapKey] = heldValue;
    return (value: heldValue, present: true);
  }

  /// Adds [mapKey] with [heldValue], evicting least-recently-used first.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a cached entry to store under the bound | [LruCache.put] |
  ///
  /// Stdlib gap (DART-SDK): `Map.[]=` stores unbounded with no recency;
  /// [put] stores and refreshes, then evicts while the holder exceeds
  /// [capacity]. Storing an already-held key replaces its value and
  /// refreshes its recency without evicting.
  ///
  /// Never mutates caller inputs: the pair moves into the private backing,
  /// and no caller collection is read or written.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// recentScores.put('ann', 91);
  /// recentScores.put('bob', 72);
  /// // recentScores.length == 2
  /// ```
  void put(Key mapKey, Value heldValue) {
    if (_entriesByKey.containsKey(mapKey)) {
      _entriesByKey.remove(mapKey);
    }
    _entriesByKey[mapKey] = heldValue;
    if (_entriesByKey.length > capacity) {
      _entriesByKey.remove(_entriesByKey.keys.first);
    }
  }

  /// Counts the entries currently cached, never more than [capacity].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the cached count to read | [LruCache.length] |
  ///
  /// Stdlib gap (DART-SDK): `Map.length` counts unbounded storage; [length]
  /// counts the bounded cache, mirroring the SDK noun so callers keep one
  /// vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// recentScores.put('ann', 91);
  /// // recentScores.length == 1
  /// ```
  int get length => _entriesByKey.length;

  /// Whether the cache holds no entries.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the cache to test for nothing cached | [LruCache.isEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `Map.isEmpty` tests unbounded storage;
  /// [isEmpty] tests the bounded cache, mirroring the SDK predicate so
  /// callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// // recentScores.isEmpty == true
  /// ```
  bool get isEmpty => _entriesByKey.isEmpty;

  /// Whether the cache holds at least one entry.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the cache to test for something cached | [LruCache.isNotEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `Map.isNotEmpty` tests unbounded storage;
  /// [isNotEmpty] tests the bounded cache, mirroring the SDK predicate so
  /// callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final LruCache<String, int> recentScores = LruCache<String, int>(2);
  /// // recentScores.isNotEmpty == false
  /// ```
  bool get isNotEmpty => _entriesByKey.isNotEmpty;
}
