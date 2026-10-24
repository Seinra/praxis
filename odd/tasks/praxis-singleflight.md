# praxis-singleflight — `singleflight` duplicate-suppression green with docs

Twelfth library slice (infra wall, second infra package: duplicate suppression for concurrent async calls — callers sharing one key share one in-flight execution instead of stampeding the backend). Ships the `singleflight` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): standing VISION MVP-line order after `pool` (owner: "Siguiente slice"); `singleflight` is next in the written sequence.
- S2 (scope): sync-registered, async-shared call dedupe (one in-flight `Future` per key; late joiners share it; errors propagate to all sharers; completion forgets the key) following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (same-key concurrent join, sequential calls re-execute, error sharing, key isolation, distinct keys run apart), no `dynamic`. No cache with TTL (that is a `repo` concern), no cross-isolate sharing (app concern, out of scope).
- S3 (SDK honesty): no SDK combinator shares one in-flight future across callers (`Future.wait` joins known futures; `Stream` shares subscriptions, not executions; no memoization primitive) — ship only that gap (per-key in-flight sharing), each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Zero runtime dependencies.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of this implementation turn.
- S5 (fidelity): contrast Axiom's `singleflight` package (owner-authorized local exploration); mirror its discipline (share in-flight, forget on settle, propagate errors), never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/singleflight.dart` + `test/singleflight_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, edge + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `singleflight`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner order, verbatim): "Siguiente slice" — taken as the next VISION MVP-line item after `pool`, i.e. `singleflight`.
- L2: ODD opened on branch `feat/praxis-singleflight` (from main `1cc787e`, tree clean); `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (T2 naming verdict): `singleflight` + two exports (`SingleflightGroup`, `call`) verified unchanged from T1 — zero renames; thesis invariant 3 clean (grep-able nouns/verbs, `requestKey`/`flightRuns`, no single-letter/abbreviated/generic names); barrel Which-row carries both symbols.
- L4 (T2 pilot + docs-sync verdict — VALIDATION_GATES rows 1–6, fail-closed, all resolve): pilot `.tmp/pilot.dart` extended (singleflight happy path via barrel with a run counter: first call → 41, sequential recall → 42 with `flightRuns == 2`, pinning re-execution instead of caching); `dart .tmp/pilot.dart` exit 0. Row 1 `checked` (`lib/src` holds 12 files; README Ships now names all twelve). Row 2 `checked` (README index row flipped to `singleflight — shipped` + `export 'src/singleflight.dart'` alphabetical (`set` < `singleflight` < `strings`) per `directives_ordering` + executed suite `dart test test/singleflight_test.dart` 9/9 green + full `dart test` +436 green at close-out). Row 3 `checked` (barrel Which-row names both singleflight symbols + per-export Which-rows in `lib/src/singleflight.dart`; `docs/` absent so no mirror claim to drop). Row 4 `checked` (grep `no singleflight|no dedupe|out-of-scope|YAGNI` across README: zero hits covering the shipped helpers; T1 YAGNI kills for wait/fromFutures/memoization stand as correctly scoped). Row 5 `checked` (the one roadmap line naming this scope — README `singleflight` index row — flips in this unit; barrel future-scope sentence + Ships now updated in the same unit). Row 6 `checked` (`loop-config.yaml` read-back `currentFeature: odd/tasks/praxis-singleflight.md`, set at T0, untouched by this unit).
- L5 (work-unit record): T1+T2 land together in `0a9e362` (389 insertions, 4 deletions per diff stat — inside the ~400 advisory slice; native review takes it as one 2-lens candidate). Parent re-ran the scoped suite on the final state (`dart test test/singleflight_test.dart` 9/9 green) plus full gates (`dart test` +436, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0) before committing.
