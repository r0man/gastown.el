# Implementation Plan: Formula Lifecycle Integration in beads.el / gastown.el

## Bead Dependency Graph

```
ge-7co  gastown-formula-var class (gastown-types.el)
  |
ge-9xy  Completion caching: formula list + var metadata
  |
ge-lz4  Dynamic var transient (gastown-formula-var-transient)
  |  \
  |   ge-joa  Output buffer infrastructure
  |   /
ge-0n4  Enhanced gastown-formula-run
ge-6e4  New gastown-sling-formula command
  |
ge-5er  beads.el injection (all 3 surfaces)

ge-po2  gastown-formula-status (depends on ge-6e4)
```

## Implementation Order (TDD throughout)

### Phase 1: Foundation

**ge-7co** — `gastown-formula-var` EIEIO class
- File: `lisp/gastown-types.el`
- Add class with slots: name (string), description (string), default (or null string), required (boolean)
- Add `gastown-completion--parse-formula-var` parser from JSON alist
- Test first: `lisp/test/gastown-completion-test.el`

**ge-joa** — Formula output buffer (parallel with ge-7co)
- File: `lisp/gastown-command-formula.el`
- `gastown-formula-output-buffer (name &optional target)`: returns `*gastown-formula: <name>*`
- Buffer uses `special-mode`, read-only, header section + step progress + raw output
- `gastown-formula-output-append (name text)`: appends to buffer (inhibit-read-only)
- `gastown-formula-output-show (name)`: interactive, pops to buffer
- Test first: new `lisp/test/gastown-command-formula-test.el`

### Phase 2: Completion Enhancement

**ge-9xy** — Formula completion caching
- File: `lisp/gastown-completion.el`
- Add `gastown-completion-formula` class: name, description, var-count, source
- Add `gastown-completion--formula-cache` (TTL 5s, same pattern as rig cache)
- Add `gastown-completion--formula-vars-cache` (keyed by formula name, longer TTL ~60s)
- `gastown-completion--fetch-formulas`: calls `gt formula list --json`, parses results
- `gastown-completion--fetch-formula-vars (name)`: calls `gt formula show <name> --json`
- Enhance `gastown-completion-read-formula`: add description + var-count annotation
- Test: extend `lisp/test/gastown-completion-test.el`

### Phase 3: Dynamic Var Transient

**ge-lz4** — `gastown-formula-var-transient`
- File: `lisp/gastown-command-formula.el`
- `gastown-formula-var-transient (formula-name action)`:
  1. Fetch vars via `gastown-completion--fetch-formula-vars`
  2. Build transient option specs: required vars in "Required" group, optional in "Optional"
  3. If >10 vars: fall back to sequential `read-string` prompts
  4. Use `transient-define-prefix` + `fset` to create dynamic prefix
  5. Per-formula history in `gastown--formula-vars-<name>` variable
  6. ACTION called with alist `((key . value) ...)` on RET
- Test: known var list produces expected transient keys + groups

### Phase 4: Enhanced Commands

**ge-0n4** — Enhance `gastown-formula-run`
- File: `lisp/gastown-command-formula.el`
- After formula name selected: call `gastown-formula-var-transient` with run action
- Run action: build `gt formula run <name> --var k=v ...` cmdline
- Show output in `gastown-formula-output-buffer`
- Update `gastown-formula-menu`: keep `r` key for this

**ge-6e4** — New `gastown-sling-formula`
- File: `lisp/gastown-command-sling.el`
- Interactive: formula picker -> rig picker -> var transient -> sling action
- Sling action: `gt sling <formula> <rig> --var k=v ...`
- Output in `gastown-formula-output-buffer`
- Add `d` key to `gastown-formula-menu`
- Add `gastown-sling-formula-on-issue (bead-id)`:
  same flow but pre-fills `--on <bead-id>` (used by beads injection)

**ge-po2** — `gastown-formula-status`
- File: `lisp/gastown-command-formula.el`
- Interactive: prompts for convoy ID (completing-read from recent dispatches)
- Calls `gt convoy status <id> --json`
- Displays in `gastown-formula-output-buffer`
- Add `S` key to `gastown-formula-menu`

### Phase 5: beads.el Integration

**ge-5er** — Inject formula into beads.el (all 3 surfaces)
- File: `lisp/gastown-beads.el`

Surface 1 — beads dispatch transient:
- Add `f Formula` entry to Gas Town sub-menu (after existing entries)
- Calls `gastown-sling-formula-on-issue` with `beads-current-issue`
- Guard: `gastown-beads--formula-dispatch-injected`

Surface 2 — issue detail buffer:
- `gastown-beads--inject-issue-formula-action`:
  via `with-eval-after-load 'beads` + `transient-append-suffix` on issue transient
- Binds `f` -> `gastown-sling-formula-on-issue` with bead from buffer context
- Guard: `gastown-beads--formula-issue-injected`

Surface 3 — beads-status section:
- `gastown-insert-formula-section`: queries recent formula dispatches from gt
- Shows: formula name, bead, elapsed time, status (running/done/failed)
- Added to `beads-status-sections-hook` (same as existing work queue section)
- Guard: `gastown-beads--formula-section-injected`

## Output Buffer Format

```
*gastown-formula: mol-idea-to-plan*

Formula:  mol-idea-to-plan
Target:   gastown_el
Started:  2026-03-29 18:52
Vars:     problem=Better integration...
          context=beads.el and gastown.el...

Steps:
  [intake]        done
  [prd-review]    done
  [human-clarify] waiting...

--- Output ---
<raw gt output appended here>
```

## Test Coverage Map

| File | Tests |
|------|-------|
| `gastown-types.el` | gastown-completion-test.el: parse-formula-var |
| `gastown-completion.el` | gastown-completion-test.el: formula cache, var cache, annotation |
| `gastown-command-formula.el` | gastown-command-formula-test.el: output buffer, var transient, run, status |
| `gastown-command-sling.el` | gastown-command-formula-test.el: sling-formula flow |
| `gastown-beads.el` | gastown-beads-test.el: all 3 injection guards, formula section |

## Risk Mitigations

1. Dynamic transient: isolated to `gastown-formula-var-transient`; if it fails,
   fallback to sequential prompts. Unit-tested with known var lists.
2. `gt formula show --json` schema: confirmed to have required/default/description.
   Parser is defensive (treat missing `required` as false, missing `default` as nil).
3. beads-status section: same magit-insert-section guard as existing work queue.
   Silently returns nil if magit-section not loaded.
