/// Package either holds two typed sides with neither side favoured.
///
/// Use [Either.left] to hold the first side and [Either.right] to hold the
/// second side. Neither side means success or failure here: a lock reason
/// on the left and a granted pack title on the right are both plain
/// payloads. Ask the side with [Either.isLeft], split it with [Either.when],
/// move one side forward with [Either.mapRight] and [Either.mapLeft],
/// exchange the sides with [Either.swap], or bridge into a [Result] with
/// [Either.toResult].
///
/// For a success-or-failure outcome use the `result` package; for a
/// maybe-present value use the `opt` package. For untyped branching over
/// `Object?` with `is`-checks, name the pair with [Either] instead so the
/// compiler checks every split.
///
/// | When you want to ...                  | Reach for ...     |
/// |---------------------------------------|-------------------|
/// | Hold two typed sides, neither favoured | [Either]          |
/// | Hold the first side                   | [Either.left]     |
/// | Hold the second side                  | [Either.right]    |
/// | Ask which side is held                | [Either.isLeft], [Either.isRight] |
/// | Split both sides into one outcome     | [Either.when]     |
/// | Transform the second side             | [Either.mapRight] |
/// | Transform the first side              | [Either.mapLeft]  |
/// | Exchange the two sides                | [Either.swap]     |
/// | Bridge into a [Result]                | [Either.toResult] |
library;

import 'package:praxis/src/result.dart';

/// Two typed sides with neither side favoured.
///
/// Holds exactly one side: a first-side value ([Left]) or a second-side
/// value ([Right]). Unlike [Result], neither side carries success or
/// failure meaning — both sides are plain payloads, so two values of the
/// same type stay distinguishable by side instead of collapsing into one.
///
/// Which-table:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | two typed sides, neither favoured | [Either] |
/// | a first side to wrap | [Either.left] |
/// | a second side to wrap | [Either.right] |
/// | a side to ask about | [Either.isLeft], [Either.isRight] |
/// | a pair to split into one branch per side | [Either.when] |
/// | a second side to transform while the first passes through | [Either.mapRight] |
/// | a first side to transform while the second passes through | [Either.mapLeft] |
/// | two sides to exchange | [Either.swap] |
/// | a pair to bridge into a success-or-failure outcome | [Either.toResult] |
///
/// Stdlib gap (DART-SDK): `dart:core` ships no two-type sum, so callers
/// fall back to `Object?` with hand-written `is`-checks that the compiler
/// cannot check for exhaustiveness. [Either] names both payload types, so
/// [Either.when] keeps both branches beside the type. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom's unbiased-union discipline — first side
/// versus second side with no favoured outcome, split, per-side maps,
/// swap, and a bridge into the outcome type — expressed with Dart sealed
/// types and exhaustive patterns instead of Go generics.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// final Either<String, String> granted = Either<String, String>.right(
///   'Frozen Depths',
/// );
/// final String label = granted.when(
///   onLeft: (String lockReason) => 'locked: $lockReason',
///   onRight: (String packTitle) => 'ready: $packTitle',
/// );
/// // label == 'ready: Frozen Depths'
/// ```
sealed class Either<LeftValue, RightValue> {
  const Either._();

  /// Wraps [leftValue] as the first side.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a first side to wrap | [Either.left] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` offers no named first side, so an
  /// alternate payload travels as an untyped branch beside the main value.
  /// [Either.left] pairs with [Either.right] so both sides share one type.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Either<String, int> locked = Either<String, int>.left(
  ///   'season pass missing',
  /// );
  /// // locked.isLeft == true
  /// ```
  const factory Either.left(LeftValue leftValue) = Left<LeftValue, RightValue>;

  /// Wraps [rightValue] as the second side.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a second side to wrap | [Either.right] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Either.left]; this factory is the
  /// second-side spelling so the pair reads as a named choice, never as a
  /// bare value beside an untyped alternate.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Either<String, int> granted = Either<String, int>.right(7);
  /// // granted.isRight == true
  /// ```
  const factory Either.right(RightValue rightValue) =
      Right<LeftValue, RightValue>;

  /// Whether this pair holds the first side.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a side to ask about (first?) | [Either.isLeft] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` leaves the side question to
  /// scattered `is`-checks over `Object?`. [Either.isLeft] answers it from
  /// the pair side itself.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// Either<String, int>.left('season pass missing').isLeft // true
  /// Either<String, int>.right(7).isLeft // false
  /// ```
  bool get isLeft => switch (this) {
    Left<LeftValue, RightValue>() => true,
    Right<LeftValue, RightValue>() => false,
  };

  /// Whether this pair holds the second side.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a side to ask about (second?) | [Either.isRight] |
  ///
  /// Stdlib gap (DART-SDK): the mirror of [Either.isLeft] for guard clauses
  /// that exit early on the first side; always exactly `!isLeft`.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// Either<String, int>.right(7).isRight // true
  /// Either<String, int>.left('season pass missing').isRight // false
  /// ```
  bool get isRight => switch (this) {
    Left<LeftValue, RightValue>() => false,
    Right<LeftValue, RightValue>() => true,
  };

  /// Splits this pair into one branch per side.
  ///
  /// Calls [onLeft] with the first-side value or [onRight] with the
  /// second-side value, then returns the chosen branch result. Both
  /// branches return the same [ReturnValue] type, so the split stays
  /// exhaustive and typed.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a pair to split into one branch per side | [Either.when] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` has no exhaustive two-side split,
  /// so `switch` statements over ad-hoc `Object?` shapes drift from the
  /// type. [Either.when] keeps both branches beside the type.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final String label = Either<String, int>.right(7).when(
  ///   onLeft: (String lockReason) => 'locked: $lockReason',
  ///   onRight: (int slotCount) => 'ready: $slotCount slots',
  /// );
  /// // label == 'ready: 7 slots'
  /// ```
  ReturnValue when<ReturnValue>({
    required ReturnValue Function(LeftValue leftValue) onLeft,
    required ReturnValue Function(RightValue rightValue) onRight,
  }) => switch (this) {
    Left<LeftValue, RightValue>(leftValue: final heldLeft) => onLeft(heldLeft),
    Right<LeftValue, RightValue>(rightValue: final heldRight) => onRight(
      heldRight,
    ),
  };

  /// Transforms the second-side value, carrying the first side through untouched.
  ///
  /// Applies [transform] to the second-side value and wraps the mapped
  /// value. A first-side pair keeps its original [Left.leftValue] without
  /// calling [transform].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a second side to transform while the first passes through | [Either.mapRight] |
  ///
  /// Stdlib gap (DART-SDK): `Iterable.map` transforms collections, not
  /// pair sides. [Either.mapRight] is the second-side transform, and it
  /// preserves the first side by construction. Fidelity note (AXIOM-SISTER):
  /// mirrors Axiom's right-side map, including the short-circuit.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Either<String, int> granted = Either<String, int>.right(21).mapRight(
  ///   (int slotCount) => slotCount * 2,
  /// );
  /// // granted.when(onLeft: (String lockReason) => -1, onRight: (int slotCount) => slotCount) == 42
  /// ```
  Either<LeftValue, MappedRight> mapRight<MappedRight>(
    MappedRight Function(RightValue rightValue) transform,
  ) => switch (this) {
    Left<LeftValue, RightValue>(leftValue: final heldLeft) =>
      Either<LeftValue, MappedRight>.left(heldLeft),
    Right<LeftValue, RightValue>(rightValue: final heldRight) =>
      Either<LeftValue, MappedRight>.right(transform(heldRight)),
  };

  /// Transforms the first-side value, carrying the second side through untouched.
  ///
  /// Applies [transform] to the first-side value and wraps the mapped
  /// value. A second-side pair keeps its original [Right.rightValue]
  /// without calling [transform].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a first side to transform while the second passes through | [Either.mapLeft] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Either.mapRight] for the other
  /// side — no SDK helper transforms one side of a named pair while
  /// carrying the other. Fidelity note (AXIOM-SISTER): mirrors Axiom's
  /// left-side map, including the short-circuit.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Either<String, int> locked = Either<String, int>.left(
  ///   'locked',
  /// ).mapLeft((String lockReason) => 'LEFT:$lockReason');
  /// // locked.when(onLeft: (String lockReason) => lockReason, onRight: (int slotCount) => 'unexpected') == 'LEFT:locked'
  /// ```
  Either<MappedLeft, RightValue> mapLeft<MappedLeft>(
    MappedLeft Function(LeftValue leftValue) transform,
  ) => switch (this) {
    Left<LeftValue, RightValue>(leftValue: final heldLeft) =>
      Either<MappedLeft, RightValue>.left(transform(heldLeft)),
    Right<LeftValue, RightValue>(rightValue: final heldRight) =>
      Either<MappedLeft, RightValue>.right(heldRight),
  };

  /// Exchanges the two sides of this pair.
  ///
  /// A first-side pair becomes a second-side pair holding the same payload,
  /// and a second-side pair becomes a first-side pair holding the same
  /// payload. Swapping twice returns to the original sides.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | two sides to exchange | [Either.swap] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` has no named pair to exchange, so
  /// callers rebuild ad-hoc shapes by hand. [Either.swap] re-sides the
  /// payload without touching it. Fidelity note (AXIOM-SISTER): mirrors
  /// Axiom's side exchange, including the double-swap round trip.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Either<int, String> swapped = Either<String, int>.left(
  ///   'locked',
  /// ).swap();
  /// // swapped.isRight == true
  /// ```
  Either<RightValue, LeftValue> swap() => switch (this) {
    Left<LeftValue, RightValue>(leftValue: final heldLeft) =>
      Either<RightValue, LeftValue>.right(heldLeft),
    Right<LeftValue, RightValue>(rightValue: final heldRight) =>
      Either<RightValue, LeftValue>.left(heldRight),
  };

  /// Bridges this pair into a success-or-failure [Result].
  ///
  /// A second-side pair becomes `Ok` holding its value. A first-side pair
  /// becomes `Failure` holding the cause that [failureOf] builds from the
  /// first-side value; [failureOf] never runs on the second side.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a pair to bridge into a success-or-failure outcome | [Either.toResult] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` has no pair-to-outcome bridge, so
  /// callers branch by hand at every fallible boundary. [Either.toResult]
  /// names the crossing once. Fidelity note (AXIOM-SISTER): mirrors Axiom's
  /// bridge into the outcome type with the same caller-supplied mapping.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Result<int> outcome = Either<String, int>.right(7).toResult(
  ///   (String lockReason) => Exception(lockReason),
  /// );
  /// // outcome.getOrElse(0) == 7
  /// ```
  Result<RightValue> toResult(
    Exception Function(LeftValue leftValue) failureOf,
  ) => switch (this) {
    Left<LeftValue, RightValue>(leftValue: final heldLeft) =>
      Result<RightValue>.failure(failureOf(heldLeft)),
    Right<LeftValue, RightValue>(rightValue: final heldRight) =>
      Result<RightValue>.ok(heldRight),
  };
}

/// The first side of an [Either].
///
/// Created through [Either.left]; [Either.mapRight] carries its [leftValue]
/// through untouched while [Either.mapLeft] moves it forward.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a first side to carry | [Left] |
///
/// Stdlib gap (DART-SDK): `dart:core` has no named first side, so the
/// alternate payload stays invisible inside bare values. [Left] names the
/// side with its type. Fidelity note (AXIOM-SISTER): the first-side half
/// of Axiom's unbiased pair, expressed as a Dart sealed-family member.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// const Left<String, int>('season pass missing').leftValue // 'season pass missing'
/// ```
final class Left<LeftValue, RightValue> extends Either<LeftValue, RightValue> {
  /// Creates a first-side pair holding [leftValue].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a first side to construct directly | [Left.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Either.left]; this constructor is
  /// the direct spelling for pattern-matching and constant contexts.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Left<String, int>('season pass missing').isLeft // true
  /// ```
  const Left(this.leftValue) : super._();

  /// The first-side value.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a first-side pair to unwrap | [Left.leftValue] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` unwraps alternates through casts
  /// and `!` assertions. [Left.leftValue] reads the value the pair already
  /// proved is held.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Left<String, int>('season pass missing').leftValue // 'season pass missing'
  /// ```
  final LeftValue leftValue;

  /// Whether [other] is a [Left] holding an equal value.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Left<LeftValue, RightValue> && other.leftValue == leftValue);

  /// Hash code matching [==].
  @override
  int get hashCode => leftValue.hashCode;

  /// Renders as `Left(leftValue)` for debugging.
  @override
  String toString() => 'Left($leftValue)';
}

/// The second side of an [Either].
///
/// Created through [Either.right]; [Either.mapLeft] carries its
/// [rightValue] through untouched while [Either.mapRight] moves it forward.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a second side to carry | [Right] |
///
/// Stdlib gap (DART-SDK): `dart:core` has no named second side, so the
/// favoured payload stays invisible inside bare values. [Right] names the
/// side with its type. Fidelity note (AXIOM-SISTER): the second-side half
/// of Axiom's unbiased pair, expressed as a Dart sealed-family member.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// const Right<String, int>(7).rightValue // 7
/// ```
final class Right<LeftValue, RightValue> extends Either<LeftValue, RightValue> {
  /// Creates a second-side pair holding [rightValue].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a second side to construct directly | [Right.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Either.right]; this constructor
  /// is the direct spelling for pattern-matching and constant contexts.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Right<String, int>(7).isRight // true
  /// ```
  const Right(this.rightValue) : super._();

  /// The second-side value.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a second-side pair to unwrap | [Right.rightValue] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Left.leftValue] for the other
  /// side — the pair already proved which value is held, so no cast is
  /// needed to read it.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Right<String, int>(7).rightValue // 7
  /// ```
  final RightValue rightValue;

  /// Whether [other] is a [Right] holding an equal value.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Right<LeftValue, RightValue> && other.rightValue == rightValue);

  /// Hash code matching [==].
  @override
  int get hashCode => rightValue.hashCode;

  /// Renders as `Right(rightValue)` for debugging.
  @override
  String toString() => 'Right($rightValue)';
}
