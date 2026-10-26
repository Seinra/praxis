# TECH_STACK

Stack, versions, and local docs policy for Praxis. Read before domain work. `modules_read` must include this file when touching toolchain, deps, or docs.

## Toolchain

| Item | Pin | Note |
| --- | --- | --- |
| Dart | 3.13.5 (`sdk: ^3.13.0` in `pubspec.yaml`) | Verified `dart --version` 2026-10-23 |
| Flutter | 3.47.7 stable | Consumer-adjacent only; Praxis is pure Dart (no Flutter import) |
| Package | `praxis` v0.1.0 | Owner decision 2026-10-23; published on pub.dev at the v0 bar |
| Lints | `lints` recommended + strict (casts/inference/raw-types) | `dart analyze` clean is the gate |
| custom_lint | REMOVED (was `^0.7.0` pinned, plugin PARKED) | upstream archived; zero rules ever existed in repo; house rules now enforced by `tools/praxis_lints` on `analysis_server_plugin` (isolated synthetic-package resolution, no analyzer 7 vs 14 war); root runs plain `dart analyze` |
| Test | `package:test` | `dart test` green is the gate |
| Consumer | Catalyst (offline-first course app) | Pilots via scratch path-only — never a Catalyst commit from here |

## Language features in use

- Records (Dart 3.0+): the `(value, present)` OrNull contract — mirrors Axiom's `(T, bool)` exactly (owner decision 2026-10-23).
- Patterns + sealed types (3.0/3.10+): exhaustive splits over `result`/`opt` without `dynamic`.
- Generics on classes, functions, and typedefs; generic methods where they teach best.
- `dart:core` / `dart:collection` / `dart:async` / `dart:convert` / `dart:math` from the SDK — always preferred over hand-rolled (stdlib-gap rule, VISION invariant 1).

## Local docs policy (Refs)

- `D:/Proyectos/Refs/dart/` + `D:/Proyectos/Refs/flutter/` are host-local and OPTIONAL: probe before citing; if absent, use workspace search + pinned external truth in REFERENCES. (Unverified this cycle — see REFERENCES gaps.)
- Axiom (`D:/Proyectos/Axiom`) is thesis-fidelity evidence, not Dart API truth: mirror its discipline (Which-tables, purity, one-feature-per-iteration), never its Go signatures.

## Dependency policy

- SDK-first; zero runtime dependencies (`dependencies: {}`). Every new dependency needs a one-line justification + version pin in REFERENCES.
- Dev-only deps (`test`, `lints`, `custom_lint`) never leak into public API.
