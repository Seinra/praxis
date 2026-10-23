# REFERENCES

Pinned external truth by category. Packs cite IDs, never raw versions. Prose citing a version without an ID has no standing. `stale`/`missing` rows never support a decision.

## How to use

Every design decision cites a stable ID below. A rename/replacement updates the pin + adapter mapping, never rule prose.

## Pins

| ID | Category | Source | Pin |
| --- | --- | --- | --- |
| DART-SDK | toolchain | local `dart --version` | `3.13.5 stable windows_x64` (2026-10-23) |
| DART-FLUTTER | toolchain | local `flutter --version` | `3.47.7 stable` (2026-10-23); consumer-adjacent only |
| AXIOM-SISTER | cloned-repo | `D:/Proyectos/Axiom` (module `github.com/seinra/axiom`, Go 1.27) | thesis-fidelity evidence: `(T, bool)` OrNull, Which-tables, purity, skeleton-then-slices, replace-then-publish; verified 2026-10-23 (FindSlice/Min/Max/Average, zero codegen, context-bound flow, manual JSON codecs, minimal lint set) |
| THESIS | methodology | `THESIS.md` (ratified 2026-10-23) | historical starting point; standing truth is `VISION.md` |
| FPDART-REF | external-docs | fpdart (v1.2.0, v2 pre-release) | reference/inspiration ONLY, never a dependency (thesis verdict 2026-10-23: monadic-effects mismatch + v1→v2 churn) |
| CATALYST-CONSUMER | consumer | owner-declared | offline-first course app; pilots via scratch path-only; no commit from here; versioned release + pin before any Catalyst commit |
| ODD-HARNESS | methodology | el Gentleman orchestrator (this session) | Authorize → Explore → Resolve → Classify → Track → Implement → Close |
| LOOP-ENGINEERING | methodology | `loop-engineering` skill v1.9 | loop authoring discipline (this loop complies) |
| COG-DOC | methodology | `cognitive-doc-design` skill v1.0 | lead-with-answer, progressive disclosure, chunking, signposting |
| FOUNDRY-CRAFT | methodology | `foundry-craft` skill v1.0 + craft-floor | absolute bans + quality floor (single policy source); exactly one Decision Gate playbook per IMPLEMENT task |
| FOUNDRY-EXPLORE | methodology | `foundry-explore` skill v1.0 | read-only mapping, stops before design |
| FOUNDRY-REQUIREMENTS | methodology | `foundry-requirements` skill v1.0 | verifiable requirements, ask before assuming |
| FOUNDRY-DEBUG | methodology | `foundry-debug` skill v1.0 | reproduce → hypothesise → probe → fix → regression-lock |
| FOUNDRY-TESTING | methodology | `foundry-testing` skill v1.0 | HOW-to-test per language (no Dart playbook — Dart mechanics come from ATELIER-DART) |
| FOUNDRY-REVIEW | methodology | `foundry-review` skill v1.0 | pre-freeze verdict gate |
| FOUNDRY-DOCS | methodology | `foundry-docs` skill v1.0 | official docs layered over cognitive-doc-design (quickstart/guide/cookbook/API ref) |
| ATELIER-DART | methodology | `atelier-dart` skill v1.0 | Dart correctness: `package:test`, analyzer, patterns, `///` docs, `{@example}` injection |
| WORK-UNIT-COMMITS | methodology | `work-unit-commits` skill v1.0 | one purpose per commit; tests + docs travel with unit |
| AGENT-GIT-COMMIT | methodology | `agent-git-commit` skill v1.0 | safe commits under agent runtime gates; never commit unless the owner explicitly asked |
| BRANCH-PR | methodology | `branch-pr` skill | open/prepare PR with approved issue + type label |
| CHAINED-PR | methodology | `chained-pr` skill | PRs over 400 lines split into chained review slices |
| ISSUE-CREATION | methodology | `issue-creation` skill | triage + create from repo evidence with read-back |
| RDD-DEFECT | methodology | `rdd-defect-workflow` skill | review authority, correction/recovery, delivery gate |

## Gaps (investigation only)

| ID | Status | Note |
| --- | --- | --- |
| CUSTOM-LINT-PLUGIN | parked | legacy plugin deprecated in DART-SDK; activation waits on new plugin-system migration (STATUS debt) |
| REFS-DART-FLUTTER | missing | host-local `D:/Proyectos/Refs/dart|flutter` unverified; probe before citing |
| ECO-DART (dart-lang/tools, fpdart API) | missing | declared for contrast only when a slice needs it; never a dependency |
