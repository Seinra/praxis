# praxis-debt-r18-r23 — Adopt or dismiss the 18 parked R18–R22 advisories + re-audit R23

Maintenance unit (no new surface): every parked informational advisory gets adopted (fix + test) or dismissed (reason + evidence). Never a review rerun — findings never overwrite rows; each batch is a NEW observation. Review receipts stand regardless.
PREPARED ONLY — implementation, verification, review and delivery all belong to the next session.

## Specs

- S1 (creation call): standing debt-batch cadence, owner order verbatim: "Verifica que esto existe: el debt batch R18–R23. Si existe prepara el slice para atacarlo, pero lo atacamos en otra sesion".
- S2 (scope): 18 parked advisories, all located (IDs + severity + paths from STATUS R18–R22 rows), judged inline from code + one re-audit batch (R23, texts unretained — fresh read-only pass, R1–R8 precedent). W1 debt-batch (18 items): R18 (2 SUGGESTIONs: R2-001 di.dart:289-293, R2-002 di.dart:335); R19 (4 SUGGESTIONs: R2-misleading-as-value-comment orderedmap.dart:160-162, R2-misnamed-drain-helper test/stack_test.dart:184-188, R2-redundant-lru-put-guard orderedmap.dart:455-457, R3-coverage-lru-null test/orderedmap_test.dart:163-247); R20 (2 WARNING + 1 SUGGESTION: R2-1 test/task_test.dart:27-38, R3-1 test/task_test.dart:27-39, R3-2 lib/src/task.dart:154-156); R21 (4 SUGGESTIONs: R2-readability-1 README.md:73, R2-readability-2 pipe.dart:103-118, R2-readability-3 pipe.dart:75-122, R3-second-leg-failure-unexercised pipe.dart:29-31); R22 (5 SUGGESTIONs: R2-DUP-WHICH-TABLE either.dart:17-51, R2-TEST-TYPE-ECHO test/either_test.dart:55-105, R2-TRIVIAL-BOILERPLATE either.dart:120-163, R3-001 test/either_test.dart:636-675, R3-002 either.dart:459-468). W2 re-audit R23 (tools/praxis_lints/** + test/tool/**, texts unretained — NEW observation with its own topic_key, never invented). Each item ends adopted (fix + green gates) or dismissed (reason + quoted evidence).
- S3 (no-rerun rule): no native review in this unit unless the adopted diff earns one at close-out (assess decides); per-slice STATUS rows gain disposition (adopted→commit ref, dismissed→reason), never edited history; new batches get new topic_keys.
- S4 (close-out): STATUS ledger dispositions, feature-doc Log, work-unit commit(s), Engram mirror update.
- S5 (fidelity): N/A with reason — fixes mirror each file's own established discipline; no new Axiom contrast needed.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2 (R18–R22) | bounded writer(s), per-file disjoint surfaces | — |
| T2 | S2 (R23 re-audit) | gentle-ai-verify, read-only over tools/praxis_lints + test/tool | — (no writes) |
| T3 | S2 fixes | bounded writer per audit size (or orchestrator if ≤3 one-liners) | — |
| T4 | S4 | orchestrator: STATUS dispositions, Log, commit(s), mirror | — |

## Log

- L1 (owner order, verbatim): "Verifica que esto existe: el debt batch R18–R23. Si existe prepara el slice para atacarlo, pero lo atacamos en otra sesion" (+ session-close protocol in the same order).
- L2 (prepared only): ODD prepared on branch `feat/praxis-debt-r18-r23` (from main `e2bc546`, tree clean); ledger holds R18 (own batch row) + R19–R22 (per-slice rows, all located) + R23 (own row, texts unretained — T2 re-audit required). Pointer untouched (`odd/tasks/praxis-docs-coherence.md` still current until the implementation turn). T0 decisions (writer split per file, R23 re-audit briefing) fold into T1's briefing next session. Implementation starts next session.
