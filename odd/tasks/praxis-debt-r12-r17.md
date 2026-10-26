# praxis-debt-r12-r17 — Adopt or dismiss the 31 parked R12–R17 advisories

Maintenance unit (no new surface): every parked informational advisory gets adopted (fix + test) or dismissed (reason + evidence). Never a review rerun — findings never overwrite rows; each batch is a NEW observation. Review receipts stand regardless.

## Specs

- S1 (owner order, verbatim): "Debt batch R12–R17"
- S2 (scope): 31 parked advisories, all located (IDs + severity + paths from STATUS R12–R17 rows and each slice L6), judged inline from code at the location. Each item ends adopted (fix + green gates) or dismissed (reason + quoted evidence). W1 flow+pool (10): R2-DOC-STATEERROR-DISCARD WARNING flow.dart:101-103, R2-DOC-STOP-CONTRACT WARNING flow.dart:176-179, R3-1 WARNING test/flow_test.dart:263-441, R3-2 WARNING flow.dart:526-528, R3-3 SUGGESTION flow.dart:143-149, R3-4 SUGGESTION flow.dart:176-179; R2-double-release-doc-mismatch WARNING pool.dart:205-207, R3-alias-gap WARNING pool.dart:221-239, R3-release-after-discard-reset SUGGESTION pool.dart:231-238, R3-use-both-throw SUGGESTION pool.dart:275-282. W2 singleflight+di (12): R2-brittle-sdk-lines SUGGESTION singleflight.dart:43-49, R2-dup-example-tests SUGGESTION test/singleflight_test.dart:167-189, R2-dup-stdlibgap-doc SUGGESTION singleflight.dart:43-49, R2-garbled-aliasing-sentence SUGGESTION singleflight.dart:34-35, R2-magic-flush-rounds SUGGESTION test/singleflight_test.dart:13, R3-001 WARNING singleflight.dart:132-151, R3-002 SUGGESTION singleflight.dart:154-166; R2-dead-null-guard SUGGESTION di.dart:324, R2-parallel-order-state SUGGESTION di.dart:88-89, R2-reset-partial-dispose-doc SUGGESTION di.dart:256-258, R3-register-once-doc SUGGESTION di.dart:109-110, R3-reset-partial-teardown WARNING di.dart:271-279. W3 repo+httpx (9): R2-repo-remove-double-lookup SUGGESTION repo.dart:204-208, R3-repository-identity-key-contract SUGGESTION repo.dart:66, R3-repository-remove-double-lookup SUGGESTION repo.dart:200-206; R2-doc-example-repetition SUGGESTION httpx.dart:1-841, R2-late-final-envelope SUGGESTION httpx.dart:805-841, R2-mixed-failure-assertions SUGGESTION test/httpx_test.dart:81-101, R3-9 WARNING httpx.dart:170-176, R3-10 WARNING httpx.dart:255-262, R3-11 SUGGESTION httpx.dart:785-792.
- S3 (no-rerun rule): no native review in this unit unless the adopted diff earns one at close-out (assess decides); per-slice STATUS rows gain disposition (adopted→commit ref, dismissed→reason), never edited history; new batches get new topic_keys.
- S4 (close-out): STATUS ledger dispositions, feature-doc Log, work-unit commit(s), Engram mirror update.
- S5 (fidelity): N/A with reason — fixes mirror each file's own established discipline; no new Axiom contrast needed.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2 (flow+pool), S3 | bounded writer, flow + pool files + tests | — |
| T2 | S2 (singleflight+di), S3 | bounded writer, singleflight + di files + tests | — |
| T3 | S2 (repo+httpx), S3 | bounded writer, repo + httpx files + tests | — |
| T4 | S4 | orchestrator: STATUS dispositions, Log, commit(s), mirror | — |

## Log

- L1 (owner order, verbatim): "Debt batch R12–R17" (picked from the post-httpx options; either stays gated).
- L2: ODD opened on branch `feat/praxis-debt-r12-r17` (from main `64f4233`, tree clean); all 31 advisories located (STATUS R12–R17 + slice L6 rows), no re-audit needed; `loop-config.yaml` `currentFeature` set at T0 (lands with the unit).
- L3 (worker verdicts — all 31 judged inline from code, packs atelier-dart + foundry-craft/api-design + docs trio where /// touched): W1 flow+pool ADOPTED 7 (StateError-discard + stop-contract docs, pre-stopped StateError test pins R3-1/R3-2, release idle-guard + stale-reference + both-throw docs), DISMISSED 3 (R3-3 intentional duplication, R3-4 subsumed, release-after-discard keeps uniform contract). W2 singleflight+di ADOPTED 9 (SDK pins dropped, gap pointer, aliasing sentence, flushRounds const, dead guard dropped, map-key order, reset continue-on-error + RED→GREEN test, 2 doc contracts), DISMISSED 3 (dup-example-tests distinct pins, R3-001 FIFO proven + pinned, R3-002 fidelity). W3 repo+httpx ADOPTED 5 (remove one-liner closes both double-lookup rows, late-final, 7 doc-truth fixes + constructor test), DISMISSED 4 (identity-key stated twice, mixed-assertions deliberate, R3-10 uniform discipline, R3-11 deliberate guard). Counts reconcile: 21 adopted + 10 dismissed = 31 parked. Cross-note (not adopted, outside surfaces): `test/flow_test.dart:12` carries the same magic `25` flush default as singleflight — follow-up if flow reopens.
- L4 (work-unit record): fixes land in `fc8ee74` (143 insertions, 60 deletions across 6 lib/test files — under the ~400 advisory slice); gates `dart test` 514 green (511 + 3 new), analyze clean, format clean, pilot exit 0. STATUS R12–R17 rows carry dispositions (adopted→fc8ee74 evidence, dismissed→reason); rows R1–R11 untouched, no finding overwritten. W2 flagged di `reset` teardown-fullness as review_focus — close-out assess decides whether the diff earns a review.
