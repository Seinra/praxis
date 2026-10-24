# praxis-httpx — `httpx` typed HTTP envelope green with docs

Octavo library slice (infra wall, HTTP adapter concern: typed JSON GET/POST over an injected transport with manual codecs — no codegen, per the ratified JSON decision). Ships the `httpx` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "Prepara el siguiente slice, pero lo atacamos en otra sesion" — owner-ordered preparation only; implementation, verification, review and delivery all belong to the next session.
- S2 (scope): typed HTTP envelope (JSON GET/POST with caller-supplied codec functions, status-code + transport + codec error taxonomy, per-export Which-tables, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins) following skeleton conventions, no `dynamic` outside codec edges (typed wrappers only).
- S3 (SDK honesty): transport choice is an OPEN T0 question for next session — `dart:io` `HttpClient` is SDK-owned but platform-specific (no web), `package:http` is external (zero-deps tension); the gap to prove is the *typed envelope* over whichever transport, each justified with a REFERENCES ID. Shelf adapter stays OUT (server-side concern, not this slice). Manual codecs now + migration guide later, per the ratified JSON decision — no codegen in the teaching library.
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of the implementation turn (NOT set during preparation — pointer still names the repo slice until then).
- S5 (fidelity): contrast Axiom's `httpx` (or `repogorm`-adjacent HTTP patterns if present; owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 (+T0 transport decision) | bounded writer, `lib/src/httpx.dart` + `test/httpx_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T0 (transport + error-taxonomy decisions) folds into T1's briefing next session — the writer gets the decided contract before writing. T1 ships the package (RED → GREEN → TRIANGULATE with fake transports, never live network). T2 closes.

## Log

- L1 (owner preparation order, verbatim): "Prepara el siguiente slice, pero lo atacamos en otra sesion".
- L2 (2026-10-24): ODD prepared only (this doc + Engram mirror) on branch `feat/praxis-httpx`; priority call: `httpx` next per the VISION MVP line after `repo` (remaining after it: `either` gated, Stack/Queue/OrderedMap, task/future, Pipe/Compose). Pointer untouched (`odd/tasks/praxis-repo.md` still current). Transport choice (`dart:io` vs `package:http`) + error taxonomy are T0 decisions for next session. Implementation starts next session.
