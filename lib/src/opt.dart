/// Package opt holds a typed absent-or-present value.
///
/// Use [Opt.present] to hold a value and [Opt.absent] for absence.
/// [Opt.valueOr] reads with an explicit fallback, [Opt.mapValue] transforms
/// the held value while carrying absence through untouched, and [Opt.andThen]
/// chains to the next [Opt]. Absence is a normal outcome here, never a
/// failure: for failures with a cause, see the `result` package.
///
/// | When you want to ...               | Reach for ...        |
/// |------------------------------------|----------------------|
/// | Hold a present value               | [Opt.present]        |
/// | Express absence                    | [Opt.absent]         |
/// | Ask whether a value is held        | [Opt.isPresent]      |
/// | Ask whether nothing is held        | [Opt.isAbsent]       |
/// | Split to the `(value, present)` record | [Opt.split]      |
/// | Transform the held value           | [Opt.mapValue]       |
/// | Chain to the next [Opt]            | [Opt.andThen]        |
/// | Read with an explicit fallback     | [Opt.valueOr]        |
/// | Read with a lazy fallback          | [Opt.valueOrElse]    |
/// | Fall back to another [Opt]         | [Opt.orElse]         |
library;

/// Typed absent-or-present value.
///
/// The sealed [Some]/[None] hierarchy keeps every split exhaustive: the
/// compiler rejects a `switch` that forgets one side, so absence can never
/// slip past silently.
///
/// | When you want to ...         | Reach for ...   |
/// |------------------------------|-----------------|
/// | Hold or miss a typed value   | [Opt]           |
///
/// Stdlib gap (DART-SDK, AXIOM-SISTER): nullable `Held?` erases the checked
/// presence discipline — a bare `null` cannot say whether the lookup ran or
/// the slot was empty. [Opt] mirrors Axiom's `(T, bool)` OrNull contract
/// (AXIOM-SISTER) as a chainable value: the presence flag travels with the
/// value, and the combinators below carry absence through without running.
///
/// ```dart
/// const current = Opt.present(4);
///
/// assert(current.isPresent);
/// assert(current.valueOr(0) == 4);
/// assert(const Opt<int>.absent().valueOr(9) == 9);
/// ```
sealed class Opt<Held> {
  /// Shares the const canonicalization of [Some] and [None].
  const Opt._();

  /// Creates a present [Opt] holding [heldValue].
  ///
  /// | When you want to ...   | Reach for ...  |
  /// |-------------------------|----------------|
  /// | Hold a present value    | [Opt.present]  |
  ///
  /// Stdlib gap (DART-SDK): the SDK offers nullable `Held?` but no typed
  /// present wrapper; [Opt.present] names the present side so `switch`
  /// splits and combinators can rely on it.
  ///
  /// ```dart
  /// const current = Opt.present(4);
  ///
  /// assert(current.isPresent);
  /// assert(current.valueOr(0) == 4);
  /// ```
  const factory Opt.present(Held heldValue) = Some<Held>;

  /// Creates an absent [Opt] holding nothing.
  ///
  /// | When you want to ...   | Reach for ... |
  /// |-------------------------|---------------|
  /// | Express absence         | [Opt.absent]  |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): a bare `null` cannot distinguish
  /// "lookup ran, slot empty" from "lookup never ran". [Opt.absent] names
  /// absence as a typed value that combinators carry through untouched.
  ///
  /// ```dart
  /// const missing = Opt<int>.absent();
  ///
  /// assert(missing.isAbsent);
  /// assert(missing.valueOr(9) == 9);
  /// ```
  const factory Opt.absent() = None<Held>;

  /// Whether this [Opt] holds a value.
  ///
  /// | When you want to ...            | Reach for ...   |
  /// |---------------------------------|-----------------|
  /// | Ask whether a value is held     | [Opt.isPresent] |
  ///
  /// Stdlib gap (DART-SDK): nullable `Held?` forces a `null` check that
  /// cannot tell present-null apart from absence. [isPresent] reports the
  /// flag, never the value.
  ///
  /// ```dart
  /// assert(const Opt.present(4).isPresent);
  /// assert(!const Opt<int>.absent().isPresent);
  /// ```
  bool get isPresent;

  /// Whether this [Opt] holds nothing.
  ///
  /// | When you want to ...            | Reach for ...  |
  /// |---------------------------------|----------------|
  /// | Ask whether nothing is held       | [Opt.isAbsent] |
  ///
  /// Stdlib gap (DART-SDK): the mirror of [Opt.isPresent] for guard clauses
  /// that exit early on absence; always exactly `!isPresent`.
  ///
  /// ```dart
  /// assert(!const Opt.present(4).isAbsent);
  /// assert(const Opt<int>.absent().isAbsent);
  /// ```
  bool get isAbsent => !isPresent;

  /// Splits this [Opt] into the `(heldValue, presentFlag)` record.
  ///
  /// | When you want to ...                          | Reach for ... |
  /// |-----------------------------------------------|---------------|
  /// | Split to the `(value, present)` record        | [Opt.split]   |
  ///
  /// Stdlib gap (AXIOM-SISTER): mirrors Axiom's `(T, bool)` OrNull pins
  /// exactly (ARCHITECTURE frozen decision 2). Never trust the value
  /// without the flag: a present `null` still reports `true`.
  ///
  /// ```dart
  /// final (heldValue, presentFlag) = const Opt.present(4).split;
  /// assert(presentFlag && heldValue == 4);
  ///
  /// final (absentValue, absentFlag) = const Opt<int>.absent().split;
  /// assert(!absentFlag && absentValue == null);
  /// ```
  (Held?, bool) get split;

  /// Transforms the held value, carrying absence through untouched.
  ///
  /// | When you want to ...            | Reach for ...  |
  /// |---------------------------------|----------------|
  /// | Transform the held value        | [Opt.mapValue] |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): the SDK maps collections, never a
  /// maybe-present scalar. [mapValue] mirrors Axiom's `MapValue`, including
  /// the short-circuit: [transform] never runs on absence.
  ///
  /// ```dart
  /// final mapped = const Opt.present(4).mapValue(
  ///   (heldValue) => heldValue + 1,
  /// );
  /// assert(mapped.valueOr(0) == 5);
  ///
  /// final carried = const Opt<int>.absent().mapValue(
  ///   (heldValue) => heldValue + 1,
  /// );
  /// assert(carried.isAbsent);
  /// ```
  Opt<Transformed> mapValue<Transformed>(
    Transformed Function(Held heldValue) transform,
  );

  /// Chains the held value to the next [Opt].
  ///
  /// | When you want to ...            | Reach for ... |
  /// |---------------------------------|---------------|
  /// | Chain to the next [Opt]         | [Opt.andThen] |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): the SDK has no flat-mapping bind
  /// for a maybe-present scalar. [andThen] mirrors Axiom's `AndThen`:
  /// absence short-circuits, so [transform] never runs on [None].
  ///
  /// ```dart
  /// final chained = const Opt.present(4).andThen(
  ///   (heldValue) => Opt.present('bound $heldValue'),
  /// );
  /// assert(chained.valueOr('missing') == 'bound 4');
  ///
  /// final carried = const Opt<int>.absent().andThen(
  ///   (heldValue) => Opt.present('$heldValue'),
  /// );
  /// assert(carried.isAbsent);
  /// ```
  Opt<Transformed> andThen<Transformed>(
    Opt<Transformed> Function(Held heldValue) transform,
  );

  /// Returns the held value, or [fallback] when absent.
  ///
  /// | When you want to ...                | Reach for ... |
  /// |-------------------------------------|---------------|
  /// | Read with an explicit fallback      | [Opt.valueOr] |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): the `??` operator reads nullable
  /// `Held?` but cannot distinguish present-null from absence. [valueOr]
  /// answers the presence flag, so `Opt.present(null)` never takes
  /// [fallback]. Mirrors Axiom's `ValueOr`.
  ///
  /// ```dart
  /// assert(const Opt.present(4).valueOr(9) == 4);
  /// assert(const Opt<int>.absent().valueOr(9) == 9);
  /// ```
  Held valueOr(Held fallback);

  /// Returns the held value, or the outcome of [fallback] when absent.
  ///
  /// | When you want to ...                | Reach for ...     |
  /// |-------------------------------------|-------------------|
  /// | Read with a lazy fallback           | [Opt.valueOrElse] |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): mirrors Axiom's `ValueOrElse`.
  /// [fallback] runs lazily: it never runs when this [Opt] is present, so
  /// expensive defaults cost nothing on the happy path.
  ///
  /// ```dart
  /// assert(const Opt.present(5).valueOrElse(() => 9) == 5);
  /// assert(const Opt<int>.absent().valueOrElse(() => 9) == 9);
  /// ```
  Held valueOrElse(Held Function() fallback);

  /// Returns this [Opt] when present, otherwise [fallback].
  ///
  /// | When you want to ...                | Reach for ... |
  /// |-------------------------------------|---------------|
  /// | Fall back to another [Opt]          | [Opt.orElse]  |
  ///
  /// Stdlib gap (DART-SDK, AXIOM-SISTER): mirrors Axiom's `OrElse` — the
  /// first present side wins, and absence plus absence stays absent.
  ///
  /// ```dart
  /// final kept = const Opt.present(1).orElse(const Opt.present(2));
  /// assert(kept.valueOr(0) == 1);
  ///
  /// final taken = const Opt<int>.absent().orElse(const Opt.present(2));
  /// assert(taken.valueOr(0) == 2);
  /// ```
  Opt<Held> orElse(Opt<Held> fallback);
}

/// Present [Opt] holding one typed value.
///
/// | When you want to ...             | Reach for ... |
/// |----------------------------------|-----------------|
/// | Hold a present value directly    | [Some.new]      |
///
/// Stdlib gap (DART-SDK): the SDK has no named present case to split on;
/// [Some] gives `switch` a branch the compiler checks for exhaustiveness.
///
/// ```dart
/// const current = Some<int>(4);
///
/// assert(current.isPresent);
/// assert(current.valueOr(0) == 4);
/// ```
final class Some<Held> extends Opt<Held> {
  /// Creates a present [Opt] holding [heldValue].
  const Some(this.heldValue) : super._();

  /// The held value.
  ///
  /// Prefer [Opt.split] or a `switch` over reading this directly: the field
  /// alone cannot prove presence to the reader.
  final Held heldValue;

  /// Whether a value is held. Always true for [Some].
  @override
  bool get isPresent => true;

  /// Splits into the `(heldValue, presentFlag)` record. Always true here.
  @override
  (Held?, bool) get split => (heldValue, true);

  /// Transforms [heldValue] with [transform].
  @override
  Opt<Transformed> mapValue<Transformed>(
    Transformed Function(Held heldValue) transform,
  ) => Some<Transformed>(transform(heldValue));

  /// Chains [heldValue] through [transform].
  @override
  Opt<Transformed> andThen<Transformed>(
    Opt<Transformed> Function(Held heldValue) transform,
  ) => transform(heldValue);

  /// Returns [heldValue]. Never takes [fallback].
  @override
  Held valueOr(Held fallback) => heldValue;

  /// Returns [heldValue]. Never runs [fallback].
  @override
  Held valueOrElse(Held Function() fallback) => heldValue;

  /// Returns this [Some]. Never takes [fallback].
  @override
  Opt<Held> orElse(Opt<Held> fallback) => this;

  /// Whether [other] is a [Some] holding an equal value.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Some<Held> && other.heldValue == heldValue);

  /// Hash code matching [==].
  @override
  int get hashCode => heldValue.hashCode;

  /// Renders as `Some(heldValue)` for debugging.
  @override
  String toString() => 'Some($heldValue)';
}

/// Absent [Opt] holding nothing.
///
/// | When you want to ...             | Reach for ... |
/// |----------------------------------|-----------------|
/// | Express absence directly         | [None.new]      |
///
/// Stdlib gap (DART-SDK): the SDK has no named absent case to split on;
/// [None] gives `switch` a branch the compiler checks for exhaustiveness.
///
/// ```dart
/// const missing = None<int>();
///
/// assert(missing.isAbsent);
/// assert(missing.valueOr(9) == 9);
/// ```
final class None<Held> extends Opt<Held> {
  /// Creates an absent [Opt] holding nothing.
  const None() : super._();

  /// Whether a value is held. Always false for [None].
  @override
  bool get isPresent => false;

  /// Splits into the `(heldValue, presentFlag)` record. Always null plus
  /// false here.
  @override
  (Held?, bool) get split => (null, false);

  /// Carries absence through. Never runs [transform].
  @override
  Opt<Transformed> mapValue<Transformed>(
    Transformed Function(Held heldValue) transform,
  ) => None<Transformed>();

  /// Carries absence through. Never runs [transform].
  @override
  Opt<Transformed> andThen<Transformed>(
    Opt<Transformed> Function(Held heldValue) transform,
  ) => None<Transformed>();

  /// Returns [fallback]. Nothing is held.
  @override
  Held valueOr(Held fallback) => fallback;

  /// Runs [fallback] and returns its outcome. Nothing is held.
  @override
  Held valueOrElse(Held Function() fallback) => fallback();

  /// Returns [fallback]. Nothing is held.
  @override
  Opt<Held> orElse(Opt<Held> fallback) => fallback;

  /// Whether [other] is an absent [None] of the same held type.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is None<Held>;

  /// Hash code matching [==].
  @override
  int get hashCode => 0;

  /// Renders as `None()` for debugging.
  @override
  String toString() => 'None()';
}
