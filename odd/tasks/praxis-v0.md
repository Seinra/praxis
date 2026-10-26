# praxis-v0 — v0 bar: tag-release, public repo, GitHub-hosted CI

Delivery slice (no library code): cut the v0 bar — publish-ready package, public repo, GitHub-hosted CI as canonical (Conduit stays as local dev CI; the old runner in `C:\Users\Seinra` stays until its one-week-green condition holds — explicitly OUT of this slice).

## Specs

- S1 (creation call): owner order verbatim: "¿Abro el slice v0 (tag-release + repo público + CI GitHub-hosted)?" → "Abrir slice v0". Executes VISION decision 6 (publish at the library bar) and the STATUS debt row (branch protection at publish time).
- S2 (scope): `.github/workflows/ci.yml` (setup-dart, `dart pub get`, `dart analyze`, `dart format --set-exit-if-changed`, `dart test`; push + PR triggers) mirroring the proven Conduit gates; `pubspec.yaml` version `0.1.0-dev` → `0.1.0`; `dart pub publish --dry-run` clean (fix warnings: `.pubignore` covers `/tools/`, `/.tmp/`, `/doc/api/`, `/.conduit-worktrees/`, `/odd/`; add `CHANGELOG.md` iff dry-run demands it); README flips private→public wording (path dep → `dart pub add praxis`, keep path-dep note for pre-release consumers); VISION invariant-6/decision-6 + STATUS debt rows updated to shipped (wording only, decisions executed — this slice IS the maturity event they name). `gh` delivery (T2 orchestrator): repo visibility → public, branch protection on `main` (PR + green CI, no direct pushes), tag `v0.1.0` + GitHub release.
- S3 (honesty): every CI step mirrors a locally+Conduit-proven gate (no invented checks); `dart pub publish --dry-run` is the publish gate (fail-closed: warnings fixed or explicitly waived with reason); no code changes, no dependency changes except the version number.
- S4 (close-out): T1 work-unit + T2 delivery evidence (workflow run green on GitHub, visibility public, protection active, tag + release exist), feature-doc Log, work-unit commit(s), Engram mirror.
- S5 (fidelity): N/A with reason — delivery mechanics, not library design; mirror the repo's own gate history (Conduit receipts) as the bar the hosted workflow must meet.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2 (files), S3 | bounded writer, workflow + pubspec + README + VISION + .pubignore (+ CHANGELOG.md iff dry-run demands) | — |
| T2 | S2 (`gh` delivery), S4 | orchestrator: dry-run gate, visibility, protection, tag/release, verification | — |

T1 ships the files (workflow YAML valid, dry-run clean). T2 delivers (all `gh` mutations + green hosted run + Log + mirror).

## Log

- L1 (owner orders, verbatim): "eso del bar v0 es para tag-release, no? Porque tambien hay que hacer el repo publico y cambiar el workflow CI de Conduit al hosteado por GitHub" → slice "Abrir slice v0" (Conduit stays as local dev CI).
- L2: ODD opened on branch `feat/praxis-v0` (from main `8d19a5a`, tree clean); `loop-config.yaml` `currentFeature` points here from T0 (lands with the unit). Old `C:\Users\Seinra` runner retirement explicitly OUT (one-week-green condition unmet).
- L3 (T2 close-out — verification + unit commit): writer packs verified (gh-actions + foundry-craft/release-gate + docs trio + atelier-dart doc-examples). Orchestrator re-ran `dart pub publish --dry-run` (same 2 waivers: dirty-git resolves at commit, `docs/` intentional), read `.github/workflows/ci.yml` in full (steps mirror VALIDATION_GATES, pins v7/v1 documented, `sdk: 3.13` per setup-dart grammar). VISION name+repo row flipped to public (this unit IS the maturity event). Gates on final state: `dart test` 698 green, `dart analyze` clean, `dart format` clean. Unit lands in `fb4bcdc` (103 insertions — under the ~400 advisory slice). Full `git diff --cached --stat` reviewed before commit: workflow + pubspec + README + VISION + .pubignore + CHANGELOG + feature doc + loop-config only; no lib/test touched.
- L4 (T2 delivery — owner ordered merge-anyway on Conduit+local evidence after hosted CI proved billing-blocked): PR #44 MERGED, issue #43 CLOSED via Closes #43. `gh` mutations verified one by one: repo visibility → PUBLIC (`gh repo view`); branch protection on main ACTIVE (required_status_checks strict + contexts ["ci"], enforce_admins, no force-push/deletions, NO required reviews — solo maintainer would deadlock, documented); tag `v0.1.0` pushed; GitHub release published (not draft/prerelease). Hosted CI never ran green: annotation on the failed run proves the billing block (payments failed / spending limit) — workflow file itself valid, pins verified existing. Main synced at merge commit; full gates re-verified on main.
