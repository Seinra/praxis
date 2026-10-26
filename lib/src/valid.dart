/// Predicate combinators over reusable boolean functions.
///
/// Use [Predicate] to name one check as a value, then compose checks with
/// [andPredicates], [orPredicates], and [notPredicate]. Reach for
/// [alwaysTrue] and [alwaysFalse] when a composition needs an explicit
/// identity element. Every combinator is pure: composing never mutates the
/// [predicates] list and calling the combined predicate never mutates the
/// candidate.
///
/// Which function?
///
/// | When you want to ...              | Reach for ...   |
/// | --------------------------------- | --------------- |
/// | Name one reusable check           | [Predicate]     |
/// | Hold only when every check holds  | [andPredicates] |
/// | Hold when any check holds         | [orPredicates]  |
/// | Flip one check                    | [notPredicate]  |
/// | A check that always holds         | [alwaysTrue]    |
/// | A check that always fails         | [alwaysFalse]   |
///
/// Out of scope by design: naming a check with a failure message and
/// collecting failures across checks (validation frameworks and
/// error-accumulation machinery) belong to future adapter slices, never
/// here — this package composes predicates, it never reports why a
/// candidate failed.
library;

/// A single reusable check over a [candidate].
///
/// Names the `bool Function(Candidate)` shape so checks travel as values:
/// stored in lists, passed to combinators, and taught by name in course
/// material instead of living as anonymous inline closures.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a reusable check to name, store, or compose | [Predicate] |
///
/// Stdlib gap (DART-SDK): `dart:core` owns `&&`/`||`/`!` over `bool` values
/// inline, but it names no function shape for a reusable check, so call
/// sites retype `(candidate) => ...` closures that cannot be composed or
/// tested by name. [Predicate] fills that gap. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom's `Predicate` discipline — one check as
/// a value — expressed as a Dart typedef instead of a Go generic func type.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Predicate<int> isAdult = (candidate) => candidate >= 18;
/// // isAdult(21) == true
/// ```
typedef Predicate<Candidate> = bool Function(Candidate candidate);

/// Holds only when every predicate in [predicates] holds for [candidate].
///
/// Legs run left to right and stop at the first `false`, so later legs
/// never run after a failure. An empty [predicates] holds vacuously and
/// reports `true` without running anything — the same identity
/// [alwaysTrue] names explicitly.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | several checks that must all hold | [andPredicates] |
///
/// Stdlib gap (DART-SDK): `&&` combines `bool` values inline, but no SDK
/// helper composes an iterable of predicate *functions* with left-to-right
/// short-circuit and vacuous truth. [andPredicates] fills that gap.
/// Fidelity note (AXIOM-SISTER): mirrors Axiom's `And` combination
/// discipline — every leg must hold, empty holds vacuously — expressed
/// over a Dart iterable instead of Go variadics. A `nil`-leg guard is
/// YAGNI-killed here with a reason: sound null safety makes it
/// unrepresentable, since [predicates] holds non-nullable [Predicate]
/// values the compiler already rejects as `null`.
///
/// Accepts any [Iterable]: re-calling the combined predicate re-iterates
/// a single-use source. Never mutates [predicates].
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Predicate<int> isPositiveEven = andPredicates<int>(<Predicate<int>>[
///   (candidate) => candidate > 0,
///   (candidate) => candidate.isEven,
/// ]);
/// // isPositiveEven(4) == true
/// // isPositiveEven(-4) == false
/// ```
Predicate<Candidate> andPredicates<Candidate>(
  Iterable<Predicate<Candidate>> predicates,
) {
  return (Candidate candidate) {
    for (final Predicate<Candidate> activePredicate in predicates) {
      if (!activePredicate(candidate)) {
        return false;
      }
    }
    return true;
  };
}

/// Holds when any predicate in [predicates] holds for [candidate].
///
/// Legs run left to right and stop at the first `true`, so later legs
/// never run after a success. An empty [predicates] fails vacuously and
/// reports `false` without running anything — the same identity
/// [alwaysFalse] names explicitly.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | several checks of which one must hold | [orPredicates] |
///
/// Stdlib gap (DART-SDK): `||` combines `bool` values inline, but no SDK
/// helper composes an iterable of predicate *functions* with left-to-right
/// short-circuit and vacuous failure. [orPredicates] fills that gap.
/// Fidelity note (AXIOM-SISTER): mirrors Axiom's `Or` combination
/// discipline — any leg holds, empty fails vacuously — expressed over a
/// Dart iterable instead of Go variadics. A `nil`-leg guard is YAGNI-killed
/// here with a reason: sound null safety makes it unrepresentable, since
/// [predicates] holds non-nullable [Predicate] values the compiler
/// already rejects as `null`.
///
/// Accepts any [Iterable]: re-calling the combined predicate re-iterates
/// a single-use source. Never mutates [predicates].
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Predicate<int> isZeroOrEven = orPredicates<int>(<Predicate<int>>[
///   (candidate) => candidate == 0,
///   (candidate) => candidate.isEven,
/// ]);
/// // isZeroOrEven(3) == false
/// // isZeroOrEven(4) == true
/// ```
Predicate<Candidate> orPredicates<Candidate>(
  Iterable<Predicate<Candidate>> predicates,
) {
  return (Candidate candidate) {
    for (final Predicate<Candidate> activePredicate in predicates) {
      if (activePredicate(candidate)) {
        return true;
      }
    }
    return false;
  };
}

/// Flips [predicate]: holds exactly when [predicate] fails for [candidate].
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | one check to negate as a reusable value | [notPredicate] |
///
/// Stdlib gap (DART-SDK): `!` negates one `bool` value inline, but no SDK
/// helper lifts negation over a reusable predicate *function*, so call
/// sites retype `(candidate) => !check(candidate)` wrappers that hide the
/// intent. [notPredicate] fills that gap. Fidelity note (AXIOM-SISTER):
/// mirrors Axiom's `Not` negation discipline as a Dart top-level function.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Predicate<int> isOdd = notPredicate<int>(
///   (candidate) => candidate.isEven,
/// );
/// // isOdd(3) == true
/// ```
Predicate<Candidate> notPredicate<Candidate>(Predicate<Candidate> predicate) {
  return (Candidate candidate) => !predicate(candidate);
}

/// Always holds, ignoring [candidate] by design.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a check that always holds | [alwaysTrue] |
///
/// Stdlib gap (DART-SDK): `dart:core` names no constant predicate, so call
/// sites retype `(candidate) => true` closures wherever a composition
/// needs an explicit identity. [alwaysTrue] fills that gap and teaches
/// the vacuous-truth edge concretely: `andPredicates` over an empty list
/// behaves exactly like [alwaysTrue]. Fidelity note (AXIOM-SISTER):
/// names the identity Axiom's empty-`And` implies but never ships as a
/// symbol.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// // alwaysTrue<int>(anything) == true
/// final Predicate<int> check = andPredicates<int>(<Predicate<int>>[
///   alwaysTrue,
///   (candidate) => candidate.isEven,
/// ]);
/// // check(4) == true
/// ```
bool alwaysTrue<Candidate>(Candidate candidate) => true;

/// Always fails, ignoring [candidate] by design.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a check that always fails | [alwaysFalse] |
///
/// Stdlib gap (DART-SDK): `dart:core` names no constant predicate, so call
/// sites retype `(candidate) => false` closures wherever a composition
/// needs an explicit identity. [alwaysFalse] fills that gap and teaches
/// the vacuous-failure edge concretely: `orPredicates` over an empty list
/// behaves exactly like [alwaysFalse]. Fidelity note (AXIOM-SISTER):
/// names the identity Axiom's empty-`Or` implies but never ships as a
/// symbol.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// // alwaysFalse<int>(anything) == false
/// final Predicate<int> check = orPredicates<int>(<Predicate<int>>[
///   alwaysFalse,
///   (candidate) => candidate.isEven,
/// ]);
/// // check(3) == false
/// ```
bool alwaysFalse<Candidate>(Candidate candidate) => false;
