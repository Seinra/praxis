# Praxis — typed generics for Dart

One small, dependable generics library: typed helpers for
results, options, and lists, built one feature at a time. Sister library of
[Axiom](https://github.com/seinra/axiom) (Go generics); same thesis, Dart idioms.

> Version: `0.1.0` (public, MIT).
> Prereqs: Dart SDK `^3.13.0` (`dart --version` → 3.13.5 verified 2026-10-23).
> Runnable API examples land with the skeleton slice; every documented example
> is CI-executed (tests assert the documented outputs), never scratch-only.

## Quick path

1. Add it:
   ```sh
   dart pub add praxis
   ```
   Pre-release consumers on an unreleased checkout can still use a path dependency (`path: ../Praxis`).
2. Use one package (skeleton ships `result`, `opt`, lists):
   ```dart
   import 'package:praxis/praxis.dart';
   ```
3. Verify: `dart test` — expect `All tests passed!` across all packages.

## Which function? (guide index)

Each package doc opens with a "Which function?" table (outcome → function).
Start there, then `dart doc` the package. New here? Work through
docs/quickstart.md first.

| If you are holding ... | Start with | Status |
| --- | --- | --- |
| a success-or-failure outcome | `result` | skeleton — shipped |
| a maybe-present value | `opt` | skeleton — shipped |
| a list to transform, find, or fold | lists | skeleton — shipped |
| two typed sides (left / right) | `either` | either — shipped |
| a builtin map to reshape | `mapx` | mapx — shipped |
| distinct values to combine or compare | `set` | set — shipped |
| a lazy `Iterable` pipeline | `iterx` | iterx — shipped |
| predicates to combine (And / Or / Not) | `valid` | valid — shipped |
| one call to run once per key | `singleflight` | singleflight — shipped |
| objects to reuse, not rebuild | `pool` | pool — shipped |
| named singleton services | `di` | di — shipped |
| records addressed by identity | `repo` | repo — shipped |
| an HTTP JSON envelope | `httpx` | httpx — shipped |
| a bounded concurrent map or first-success race | `flow` | flow — shipped |
| a background computation to join later | `task` | task — shipped |
| whole numbers to test, divide, or combine | `mathx` | mathx — shipped |
| text to split or cut by runes | `strings` | strings — shipped |
| values in last-in-first-out order | `stack` | stack — shipped |
| values in first-in-first-out order | `queue` | queue — shipped |
| keys in insertion order, or bounded recent use | `orderedmap` | orderedmap — shipped |
| left-to-right and right-to-left function composition | `pipe` | pipe — shipped |

Records `(value, present)` are our OrNull across Praxis: the `present` flag
reports presence — never trust the value without it (owner decision 2026-10-23,
mirrors Axiom's `(T, bool)`).

| If you are holding ... | Reach for |
| --- | --- |
| a loose value that may be missing, your own code | `(value, present)` record |
| an absence to chain or transform | `opt` |
| a failure with a cause | `result` |
| two typed sides | `either` |

## Details

| Topic | Decision |
| --- | --- |
| Package / toolchain | `praxis`, Dart `^3.13.0` (records, patterns, sealed types) |
| Ships now | `result` + `opt` + lists, `either`, `mapx`, `set`, `iterx`, `valid`, `strings`, `mathx`, `flow`, `pool`, `singleflight`, `di`, `repo`, `httpx`, `stack` + `queue` + `orderedmap`, `task`, `pipe`, `praxis_lints` (dev tooling) — see `docs/quickstart.md` to start, `CHANGELOG.md` for the slice history |
| Rules | You follow the [VISION Invariants](VISION.md#invariants-non-negotiable-ratified-2026-10-23) and the [CONTRIBUTING Declined list](CONTRIBUTING.md#declined-with-reasons-dont-open-these) — SDK-first, typed APIs, grep-able names, doc comments with CI-executed examples, pure helpers |

## Linter

You enable `praxis_lints` (the house-rule analyzer plugin) in your `analysis_options.yaml`:

```yaml
plugins:
  praxis_lints:
    path: tools/praxis_lints
    diagnostics:
      no_single_letter: true
      no_banned_names: true
```

You read the rule docs in [`tools/praxis_lints/README.md`](tools/praxis_lints/README.md) (symptom → rule table, violation vs clean pairs, scope notes); you restart the analysis server after changing the section.

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

You work the [quickstart](docs/quickstart.md) next — you point, run, and verify in under five minutes.
