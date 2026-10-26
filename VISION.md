# VISION — Praxis Product Vision

## Vision

The Echo of Dart generics: one small, dependable library that makes the hard
parts of generics easy — for humans and for AI — so apps like Catalyst teach
and ship typed code instead of `dynamic` soup.

## Invariants (non-negotiable, ratified 2026-10-23)

1. **SDK-first.** Dart SDK (`dart:core`, `dart:collection`, `dart:async`, `dart:convert`, `dart:math`) before hand-rolled; every new symbol justifies what the SDK lacked (stdlib-gap rule).
2. **Typed over `dynamic`.** Public APIs name their type parameters; `dynamic` lives only at codec edges (JSON) behind typed wrappers.
3. **Names a stranger can grep.** No single-letter identifiers (short loop indices excepted), no abbreviations, no generic names (`data`, `item`, `res`); collections are plural nouns; predicates are `is/has/can/should`.
4. **Tree green after every iteration; one logical feature per iteration.**
5. **AI-readable.** Package docs answer "which function?" without reading bodies (Which-table per package); stable names across releases.
6. **Private now, public at maturity.** Consumed via path/git dependency while developing; published open-source (MIT) once it passes the library bar — owner decision 2026-10-23.
7. **Teachable API.** Every package doubles as course content for the Catalyst generics DLC: names, doc comments, and examples must work as lesson material, not just as reference.
8. **Standalone teachability.** The split is inside the library — reference (doc comments + Which-tables) vs. guide (decision ladders + compiling examples), all in-repo and standalone. The DLC consumes that material for curriculum; it never hosts missing content.
9. **Purity.** Helpers never mutate inputs; outputs are fresh values. Mutable in-place variants are rejected — Dart already offers mutation via plain loops and the SDK when the caller opts in.
10. **No reflection.** No `dart:mirrors` (unavailable in Flutter anyway); no code generation as a substitute for generics.

## Ratified owner decisions (2026-10-23, thesis open decisions 1–6)

| # | Decision | Owner call |
| --- | --- | --- |
| — | Name + repo | `Praxis`, package `praxis`, repo `D:/Proyectos/Praxis` (private until the v0 bar) |
| 1 | Absence contract | **(a) Records `(valor, presente)`** mirroring Axiom's `(T, bool)` exactly; revisit with evidence only |
| 3 | Async story | **Deferred to the `flow` slice** — the library started sync-only; `Future`/`Stream` + cancellation shipped with the `flow` slice (`FlowScope`, `lib/src/flow.dart`) as decided when `flow` opened |
| 4 | JSON story | **Manual codecs now + migration guide later** — no codegen in the teaching library; `json_serializable` stays a Catalyst-side option |
| 5 | Lint set | **`dart analyze` strict + `praxis_lints`** encoding the house rules (grep-able names, doc coverage) |
| 6 | Release/versioning | **Path/git dependency while private; publish (MIT) at the library bar**, mirroring Axiom's v0 gate |

## Non-goals

- Not a mega-framework: small composable packages, never "install this whole world".
- No reflection-first APIs; no code generation as a generics substitute.
- No `dynamic`-soup helpers, no mutable in-place variants.
- Tuples T2–T9 (Dart records cover small arities; beyond that, name a class).
- Reimplemented SDK-owned surface (`sort`, `where`, `map`, `fold`, …).
- Domain helpers (dates, URLs, query strings) — adapter concern, not generics lessons.

## MVP line

`skeleton`: `result` + `opt` + list helpers green with docs → then one ODD feature per package — shipped `mapx`, `set`, `iterx`, `valid`, `strings`, `mathx`, `flow`, `pool`, `singleflight`, `di`, `repo`, `httpx`, `stack` + `queue` + `orderedmap`, `task`, `pipe`, `either` — until the 21-package coverage map is real. Curriculum need gates new helpers (thesis rule): the library precedes the DLC, so no feature waits for "a class in the DLC that consumes it".

## Currency rule

Every close-out declares per-artifact disposition (UPDATED vs verified-unchanged with reason); a close-out without it is invalid. On drift, flag it in the open log (STATUS.md debt ledger) — never silently rewrite ratified intent.

## Provenance

Owner request 2026-10-23 (librería de genéricos Dart desde cero sobre `THESIS.md`, hermana de Axiom, consumida por Catalyst) + thesis ratification (name `Praxis` + decisions 1–6) + Axiom scout (`D:/Proyectos/Axiom`, module `github.com/seinra/axiom`) + Dart SDK 3.13.5 / Flutter 3.47.7 toolchain probe.
