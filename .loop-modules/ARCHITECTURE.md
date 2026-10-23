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
│   └── src/
│       ├── result.dart      # Result<T> + Ok/Fail helpers (skeleton: YES)
│       ├── opt.dart         # Opt<T> absent-or-present (skeleton: YES)
│       └── lists.dart       # list helpers over dart:core (skeleton: YES)
└── test/
    ├── result_test.dart
    ├── opt_test.dart
    └── lists_test.dart
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
9. Skeleton slice ships only `result` + `opt` + `lists`; everything else is declared future scope, never stubbed speculatively.
10. Purity: all helpers are pure — inputs are never mutated, outputs are fresh values. Mutable in-place variants are rejected: callers rely on inputs staying intact, and Dart already offers mutation via plain loops and the SDK when the caller opts in.
11. Async story deferred to the `flow` slice (owner decision 2026-10-23): skeleton is sync-only. Rationale from Axiom evidence — `flow` threads cancellation through every signature (errgroup parity); Dart has no `context.Context` equivalent, so the design is made when `flow` opens, not before.

## Coverage map (present → future)

| Area | Present (skeleton) | Future (declared, not built) |
| --- | --- | --- |
| Collections | lists Map/Filter/Fold/Find/GroupBy | `mapx`, `set`, Stack/Queue/OrderedMap |
| FP | `result`, `opt` | Either/Future/Task, Pipe/Compose |
| Concurrency | — | `flow` (bounded fan-out, races), `singleflight`, `task`/`future` |
| Infra | — | `pool`, `di`, `repo`, `httpx`, `valid` |
| Numbers | — | `mathx` |
| Text | — | `strings` (rune-aware, via `characters`-style homes where due) |

## Non-goals (thesis; reopen only with new evidence + a new decision)

- Mega-framework, reflection-first APIs, codegen as generics substitute.
- `dynamic`-soup helpers; mutable in-place variants.
- Tuples T2–T9 (records cover small arities; beyond that, name a class).
- SDK-owned surface reimplements; domain helpers (dates, URLs, query strings).
