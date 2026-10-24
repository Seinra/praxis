# Praxis — typed generics for Dart

One small, dependable generics library at Echo-level quality: typed helpers for
results, options, and lists, built one feature at a time. Sister library of
[Axiom](https://github.com/seinra/axiom) (Go generics); same thesis, Dart idioms.

> Version: `0.1.0-dev` (private — path/git dependency until the v0 bar).
> Prereqs: Dart SDK `^3.13.0` (`dart --version` → 3.13.5 verified 2026-10-23).
> Runnable API examples land with the skeleton slice; every documented example
> is CI-executed (tests assert the documented outputs), never scratch-only.

## Quick path

1. Point at it (private library — path dependency, not `pub get`):
   ```yaml
   # pubspec.yaml of the consumer (e.g. Catalyst)
   dependencies:
     praxis:
       path: ../Praxis
   ```
2. Use one package (skeleton ships `result`, `opt`, lists):
   ```dart
   import 'package:praxis/praxis.dart';
   ```
3. Verify: `dart test` — expect `All tests passed!` across all packages.

## Which function? (guide index)

Each package doc opens with a "Which function?" table (outcome → function).
Start there, then `dart doc` the package. Skeleton shipped the first three rows;
everything else is declared future scope (one ODD feature per package).

| If you are holding ... | Start with | Status |
| --- | --- | --- |
| a success-or-failure outcome | `result` | skeleton — shipped |
| a maybe-present value | `opt` | skeleton — shipped |
| a list to transform, find, or fold | lists | skeleton — shipped |
| two typed sides (left / right) | `either` | declared future (same gate as Axiom's) |
| a builtin map to reshape | `mapx` | mapx — shipped |
| distinct values to combine or compare | `set` | set — shipped |
| a lazy `Iterable` pipeline | `iterx` | iterx — shipped |
| predicates to combine (And / Or / Not) | `valid` | valid — shipped |
| one call to run once per key | `singleflight` | singleflight — shipped |
| objects to reuse, not rebuild | `pool` | pool — shipped |
| named singleton services | `di` | di — shipped |
| records addressed by identity | `repo` | declared future |
| an HTTP JSON envelope | `httpx` | declared future |
| a bounded concurrent map or first-success race | `flow` | flow — shipped |
| a background computation to join later | `task`/`future` | declared future |
| whole numbers to test, divide, or combine | `mathx` | mathx — shipped |
| text to split or cut by runes | `strings` | strings — shipped |

Records `(value, present)` are our OrNull across Praxis: the `present` flag
reports presence — never trust the value without it (owner decision 2026-10-23,
mirrors Axiom's `(T, bool)`).

| If you are holding ... | Reach for |
| --- | --- |
| a loose value that may be missing, your own code | `(value, present)` record |
| an absence to chain or transform | `opt` |
| a failure with a cause | `result` |
| two typed sides | `either` (future) |

## Details

| Topic | Decision |
| --- | --- |
| Package / toolchain | `praxis`, Dart `^3.13.0` (records, patterns, sealed types) |
| Ships now | skeleton: `result` + `opt` + lists (`odd/tasks/praxis-skeleton.md`); set slice: `set` (`odd/tasks/praxis-set.md`); mapx slice: `mapx` (`odd/tasks/praxis-mapx.md`); iterx slice: `iterx` (`odd/tasks/praxis-iterx.md`); valid slice: `valid` (`odd/tasks/praxis-valid.md`); strings slice: `strings` (`odd/tasks/praxis-strings.md`); mathx slice: `mathx` (`odd/tasks/praxis-mathx.md`); flow slice: `flow` (`odd/tasks/praxis-flow.md`); pool slice: `pool` (`odd/tasks/praxis-pool.md`); singleflight slice: `singleflight` (`odd/tasks/praxis-singleflight.md`); di slice: `di` (`odd/tasks/praxis-di.md`) |
| Rules | SDK-first (`dart:core`/`dart:collection`/`dart:async` before hand-rolled); typed API, `dynamic` only at codec edges; grep-able names (no `data`/`item`/`res`); doc comment on every export + one CI-executed example per package happy path; pure helpers (never mutate inputs) |
| Loop | `PRAXIS_LOOP.md` + `.loop-modules/` + `VISION.md` + `loop-config.yaml`; ODD-tracked in `odd/tasks/` |
| Declared future (owner-gated) | new packages need an explicit owner package-creation call before any ODD — curriculum need gates helpers, never speculative generality |
| Consumer | Catalyst (offline-first course app) pilots via scratch path-only — never a Catalyst commit from here |

## Checklist

- [ ] `dart test` green on Dart 3.13
- [ ] `dart analyze` clean and `dart format` clean
- [ ] New symbol cites what the SDK lacked + carries a doc comment with an example
- [ ] No `dynamic` in public signatures except codec edges with typed wrappers

## Why not just use `fpdart`?

Use it as reference — it is a fine library, and Praxis will never try to
out-cover it. Praxis is the teachable companion, not a replacement: every
package opens with a Which-function table, every export carries a doc comment
plus a CI-executed example, and every addition documents what the SDK lacked.
It doubles as the Catalyst generics course material, and its v0 API is frozen —
the same library students learn on is the one they keep.

## Contributing

External PRs are judged by one rule: genuinely good **and** thesis-fitting, or
fork it. See [CONTRIBUTING.md](CONTRIBUTING.md) before opening anything — most
well-meaning asks (SDK duplicates, reflection-first APIs, mutable variants,
domain helpers) are declined there with reasons.

## Next step

Read `VISION.md` for the product line, then `.loop-modules/ARCHITECTURE.md` for
the coverage map — each future package becomes one ODD feature.
