# praxis-pipecompose — Pipe/compose function combinators, green with docs

FP slice (one ODD slice): left-to-right `pipe` and right-to-left `compose` over typed unary functions. Ships the package(s) only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order, next after task per priority (`either` stays gated; Pipe/Compose is the last named infrastructure item); owner order verbatim: "Sigamos atacando por orden de prioridad".
- S2 (scope): `lib/src/pipe.dart` (+ `lib/src/compose.dart` iff the gap-proof earns a distinct second shape) + tests, following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic` outside typed wrappers. T0 gap-proof folds into T1's briefing: the writer proves the typed teaching gap against cascade/method chaining (SDK call syntax already sequences calls), `Result.mapValue`/`andThen` (already compose outcome-level steps), and `flow`/`singleflight`/`task` (already own concurrency shapes) — with one-line justifications citing REFERENCES IDs — or returns no-gap evidence for an owner call. Killing a shape is reportable; stubbing is not. Exact export names are the writer's proposal; T2 verifies them against thesis invariant 3.
- S3 (SDK honesty): call syntax and cascades own sequencing; `Result` owns outcome chaining — ship only the proven gap, each symbol justified with a REFERENCES ID; anything the SDK or a sibling package owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export(s), README index row(s), scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn. CI evidence comes from Conduit (job per work unit) plus the local gates the writer runs.
- S5 (fidelity): contrast Axiom's pipe/compose-adjacent helpers if present (owner-authorized local exploration; Go has no pipe idiom — a missing contrast is a valid reported outcome, never an invented one); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 (+T0 gap-proof) | bounded writer, `lib/src/pipe.dart` (+ `compose.dart` iff earned) + tests | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package(s) (RED → GREEN → TRIANGULATE with gap-proof first, Which-table per export, edge + purity pins, `dart doc` clean). T2 closes (barrel export rows flip, README rows, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Sigamos atacando por orden de prioridad" (Pipe/Compose next; `either` stays gated).
- L2: ODD opened on branch `feat/praxis-pipecompose` (from main `d4cbd54`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit). T0 gap-proof (call syntax vs Result chaining vs concurrency shapes) folds into T1's briefing.
- L3 (T2 naming verdict + pilot + docs-sync — VALIDATION_GATES rows 1–6, fail-closed, all resolve): naming verified unchanged from T1 — `pipe` + `compose` (binary, both directions co-located; type params `InputValue`/`BridgeValue`/`OutputValue` are descriptive role names, thesis invariant 3 clean); barrel Which-row carries both symbols. Pilot `.tmp/pilot.dart` extended (pipe 3→7, compose 3→7 via barrel); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 20 files; README Ships now names all twenty). Row 2 `checked` (README index row added for `pipe` + `export 'src/pipe.dart'` alphabetical (`orderedmap` < `pipe` < `pool` < `queue`, pi-lens autofix verified) per `directives_ordering` + executed suite `dart test test/pipe_test.dart` 13/13 green + full `dart test` 604 green). Row 3 `checked` (barrel Which-row names both pipe symbols + per-export Which-rows in `lib/src/pipe.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no pipe|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; `compose.dart` kill rationale lives in T1's gap-proof). Row 5 `checked` (README `pipe` index row added in this unit; barrel future-scope sentence + Ships now updated in the same unit; no stale roadmap line named pipe). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-pipecompose.md`, set at T0, untouched by this unit).
- L5 (R21 native review of the pipe slice burned — lineage review-a22c9e8e71c03dee APPROVED + burned (readability+reliability, 331 lines, group 2/2 clean via pi_host_relay after one provider-side transport failure on the first submit — fresh STATUS reoffered the same 2 slots, retry admitted clean); 4 SUGGESTIONs parked informational in their OWN ledger row (R2-readability-1 SUGGESTION README.md:73, R2-readability-2 SUGGESTION pipe.dart:103-118, R2-readability-3 SUGGESTION pipe.dart:75-122, R3-second-leg-failure-unexercised SUGGESTION pipe.dart:29-31) — zero WARNINGs; rows R1–R20 untouched, no finding overwritten; Conduit CI job-1793017518669180100 green on this candidate (test 604 + analyze + format, 3 exits 0); delivery per ordinary policy.
- L4 (work-unit record): T1+T2 land together in `f77cd7b` (327 insertions per diff stat — fits the ~400 advisory slice; single reviewable unit). Parent re-ran the scoped suite on the final state (`dart test test/pipe_test.dart` 13/13 green) plus full gates (`dart test` 604, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
