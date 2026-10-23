# praxis-iterx — `iterx` lazy adapters green with docs

Fourth library slice (closes the collections wall: eager `lists` vs lazy `iterx` — a core DLC chapter). Ships the `iterx` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "Vamos por iterx" — owner's explicit package-creation order, with standing instruction to inject the correct skill set on every delegation.
- S2 (scope): lazy `Iterable` adapters following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity (no hidden memoization unless documented) + edge pins, no `dynamic`, teaching the eager-vs-lazy split against `lists`.
- S3 (SDK honesty): `dart:core` `Iterable` already owns `map`/`where`/`expand`/`take`/`skip`/`followedBy`/`toList` — ship only proven gaps (e.g. zip, chunked/windows over iterables, cycle/repeat, dedupe, takeWhile/dropWhile), each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Laziness must be real: no eager `toList` inside adapters (pins prove it).
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0.
- S5 (fidelity): contrast Axiom's `iterx` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/iterx.dart` + `test/iterx_test.dart` | 1df3fbc |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | 1df3fbc |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, laziness + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `iterx`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner package-creation order, verbatim): "Vamos por iterx, inyecta el set de skills correcto cada vez que delegues".
- L2 (2026-10-23): ODD opened on branch `feat/praxis-iterx`; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit); mapx delivered (R6 burned, PR #6 merged, issue #5 closed).
- L3 (T2 naming verdict, 2026-10-23): `iterx` + six adapters (`zipIterables`, `chunkedIterable`, `windowedIterable`, `cycleIterable`, `repeatElement`, `deduplicateAdjacent`) verified unchanged from T1 — zero renames; barrel Which-row in `lib/praxis.dart` carries the eager-vs-lazy pointer (reach for `iterx` on lazy `Iterable` pipelines, eager `lists` on finished `List` values).
- L4 (T2 pilot note, 2026-10-23): `.tmp/pilot.dart` extended with one bounded `iterx` happy path through `package:praxis/praxis.dart` (`zipIterables(<int>[1, 2, 3], <String>['a', 'b'])` → 2 paired records, shorter side wins; no infinite source in the pilot); `dart .tmp/pilot.dart` exit 0 — output: `ok→getOrElse: 21`, `present→valueOr: 4`, `findElement→present: true value=91`, `symmetricDifference→containsAll: true length=3`, `invertEntries→grouped: {1: [ann, cid], 2: [bob]}`, `zipIterables→paired: [(first: 1, second: a), (first: 2, second: b)]`.
- L5 (T2 docs-sync verdict, 2026-10-23 — VALIDATION_GATES rows 1–6, fail-closed, all resolve): row 1 `checked` (`lib/src` holds 6 files — `ls` → iterx/lists/mapx/opt/result/set; README Ships now names all six: skeleton 3 + set + mapx + iterx); row 2 `checked` (README index row flipped to `iterx — shipped` + `export 'src/iterx.dart'` first in `lib/praxis.dart` + executed suite `dart test` 269/269 green incl. T1's 60 iterx pins); row 3 `checked` (barrel Which-row names all six adapters + per-export Which-rows in `lib/src/iterx.dart`; no separate family guide exists — `docs/` absent — so no mirror claim to drop); row 4 `checked` (grep new symbols across README + repo: zero `no X / out-of-scope / YAGNI` lines cover them; T1 YAGNI kills for SDK-owned surface stand); row 5 `checked` (the one roadmap line naming this scope — README `iterx` index row — flips in this unit; barrel future-scope sentence updated in the same unit); row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-iterx.md`, set at T0, untouched by this unit).
- L6 (2026-10-23, work-unit record): T1+T2 land together in `1df3fbc` (1069 authored lines, past the ~400 advisory slice — kept whole per keep-tests-with-code, same disposition as set L7 and mapx L6; native review takes it as one 2-lens candidate). Parent re-ran the full suite on the final state (`dart test` 269/269 green) before committing.
- L7 (2026-10-23, parent mutation probe, uncommitted): flipped `==` to `!=` in `deduplicateAdjacent` → suite went red (+52 -8, incl. documented example); reverted → 60/60 green. Oracles are independent; `git status` confirms zero trace left in `lib/src/iterx.dart`.
