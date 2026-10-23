# SUCCESS_METRICS

Definition of Done for Praxis. Measurable, no aspirational checkboxes.

## Skeleton slice (this feature)

- [ ] `dart test` green on Dart 3.13.5 (paste `command: observed result`).
- [ ] `dart analyze` clean.
- [ ] `dart format --output=none --set-exit-if-changed .` empty.
- [ ] `result`, `opt`, `lists` each ship ≥2 exported symbols with doc comments + table-driven tests incl. error paths.
- [ ] Zero thesis bans (naming, `dynamic` outside codec edges, single-export files, mutation).
- [ ] README quick path verified by a fresh reader in ≤5 minutes (checklist below).
- [ ] Catalyst pilot note in feature doc Log (scratch path-only, no Catalyst commit).

## Library bar (every future slice)

- [ ] New package cites its REFERENCES ID + SDK-first justification (what the SDK lacked).
- [ ] Every export has a doc comment with an example; every rule names its types, never bare `dynamic`.
- [ ] AI-check: a code model can name the right function from the package doc alone (spot-check, recorded).
- [ ] Human-check: naming passes the thesis invariant-3 audit (zero violations).
