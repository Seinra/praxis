# praxis-lints — House-rule analyzer plugin, green with docs

Tooling slice (dev-only, never published API): `tools/praxis_lints`, an analysis-server plugin encoding Praxis house rules. Replaces the parked `custom_lint` dependency (archived upstream, zero rules in repo) per the closed migration investigation (spike: analysis_server_plugin ^0.3.25 resolves under SDK 3.13.5, top-level `plugins:` activation, isolated synthetic-package resolution — no analyzer 7 vs 14 war).

## Specs

- S1 (creation call): owner order verbatim: "arma el plugin dentro de tools/ como decis, prepara el slice".
- S2 (scope): `tools/praxis_lints` package (own pubspec: sdk `^3.13.0`, `analysis_server_plugin`, `analyzer`; never a root dependency, never public API) + tests. Rules v1 (writer proves implementability per rule with the plugin API or kills with reason — killing is reportable): `no_single_letter` (locals/params, short loop indices excepted) and `no_banned_names` (configurable denylist seeded with `data`/`item`/`res` + common abbreviations). Each rule: Which-table row, doc comment with stdlib-gap justification + runnable example, purity + edge pins, no `dynamic` outside typed wrappers. Sibling `analysis_options.yaml` enables it via top-level `plugins:` (path ref) + `diagnostics:` toggles; `dart analyze` is the runner (no separate command).
- S3 (honesty + removal): `custom_lint` dev-dep removed from root `pubspec.yaml` (unused, archived upstream); built-in lints stay untouched; any SDK/server-owned surface is YAGNI-killed with a reason. Zero runtime dependencies added to the library.
- S4 (close-out): activation in `analysis_options.yaml`, `.pubignore` covers `tools/praxis_lints/`, STATUS debt row disposition (superseded), pilot note (prove rules fire on a scratch violation, then repo clean), docs-sync rows, work-unit commit(s). CI evidence from Conduit plus local gates.
- L4 (work-unit record): T1+T2 land together in `688c90c` (1134 insertions per diff stat — past the ~400 advisory slice; kept whole per keep-tests-with-code: splitting the plugin package from its pin suite or the activation/config rows would break the reviewable unit; same disposition as library slices, native review takes it as one candidate). Parent re-ran the scoped suite on the final state (`dart test test/tool/` +14 green) plus full gates (`dart test` 667, `dart analyze` clean, `dart format` clean, fire-proof both rules on scratch violation) before committing.
- L5 (R23 native review of the praxis-lints slice burned — lineage review-58bc77e29904c623 APPROVED + burned (readability+reliability; group 2/2 clean via pi_host_relay); finding texts UNRETAINED — the receipt store holds lineage+target only and the ack receipt never surfaced its closure in-session, so no IDs/locations are quoted here (never invent findings). A later debt batch re-audits `tools/praxis_lints/**` + `test/tool/**` with evidence, same precedent as the R1–R8 re-audit; rows R1–R22 untouched, no finding overwritten; Conduit CI job-1793023461668905500 green on this candidate (test 667 + analyze + format, 3 exits 0); delivery per ordinary policy.
- S5 (fidelity): N/A with reason — dev tooling, not library surface; conventions mirrored from the house rules themselves.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3 (+T0 rule-proof per rule) | bounded writer, `tools/praxis_lints/**` + tests | — |
| T2 | S4 | orchestrator: analysis_options activation, custom_lint removal, .pubignore, STATUS disposition, Log, commit(s), mirror | — |

T1 ships the plugin + rules + tests (resolve `tools/praxis_lints` deps first, then read the plugin API + writing/testing docs from the pub-cache package source — no network assumption; RED → GREEN → TRIANGULATE with `expect_lint`-style or analyzer_testing pins). T2 activates + removes + verifies (rules fire on scratch violation, full repo clean).

## Log

- L1 (owner order, verbatim): "arma el plugin dentro de tools/ como decis, prepara el slice" (dart_eval evaluated RED by owner; interpreter goes to its own project, out of this slice).
- L2: ODD opened on branch `feat/praxis-lints` (from main `5e462fd`, tree clean); `loop-config.yaml` `currentFeature` points here from T0 (lands with the unit). custom_lint migration investigation closed as superseded (this slice replaces instead of migrating).
- L3 (T2 close-out — rename + activation + removal + gates): `tool/` renamed to `tools/` per owner verbatim (copy + delete; MSYS `mv` hit an OS file lock, `doc/api` busy at the time — covered by `.pubignore`); my rename broke the fixture's hardcoded `tool/` path (full suite went 653+14 red) — fixed the path in `test/tool/lint_fixture.dart`, re-verified `dart test test/tool/` +14 green. Activation: top-level `plugins:` + `diagnostics:` (both rules on) in root `analysis_options.yaml`; fire-proof on scratch violation (both codes fire via plain `dart analyze`), full repo clean. `custom_lint` deleted from root `pubspec.yaml` (`dart pub get` clean); `.pubignore` covers `tools/`; TECH_STACK row + STATUS debt row dispositioned (superseded, done); VISION/THESIS left untouched (ratified intent — strict + custom house rules — stands, only the mechanism changed). Gates: `dart test` 667 green, `dart analyze` clean, `dart format` clean.
