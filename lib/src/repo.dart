/// Identity-keyed in-memory record store with typed access.
///
/// Reach for this when a [Map] names the storage but not the lifecycle:
/// [Repository] holds one record per identity, [Repository.put] stores or
/// replaces under the extracted identity, [Repository.get] reads through
/// [Opt] so a missing identity is absence instead of a throw,
/// [Repository.remove] drops one identity and reports whether it was held,
/// and [Repository.list] returns a fresh snapshot per call. Identity comes
/// from the caller-supplied [keyOf] extractor, never from the record type
/// itself, so `String` slugs and `int` numbers address records the same way.
///
/// Which function?
///
/// | When you want to ...                            | Reach for ...      |
/// | ----------------------------------------------- | ------------------ |
/// | Hold one key space of identity-addressed records | [Repository]       |
/// | Store or replace the record under its identity  | [Repository.put]   |
/// | Read the record as present-or-absent            | [Repository.get]   |
/// | Drop one identity, reporting what was held      | [Repository.remove] |
/// | Read a fresh snapshot of every stored record    | [Repository.list]  |
///
/// Out of scope by design: persistence (a future adapter slice owns it,
/// never this in-memory store), paging and queries (callers slice the
/// [Repository.list] snapshot; a `Page` convention belongs to a future
/// adapter slice), and identity validation (any constructed identity is
/// addressable; validity is caller domain policy, never store policy).
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

import 'package:praxis/src/opt.dart';

/// Holds one record per identity behind a caller-supplied extractor.
///
/// The store is caller-owned mutable state: [put] stores or replaces under
/// the identity [keyOf] extracts, [get] reads through [Opt] so a missing
/// identity is absence instead of a throw, [remove] drops one identity and
/// reports whether it was held, and [list] returns a fresh snapshot per
/// call in insertion order. There is no shared registry: tests create a
/// fresh store per test instead of sharing one.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | identity-addressed records | [Repository] |
///
/// Stdlib gap (DART-SDK): [Map] names keyed storage but no identity
/// lifecycle — no extracted-identity rule, no upsert-vs-reject policy, no
/// absent-instead-of-throw read, no snapshot discipline — so [Repository]
/// owns that lifecycle as a hand-rolled slot table over an SDK map, never
/// a reimplementation. Fidelity note (AXIOM-SISTER): mirrors Axiom's `repo`
/// discipline (identity-keyed records, `keyOf` extraction, upsert store,
/// per-test stores) without Go signatures: [Opt] instead of
/// `(Record, error)`, `bool` instead of `ErrRecordNotFound` on remove, and
/// a full fresh snapshot instead of pages — paging belongs to a future
/// adapter slice, never here.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Repository<String, String> lessonStore = Repository<String, String>(
///   keyOf: (String candidate) => candidate,
/// );
/// lessonStore.put('lesson-a');
/// // lessonStore.get('lesson-a').isPresent == true
/// ```
final class Repository<StoredRecord extends Object, Identity extends Object> {
  /// Creates an empty store keyed by [keyOf].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an empty key space to fill with identity-addressed records | [Repository.new] |
  ///
  /// Stdlib gap (DART-SDK): no SDK constructor names an
  /// extracted-identity lifecycle, so [Repository.new] names the empty slot
  /// table that [Repository.put] fills entry by entry. Fidelity note
  /// (AXIOM-SISTER): mirrors Axiom's `NewMemoryRepository` without Go
  /// signatures — a `null`-extractor guard is YAGNI-killed here with a
  /// reason: sound null safety makes it unrepresentable, since [keyOf] is
  /// a non-nullable function the compiler already rejects as `null`.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Repository<String, String> lessonStore = Repository<String, String>(
  ///   keyOf: (String candidate) => candidate,
  /// );
  /// lessonStore.put('lesson-a');
  /// // lessonStore.get('lesson-a').isPresent == true
  /// ```
  // `this._keyOf` would privatize the public `keyOf` parameter, which
  // external callers could no longer pass.
  Repository({required Identity Function(StoredRecord candidate) keyOf})
    : _keyOf = keyOf; // ignore: prefer_initializing_formals

  final Identity Function(StoredRecord candidate) _keyOf;
  final Map<Identity, StoredRecord> _recordsById = <Identity, StoredRecord>{};

  /// Stores [candidate] under its extracted identity, replacing any record.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a record to store or replace under its identity | [Repository.put] |
  ///
  /// Stdlib gap (DART-SDK): [Map.operator []=] stores under a caller-held
  /// key but never extracts the identity — no `keyOf` rule, no stated
  /// duplicate policy — so [put] owns the extract-then-upsert rule.
  /// Fidelity note (AXIOM-SISTER): mirrors Axiom's `Store` overwrite rule
  /// without Go signatures: a duplicate put replaces and keeps one entry
  /// per identity, so [put] stays total and never throws for duplicates.
  /// A reject-on-duplicate branch is YAGNI-killed here with a reason: the
  /// single upsert path already covers re-seeds and retries with no halfway
  /// state to specify.
  ///
  /// Replacing keeps the original listing position: [list] still reports
  /// the identity where it was first stored.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Repository<String, String> lessonStore = Repository<String, String>(
  ///   keyOf: (String candidate) => candidate,
  /// );
  /// lessonStore.put('lesson-a');
  /// lessonStore.put('lesson-a');
  /// // lessonStore.list().length == 1
  /// ```
  void put(StoredRecord candidate) {
    _recordsById[_keyOf(candidate)] = candidate;
  }

  /// Reads the record held under [recordId] as present-or-absent.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an identity to read without throwing when missing | [Repository.get] |
  ///
  /// Stdlib gap (DART-SDK): [Map.operator []] reads nullable values that
  /// conflate "lookup ran, slot empty" with "lookup never ran". [get]
  /// answers the presence flag through [Opt] instead: a missing identity
  /// reads as absent, never as a throw. Fidelity note (AXIOM-SISTER):
  /// mirrors Axiom's `Fetch` missing contract and the thesis `(value,
  /// present)` absence record (ARCHITECTURE frozen decision 2) — [Opt.split]
  /// carries that exact pair, so callers never trust the value without the
  /// flag.
  ///
  /// Never throws for a missing identity: absence is a normal outcome here,
  /// never a failure.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Repository<String, String> lessonStore = Repository<String, String>(
  ///   keyOf: (String candidate) => candidate,
  /// );
  /// lessonStore.put('lesson-a');
  /// final Opt<String> fetchedLesson = lessonStore.get('lesson-a');
  /// // fetchedLesson.isPresent == true
  /// ```
  Opt<StoredRecord> get(Identity recordId) {
    final StoredRecord? foundRecord = _recordsById[recordId];
    if (foundRecord == null) {
      return Opt<StoredRecord>.absent();
    }
    return Opt<StoredRecord>.present(foundRecord);
  }

  /// Drops the record held under [recordId], reporting what was held.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an identity to drop, learning whether it was held | [Repository.remove] |
  ///
  /// Stdlib gap (DART-SDK): [Map.remove] returns the dropped nullable value,
  /// which conflates a held `null` with absence. [remove] reports the
  /// presence flag as a `bool` instead: `true` when a record was dropped,
  /// `false` when nothing was held. Fidelity note (AXIOM-SISTER): mirrors
  /// Axiom's `Remove` missing contract without Go signatures — a missing
  /// identity reports `false` instead of `ErrRecordNotFound`, so removal
  /// stays idempotent and never throws for absence.
  ///
  /// Removing then re-storing lists the identity at the end: the drop
  /// releases its original listing position.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Repository<String, String> lessonStore = Repository<String, String>(
  ///   keyOf: (String candidate) => candidate,
  /// );
  /// lessonStore.put('lesson-a');
  /// final bool droppedLesson = lessonStore.remove('lesson-a');
  /// // droppedLesson == true
  /// ```
  bool remove(Identity recordId) {
    if (!_recordsById.containsKey(recordId)) {
      return false;
    }
    _recordsById.remove(recordId);
    return true;
  }

  /// Returns a fresh snapshot holding every stored record.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | every stored record as an independent snapshot | [Repository.list] |
  ///
  /// Stdlib gap (DART-SDK): [Map.values] views live storage, so holding the
  /// view leaks later puts into earlier reads. [list] copies into a fresh
  /// growable list per call instead: mutating the snapshot never touches
  /// the store, and later puts never rewrite an earlier snapshot.
  /// Fidelity note (AXIOM-SISTER): mirrors Axiom's per-call collection
  /// without Go signatures — and states the one honest difference:
  /// insertion order is pinned here (the SDK map guarantees it) where Go
  /// maps randomize, so callers may rely on first-stored-first-listed.
  ///
  /// An empty store lists an empty snapshot, never `null`.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Repository<String, String> lessonStore = Repository<String, String>(
  ///   keyOf: (String candidate) => candidate,
  /// );
  /// lessonStore.put('lesson-a');
  /// lessonStore.put('lesson-b');
  /// final List<String> listedLessons = lessonStore.list();
  /// // listedLessons.length == 2
  /// ```
  List<StoredRecord> list() => List<StoredRecord>.of(_recordsById.values);
}
