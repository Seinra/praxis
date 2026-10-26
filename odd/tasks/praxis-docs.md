# praxis-docs — Audit every doc against the library, Axiom-style docs

Docs-only slice (no library code): audit each Praxis doc for currency against `lib/` (21 packages, 667 tests), restyle to the Axiom docs bar, and document the `praxis_lints` plugin where it belongs. THESIS.md is historical (never rewrite ratified intent — flag drift); VISION.md is standing truth (audit wording, keep decisions).

## Specs

- S1 (owner orders, verbatim): "Ok, ahora toca auditar la documentacion, todo, para que este al dia respecto a la libreria y depa dejamos los docs al estilo que tiene Axiom" + "Con el extra de lo del linter en el doc que corresponda".
- S2 (scope): inventory = README.md, VISION.md, CONTRIBUTING.md, pubspec.yaml description, analysis_options.yaml comments, tools/praxis_lints docs (lib comments + examples), .loop-modules/TECH_STACK.md + REFERENCES.md + ARCHITECTURE.md coverage map, PRAXIS_LOOP.md hub accuracy; EXCLUDED: odd/tasks/* (process log), .loop-modules/STATUS.md (ledger), generated doc/api. Axiom bar (from D:/Proyectos/Axiom, owner-authorized): README quick path (point → use → verify) + guide index Which-tables with Guide column, Details decision table, per-package doc + compiling examples (Axiom docs/: quickstart.md, cookbook.md, guides/ — all CI-executed via *_test.go), "Why not X" contrast section, Contributing decline-table. Linter placement decided in T1 (README section and/or plugin page + TECH_STACK row already true).
- S3 (docs honesty): every behavior claim in docs resolves to `lib/` or `test/` evidence (`path:line`); no invented coverage; THESIS.md untouched (history); VISION.md decisions kept, wording only.
- S4 (close-out): gap ledger dispositions, feature-doc Log, work-unit commit(s), Engram mirror update. Build gate for prose: `dart analyze` clean + `dart doc` renders the touched scope + `dart test` green (examples are CI-executed); no RED invented (prose matrix).
- S5 (fidelity): Axiom IS the style source (S5 contrast = the bar itself); mirror its doc discipline (quick path, Which-tables, decision ladders, compiling examples), never copy prose verbatim.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2 (map only), S5 | scout (read-only): gap ledger per doc (OK/STALE/MISSING + evidence) + target docs tree + style bar + linter placement | — |
| T2 | S2 (fix), S3 | bounded writer(s) per docs unit, trio per unit | — |
| T3 | S4 | orchestrator: ledger dispositions, Log, commit(s), mirror | — |

T1 maps (no edits). T2 fixes (trio: atelier-dart doc-examples + foundry-docs + cognitive-doc-design per unit). T3 closes.

## Log

- L1 (owner orders, verbatim): "Ok, ahora toca auditar la documentacion, todo, para que este al dia respecto a la libreria y depa dejamos los docs al estilo que tiene Axiom" + "Con el extra de lo del linter en el doc que corresponda".
- L2: ODD opened on branch `feat/praxis-docs` (from main `e930ec3`, tree clean); `loop-config.yaml` `currentFeature` points here from T0 (lands with the unit). THESIS.md excluded from edits (history); VISION.md wording-only.
- L2b (owner calls mid-slice, verbatim): "No te olvides del pack de skills como foundry-docs, cognitive-doc-design y foundry-review para la auditoria" → T1 scout carries foundry-explore + foundry-docs + cognitive-doc-design + foundry-review (+ atelier-dart for doc-example correctness; atelier-explore/gui/review explicitly excluded as UI track). "O las de atelier" → resolved as atelier-dart only. "Verifica los claims inline con los MCP + rg" → parent verified every scout claim with rg + Codegraph + zvec-grep (contradiction confirmed, linter gap confirmed, 21 packages, Which-tables pervasive). "¿Apruebo el wording ratificado...?" → "Sí, actualizar" (wording only, decisions intact).
- L3 (T2 close-out — 5 writers, all verified inline by parent re-running each companion suite): W1 fixes (README OrNull row + Linter section, ARCHITECTURE map + frozen 9/11, REFERENCES live pin, VISION wording-only, LOOP objective) — `dart analyze` clean, `dart format` clean. W2 quickstart + cookbook + plugin page + 3 companion suites (7/7 re-run green). W3 foundations + 7 guides + test a (8/8). W4 7 guides + test b (7/7). W5 7 guides + test c (8/8). T3 extras: README Linter link now points at `tools/praxis_lints/README.md`; full gates `dart test` 698 (= 667 + 31 docs tests) green, `dart analyze` clean, `dart format` clean, `dart doc` 5 pre-existing warnings only (valid/singleflight/root), link check ALL_LINKS_OK across docs/README/plugin page. Conduit CI job dispatched per unit (receipt below).
- L4 (work-unit record): T1+T2 land together in `db3839c` (3633 insertions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting any guide from its companion pin suite or the README/index rows would break the reviewable unit; same disposition as library slices, native review takes it as one candidate if ordered — note S4: prose candidates skip native review per loop rule + standing owner rule docs-only exclusions). Parent re-ran the scoped suites on the final state (W1 greps, W2 7/7, W3 8/8, W4 7/7, W5 8/8) plus full gates (`dart test` 698, `dart analyze` clean, `dart format` clean, `dart .tmp/pilot.dart` exit 0, link check ALL_LINKS_OK) before committing. Conduit CI job-1793026437255930100 dispatched on this candidate (detached worktree at dispatch HEAD); verdict to be confirmed before delivery — see L5.
