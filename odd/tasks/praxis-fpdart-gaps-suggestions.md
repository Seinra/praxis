# praxis-fpdart-gaps-suggestions — Adopt the 3 SUGGESTION gaps (chain 2/2)

Additive API slice (no existing behavior changes): pure sort, extremes by derived key, lazy drop-last, each with Which-row, stdlib-gap doc, CI-executed example, and purity pins. Parked until chain 1/2 (`praxis-fpdart-gaps-warnings`) merges; then branches from post-merge main.

## Specs

- S1 (creation calls, owner verbatim): "Dale, seamos estrictos para estar seguros" + "(custom) Adoptamos los 5 gaps pero antes de implementar nada, decime que significa eso de que "iterx excede a fpdart en 6 adapters"" + "Abri el slice." + "Slice o slice t-chain dependiendo el tamaño que necesites".
- S2 (scope — SUGGESTION tier only, from the parent-verified audit ledger `praxis/audit/fpdart-gap-01`): (a) `sortedElements` in `lib/src/lists.dart`: `List<Element> sortedElements<Element>(List<Element> elements, Comparator<Element>? compare)`; Which-row "Sorted copy, input untouched → sortedElements"; SDK pain: `sort` mutates in place, fresh pipelines need the unnamed `List.of(x)..sort()` idiom. (b) `minElementBy`/`maxElementBy` in `lib/src/lists.dart`: `({Element? value, bool present}) minElementBy<Element, ExtractedKey extends Comparable<Object>>(List<Element> elements, ExtractedKey Function(Element) keyOf)` + `maxElementBy` twin; Which-rows "Smallest by a derived key → minElementBy" / "Largest by a derived key → maxElementBy"; SDK pain: no `minBy`, manual fold-with-comparator-over-extract. (c) `dropRightElements` in `lib/src/iterx.dart`: `Iterable<Element> dropRightElements<Element>(Iterable<Element> sourceElements, int droppedCount)`; Which-row "Drop the last n, lazily → dropRightElements"; SDK pain: `skip` drops from front only, `reversed.take`+`reverse` materializes; eager `ArgumentError` on bad count + lazy queue-buffer body per the `windowedIterable` convention.
- S3 (accepted shape, per CONTRIBUTING): same as chain 1/2 — Which row + `DART-SDK` gap doc + CI example + pins; guides mirror verbatim; barrel rows.
- S4 (close-out): same gates as chain 1/2; STATUS.md Log row; work-unit commit(s) on its own `feat/praxis-fpdart-gaps-suggestions` branch (from post-merge main); mirror update; push/PR owner-gated.
- S5 (fidelity): own-file discipline + `AXIOM-SISTER` tags where precedent is real (cycle/window conventions for S2c); no new Axiom contrast needed.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S2(a), S2(b), S3 | bounded writer | — |
| T2 | S2(c), S3 | bounded writer (disjoint surfaces from T1, parallelizable) | — |
| T3 | S4 | orchestrator: barrel rows, gates, STATUS row, commit(s), mirror | — |

Allowed edit surfaces: T1 `lib/src/lists.dart`, `test/lists_test.dart`, `docs/guides/lists.md`; T2 `lib/src/iterx.dart`, `test/iterx_test.dart`, `docs/guides/iterx.md`; T3 adds `lib/praxis.dart` (barrel rows only), `STATUS.md`, `CHANGELOG.md` if convention calls for it.

## Log

- L1 (owner orders, verbatim): "Dale, seamos estrictos para estar seguros" + "(custom) Adoptamos los 5 gaps pero antes de implementar nada, decime que significa eso de que "iterx excede a fpdart en 6 adapters"" + "Abri el slice." + "Slice o slice t-chain dependiendo el tamaño que necesites".
- L2 (parked as chain 2/2): no branch yet — opens from post-merge main after chain 1/2 lands; size est ≈ 260 authored lines (under the ~400 guard); pointer flips here at its turn.
- L3 (opened 2026-11-06): branch `feat/praxis-fpdart-gaps-suggestions` from post-merge main `fa8928f`, tree clean; `loop-config.yaml` `currentFeature` points here; T1+T2 dispatched in parallel (disjoint surfaces).
- L4 (close-out 2026-11-06): T1 verified inline (impl read + `dart analyze` clean + 98 lists tests re-run green, incl. 3 doc-example pins; mutation probe writer-run) → commit C1. T2 verified inline (impl read + `dart analyze` clean + 74 iterx tests re-run green, incl. writer mutation probe + laziness pins; no CRLF) → commit C2 with barrel rows + STATUS Log. Full gates on final tree: `dart test` 775 green, `dart analyze` clean, `dart format` clean (one test-file alignment fix re-verified 172), `dart doc` 4 pre-existing warnings only. Docs-sync: guides mirror Which-tables verbatim, barrel synced; guide Examples intentionally untouched (asserted by `docs_guides_a_test`, out of slice scope). Mirror updated. Push/PR owner-gated; finding-slice opens its branch from post-chain-2 main.
