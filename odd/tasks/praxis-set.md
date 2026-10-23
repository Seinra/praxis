# praxis-set — `set` distinct-value helpers green with docs

Second library slice (first wall after the skeleton). Ships the `set` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "Y vamos por tu recomendacion de set" — owner's explicit package-creation order for the first wall.
- S2 (scope): `Set<T>` distinct-value helpers following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic`, sealed teaching style where it teaches.
- S3 (SDK honesty): `dart:core` `Set` already owns `union`/`intersection`/`difference`/`containsAll` — ship only proven gaps (e.g. symmetric difference), each justified with a REFERENCES ID in its doc comment; anything the SDK owns is YAGNI-killed, never wrapped.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0.
- S5 (fidelity): contrast Axiom's `set` package (owner picked set first there too); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/set.dart` + `test/set_test.dart` | b2ade47 |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | b2ade47 |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, purity + never-mutate pins, `dart doc` clean). T2 closes (barrel export, README row flip for `set`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner package-creation order, verbatim): "Y vamos por tu recomendacion de set".
- L2 (2026-10-23): ODD opened on branch `feat/praxis-set`; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit); skeleton chain delivered (R1–R4 burned, PR #2 merged, issue #1 closed).
- L3 (2026-10-23, T1 verified by parent): full read-back of `lib/src/set.dart` (Which-tables, stdlib-gap justifications with REFERENCES IDs, purity + never-mutate pins hold), `dart test test/set_test.dart` 49/49 green, YAGNI kills recorded (SDK-owned `union`/`intersection`/`difference`/`containsAll` never wrapped); re-verified in a T2 scoped run, 49/49 green.
- L4 (2026-10-23, T2 naming verdict — record only, zero renames): `symmetricDifference`/`isSubsetOf`/`isSupersetOf`/`isDisjointFrom`/`hasSameMembers` mirror the Axiom `set` precedent per S5 (each doc comment cites its REFERENCES ID); `firstSets`/`secondSets` are plural nouns, `candidateMember` the descriptive loop binding, `differed` carries the either-side outcome. No thesis invariant-3 ban triggered — keep all names.
- L5 (2026-10-23, T2 scratch pilot — `.tmp/pilot.dart`, gitignored, never committed): `dart .tmp/pilot.dart` → `exit=0`, output `ok→getOrElse: 21` / `present→valueOr: 4` / `findElement→present: true value=91` / `symmetricDifference→containsAll: true length=3` (one `set` happy path through the barrel: symmetricDifference→containsAll; asserts held; prior three package paths re-printed unchanged).
- L6 (2026-10-23, T2 docs-sync verdict, VALIDATION_GATES rows 1–6): (1) checked — `ls lib/src/*.dart` → 4 files, README Ships-now cell names `result`+`opt`+lists+`set`. (2) checked — this unit carries the new-package wiring: barrel export + index row flip (`git diff --stat`: `lib/praxis.dart` +2, `README.md` 2+/2-) + executed suite (scoped `set` 49/49, full `dart test` 169 green). (3) checked — barrel Which-package `set` row (`lib/praxis.dart:13`) resolves to the package-doc Which-table (`lib/src/set.dart`); no `docs/` dir, no separate family guide. (4) checked — no `docs/` dir; README contradiction scan (`out-of-scope|YAGNI|never ship|no set|without set`) → zero hits; the only `set`-as-future line was the index row, flipped in this unit. (5) checked — stale scope lines leave in this unit (`set` index row → `set — shipped`, Ships-now cell extended with the set slice); remaining 13 declared-future index rows byte-identical. (6) checked — `loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-set.md` (set at T0, lands with the unit; read-only in T2).
- L7 (2026-10-23, work-unit size note): the unit carries 710 authored lines (one package + 49 tests + wiring), past the ~400 advisory slice. Kept whole: splitting lib from tests would violate keep-tests-with-code, and the wiring without the package explains nothing. Native review takes it as one 2-lens candidate, same scale as R1 (788 lines).
- L8 (2026-10-23, parent mutation probe, uncommitted): inverted one `contains` in `symmetricDifference` → suite went red (+43 -6, 6 failures incl. documented example); reverted → 49/49 green. Oracles are independent; `git status` confirms zero trace left in `lib/src/set.dart`.
- L9 (2026-10-23): R5 native review of the set slice burned — lineage review-9675af03d618cf2f APPROVED + burned (readability+reliability, 748 lines, group 2/2 clean via pi_host_relay, no resubmits); 4 advisories parked informational in their OWN ledger row (R2-001 set.dart:156-161, R2-002 test:5-13, R3-set-table-alignment-2 set.dart:25, R3-tests-via-internal-import-1 test:1 — all SUGGESTION) — skeleton rows R1–R4 untouched, no finding overwritten; scratch worktree removed; delivery per ordinary policy.
- L9 (2026-10-23, verifier suggestions 1+2 adopted per owner order): `firstSets`/`secondSets` → `firstMembers`/`secondMembers` (content-plural, set-theory vocabulary), local `differed` → `difference` (defer/differ ambiguity); positional params, zero API break; suite 169/169 + analyzer + format re-greened; committed as `128f043` refactor unit on this branch.
