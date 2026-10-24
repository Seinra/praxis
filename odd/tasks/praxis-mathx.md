# praxis-mathx — `mathx` integer helpers green with docs

Seventh library slice (numbers wall: primality testing, prime generation, GCD/LCM with overflow discipline — the genuinely hard integer material the SDK leaves out, strong course value beside `strings`). Ships the `mathx` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "continuemos con mathx" — owner's explicit package-creation order (plus branch hygiene + correct skill injection on delegation, handled by the orchestrator).
- S2 (scope): integer helpers over `int` (test: primality; generate: primes up to a bound; combine: GCD/LCM) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (0, 1, 2, negatives, large primes, coprime pairs, overflow-adjacent bounds), no `dynamic`. No floating-point helpers (doubles are a separate domain, out of scope).
- S3 (SDK honesty): `dart:core` `int` owns `abs`/`compareTo`/`~/`/`%` and `dart:math` owns `max`/`min`/`pow`/`sqrt` — ship only proven gaps (e.g. `isPrime`, primes sieve, `gcd`/`lcm` if absent from the SDK), each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Overflow discipline explicit: document the bound behavior (sieve caps, `ArgumentError` on programmer-error inputs like negative bounds) instead of silently wrapping.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's `mathx` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/mathx.dart` + `test/mathx_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, edge + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `mathx`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner package-creation order, verbatim): "continuemos con mathx".
- L2: ODD opened on branch `feat/praxis-mathx` (hygiene verified first: only `main` local, only `origin/main` remote, tree clean); priority call: `mathx` next per the established strings→mathx order; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (T2 naming verdict): `mathx` + three exports (`isPrime`, `primesUpTo`, `lcm`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able verbs, `firstNumber`/`secondNumber`/`upperBound`/`candidate`/`divisor`, no single-letter/abbreviated/generic names); barrel Which-row in `lib/praxis.dart` carries all three symbols.
- L4 (T2 pilot note): `.tmp/pilot.dart` extended with one `mathx` happy path through `package:praxis/praxis.dart` (`isPrime(7)` → true, `primesUpTo(10)` → `[2, 3, 5, 7]`, `lcm(4, 6)` → 12); `dart .tmp/pilot.dart` exit 0 — output: `isPrime→seven: true`, `primesUpTo→ten: [2, 3, 5, 7]`, `lcm→four-six: 12`.
- L5 (T2 docs-sync verdict — VALIDATION_GATES rows 1–6, fail-closed, all resolve): row 1 `checked` (`lib/src` holds 9 files — `ls` → iterx/lists/mapx/mathx/opt/result/set/strings/valid; README Ships now names all nine: skeleton 3 + set + mapx + iterx + valid + strings + mathx); row 2 `checked` (README index row flipped to `mathx — shipped` + `export 'src/mathx.dart'` in `lib/praxis.dart` alphabetical (`mapx` < `mathx` < `opt`) per `directives_ordering` + executed suite `dart test test/mathx_test.dart` 27/27 green + full `dart test` +375 green at close-out); row 3 `checked` (barrel Which-row names all three mathx symbols + per-export Which-rows in `lib/src/mathx.dart`; no separate family guide exists — `docs/` absent — so no mirror claim to drop); row 4 `checked` (grep `no mathx|no numbers|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; T1 YAGNI kills for `int.gcd`/arithmetic/`dart:math` stand as correctly scoped); row 5 `checked` (the one roadmap line naming this scope — README `mathx` index row — flips in this unit; barrel future-scope sentence + Ships now updated in the same unit); row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-mathx.md`, set at T0, untouched by this unit).
- L6 (work-unit record): T1+T2 land together in `57955b3` (378 insertions, 4 deletions per diff stat — inside the ~400 advisory slice; native review takes it as one 2-lens candidate). Parent re-ran the scoped suite on the final state (`dart test test/mathx_test.dart` 27/27 green) plus full gates (`dart test` +375, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
- L7 (R10 native review of the mathx slice burned — lineage review-422480f56e02e4e5 APPROVED + burned (readability+reliability, 383 lines, group 2/2 clean via pi_host_relay with inner-binding form first try); 4 advisories parked informational in their OWN ledger row (R2-1 SUGGESTION test/mathx_test.dart:132-146, R3-001 WARNING lib/src/mathx.dart:84-89, R3-002 SUGGESTION test/mathx_test.dart:1, R3-003 SUGGESTION lib/src/mathx.dart:148-152) — rows R1–R9 untouched, no finding overwritten; delivery per ordinary policy.
