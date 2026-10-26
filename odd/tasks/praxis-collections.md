# praxis-collections — `stack` + `queue` + `orderedmap` helpers green with docs

Collections slice (one ODD slice, three packages): typed helpers over stack, queue, and insertion-ordered-map shapes. Ships the three packages only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order, owner granularity order verbatim: "Los tres juntos" (Stack+Queue+OrderedMap in one slice; `either` stays gated).
- S2 (scope): one file per package (`lib/src/stack.dart`, `lib/src/queue.dart`, `lib/src/orderedmap.dart`) + tests, following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic` outside codec edges. T0 gap-proof folds into T1's briefing: for each structure the writer either proves a typed teaching gap over `dart:collection` (DART-SDK ID) with Which-table + example, or returns no-gap evidence for an owner call (killing a structure is a valid, reportable outcome — never a silent stub, never a thin SDK alias). Exact export names are the writer's proposal; T2 verifies them against thesis invariant 3.
- S3 (SDK honesty): `List` owns indexed stack ops, `dart:collection` `Queue` owns double-ended ops, `LinkedHashMap`/`SplayTreeMap` own insertion-ordered/sorted maps — ship only each proven gap, every symbol justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel exports, README index rows, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's collection helpers (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 (+T0 gap-proof per structure) | bounded writer, `lib/src/stack.dart` + `lib/src/queue.dart` + `lib/src/orderedmap.dart` + tests | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the packages (RED → GREEN → TRIANGULATE with gap-proof per structure, Which-table per export, edge + purity pins, `dart doc` clean). T2 closes (barrel exports, README rows flip for shipped packages, pilot happy paths, docs-sync rows, commit on this branch).

## Log

- L1 (owner orders, verbatim): "Vamos por orden de prioridad" → "Los tres juntos" (Stack+Queue+OrderedMap in one slice; `either` stays gated).
- L2: ODD opened on branch `feat/praxis-collections` (from main `667fe27`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit). T0 gap-proof per structure folds into T1's briefing (prove gap or return no-gap evidence; killing is reportable, stubbing is not).
- L3 (T2 naming verdict + pilot + docs-sync — VALIDATION_GATES rows 1–6, fail-closed, all resolve): naming verified unchanged from T1 — `Stack` (+push/pop/peek), `FifoQueue` (+enqueue/dequeue/peek), `OrderedMap` (+put/get/remove) + `LruCache`; thesis invariant 3 clean (grep-able nouns; `Fifo`/`Lru` are standard domain initialisms, not truncations — `Queue` left to the SDK to avoid the import clash, documented in the gap-proof); barrel Which-rows carry all symbols. Pilot `.tmp/pilot.dart` extended (stack pop 2, queue dequeue a, orderedmap get 1 via barrel); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 18 files; README Ships now names all eighteen). Row 2 `checked` (3 README index rows + 3 barrel exports alphabetical per `directives_ordering` + executed suite `dart test test/stack_test.dart test/queue_test.dart test/orderedmap_test.dart` 70/70 green + full `dart test` 584 green). Row 3 `checked` (barrel Which-rows name all package symbols + per-export Which-rows in each file; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no stack|no queue|no orderedmap|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers). Row 5 `checked` (3 README index rows added + barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-collections.md`, set at T0, untouched by this unit).
- L4 (work-unit record): T1+T2 land together in `9491a9c` (1794 insertions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting any of the three packages from its pin suite or the barrel/README rows would break the reviewable unit; same disposition as httpx `1798281`, native review takes it as one candidate). Parent re-ran the scoped suite on the final state (`dart test` stack+queue+orderedmap 70/70 green) plus full gates (`dart test` 584, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
