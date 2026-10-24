# praxis-debt-adopt — Adopt or dismiss the 40 parked R1–R10 advisories

Maintenance unit (no new surface): every parked informational advisory gets adopted (fix + test) or dismissed (reason + evidence). Never a review rerun — findings never overwrite rows; each batch is a NEW observation. Review receipts stand regardless.

## Specs

- S1 (owner order, verbatim): "Vamos por las deudas primero. Asi no se acumula mucho trabajo."
- S2 (scope): 40 parked advisories — R9/R10 (7 located: strings.dart:158-167, :79-82, strings_test.dart:94-96; mathx_test.dart:132-146, mathx.dart:84-89, mathx_test.dart:1, mathx.dart:148-152) judged inline from code; R1–R8 (33 unlocated: store holds receipts only, no finding text) re-audited read-only over `result`/`opt`/`lists`/`set`/`mapx`/`iterx`/`valid`, then fixed. Each item ends adopted (fix commit + green gates) or dismissed (reason + quoted evidence).
- S3 (no-rerun rule): no native review in this unit (prose+fix receipts only); per-slice STATUS rows gain disposition (adopted→commit ref, dismissed→reason), never edited history; new batches get new topic_keys.
- S4 (close-out): STATUS ledger dispositions, feature-doc Log, work-unit commit(s) per batch, Engram mirror update.
- S5 (fidelity): N/A with reason — fixes mirror each file's own established discipline; no new Axiom contrast needed.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2 (R9/R10 only), S3 | orchestrator inline (7 spots, disjoint from T2 audit files) | — |
| T2 | S2 (R1–R8 re-audit) | gentle-ai-verify, read-only over 7 files + tests | — (no writes) |
| T3 | S2 (R1–R8 fixes) | bounded writer per audit size (or orchestrator if ≤3 one-liners) | — |
| T4 | S4 | orchestrator: STATUS dispositions, Log, commit(s), mirror | — |

## Log

- L1 (owner order, verbatim): "Vamos por las deudas primero. Asi no se acumula mucho trabajo."
- L2: ODD opened on branch `feat/praxis-debt` (from main `466c256`); store probe: `review-transactions/terminal-consumption` holds 10 receipts (lineage+target only, no finding text) — R1–R8 locations unrecoverable, re-audit required; R9/R10 locations on record from burn-time Log rows.
- L3 (T1 verdicts, R9/R10 located advisories — inference stated per item, finding text unretained): ADOPTED (in `1de7a71`, gates `dart test` +376 green, analyze clean, format clean) — R2-002 splitWords double-`trim()` → single `trimmedSource`; R2-003 misplaced `takeRunes` expect inside truncateRunes group → relocated as its own `takeRunes` test (net +1 test); R2-1 gcd-factored computed expected (mirrors implementation) → literal multiples (12,18)→36, (21,6)→42, (35,49)→245; R3-001 "odd sieving" misnomer (code sieves all divisors) → "overflow-safe bound idiom" wording. DISMISSED with reason + evidence — R2-001 truncateRunes fits-case returns `sourceText`: immutable aliasing is unobservable, 51→52 tests pin behavior, take/drop share the pattern deliberately; R3-002 test imports `src` directly: repo convention across all 9 test files, barrel surface pinned by pilot + docs-sync row 2; R3-003 lcm divide-first claims: test-pinned (`1<<32` pair) + wrap semantics documented with BigInt pointer, no defect visible. No correction was offered by either review; receipts stand.
- L4 (T3 re-audit adoption, R1–R8 — fresh read-only pass by gentle-ai-verify mvls0exw-5-imix, NEW observation per S3; old texts/locations unrecoverable so no reconciliation possible): ADOPTED (in `efd81a6`, gates `dart test` +380 green, analyze clean, format clean) — result `==`/`hashCode`/`toString` for Ok/Failure mirroring the Opt trio + equality tests + Failure Exception-only design note; set `smallerMembers`/`largerMembers` rename; mapx `as`-preserves-null comment + present-null test; iterx `Queue` buffer for the windowed slide; valid `and`/`orPredicates` widened `List`→`Iterable` + doc notes. DISMISSED as not-reproduced on the fresh pass (each file fully re-read, no defect found): R1 remaining 6, R2 all 6, R3 all 3, R4 all 4 (barrel/README re-read clean), R5 remaining 3, R6 remaining 2, R7 remaining 2, R8 remaining 1. Counts reconcile: 6 adopted + 27 not-reproduced = 33 parked. No review rerun; receipts stand.
- L5 (R11 native review of the debt batch burned — lineage review-c2cc73bd216b7585 APPROVED + burned (readability+reliability, 198 lines, group 2/2 clean via pi_host_relay with inner-binding form first try); 2 advisories parked informational in their OWN ledger row (R3-001 WARNING lib/src/iterx.dart:193, R3-002 SUGGESTION lib/src/valid.dart:92) — rows R1–R10 untouched, no finding overwritten; delivery per ordinary policy.
