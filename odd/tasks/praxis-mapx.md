# praxis-mapx — `mapx` helpers over `Map` green with docs

Third library slice (second wall; completes the `lists` → `set` → `mapx` collections wall). Ships the `mapx` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): owner picked the recommendation — "Crealo y larga, inyecta las skills correctas eh" (mapx follows the set wall per owner order).
- S2 (scope): `Map<Key, Value>` helpers — the first two-type-param package (new teaching dimension after single-`T` slices). Skeleton conventions hold: Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic`, sealed teaching style where it teaches.
- S3 (SDK honesty): `dart:core` `Map` already owns `map`/`keys`/`values`/`containsKey`/`update`/`putIfAbsent`/`addAll`/`remove` — ship only proven gaps (e.g. invert, omit/pick, typed key/value transforms, group-by over entries), each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0.
- S5 (fidelity): contrast Axiom's `mapx` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/mapx.dart` + `test/mapx_test.dart` | 9d8a5bd |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | 9d8a5bd |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, purity + never-mutate pins, `dart doc` clean). T2 closes (barrel export, README row flip for `mapx`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner package-creation order, verbatim): "Crealo y larga, inyecta las skills correctas eh" (mapx, following the `set` wall per owner-accepted recommendation).
- L2 (2026-10-23): ODD opened on branch `feat/praxis-mapx`; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit); set delivered (R5 burned, PR #4 merged, issue #3 closed).
- L3 (2026-10-23, T2 naming verdict): PASS — `invertEntries`, `pickEntries`, `omitEntries`, `mapValues`, `mapKeys`, `groupEntriesBy` carry full-word names; params (`wantedKeys`, `excludedKeys`, `transformValue`, `groupOf`) name their role; no single-letter identifiers, no `data`/`item`/`res`; `mapx` package name mirrors the Axiom `mapx` precedent per S5 (T1 surfaces frozen, verify-only).
- L4 (2026-10-23, T2 pilot): `.tmp/pilot.dart` (gitignored scratch) extended with one `mapx` happy path through `package:praxis/praxis.dart` — `invertEntries({'ann': 1, 'bob': 2, 'cid': 1})` groups to `{1: [ann, cid], 2: [bob]}`; `dart .tmp/pilot.dart` exit 0, output `invertEntries→grouped: {1: [ann, cid], 2: [bob]}` (barrel export resolves).
- L5 (2026-10-23, T2 docs-sync verdict 6/6): row 1 checked (`lib/src` holds 5 non-test `.dart` — lists, mapx, opt, result, set — and README Ships-now names all 5); row 2 checked (this unit carries the new-package wiring — `lib/praxis.dart` barrel export + Which-row, README index row flip, executed suite `dart test test/mapx_test.dart` 40/40); row 3 checked (`invertEntries` Which-row in barrel `lib/praxis.dart:14` and package Which-table `lib/src/mapx.dart:14`; no separate family guide exists — no `docs/` dir); row 4 checked (zero `no mapx` / out-of-scope hits across `README.md` + `lib/praxis.dart`); row 5 checked (`mapx` declared-future row leaves in this unit's README diff); row 6 checked (`loop-config.yaml` `currentFeature: odd/tasks/praxis-mapx.md`, set at T0).
- L7 (2026-10-23, parent mutation probe, uncommitted): inverted one `containsKey` in `pickEntries` → suite went red (+33 -7, incl. documented example); reverted → 40/40 green. Oracles are independent; `git status` confirms zero trace left in `lib/src/mapx.dart`.
- L8 (2026-10-23): R6 native review of the mapx slice burned — lineage review-899ea61284f164b1 APPROVED + burned (readability+reliability, 732 lines, group 2/2 clean via pi_host_relay, no resubmits); 3 advisories parked informational in their OWN ledger row (R2-mapkeys-collision-doc WARNING mapx.dart:197-200 + R2-entries-param-name and R2-pick-as-cast SUGGESTIONs) — skeleton rows R1–R4 and R5 untouched, no finding overwritten; scratch worktree removed; delivery per ordinary policy.
- L6 (2026-10-23, work-unit record): T1+T2 land together in `9d8a5bd` (731 authored lines, past the ~400 advisory slice — kept whole per keep-tests-with-code, same disposition as set L7; native review takes it as one 2-lens candidate). Parent re-ran the full suite on the final state (`dart test` 209/209 green) before committing.
