# praxis-taskfuture — background computation to join later, green with docs

Concurrency slice (one ODD slice): a join-later handle over background work. Ships the package(s) only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order, next after collections per priority (`either` stays gated; task/future before Pipe/Compose); owner granularity order verbatim: "Segui lanzando por orden de prioridad".
- S2 (scope): `lib/src/task.dart` (+ `lib/src/future.dart` iff the gap-proof earns a second file) + tests, following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic` outside codec edges. T0 gap-proof folds into T1's briefing: the writer proves the typed teaching gap against `Future` (SDK joins later already), `flow` (bounded fan-out with FlowScope), and `singleflight` (shared per-key execution: late joiners share, completion forgets) — with one-line justifications citing REFERENCES IDs — or returns no-gap evidence for an owner call. Killing is reportable; stubbing is not. Exact export names are the writer's proposal; T2 verifies them against thesis invariant 3.
- S3 (SDK honesty): `Future`/`async`-`await` own joining; `flow` owns bounded fan-out; `singleflight` owns per-key sharing — ship only the proven gap, each symbol justified with a REFERENCES ID; anything the SDK or a sibling package owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export(s), README index row(s), scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn. CI evidence comes from Conduit (job per work unit) plus the local gates the writer runs.
- S5 (fidelity): contrast Axiom's `task`/`future` packages (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 (+T0 gap-proof) | bounded writer, `lib/src/task.dart` (+ `future.dart` iff earned) + tests | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package(s) (RED → GREEN → TRIANGULATE with gap-proof first, Which-table per export, edge + purity pins, `dart doc` clean). T2 closes (barrel export rows flip, README rows, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner orders, verbatim): "Vamos por orden de prioridad" → next slice task/future ("Segui lanzando por orden de prioridad con su pack de skills correspondiente"); `either` stays gated.
- L2: ODD opened on branch `feat/praxis-taskfuture` (from main `0865560`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit). T0 gap-proof (Future vs flow vs singleflight) folds into T1's briefing.
- L3 (T2 naming verdict + pilot + docs-sync — VALIDATION_GATES rows 1–6, fail-closed, all resolve): naming verified unchanged from T1 — `Task` + `Task.spawn` + `Task.join` (join is an instance method, `await backgroundTask.join()`, documented and tested as such; barrel `[Task.join]` member reference matches the `[Pool.acquire]` precedent); thesis invariant 3 clean; barrel Which-row carries all symbols. Pilot `.tmp/pilot.dart` extended (spawn → join `done` via barrel); `dart .tmp/pilot.dart` exit 0 (pilot initially called a static `Task.join` — corrected to the instance method before green). Row 1 `checked` (`lib/src` holds 19 files; README Ships now names all nineteen). Row 2 `checked` (README index row flipped to `task — shipped` + `export 'src/task.dart'` alphabetical (`strings` < `task` < `valid`) per `directives_ordering` + executed suite `dart test test/task_test.dart` 7/7 green + full `dart test` 591 green). Row 3 `checked` (barrel Which-row names all task symbols + per-export Which-rows in `lib/src/task.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no task|out-of-scope|YAGNI` across README: zero hits covering the shipped helper; `future.dart` kill rationale lives in T1's gap-proof). Row 5 `checked` (README `task` index row flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-taskfuture.md`, set at T0, untouched by this unit).
- L4 (work-unit record): T1+T2 land together in `52b2917` (322 insertions per diff stat — fits the ~400 advisory slice; single reviewable unit). Parent re-ran the scoped suite on the final state (`dart test test/task_test.dart` 7/7 green) plus full gates (`dart test` 591, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
- L5 (R20 native review of the task slice burned — lineage review-4c2a5dcb4fb3002a APPROVED + burned (readability+reliability, 327 lines, group 2/2 clean via pi_host_relay); 3 advisories parked informational in their OWN ledger row (R2-1 WARNING test/task_test.dart:27-38, R3-1 WARNING test/task_test.dart:27-39, R3-2 SUGGESTION lib/src/task.dart:154-156) — zero BLOCKERs; rows R1–R19 untouched, no finding overwritten; Conduit CI job-1793016068204355400 green on this candidate (test 591 + analyze + format, 3 exits 0); delivery per ordinary policy.
