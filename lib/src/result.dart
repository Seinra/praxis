/// Package result holds a typed success-or-failure outcome.
///
/// Use [Result.ok] to wrap a success and [Result.failure] to wrap a failure
/// cause. Ask the side with [Result.isOk], split it with [Result.when], or
/// move it forward with [Result.mapValue] and [Result.andThen]. Failures
/// carry their cause through untouched.
///
/// | When you want to ...              | Reach for ...    |
/// |------------------------------------|------------------|
/// | Hold a success-or-failure outcome  | [Result]         |
/// | Wrap a success value               | [Result.ok]      |
/// | Wrap a failure cause               | [Result.failure] |
library;

/// A typed success-or-failure outcome.
///
/// Holds either a success value ([Ok]) or a failure cause ([Failure]), so
/// fallible work returns its outcome instead of throwing across API
/// boundaries. Ask the side with [Result.isOk] or [Result.isFailure], split
/// it with [Result.when], or move it forward with [Result.mapValue] and
/// [Result.andThen].
///
/// Which-table:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a success-or-failure outcome | [Result] |
/// | a success value to wrap | [Result.ok] |
/// | a failure cause to wrap | [Result.failure] |
/// | a side to ask about | [Result.isOk], [Result.isFailure] |
/// | an outcome to split into one branch per side | [Result.when] |
/// | an outcome to read with a backup value | [Result.getOrElse] |
/// | a success to transform while failures pass through | [Result.mapValue] |
/// | a success to chain into the next outcome | [Result.andThen] |
///
/// Stdlib gap (DART-SDK): `dart:core` ships no success-or-failure sum type,
/// so callers fall back to throwing, to nullable returns that conflate
/// missing with failed, or to ad-hoc tuples. [Result] names both sides with
/// types, so the compiler keeps the failure path visible. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom's typed-outcome discipline with Dart sealed
/// types and exhaustive patterns.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// final Result<int> outcome = Result<int>.ok(21);
/// final int answer = outcome.getOrElse(0);
/// // answer == 21
/// ```
sealed class Result<OutcomeValue> {
  const Result._();

  /// Wraps [successValue] as a success outcome.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a success value to wrap | [Result.ok] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` offers no typed success wrapper, so
  /// successes travel as bare values beside throwing failure paths.
  /// [Result.ok] pairs with [Result.failure] so both sides share one type.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Result<int> outcome = Result<int>.ok(21);
  /// // outcome.isOk == true
  /// ```
  const factory Result.ok(OutcomeValue successValue) = Ok<OutcomeValue>;

  /// Wraps [failureCause] as a failure outcome.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a failure cause to wrap | [Result.failure] |
  ///
  /// Stdlib gap (DART-SDK): failures usually travel as thrown objects that
  /// skip return types, so callers cannot see them. [Result.failure] keeps
  /// the failure inside the type so callers handle it.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Result<int> outcome = Result<int>.failure(Exception('offline'));
  /// // outcome.isFailure == true
  /// ```
  const factory Result.failure(Exception failureCause) = Failure<OutcomeValue>;

  /// Whether this outcome holds success.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a side to ask about (success?) | [Result.isOk] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` leaves the success question to
  /// `null` checks and scattered `is` tests. [Result.isOk] answers it from
  /// the outcome side itself.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// Result<int>.ok(1).isOk // true
  /// Result<int>.failure(Exception('offline')).isOk // false
  /// ```
  bool get isOk => switch (this) {
    Ok<OutcomeValue>() => true,
    Failure<OutcomeValue>() => false,
  };

  /// Whether this outcome holds failure.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a side to ask about (failure?) | [Result.isFailure] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` leaves the failure question to
  /// `try`/`catch` handling at a distance. [Result.isFailure] answers it
  /// from the outcome side itself.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// Result<int>.failure(Exception('offline')).isFailure // true
  /// Result<int>.ok(1).isFailure // false
  /// ```
  bool get isFailure => switch (this) {
    Ok<OutcomeValue>() => false,
    Failure<OutcomeValue>() => true,
  };

  /// Splits this outcome into one branch per side.
  ///
  /// Calls [ok] with the success value or [failure] with the failure cause,
  /// then returns the chosen branch result. Both branches return the same
  /// [ReturnValue] type, so the split stays exhaustive and typed.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outcome to split into one branch per side | [Result.when] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` has no exhaustive outcome split, so
  /// `switch` statements over ad-hoc shapes drift from the type. [Result.when]
  /// keeps both branches beside the type.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final String label = Result<int>.ok(3).when(
  ///   ok: (int successValue) => 'ok:$successValue',
  ///   failure: (Exception failureCause) => 'failure',
  /// );
  /// // label == 'ok:3'
  /// ```
  ReturnValue when<ReturnValue>({
    required ReturnValue Function(OutcomeValue successValue) ok,
    required ReturnValue Function(Exception failureCause) failure,
  }) => switch (this) {
    Ok<OutcomeValue>(value: final successValue) => ok(successValue),
    Failure<OutcomeValue>(cause: final failureCause) => failure(failureCause),
  };

  /// Reads the success value, falling back to [fallbackValue] on failure.
  ///
  /// Never throws for a failure outcome; a success value passes through
  /// untouched.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outcome to read with a backup value | [Result.getOrElse] |
  ///
  /// Stdlib gap (DART-SDK): nullable reads with `??` conflate missing with
  /// failed. [Result.getOrElse] substitutes only on the failure side.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// Result<int>.ok(7).getOrElse(0); // 7
  /// Result<int>.failure(Exception('offline')).getOrElse(0); // 0
  /// ```
  OutcomeValue getOrElse(OutcomeValue fallbackValue) => switch (this) {
    Ok<OutcomeValue>(value: final successValue) => successValue,
    Failure<OutcomeValue>() => fallbackValue,
  };

  /// Transforms the success value, carrying failures through untouched.
  ///
  /// Applies [transform] to the success value and wraps the mapped value. A
  /// failure outcome keeps its original [Failure.cause] instance without
  /// calling [transform].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a success to transform while failures pass through | [Result.mapValue] |
  ///
  /// Stdlib gap (DART-SDK): `Iterable.map` transforms collections, not
  /// outcomes. [Result.mapValue] is the outcome-level transform, and it
  /// preserves the failure side by construction.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Result<int> doubled = Result<int>.ok(21).mapValue(
  ///   (int successValue) => successValue * 2,
  /// );
  /// // doubled.getOrElse(0) == 42
  /// ```
  Result<MappedValue> mapValue<MappedValue>(
    MappedValue Function(OutcomeValue successValue) transform,
  ) => switch (this) {
    Ok<OutcomeValue>(value: final successValue) => Result<MappedValue>.ok(
      transform(successValue),
    ),
    Failure<OutcomeValue>(cause: final failureCause) =>
      Result<MappedValue>.failure(failureCause),
  };

  /// Chains this outcome into the next outcome.
  ///
  /// Runs [next] on the success value and returns its outcome. A failure
  /// outcome short-circuits: [next] never runs and the original
  /// [Failure.cause] instance carries into the chained outcome.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a success to chain into the next outcome | [Result.andThen] |
  ///
  /// Stdlib gap (DART-SDK): `Future.then` chains asynchronous values, but
  /// synchronous outcomes have no chain. [Result.andThen] sequences fallible
  /// steps without `try`/`catch` at call sites.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Result<int> chained = Result<int>.ok(21).andThen(
  ///   (int successValue) => Result<int>.ok(successValue + 1),
  /// );
  /// // chained.getOrElse(0) == 22
  /// ```
  Result<ChainedValue> andThen<ChainedValue>(
    Result<ChainedValue> Function(OutcomeValue successValue) next,
  ) => switch (this) {
    Ok<OutcomeValue>(value: final successValue) => next(successValue),
    Failure<OutcomeValue>(cause: final failureCause) =>
      Result<ChainedValue>.failure(failureCause),
  };
}

/// The success side of a [Result].
///
/// Created through [Result.ok]; [Result.mapValue] and [Result.andThen] move
/// its [value] forward while [Failure] outcomes pass through untouched.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a success value to carry | [Ok] |
///
/// Stdlib gap (DART-SDK): `dart:core` has no named success side, so successes
/// stay invisible inside bare values. [Ok] names the side with its type.
/// Fidelity note (AXIOM-SISTER): the success half of Axiom's typed-outcome
/// pair, expressed as a Dart sealed-family member.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// const Ok<int>(21).value // 21
/// ```
final class Ok<OutcomeValue> extends Result<OutcomeValue> {
  /// Creates a success outcome holding [value].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a success value to construct directly | [Ok.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Result.ok]; this constructor is the
  /// direct spelling for pattern-matching and constant contexts.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Ok<int>(21).value // 21
  /// ```
  const Ok(this.value) : super._();

  /// The success value.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a success outcome to unwrap | [Ok.value] |
  ///
  /// Stdlib gap (DART-SDK): `dart:core` unwraps through casts and `!`
  /// assertions. [Ok.value] reads the value the outcome already proved
  /// present.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const Ok<int>(21).value // 21
  /// ```
  final OutcomeValue value;

  /// Whether [other] is an [Ok] holding an equal value.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ok<OutcomeValue> && other.value == value);

  /// Hash code matching [==].
  @override
  int get hashCode => value.hashCode;

  /// Renders as `Ok(value)` for debugging.
  @override
  String toString() => 'Ok($value)';
}

/// The failure side of a [Result].
///
/// Created through [Result.failure]; its [cause] travels through
/// [Result.mapValue] and [Result.andThen] untouched.
///
/// Cause type note (DART-SDK): [Exception] is the only failure value by
/// design — callers with codes or ADTs wrap them in an [Exception];
/// generalizing the cause type stays a future ODD with a migration note.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a failure cause to carry | [Failure] |
///
/// Stdlib gap (DART-SDK): `dart:core` carries failures as thrown objects
/// outside the type. [Failure] keeps the cause inside the outcome with its
/// type. Fidelity note (AXIOM-SISTER): the failure half of Axiom's
/// typed-outcome pair, expressed as a Dart sealed-family member.
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
///
/// ```dart
/// final Failure<int> outcome = Failure<int>(Exception('offline'));
/// // outcome.isFailure == true
/// ```
final class Failure<OutcomeValue> extends Result<OutcomeValue> {
  /// Creates a failure outcome holding [cause].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a failure cause to construct directly | [Failure.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [Result.failure]; this constructor
  /// is the direct spelling for pattern-matching and constant contexts.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Failure<int> outcome = Failure<int>(Exception('offline'));
  /// // outcome.isFailure == true
  /// ```
  const Failure(this.cause) : super._();

  /// The failure cause.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a failure outcome to inspect | [Failure.cause] |
  ///
  /// Stdlib gap (DART-SDK): thrown causes scatter across `catch` clauses.
  /// [Failure.cause] keeps the original instance on the outcome, so
  /// [Result.mapValue] and [Result.andThen] carry it through untouched.
  ///
  /// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Exception rootCause = Exception('offline');
  /// final Failure<int> outcome = Failure<int>(rootCause);
  /// // identical(outcome.cause, rootCause) == true
  /// ```
  final Exception cause;

  /// Whether [other] is a [Failure] holding the identical cause.
  ///
  /// [Exception] carries identity equality, so sameness here is [identical].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<OutcomeValue> && identical(other.cause, cause));

  /// Hash code matching [==].
  @override
  int get hashCode => cause.hashCode;

  /// Renders as `Failure(cause)` for debugging.
  @override
  String toString() => 'Failure($cause)';
}
