# ARCHITECTURE

Component layout, data flow, and frozen decisions for Praxis. Read before designing any package.

## Layout (library, not service)

```text
praxis/
├── PRAXIS_LOOP.md
├── VISION.md
├── THESIS.md
├── loop-config.yaml
├── .loop-modules/
├── odd/tasks/
├── lib/
│   ├── praxis.dart          # barrel: re-exports every package
│   └── src/                 # 21 packages, one file per package
│       ├── result.dart      # Result<T> + Ok/Fail helpers
│       ├── opt.dart         # Opt<T> absent-or-present
│       ├── lists.dart       # list helpers over dart:core
│       ├── either.dart      # Either left/right two typed sides
│       ├── mapx.dart        # builtin map reshapes
│       ├── set.dart         # distinct-value combine/compare
│       ├── iterx.dart       # lazy Iterable pipelines
│       ├── valid.dart       # predicate combinators (And/Or/Not)
│       ├── strings.dart     # rune-aware text cuts
│       ├── mathx.dart       # whole-number helpers
│       ├── flow.dart        # bounded concurrency + FlowScope
│       ├── pool.dart        # object reuse pool
│       ├── singleflight.dart # one shared execution per key
│       ├── di.dart          # named singleton services
│       ├── repo.dart        # identity-addressed records
│       ├── httpx.dart       # typed HTTP JSON envelope
│       ├── task.dart        # background computation to join later
│       ├── stack.dart       # last-in-first-out values
│       ├── queue.dart       # first-in-first-out values
│       ├── orderedmap.dart  # insertion-order keys + LRU
│       └── pipe.dart        # left-to-right/right-to-left composition
└── test/                    # 21 test files, one per package
    ├── result_test.dart
    ├── opt_test.dart
    ├── lists_test.dart
    ├── either_test.dart
    ├── mapx_test.dart
    ├── set_test.dart
    ├── iterx_test.dart
    ├── valid_test.dart
    ├── strings_test.dart
    ├── mathx_test.dart
    ├── flow_test.dart
    ├── pool_test.dart
    ├── singleflight_test.dart
    ├── di_test.dart
    ├── repo_test.dart
    ├── httpx_test.dart
    ├── task_test.dart
    ├── stack_test.dart
    ├── queue_test.dart
    ├── orderedmap_test.dart
    └── pipe_test.dart
```

Library rule (adapted from foundry package-organization): every file under `lib/` is public API — that raises the bar, it never lowers it. No `internal/` exports; test helpers shared across packages live in `test/` and must NOT become API.

## Data flow

```text
Catalyst (consumer)
   │  import 'package:praxis/praxis.dart'
   ▼
praxis packages (pure Dart, SDK only: dart:core/collection/async/convert/math)
   │  no Flutter, no third-party imports in core (httpx/repo adapt at the edge)
   ▼
Dart SDK (core, collection, async, convert, math)
```

Core packages MUST NOT import Flutter or any third-party package. Adapter packages (`httpx`, `repo`) own those deps alone.

## Flutter posture (owner addendum 2026-10-23)

- Core stays pure Dart: zero dependencies means any Flutter app imports
  Praxis at no cost — that importability IS the Flutter support. No Flutter
  import in core, ever (keeps `dart test` as the gate).
- Guides speak Flutter where it teaches better: async (`flow`, `task`)
  examples use the `Future`/`Stream` idioms a Flutter dev already holds; the
  deferred async design must fit lifecycle-safe cancellation when `flow` opens.
- No Flutter-specific packages in the coverage map: Flutter devs consume the
  same `result`/`opt`/lists API; anything widget-bound belongs to the app,
  never to this library.

## Frozen decisions

1. Dart ^3.13.0 minimum; records + patterns + sealed types in play.
2. Absence contract: records `(value, present)` everywhere presence is checked — mirrors Axiom's `(T, bool)` exactly (owner decision 2026-10-23). Never trust the value without the flag.
3. SDK-first: `dart:core`/`dart:collection`/`dart:async`/`dart:convert`/`dart:math` before hand-rolled. Zero runtime dependencies.
4. No `dynamic` in domain-facing API; `dynamic` only at JSON/codec edges with typed wrappers. Manual handwritten codecs (`dart:convert` at the edge, explicit `fromJson`/`toJson`) — no code generation in the teaching library (owner decision 2026-10-23; Axiom evidence: handwritten `MarshalJSON`/`UnmarshalJSON`, zero `go:generate`).
5. Naming per thesis invariant 3: no single-letter identifiers (short loop indices excepted), no abbreviations, no generic names (`data`/`item`/`res`); collections are plural nouns; predicates are `is/has/can/should`. Constructors: unnamed constructor is the default for its type; stateful/adapting construction gets a named constructor.
6. Fewest files: one file per package until the file earns its boundary; never single-export files — co-locate until the split pays for itself.
7. Functions ≤50 lines / complexity ≤10 / params ≤4; guard clauses over nesting; failures travel as typed values (`Result`), never thrown across API boundaries except programmer errors.
8. Convenience outweighs minimalism (mirrors Axiom owner decision): an SDK-adjacent helper that saves lines or teaches better stays even if it wraps the SDK thinly; YAGNI still kills speculative generality, never proven convenience.
9. Slices shipped one package at a time (`result` + `opt` + `lists` first, then one ODD feature per package to 21); declared future scope stayed unbuilt until its slice opened — never stubbed speculatively.
10. Purity: all helpers are pure — inputs are never mutated, outputs are fresh values. Mutable in-place variants are rejected: callers rely on inputs staying intact, and Dart already offers mutation via plain loops and the SDK when the caller opts in.
11. Async story landed with the `flow` slice (owner decision 2026-10-23): the library started sync-only, and `flow` shipped bounded fan-out, first-success races, and `FlowScope` cooperative cancellation (`lib/src/flow.dart`) when the slice opened. Rationale from Axiom evidence — `flow` threads cancellation through every signature (errgroup parity); Dart has no `context.Context` equivalent, so the design was made when `flow` opened, not before.

## Coverage map (all shipped — 21 packages)

| Area | Present |
| --- | --- |
| Collections | lists Map/Filter/Fold/Find/GroupBy, `mapx`, `set`, `stack`, `queue`, `orderedmap`, `iterx` (lazy) |
| FP | `result`, `opt`, `either`, `pipe`, `task` |
| Concurrency | `flow` (bounded fan-out, races, FlowScope), `singleflight` |
| Infra | `pool`, `di`, `repo`, `httpx`, `valid` |
| Numbers | `mathx` |
| Text | `strings` (rune-aware) |

## Non-goals (thesis; reopen only with new evidence + a new decision)

- Mega-framework, reflection-first APIs, codegen as generics substitute.
- `dynamic`-soup helpers; mutable in-place variants.
- Tuples T2–T9 (records cover small arities; beyond that, name a class).
- SDK-owned surface reimplements; domain helpers (dates, URLs, query strings).
