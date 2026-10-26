/// Left-to-right and right-to-left composition over typed unary functions.
///
/// Use [pipe] to name a two-step pipeline that reads in application order,
/// and [compose] to name the same shape in mathematical order. Both take
/// two plain unary functions and hand back one reusable function value:
/// stored in a variable, passed to another helper, or taught by name in
/// course material instead of living as a nested call inline.
///
/// Which function?
///
/// | When you want to ...                   | Reach for |
/// | --- | --- |
/// | Name a pipeline that reads left to right | [pipe]    |
/// | Name a composition that reads outside in | [compose] |
///
/// Out of scope by design: composing fallible steps (that chaining belongs
/// to [Result.mapValue] and [Result.andThen] over an already-wrapped
/// outcome, never here), arities beyond two steps in one call (nest one
/// [pipe] inside another — composition closes over composition — instead
/// of speculative `pipe3`/`pipe4` generality), and async execution shapes
/// (bounded fan-out belongs to `flow`, per-key dedupe to `singleflight`,
/// eager spawn-and-join to `task`, never here). This package composes two
/// plain total unary functions into one reusable value; it never runs
/// anything until the composed function is called.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

/// Names a two-step pipeline that reads in application order.
///
/// Returns one function value: calling it runs [firstStep] on the input,
/// then [secondStep] on that result. Legs run left to right exactly once
/// per call — composing never runs a leg, and re-calling re-runs both
/// legs, so nothing is memoized. A leg failure propagates to the caller
/// and later legs never run. Longer pipelines nest: `pipe(pipe(a, b), c)`
/// stays typed through every bridge.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | two steps to name as one left-to-right pipeline | [pipe] |
///
/// Stdlib gap (DART-SDK): nested calls `second(first(value))` sequence one
/// inline call site but name no reusable value, so the pipeline cannot be
/// stored, passed, or taught by name; cascades (`..`) chain methods on one
/// object, never free unary functions; `Iterable.map` transforms
/// collections and `Result.mapValue`/`Result.andThen` chain
/// already-wrapped outcomes — none composes two plain total unary
/// functions into one named value. [pipe] fills that gap. Fidelity note
/// (AXIOM-SISTER): Axiom ships no pipe symbol — Go composes by nesting
/// calls and Axiom chains outcomes via `result.AndThen` — so there is no
/// Axiom signature to mirror; the mirrored discipline is Which-tables,
/// purity pins, and YAGNI-killed arities.
///
/// A `null`-leg guard is YAGNI-killed here with a reason: sound null
/// safety makes it unrepresentable, since both legs are non-nullable
/// functions the compiler already rejects as `null`.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final int Function(int) addOneThenDouble = pipe<int, int, int>(
///   (int firstValue) => firstValue + 1,
///   (int pipedValue) => pipedValue * 2,
/// );
/// // addOneThenDouble(3) == 8
/// ```
OutputValue Function(InputValue inputValue)
pipe<InputValue, BridgeValue, OutputValue>(
  BridgeValue Function(InputValue inputValue) firstStep,
  OutputValue Function(BridgeValue pipedValue) secondStep,
) {
  return (InputValue inputValue) => secondStep(firstStep(inputValue));
}

/// Names a two-step composition that reads in outside-in order.
///
/// Returns one function value: calling it runs [innerStep] on the input,
/// then [outerStep] on that result. Legs run right to left exactly once
/// per call — composing never runs a leg, and re-calling re-runs both
/// legs, so nothing is memoized. A leg failure propagates to the caller
/// and the outer leg never runs after an inner failure. Longer
/// compositions nest: `compose(c, compose(b, a))` stays typed through
/// every bridge. Mirrors [pipe] with mirrored argument order:
/// `compose(outerStep, innerStep)` behaves as `pipe(innerStep, outerStep)`.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | two steps to name as one outside-in composition | [compose] |
///
/// Stdlib gap (DART-SDK): same gap as [pipe] — nested calls
/// `outer(inner(value))` sequence one inline call site but name no
/// reusable value, and no SDK helper lifts outside-in composition over
/// plain unary functions into a named value. [compose] fills the
/// mathematical-order half of that gap. Fidelity note (AXIOM-SISTER):
/// same missing contrast as [pipe] — Axiom ships no compose symbol — so
/// there is no Axiom signature to mirror; the mirrored discipline is
/// Which-tables, purity pins, and YAGNI-killed arities.
///
/// A `null`-leg guard is YAGNI-killed here with a reason: sound null
/// safety makes it unrepresentable, since both legs are non-nullable
/// functions the compiler already rejects as `null`.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final int Function(int) doubleAfterAddOne = compose<int, int, int>(
///   (int outerValue) => outerValue * 2,
///   (int innerValue) => innerValue + 1,
/// );
/// // doubleAfterAddOne(3) == 8
/// ```
OutputValue Function(InputValue inputValue)
compose<InputValue, BridgeValue, OutputValue>(
  OutputValue Function(BridgeValue outerValue) outerStep,
  BridgeValue Function(InputValue innerValue) innerStep,
) {
  return (InputValue inputValue) => outerStep(innerStep(inputValue));
}
