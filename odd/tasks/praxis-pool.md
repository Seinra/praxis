# praxis-pool — `pool` object-reuse helpers green with docs

Ninth library slice (infra wall, first infra package: sync object reuse — acquire/release over a bounded idle set, a borrow helper for scoped use — the small sync shape the SDK never names). Ships the `pool` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order after `flow` (owner: "Siguiente slice"); `pool` is next in the written sequence.
- S2 (scope): sync object-reuse helpers (bounded idle set, acquire/release, scoped borrow) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (empty pool, exhausted pool, double-release, reset-on-release), no `dynamic`. Async-aware pooling (waiting acquirers, timeouts) stays OUT — that belongs to a future `flow`-crossing design, not this slice.
- S3 (SDK honesty): `dart:core`/`dart:collection` name no reuse pool (`Queue`/`List` are storage, not lifecycle) — ship only the lifecycle gap (bounded idle set with factory + reset + discard rules), each justified with a REFERENCES ID; a hand-rolled free-list over SDK collections is the gap, never a reimplementation.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's `pool` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/pool.dart` + `test/pool_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, edge + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `pool`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Siguiente slice" — taken as the next VISION MVP-line item after `flow`, i.e. `pool`.
- L2: ODD opened on branch `feat/praxis-pool` (from main `c288558`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (T2 naming verdict): `pool` + six exports (`Pool`, `acquire`, `release`, `use`, `idleCount`, `maxSize`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able verbs, `borrowedValue`/`idleValues`/`maxSize`, no single-letter/abbreviated/generic names); barrel Which-row carries all six symbols.
- L4 (T2 pilot + docs-sync verdict — VALIDATION_GATES rows 1–6, fail-closed, all resolve): pilot `.tmp/pilot.dart` extended (sync pool happy path via barrel: acquire → write → release → `idleCount == 1`, re-acquire identical buffer); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 11 files; README Ships now names all eleven). Row 2 `checked` (README index row flipped to `pool — shipped` + `export 'src/pool.dart'` alphabetical (`opt` < `pool` < `result`) per `directives_ordering` + executed suite `dart test test/pool_test.dart` 14/14 green + full `dart test` +427 green at close-out). Row 3 `checked` (barrel Which-row names all six pool symbols + per-export Which-rows in `lib/src/pool.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no pool|no reuse|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; T1 lifecycle YAGNI stands as correctly scoped). Row 5 `checked` (the one roadmap line naming this scope — README `pool` index row — flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-pool.md`, set at T0, untouched by this unit).
- L5 (work-unit record): T1+T2 land together in `f458abc` (511 insertions, 4 deletions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting the 287-line pool implementation from its 191-line test suite or the barrel/README rows would break the reviewable unit; same disposition as flow R12 (1468) and earlier slices, native review takes it as one 2-lens candidate). Parent re-ran the scoped suite on the final state (`dart test test/pool_test.dart` 14/14 green) plus full gates (`dart test` +427, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
- L6 (R13 native review of the pool slice burned — lineage review-3687abd5ba77a4a6 APPROVED + burned (readability+reliability, 516 lines, group 2/2 clean via pi_host_relay with inner-binding form after one self-caught transcription slip); 4 advisories parked informational in their OWN ledger row (R2-double-release-doc-mismatch WARNING pool.dart:205-207, R3-alias-gap WARNING pool.dart:221-239, R3-release-after-discard-reset SUGGESTION pool.dart:231-238, R3-use-both-throw SUGGESTION pool.dart:275-282) — rows R1–R12 untouched, no finding overwritten; delivery per ordinary policy. Learned: the group validator cross-checks every token — a single R12-target hash pasted into one R13 argumentToken fails the whole group; re-read each hash at resubmission.
