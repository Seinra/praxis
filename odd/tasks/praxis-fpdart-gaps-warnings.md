# praxis-fpdart-gaps-warnings — Adopt the 2 WARNING gaps (chain 1/2)

Additive API slice (no existing behavior changes): absent-safe first/last of list + absent-safe map lookup, each with Which-row, stdlib-gap doc, CI-executed example, and OrNull/purity pins. Chain 2/2 (SUGGESTIONs) opens after this merges.

## Specs

- S1 (creation calls, owner verbatim): "Dale, seamos estrictos para estar seguros" + "(custom) Adoptamos los 5 gaps pero antes de implementar nada, decime que significa eso de que "iterx excede a fpdart en 6 adapters"" + "Abri el slice." + "Slice o slice t-chain dependiendo el tamaño que necesites".
- S2 (scope — WARNING tier only, from the parent-verified audit ledger `praxis/audit/fpdart-gap-01`): (a) `firstElement`/`lastElement` in `lib/src/lists.dart`: `({Element? value, bool present}) firstElement<Element>(List<Element> elements)` + `lastElement` twin; Which-rows "First element, presence-flagged → firstElement" / "Last element, presence-flagged → lastElement"; SDK pain: `first` throws `StateError`, `firstOrNull` confounds a stored null with absence. (b) `lookupValue` in `lib/src/mapx.dart`: `({Value? value, bool present}) lookupValue<Key, Value>(Map<Key, Value> entries, Key wantedKey)`; Which-row "Look one value up, presence-flagged → lookupValue"; SDK pain: `map[k]` null-confounds, `containsKey`+`[]` is two probes with a cast dance (already paid inline at `mapx.dart:95-98`).
- S3 (accepted shape, per CONTRIBUTING): per export Which-table row in package doc + doc comment with `DART-SDK` gap justification + runnable example + OrNull contract + purity/edge pins (empty, stored-null); guide (`docs/guides/lists.md`, `mapx.md`) mirrors the Which-table verbatim; barrel `lib/praxis.dart` doc-table rows for the new symbols.
- S4 (close-out): `dart test` (incl. `docs_guides` suites) + `dart analyze` + `dart format` green, `dart doc` no new warnings; STATUS.md Log row; work-unit commit(s) on `feat/praxis-fpdart-gaps-warnings`; mirror update; push/PR owner-gated. Chain 2/2 branches from post-merge main.
- S5 (fidelity): mirror each file's own established discipline (`findElement` OrNull spelling for S2a, `OrderedMap.get` presence semantics for S2b); `AXIOM-SISTER` tags where the precedent is real; no new Axiom contrast needed.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S2(a), S3 | bounded writer | — |
| T2 | S2(b), S3 | bounded writer (disjoint surfaces from T1, parallelizable) | — |
| T3 | S4 | orchestrator: barrel rows, gates, STATUS row, commit(s), mirror | — |

Allowed edit surfaces: T1 `lib/src/lists.dart`, `test/lists_test.dart`, `docs/guides/lists.md`; T2 `lib/src/mapx.dart`, `test/mapx_test.dart`, `docs/guides/mapx.md`; T3 adds `lib/praxis.dart` (barrel rows only), `STATUS.md`, `CHANGELOG.md` if the repo convention calls for it. Writers never touch `lib/praxis.dart`.

## Log

- L1 (owner orders, verbatim): "Dale, seamos estrictos para estar seguros" + "(custom) Adoptamos los 5 gaps pero antes de implementar nada, decime que significa eso de que "iterx excede a fpdart en 6 adapters"" + "Abri el slice." + "Slice o slice t-chain dependiendo el tamaño que necesites".
- L2 (opened as chain 1/2): branch `feat/praxis-fpdart-gaps-warnings` from main `c7af8ed`, tree clean; `loop-config.yaml` `currentFeature` points here; size call: warnings-only ≈ 180 authored lines (under the ~400 guard), full-5 ≈ 440 (over) → t-chain of 2; chain 2/2 doc parked at `odd/tasks/praxis-fpdart-gaps-suggestions.md`, no branch until this merges. Implementation starts on owner order.
