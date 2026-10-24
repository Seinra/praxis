# praxis-strings — `strings` rune-aware text helpers green with docs

Sixth library slice (text wall: rune-aware splitting/chunking/truncation — deep Flutter relevance since every app renders text, plus Dart UTF-16-vs-runes is genuinely hard material). Ships the `strings` package only; everything else stays declared future scope, never stubbed.

## Specs

- S1 (creation call): "Prepara el siguiente slice siguiendo el mismo orden de prioridad con el que venimos trabajando. Pero dejalo listo nomas porque frenamos aca y lo atacamos en la siguiente sesion." — owner-ordered preparation only; implementation, verification, review and delivery all belong to the next session.
- S2 (scope): rune-aware text helpers following skeleton conventions — Which-table rows, doc comment per export with stdlib-gap justification + runnable example, purity + edge pins (empty, multibyte, emoji/grapheme-adjacent cases via `runes`), no `dynamic`. Case converters stay OUT (they belong with `characters`/`intl`-style homes, per thesis).
- S3 (SDK honesty): `dart:core` `String` already owns `split`/`substring`/`trim`/`padLeft`/`toUpperCase` and friends — ship only proven gaps (e.g. chunk by runes, truncate by runes with ellipsis, rune-safe take/drop), each justified with a REFERENCES ID; anything the SDK owns is YAGNI-killed with a reason. Grapheme clusters beyond `runes` need the external `characters` package — out of scope unless a new owner decision reopens it (SDK-first: zero runtime dependencies).
- S4 (close-out): barrel export, README index row, scratch pilot note, Docs-sync verdict; `loop-config.yaml` `currentFeature` points here from T0 of the implementation turn (NOT set during preparation — pointer still names the valid slice until then).
- S5 (fidelity): contrast Axiom's `strings` package (owner-authorized local exploration); mirror its discipline, never its Go signatures.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S1, S2, S3, S5 | bounded writer, `lib/src/strings.dart` + `test/strings_test.dart` | — |
| T2 | S4 | orchestrator: barrel, README, pilot, docs-sync, loop-config pointer, work-unit commit | — |

T1 ships the package (RED → GREEN → TRIANGULATE, Which-table per export, CI-executed examples, multibyte + purity pins, `dart doc` clean). T2 closes (barrel export, README row flip for `strings`, pilot happy path, docs-sync rows, commit on this branch).

## Log

- L1 (owner preparation order, verbatim): "Prepara el siguiente slice siguiendo el mismo orden de prioridad con el que venimos trabajando. Pero dejalo listo nomas porque frenamos aca y lo atacamos en la siguiente sesion. Guarda el sumario en Engram y busca que ID le da el agente Pi a esta sesion, usa esa ID para cerrar sesion en Engram."
- L2 (2026-10-23): ODD prepared only (this doc + Engram mirror) on branch `feat/praxis-strings`; priority call: `strings` before `mathx` (Flutter-posture text relevance + UTF-16-vs-runes lesson value; owner may flip next session). Pointer untouched (`odd/tasks/praxis-valid.md` still current). Implementation starts next session with T1 writer.
