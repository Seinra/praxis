# AxiomDart — Thesis (DRAFT, UNRATIFIED)

> Status: **RATIFIED 2026-10-23. Owner decisions recorded in `VISION.md`.**
> Name `Praxis` (`D:/Proyectos/Praxis`, package `praxis`) replaces the
> provisional `AxiomDart`. Open decisions 1–6 answered (see `VISION.md`
> ratification table). This document stays the historical starting point;
> `VISION.md` is the standing product truth, with the same thesis as
> [Axiom](../Axiom/README.md) (Go generics library,
> `github.com/seinra/axiom`), consumed the same way by Catalyst.

## One-line identity

The Echo of Dart generics: one small, dependable library that makes the hard
parts of generics easy — for humans and for AI — so apps like Catalyst teach
and ship typed code instead of `dynamic` soup.

## Why not adopt an existing package

Surveyed 2026-10-23. Nothing carries this thesis:

- **dartz**: unmaintained (no release in ~4 years; community consensus is to avoid it).
- **fpdart** (v1.2.0, v2 in pre-release rewrite): alive, but a different school — fp-ts/cats-style monadic effects (`IO`, `Reader`, `TaskEither`) currently being rewritten around an `Effect` class. Axiom is plain-data + explicit effects, stdlib-shaped, not monadic. Importing it would buy a philosophy mismatch plus v1→v2 churn.
- Small libs (`fp_dart`, `vsavkin/fpdart`, helpers): unmaintained experiments.

**Verdict recorded:** fpdart is reference/inspiration at most, never a dependency.
A twin is built, not adopted.

## Invariants (proposed, non-negotiable once ratified)

Adapted from Axiom's VISION; Dart differences are explicit, not silent.

1. **SDK-first.** Dart SDK (`dart:core`, `dart:collection`, `dart:async`, `dart:convert`, `dart:math`) before hand-rolled; every new symbol justifies what the SDK lacked (stdlib-gap rule).
2. **Typed over `dynamic`.** Public APIs name their type parameters; `dynamic` lives only at codec edges (JSON) behind typed wrappers.
3. **Names a stranger can grep.** No single-letter identifiers (short loop indices excepted), no abbreviations, no generic names (`data`, `item`, `res`); collections are plural nouns; predicates are `is/has/can/should`.
4. **Tree green after every iteration; one logical feature per iteration.**
5. **AI-readable.** Package docs answer "which function?" without reading bodies (Which-table per package); stable names across releases.
6. **Private now, public at maturity.** Consumed via path/git dependency while developing; published open-source (MIT/BSD) once it passes the library bar — **owner decision required**.
7. **Teachable API.** Every package doubles as course content for the Catalyst generics DLC: names, doc comments, and examples must work as lesson material, not just as reference.
8. **Standalone teachability.** The split is inside the library — reference (doc comments + Which-tables) vs. guide (decision ladders + compiling examples), all in-repo and standalone. The DLC consumes that material for curriculum; it never hosts missing content.
9. **Purity.** Helpers never mutate inputs; outputs are fresh values. Mutable in-place variants are rejected — Dart already offers mutation via plain loops and the SDK when the caller opts in.
10. **No reflection.** No `dart:mirrors` (unavailable in Flutter anyway); no code generation as a substitute for generics.

## Quality bar per export (all mandatory)

- Which-table row in the package doc, mirroring the guide.
- Doc comment with stdlib-gap justification + runnable example.
- Example is CI-executed (tests assert the documented outputs), never scratch-only.
- OrNull/empty contract explicit (see open decision #1).
- Purity + edge pins in tests (empty, zero, negative, boundary, multibyte where text is involved); never-mutate pins.
- Godoc-equivalent (`dart doc`) renders without warnings.

## Package map (mirrors Axiom; adapt names only where Dart forces it)

| Area | Packages | Notes |
| --- | --- | --- |
| FP core | `result`, `opt`, (`either` when gated) | `either` enters only on the same gate as Axiom's |
| Collections | `slice`→lists, `mapx`, `set`, `iterx`→`Iterable` adapters | Dart `Iterable` is lazy-first; document eager-vs-lazy per helper |
| Concurrency | `flow` (bounded fan-out, races), `singleflight`, `task`/`future` | See open decision #3 |
| Infra | `pool`, `di`, `repo`, `httpx`, `valid` | HTTP adapter targets Dart's `HttpClient`/Shelf, not Echo; see open decision #4 |
| Numbers | `mathx` | Primes, GCD/LCM with the same overflow discipline |
| Text | `strings` | Rune-aware splitting/chunking/truncation; case converters stay out (they belong with `characters`/`intl`-style homes) |
| Bridges | pointer↔value has no Dart equivalent (references are nullable) | Fold into `opt` conventions; see open decision #1 |

## Non-goals (rejected unless new evidence + a new decision reopens them)

- A mega-framework or "install this whole world" package.
- Reflection-first APIs; code generation as a generics substitute.
- `dynamic`-soup helpers; mutable in-place variants.
- Tuples T2–T9 (Dart records cover small arities; beyond that, name a class).
- Reimplementing SDK-owned surface (`sort`, `where`, `map`, `fold`, `wm`...).
- Domain helpers (dates, URLs, query strings) — adapter concern, not generics lessons.

## Open decisions (owner)

1. **Absence contract in Dart.** Axiom uses `(T, bool)`. Dart-native is nullable `T?`, but nullable erases the "checked presence" discipline. Options: (a) records `(T, bool)` mirroring Axiom exactly; (b) nullable `T?` with documented check discipline; (c) per-package split. Recommendation: start with (a) for thesis fidelity; revisit with evidence.
2. **Package + repo name.** `AxiomDart` here is provisional.
3. **Async story.** `Future`/`Stream` semantics for the `flow` port (cancellation tokens differ from Go contexts).
4. **JSON story.** Manual codecs vs `json_serializable`; codec-edge rule stays either way.
5. **Lint set.** `dart analyze` baseline + `custom_lint` rules encoding the house rules (grep-able names, doc coverage).
6. **Release/versioning.** Path dependency first; publish gate mirrors Axiom's v0 bar.

## What this document is not

No API freeze, no estimates, no implementation, no delivery plan. The next step after ratification is a loop + first ODD (skeleton: `result` + `opt` + list helpers, mirroring Axiom's skeleton rule), each launching only on explicit owner order.

## Next step (ratified 2026-10-23)

Decisions taken — see `VISION.md`. Order: scaffold repo + loop + skeleton ODD
(`result` + `opt` + list helpers). Loop + skeleton each run under `PRAXIS_LOOP.md`.
