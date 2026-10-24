# STATUS

Progress log + debt ledger. Columns: Item, Phase, Ceiling, Upgrade Path. NEVER design prose here.

## Log

| Date | Item | Phase | Note |
| --- | --- | --- | --- |
| 2026-10-23 | thesis ratified → VISION.md | PLAN | owner decisions: name `Praxis` + 1–6 (records-OrNull, async-deferred, manual-codecs, strict+custom_lint, path-then-publish); `dart --version` 3.13.5 |
| 2026-10-23 | scaffold: pubspec/analysis/README/CONTRIBUTING/LICENSE/lib | IMPLEMENT | `dependencies: {}`, strict lints; `dart pub get` 63 deps ok; `dart analyze` clean; `dart format` clean |
| 2026-10-23 | loop hub + 7 modules + VISION + config | IMPLEMENT | PRAXIS_LOOP.md v0.1 + TECH_STACK/REFERENCES/ARCHITECTURE/REVIEW_PACKS/VALIDATION_GATES/SUCCESS_METRICS + this file; mirrors AXIOM_LOOP v0.3 governance |
| 2026-10-23 | Axiom contrast (thesis fidelity) | VALIDATE | `(T, bool)` pins (FindSlice/Min/Max/Average), zero codegen, context-bound flow → deferral holds, manual JSON codecs, minimal lint set, CONTRIBUTING decline rows |
| 2026-10-23 | skeleton T1–T4 done + verifier Go | VALIDATE | 120/120 tests, analyze/format clean, docs-sync 6/6, pilot exit 0; 1 SUGGESTION adopted (result library doc); no commits, push/PR owner-gated |

## Debt ledger

| Item | Phase | Ceiling | Upgrade Path |
| --- | --- | --- | --- |
| custom_lint plugin activation | parked | legacy plugin deprecated in Dart 3.13; dep pinned `^0.7.0` | migrate to new analyzer plugin system, then re-enable in `analysis_options.yaml` |
| Branch protection / remote | done | `Seinra/praxis` private created 2026-10-23, main pushed (11 commits), tracks `origin/main` | branch protection at publish time; meanwhile discipline-gated work |
| Catalyst path pilot | T-phase | scratch only | versioned release + pin before any Catalyst commit |
| R1 result-slice advisories (R2-001 WARNING + 7 SUGGESTIONs) | parked | informational, receipt stands, no correction offered | later slice adopts/dismisses with evidence; never a review rerun |
| R2 opt-slice advisories (R2-import-package-name WARNING + 5 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R3 lists-slice advisories (3 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1/R2 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R4 close-out advisories (2 WARNING + 2 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1/R2/R3 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R5 set-slice advisories (4 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R4 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R6 mapx-slice advisories (1 WARNING + 2 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R5 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R7 iterx-slice advisories (3 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R6 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R8 valid-slice advisories (2 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R7 untouched | later slice adopts/dismisses with evidence; never a review rerun |
| R9 strings-slice advisories (1 WARNING + 2 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R8 untouched | later slice adopts/dismisses with evidence; never a review rerun (R2-001 WARNING strings.dart:158-167, R2-002 SUGGESTION strings.dart:79-82, R2-003 SUGGESTION strings_test.dart:94-96) |
| R10 mathx-slice advisories (1 WARNING + 3 SUGGESTIONs) | parked | informational, receipt stands, no correction offered; own row, R1–R9 untouched | later slice adopts/dismisses with evidence; never a review rerun (R2-1 SUGGESTION mathx_test.dart:132-146, R3-001 WARNING mathx.dart:84-89, R3-002 SUGGESTION mathx_test.dart:1, R3-003 SUGGESTION mathx.dart:148-152) |
