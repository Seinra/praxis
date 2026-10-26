# praxis-docs-coherence — Fix doc placement/coherence gaps, publish 0.1.1

Docs + delivery slice (no library behavior change): apply the coherence-audit move plan on the merged docs tree, set the repo About, and publish `praxis` 0.1.1 to pub.dev.

## Specs

- S1 (owner orders, verbatim): "Y el about del repo: [Axiom About] / Arma el slice para aplicar los fixes que se requieran con el about del repo remoto incluido, de ahi prepara el dart pub publish y manda delivery completo." + prior: "Manda un explorer a hacer una auditoria de los docs con el contrato full de foundry-docs, sumale cognitive-doc-design y el resto de skills que apliquen para atacar coherencia, legibilidad, etc."
- S2 (scope): (a) audit fixes EXCEPT scout-W1 (Which-table verbatim copies STAY — overruled: Axiom itself repeats tables, it was the ratified bar; guides keep verbatim tables + links): B1 gate-checklist README→CONTRIBUTING; B2 loop/ODD/Catalyst rows README→CONTRIBUTING/STATUS/CHANGELOG + quickstart links; B3 install-path (quickstart `dart pub add` primary; plugin README path note → public); B4 version floors `0.1.0-dev` → `0.1.0` in prose (docs headers); W3 rules row → link; W4 imports → barrel in 8 older guides; W5 Expected-output + asserted-pointer labels; W6 cookbook backlinks + file-ref fix; W7 ODD-token scrub; S1 headings/checklists/voice. (b) About: `gh repo edit` description → "Composable, educative typed generics for Dart 3.13 — 21 pkgs, Which-tables + examples, SDK-first" (Axiom shape, Dart terms); pubspec description same line (60–180 chars, verified). (c) Version: bump 0.1.0 → 0.1.1 (docs-coherence release; v0.1.0 tag/release already cut pre-fixes — never move tags) + CHANGELOG `## 0.1.1` entry. (d) `dart pub publish` (dry-run gate first, then publish with explicit owner order). (e) Delivery: issue + PR + merge (hosted CI green required), tag v0.1.1 + GitHub release.
- S3 (honesty): every moved claim keeps its evidence; no invented coverage; THESIS.md untouched (history); VISION wording-only (pre-authorized); `lib/` untouched except mechanical `Available since 0.1.0-dev` → `0.1.0` comment sweep by orchestrator (sd, grep-verified uniform, zero behavior).
- S4 (close-out): Conduit CI + hosted CI green, `dart pub publish` receipt, mirror + STATUS disposition, work-unit commit(s).
- S5 (fidelity): N/A (docs + delivery mechanics).

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2(a) | 5 bounded writers (disjoint surfaces), docs trio each | — |
| T2 | S2(c) lib sweep, S4 gates | orchestrator: sd sweep + full gates + Conduit CI | — |
| T3 | S2(b,d,e), S4 | orchestrator: About (gh), publish, delivery, tag/release, mirror | — |

## Log

- L1 (owner orders, verbatim): coherence audit with full foundry-docs + cognitive-doc-design + applicable skills; About short vs Axiom; slice with fixes + remote About + `dart pub publish` + full delivery. Standing decisions: scout-W1 Which-table delink proposal REJECTED (Axiom repeats tables — ratified bar stands); version strategy 0.1.1 (never move the v0.1.0 tag).
- L2: ODD opened on branch `feat/praxis-docs-coherence` (from main `8d19a5a`, tree clean); `loop-config.yaml` `currentFeature` points here from T0 (lands with the unit).
- L3 (T2 close-out — 5 writers verified inline by parent re-running suites: W1 hub fixes (README landing decontamination, CONTRIBUTING process, VISION wording-only per explicit owner call, LOOP objective, REFERENCES live pin, ARCHITECTURE map, pubspec 0.1.1 Axiom-mirror description, CHANGELOG 0.1.1); W2-W4 guides A/B/C + test a/b/c (8+7+8 green); W5 quickstart/cookbook/plugin page + tests (7+1 green); heading rule UNIFORM `Which function?` in all 22 guides per unanimous lib/src evidence (overrules W2/W3 noun-verb split); T3 landing pass (Ships-now compact index, Process row dropped); lib Available-since sweep (175 lines, sd-verified zero remainder). Gates on final state: `dart test` 698 green, `dart analyze` clean, `dart format` clean, `dart doc` 5 pre-existing warnings only, ALL_LINKS_OK link check, `dart .tmp/pilot.dart` exit 0. Conduit CI dispatched per work unit (receipt in Log L4).
