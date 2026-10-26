# praxis-either — Two typed sides, green with docs

FP slice (one ODD slice): `Either` with left/right sides over two arbitrary types. Ships the package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call + gate lift): standing VISION MVP-line order; owner orders verbatim: "Manda either" — this IS the explicit owner package-creation call the README demands for gated packages, and it lifts the `either` gate ("same gate as Axiom's" declared-future row).
- S2 (scope): `lib/src/either.dart` + `test/either_test.dart`, following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic` outside codec edges. T0 gap-proof folds into T1's briefing: the writer proves the typed teaching gap against `Result` (success/failure sum type), `(value, present)` records (presence, not two types), and `Object?`+`is`-checks (untyped branching) — with one-line justifications citing REFERENCES IDs — or returns no-gap evidence for an owner call. Killing is reportable; stubbing is not. Exact export names are the writer's proposal; T2 verifies them against thesis invariant 3.
- S3 (SDK honesty): `dart:core` owns no two-type sum (`Object?` + `is` is untyped branching, not a named pair) — ship only the proven gap, each symbol justified with a REFERENCES ID; anything the SDK or a sibling package owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export(s), README index row(s), scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn. CI evidence comes from Conduit (job per work unit) plus the local gates the writer runs.
- S5 (fidelity): contrast Axiom's `either` (owner-authorized local exploration — the gate names it; read how Axiom gates/uses it); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 (+T0 gap-proof) | bounded writer, `lib/src/either.dart` + `test/either_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE with gap-proof first, Which-table per export, edge + purity pins, `dart doc` clean). T2 closes (barrel export row flips, README row, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Manda either" (explicit package-creation call; lifts the `either` gate).
- L2: ODD opened on branch `feat/praxis-either` (from main `2cae990`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit). T0 gap-proof (Result sum vs records vs untyped branching; Axiom either gate) folds into T1's briefing.
- L3 (T2 naming verdict + pilot + docs-sync — VALIDATION_GATES rows 1–6, fail-closed, all resolve): naming verified unchanged from T1 — `Either`, `Either.left`/`Either.right`, `Left`/`Right` (+ `when`/`mapRight`/`mapLeft`/`swap`/`toResult`); thesis invariant 3 clean; barrel Which-row carries all symbols. Pilot `.tmp/pilot.dart` extended (spawning prose: `Either.right(7)` → `when` reads `right:7` via barrel; pilot initially called non-existent `left:`/`right:` params — corrected to `onLeft:`/`onRight:` per the `when` signature before green); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 21 files; README Ships now names all twenty-one). Row 2 `checked` (README index row flipped from `declared future (same gate as Axiom's)` to `either — shipped` + `export 'src/either.dart'` alphabetical (`di` < `either` < `flow`) per `directives_ordering` + executed suite `dart test test/either_test.dart` 49/49 green + full `dart test` 653 green). Row 3 `checked` (barrel Which-row names all either symbols + per-export Which-rows in `lib/src/either.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no either|out-of-scope|YAGNI` across README: zero hits covering the shipped helper). Row 5 `checked` (README `either` index row flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-either.md`, set at T0, untouched by this unit).
- L5 (R22 native review of the either slice burned — lineage review-96b83eb23b418d12 APPROVED + burned (readability+reliability, 1196 lines, group 2/2 clean via pi_host_relay); 5 SUGGESTIONs parked informational in their OWN ledger row (R2-DUP-WHICH-TABLE SUGGESTION either.dart:17-51, R2-TEST-TYPE-ECHO SUGGESTION test/either_test.dart:55-105, R2-TRIVIAL-BOILERPLATE SUGGESTION either.dart:120-163, R3-001 SUGGESTION test/either_test.dart:636-675, R3-002 SUGGESTION either.dart:459-468) — zero WARNINGs; rows R1–R21 untouched, no finding overwritten; Conduit CI job-1793018562514611700 green on this candidate (test 653 + analyze + format, 3 exits 0); delivery per ordinary policy.
- L4 (work-unit record): T1+T2 land together in `a853f9b` (1195 insertions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting the 600-line implementation from its 678-line pin suite or the barrel/README rows would break the reviewable unit; same disposition as httpx/collections, native review takes it as one candidate). Parent re-ran the scoped suite on the final state (`dart test test/either_test.dart` 49/49 green) plus full gates (`dart test` 653, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
