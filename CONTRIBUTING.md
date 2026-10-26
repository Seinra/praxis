# Contributing to Praxis

Praxis is a teaching library: every export is lesson material. Contributions
must be genuinely good **and** thesis-fitting (`VISION.md`), or fork it.

## Declined with reasons (don't open these)

- **SDK duplicates.** `sort`, `where`, `map`, `fold`, case converters — if the
  SDK owns it, we link it; new symbols justify the stdlib gap in their doc.
- **Reflection-first APIs.** No `dart:mirrors`, no codegen as a generics
  substitute (manual codecs stay handwritten for the same reason).
- **`dynamic`-soup helpers.** `dynamic` only at codec edges behind typed
  wrappers; public APIs name their type parameters.
- **Mutable in-place variants.** Helpers are pure — fresh outputs, inputs
  untouched. Callers who want mutation already have loops and the SDK.
- **Domain helpers.** Dates, URLs, query strings are adapter concerns, not
  generics lessons.
- **New packages without an owner call.** Each package is one ODD feature and
  opens only on an explicit owner package-creation order.

## Accepted shape (every export)

1. Which-table row in the package doc.
2. Doc comment with stdlib-gap justification + runnable example.
3. Example is CI-executed (a test asserts the documented outputs).
4. OrNull/empty contract explicit (`(value, present)` record discipline).
5. Purity + edge pins in tests (empty, zero, negative, boundary, multibyte
   where text is involved); never-mutate pins.
6. `dart doc` renders without warnings.

## Process

You work inside `PRAXIS_LOOP.md` + `.loop-modules/` + `VISION.md`; each package ships as one ODD-tracked slice in `odd/tasks/`. You keep one logical feature per iteration; pushes stay owner-gated. Catalyst pilots consume versioned releases only — never a Catalyst commit from here.

## Gates

```text
dart test
dart analyze
dart format --output=none --set-exit-if-changed .
```

Tree green after every iteration; one logical feature per iteration. Pushes stay
owner-gated.
