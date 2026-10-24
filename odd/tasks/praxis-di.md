# praxis-di — `di` named services green with docs

Decimotercer library slice (infra wall, third infra package: named singleton services — register once by key, resolve by key, with lifecycle hooks — the small service-locator shape the SDK never names). Ships the `di` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order after `singleflight` (owner: "Siguiente slice"); `di` is next in the written sequence.
- S2 (scope): named service registration + resolution (register factory/singleton under a key, resolve with lazy singleton semantics, reset/unregister for tests, optional dispose hooks) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (duplicate registration, missing-key resolve, reset isolation, lazy-once semantics), no `dynamic`. No auto-wiring/reflection (thesis invariant 10), no scopes/hierarchies (that belongs to a future design, not this slice).
- S3 (SDK honesty): no SDK service locator exists (`Map` is storage, not lifecycle with lazy-singleton + dispose semantics) — ship only that gap, each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's `di` package if present, else Axiom's package-organization discipline (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/di.dart` + `test/di_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, edge + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `di`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Siguiente slice" — taken as the next VISION MVP-line item after `singleflight`, i.e. `di`.
- L2: ODD opened on branch `feat/praxis-di` (from main `60aa4a6`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (T2 naming verdict): `di` + five exports (`ServiceContainer`, `register`, `resolve`, `unregister`, `reset`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able nouns/verbs, `serviceName`/`flightRuns`-style locals, no single-letter/abbreviated/generic names); barrel Which-row carries all five symbols.
- L4 (T2 pilot + docs-sync verdict — VALIDATION_GATES rows 1–6, fail-closed, all resolve): pilot `.tmp/pilot.dart` extended (sync di happy path via barrel: register → resolve `hello` → unregister → re-register `hi` → resolve; asserts both reads); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 13 files; README Ships now names all thirteen). Row 2 `checked` (README index row flipped to `di — shipped` + `export 'src/di.dart'` alphabetical (`di` < `flow`) per `directives_ordering` + executed suite `dart test test/di_test.dart` 22/22 green + full `dart test` +458 green at close-out). Row 3 `checked` (barrel Which-row names all five di symbols + per-export Which-rows in `lib/src/di.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no di|no service|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; T1 YAGNI kills for Replace/auto-wiring/scopes stand as correctly scoped). Row 5 `checked` (the one roadmap line naming this scope — README `di` index row — flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-di.md`, set at T0, untouched by this unit).
- L5 (work-unit record): T1+T2 land together in `59dfabf` (679 insertions, 4 deletions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting the 328-line implementation from its 318-line pin suite or the barrel/README rows would break the reviewable unit; same disposition as flow R12 (1468) and earlier slices, native review takes it as one 2-lens candidate). Parent re-ran the scoped suite on the final state (`dart test test/di_test.dart` 22/22 green) plus full gates (`dart test` +458, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
