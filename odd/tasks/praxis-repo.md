# praxis-repo — `repo` identity-addressed records green with docs

Decimocuarto library slice (infra wall: typed in-memory record store keyed by identity — put/get/remove/list over records addressed by id, with typed access and fresh snapshots). Ships the `repo` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order after `di` (owner: "Siguiente slice"); `repo` is next in the written sequence.
- S2 (scope): identity-keyed record store (put by id with upsert-or-reject policy, get/remove by id, list snapshot, typed per-record access) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (missing id, duplicate put policy, empty store, snapshot freshness), no `dynamic`. No persistence/query language (that belongs to future adapter work, not this slice).
- S3 (SDK honesty): `Map` is keyed storage, not an identity lifecycle (no typed per-record access, no snapshot discipline, no duplicate-put policy) — ship only that gap, each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's `repo` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/repo.dart` + `test/repo_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, edge + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `repo`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Siguiente slice" — taken as the next VISION MVP-line item after `di`, i.e. `repo`.
- L2: ODD opened on branch `feat/praxis-repo` (from main `83c8ca9`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (T2 naming verdict): `repo` + five exports (`Repository`, `put`, `get`, `remove`, `list`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able nouns/verbs, `serviceName`-style callers, no single-letter/abbreviated/generic names); barrel Which-row carries all five symbols.
- L4 (T2 pilot + docs-sync verdict — VALIDATION_GATES rows 1–6, fail-closed, all resolve): pilot `.tmp/pilot.dart` extended (sync repo happy path via barrel: put → get present → remove true; all `Opt`-typed reads); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 14 files; README Ships now names all fourteen). Row 2 `checked` (README index row flipped to `repo — shipped` + `export 'src/repo.dart'` alphabetical (`pool` < `repo` < `result`) per `directives_ordering` + executed suite `dart test test/repo_test.dart` 24/24 green + full `dart test` +482 green at close-out). Row 3 `checked` (barrel Which-row names all five repo symbols + per-export Which-rows in `lib/src/repo.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no repo|no record|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; T1 YAGNI kills for persistence/paging/validation stand as correctly scoped). Row 5 `checked` (the one roadmap line naming this scope — README `repo` index row — flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-repo.md`, set at T0, untouched by this unit).
