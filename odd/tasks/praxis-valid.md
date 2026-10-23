# praxis-valid — `valid` predicate combinators green with docs

Fifth library slice (first fixture wall: composable predicates used everywhere — forms, exams, guards). Ships the `valid` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "Lanza valid" — owner's explicit package-creation order.
- S2 (scope): predicate combinators over `bool Function(Value)` (And/Or/Not plus named small builders where they teach) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (vacuous truth, short-circuit), no `dynamic`.
- S3 (SDK honesty): `dart:core` owns `&&`/`||`/`!` over `bool` — ship only the *combinator* gap (composing predicate *functions*, testing them, naming them for course material), each justified with a REFERENCES ID; anything the operators already do inline is YAGNI-killed with a reason. No validation framework, no error-accumulation machinery (that is a future `repo`/`httpx` adapter concern, not this slice).
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0.
- S5 (fidelity): contrast Axiom's `valid` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/valid.dart` + `test/valid_test.dart` | 8f67788 |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | 8f67788 |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, vacuous-truth + short-circuit pins, `dart doc` clean). T2 closes (barrel export, README row flip for `valid`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner package-creation order, verbatim): "Lanza valid".
- L2 (2026-10-23): ODD opened on branch `feat/praxis-valid`; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit); iterx delivered (R7 burned, PR #8 merged, issue #7 closed).
- L3 (T2 naming verdict, 2026-10-23): `valid` + six exports (`Predicate`, `andPredicates`, `orPredicates`, `notPredicate`, `alwaysTrue`, `alwaysFalse`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able verbs, no single-letter/abbreviated/generic names); barrel Which-row in `lib/praxis.dart` carries all six symbols.
- L4 (T2 pilot note, 2026-10-23): `.tmp/pilot.dart` extended with one `valid` happy path through `package:praxis/praxis.dart` (`andPredicates<int>([(candidate) => candidate >= 60, (candidate) => candidate.isEven])` → 84 holds, 83 fails); `dart .tmp/pilot.dart` exit 0 — output: `ok→getOrElse: 21`, `present→valueOr: 4`, `findElement→present: true value=91`, `symmetricDifference→containsAll: true length=3`, `invertEntries→grouped: {1: [ann, cid], 2: [bob]}`, `zipIterables→paired: [(first: 1, second: a), (first: 2, second: b)]`, `andPredicates→passingEven: 84=true 83=false`.
- L5 (T2 docs-sync verdict, 2026-10-23 — VALIDATION_GATES rows 1–6, fail-closed, all resolve): row 1 `checked` (`lib/src` holds 7 files — `ls` → iterx/lists/mapx/opt/result/set/valid; README Ships now names all seven: skeleton 3 + set + mapx + iterx + valid); row 2 `checked` (README index row flipped to `valid — shipped` + `export 'src/valid.dart'` last in `lib/praxis.dart` alphabetical per `directives_ordering` + executed suite `dart test test/valid_test.dart` 28/28 green + full `dart test` green at close-out); row 3 `checked` (barrel Which-row names all six valid symbols + per-export Which-rows in `lib/src/valid.dart`; no separate family guide exists — `docs/` absent — so no mirror claim to drop); row 4 `checked` (grep new symbols across README + repo: zero `no X / out-of-scope / YAGNI` lines cover the shipped combinators; T1 YAGNI kills for nil-leg guards via sound null safety and validation-framework/error-accumulation as future `repo`/`httpx` concern stand as correctly scoped); row 5 `checked` (the one roadmap line naming this scope — README `valid` index row — flips in this unit; barrel future-scope sentence + README Ships now updated in the same unit); row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-valid.md`, set at T0, untouched by this unit).
- L6 (2026-10-23, work-unit record): T1+T2 land together in `8f67788` (576 insertions per diff stat, past the ~400 advisory slice — kept whole per keep-tests-with-code, same disposition as set L7, mapx L6 and iterx L6; native review takes it as one 2-lens candidate). Parent re-ran the scoped suite on the final state (`dart test test/valid_test.dart` 28/28 green) plus full gates before committing.
