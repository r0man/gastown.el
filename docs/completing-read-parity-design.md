# Design: Full CLI Parity — completing-read for All Options and Readers

**Issue**: ge-mol-vwgg
**Implements**: ge-mol-0h3d

## Problem

Three command files have entity-identifier slots missing `:transient-reader`
annotations. Without these, transient menus use plain `read-string` prompts
instead of `completing-read` interfaces with live data from the `gt` CLI.

## Existing Infrastructure

All necessary reader functions already exist — no new readers needed.

### Reader Functions

| Reader | Module | Purpose |
|--------|--------|---------|
| `gastown-reader-rig-name` | `gastown-reader.el` | Rig names with status annotation |
| `gastown-reader-polecat-address` | `gastown-reader.el` | Polecat `rig/name` with state annotation |
| `gastown-reader-mail-address` | `gastown-reader.el` | Mail addresses `rig/role` |
| `gastown-reader-convoy-id` | `gastown-reader.el` | Convoy IDs with title annotation |
| `gastown-reader-formula-name` | `gastown-reader.el` | Formula names with description |
| `gastown-reader-crew-name` | `gastown-reader.el` | Crew worker names with session status |
| `gastown-reader-merge-strategy` | `gastown-reader.el` | Fixed: `mr`, `direct`, `local` |
| `gastown-reader-bead-id` | `gastown-context.el` | Bead IDs (context-aware) |
| `gastown-reader-agent-target` | `gastown-context.el` | Agent targets (context-aware) |

## Changes Required

### 1. `gastown-command-agents.el`

**Add require** at top (currently missing):
```elisp
(require 'gastown-reader)
```

**Add `:transient-reader gastown-reader-rig-name`** to `rig` slots in:
- `gastown-command-agents`
- `gastown-command-witness-status`
- `gastown-command-refinery-status`
- `gastown-command-session-list`
- `gastown-command-witness-attach`
- `gastown-command-witness-start`
- `gastown-command-witness-stop`
- `gastown-command-refinery-attach`
- `gastown-command-refinery-start`
- `gastown-command-refinery-stop`
- `gastown-command-refinery-pause`
- `gastown-command-refinery-resume`
- `gastown-command-refinery-unclaimed`
- `gastown-command-session-check`

**Add `:transient-reader gastown-reader-polecat-address`** to `polecat-address`
slots in:
- `gastown-command-session-at`
- `gastown-command-session-capture`
- `gastown-command-session-inject`
- `gastown-command-session-restart`
- `gastown-command-session-start`
- `gastown-command-session-status`
- `gastown-command-session-stop`

### 2. `gastown-command-mail.el`

**Add require** at top (currently missing):
```elisp
(require 'gastown-reader)
```

**Add `:transient-reader gastown-reader-mail-address`** to:
- `gastown-command-mail-send`: `recipient` slot
- `gastown-command-mail-clear`: `target` slot
- `gastown-command-mail-search`: `from` slot

### 3. `gastown-command-sling.el`

Already has `(require 'gastown-reader)`.

**Add readers** to `gastown-command-sling`:
- `formula` slot → `:transient-reader gastown-reader-formula-name`
- `crew` slot → `:transient-reader gastown-reader-crew-name`

## Implementation Pattern

The pattern is uniform — add one line to each slot definition:

```elisp
;; Before:
(formula
  :initarg :formula
  :type (or null string)
  :initform nil
  :documentation "Formula to apply."
  :long-option "formula"
  :option-type :string
  :key "F"
  :transient "--formula"
  :class transient-option
  :argument "--formula="
  :prompt "Formula: "
  :transient-group "Work"
  :level 1
  :order 20)

;; After (add :transient-reader line):
(formula
  :initarg :formula
  :type (or null string)
  :initform nil
  :documentation "Formula to apply."
  :long-option "formula"
  :option-type :string
  :key "F"
  :transient "--formula"
  :class transient-option
  :argument "--formula="
  :prompt "Formula: "
  :transient-reader gastown-reader-formula-name  ; ← add this
  :transient-group "Work"
  :level 1
  :order 20)
```

## Tests

Add to `lisp/test/gastown-command-coverage-test.el`:

```elisp
;; agents.el readers
(ert-deftest gastown-command-agents-rig-reader ()
  "gastown-command-agents rig slot should use gastown-reader-rig-name."
  (should (equal (beads-meta-slot-property
                  'gastown-command-agents 'rig :transient-reader)
                 'gastown-reader-rig-name)))

;; mail.el readers
(ert-deftest gastown-command-mail-send-recipient-reader ()
  "gastown-command-mail-send recipient slot should use gastown-reader-mail-address."
  (should (equal (beads-meta-slot-property
                  'gastown-command-mail-send 'recipient :transient-reader)
                 'gastown-reader-mail-address)))

;; sling.el readers
(ert-deftest gastown-command-sling-formula-reader ()
  "gastown-command-sling formula slot should use gastown-reader-formula-name."
  (should (equal (beads-meta-slot-property
                  'gastown-command-sling 'formula :transient-reader)
                 'gastown-reader-formula-name)))

(ert-deftest gastown-command-sling-crew-reader ()
  "gastown-command-sling crew slot should use gastown-reader-crew-name."
  (should (equal (beads-meta-slot-property
                  'gastown-command-sling 'crew :transient-reader)
                 'gastown-reader-crew-name)))
```

Add similar tests for all the session-* polecat-address slots and the
other rig slots. Cover all commands listed in the Changes Required section.

## Scope

- **No new functions** — only `:transient-reader` annotations added to existing slots.
- **No behavior changes** — `gastown-command-execute` is unaffected.
- **No new completion sources** — all data comes from existing cached sources.
- Tests verify slot metadata, not runtime behavior (fast, no CLI required).
