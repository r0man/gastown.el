# Design: Live Emacs Integration Test for gastown.el

**Issue**: ge-mol-z03i
**Implements**: ge-mol-f18w (shiny-enterprise epic)
**Blocked by this**: ge-mol-mxfu (Draft: Implement)

## Goal

Verify that every command class, transient menu, and completing-read reader
in gastown.el works correctly against a live Gas Town installation at `~/gt`.

## Smoke-Test Findings (2026-03-31)

All 25 transient menus open and close without errors. 8 of 9 completing-read
readers work. One reader hangs due to a CLI flag bug (see Bugs section).

### Transient Menus — All Pass

| Menu | Status |
|------|--------|
| `gastown` (main) | OK |
| `gastown-formula-menu` | OK |
| `gastown-work-menu` | OK |
| `gastown-agent-management` | OK |
| `gastown-witness` | OK |
| `gastown-refinery` | OK |
| `gastown-session-menu` | OK |
| `gastown-comm-menu` | OK |
| `gastown-services` | OK |
| `gastown-quota-menu` | OK |
| `gastown-scheduler-menu` | OK |
| `gastown-workspace-menu` | OK |
| `gastown-crew-menu` | OK |
| `gastown-namepool-menu` | OK |
| `gastown-worktree-menu` | OK |
| `gastown-config-menu` | OK |
| `gastown-account-menu` | OK |
| `gastown-config-values-menu` | OK |
| `gastown-directive` | OK |
| `gastown-hooks-menu` | OK |
| `gastown-diagnostics` | OK |
| `gastown-convoy` | OK |
| `gastown-mq` | OK |
| `gastown-synthesis-menu` | OK |
| `gastown-wl` | OK |

### Completing-Read Readers

| Reader | Source module | Live candidates | Status |
|--------|--------------|-----------------|--------|
| `gastown-reader-rig-name` | `gastown-reader.el` | 3 rigs | OK |
| `gastown-reader-formula-name` | `gastown-reader.el` | 47 formulas | OK |
| `gastown-reader-mail-address` | `gastown-reader.el` | 16 addresses | OK |
| `gastown-reader-merge-strategy` | `gastown-reader.el` | 3 fixed choices | OK |
| `gastown-reader-convoy-id` | `gastown-reader.el` | 25 convoys | OK |
| `gastown-reader-crew-name` | `gastown-reader.el` | 1 crew | OK |
| `gastown-reader-bead-id` | `gastown-context.el` | context-aware | OK |
| `gastown-reader-agent-target` | `gastown-context.el` | context-aware | OK |
| `gastown-reader-polecat-address` | `gastown-reader.el` | — | **HANG** |

## Known Bugs (File as Beads)

### Bug 1: `gastown-command-polecat-list` missing `--all` flag

**Symptom**: `gastown-reader-polecat-address` hangs. The emacsclient process
never returns, requiring forceful termination.

**Root cause**: `gastown-completion--fetch-polecats` calls:
```elisp
(gastown-command-polecat-list :json t)
```
This generates `gt polecat list --json`. The CLI requires a rig name or `--all`:
```
Error: rig name required (or use --all)
```

The docstring says "via gt polecat list **--all** --json" but the command class
has no `:all` slot. The fix is to add an `--all` boolean slot to
`gastown-command-polecat-list` and pass `:all t` in the fetch function.

**Fix location**: `lisp/gastown-command-polecat.el` and
`lisp/gastown-completion.el`.

### Bug 2: `gastown-completion--fetch-polecats` lacks error handling

**Symptom**: When `gastown-command-execute` throws, the error is not caught and
the completion table construction crashes. Unlike `gastown-completion--fetch-crew`
and `gastown-completion--fetch-formulas` (which use `call-process` with
`condition-case`), the polecat fetcher propagates errors into the completion UI.

**Fix**: Wrap the execute call in `condition-case` and return `nil` on error
(same pattern as the crew and formula fetchers).

## Test Architecture

### Setup

Use the Emacs daemon approach (from `CLAUDE.md`):

```bash
WORKDIR="$(pwd)"
BEADS_DIR="$HOME/workspace/beads.el/lisp"
guix shell -D -f guix.scm -- emacs --daemon=gastown-test \
  --eval "(progn (push \"$BEADS_DIR\" load-path) \
                 (push \"$WORKDIR/lisp\" load-path))"
guix shell -D -f guix.scm -- emacsclient -s gastown-test \
  -e "(require 'gastown)"
```

Then use `emacsclient -s gastown-test -e "(expr)"` for all assertions.
Avoids the key-sending brittleness of raw tmux send-keys.

### Teardown

```bash
guix shell -D -f guix.scm -- emacsclient -s gastown-test -e "(kill-emacs)"
```

### Test File

New file: `lisp/test/gastown-live-integration-test.el`

Tag all tests `:tags '(:live)` so they're excluded from the default ERT run.
Live tests require `~/gt` to be a working Gas Town installation.

Skip guard:
```elisp
(gastown-test-skip-unless-gt)
(skip-unless (file-directory-p (expand-file-name "~/gt")))
```

## Test Plan

### 1. Menu Rendering Tests

For each of the 25 transient prefixes, verify:
- Function is `fboundp`
- Can be called without error
- Produces a `*transient*` buffer
- Buffer content contains expected section headings

```elisp
(ert-deftest gastown-live-menus-all-render ()
  "All 25 transient prefixes render without error."
  :tags '(:live)
  (gastown-test-skip-unless-gt)
  (dolist (sym *gastown-live-test-menus*)
    (condition-case err
      (progn
        (funcall sym)
        (sit-for 0.05)
        (transient-quit-all)
        (sit-for 0.02))
      (error (ert-fail (format "%s raised: %s" sym err))))))
```

Where `*gastown-live-test-menus*` is the list of all 25 menu symbols.

### 2. Reader Completion Tests

For each reader, mock `completing-read` to capture the completion table and
verify it provides live candidates:

```elisp
(ert-deftest gastown-live-reader-rig-name ()
  "gastown-reader-rig-name provides live rig candidates."
  :tags '(:live)
  (let ((default-directory (expand-file-name "~/gt"))
        candidates)
    (cl-letf (((symbol-function 'completing-read)
               (lambda (_prompt coll &rest _)
                 (setq candidates (all-completions "" coll))
                 (car candidates))))
      (gastown-reader-rig-name "Rig: "))
    (should (> (length candidates) 0))
    (should (stringp (car candidates)))))
```

Readers to cover: `rig-name`, `formula-name`, `mail-address`,
`merge-strategy`, `convoy-id`, `crew-name`, `bead-id`, `agent-target`.

**Skip `polecat-address`** until Bug 1 and Bug 2 are fixed.

### 3. Command-Line Integration Tests

For read-only commands (no side effects), test full execution against `~/gt`:

| Command | Verification |
|---------|-------------|
| `gastown-command-status` | Exit 0, non-empty output |
| `gastown-command-rig-list` | Returns ≥1 rig objects |
| `gastown-command-convoy-list` | Returns list (may be empty) |
| `gastown-command-formula-list` | Returns ≥1 formula objects |
| `gastown-command-vitals` | Exit 0, non-empty output |

```elisp
(ert-deftest gastown-live-status-runs ()
  "gastown-command-status executes successfully against ~/gt."
  :tags '(:live)
  (gastown-test-skip-unless-gt)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-status))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))))
```

### 4. Annotation Function Tests

Verify completion annotations render for each entity type:

```elisp
(ert-deftest gastown-live-rig-annotations ()
  "Rig completion entries have status annotations."
  :tags '(:live)
  (let* ((default-directory (expand-file-name "~/gt"))
         (table (gastown-completion-rig-table))
         (ann-fn (completion-metadata-get
                  (completion-metadata "" table nil)
                  'annotation-function)))
    (when ann-fn
      (let* ((candidates (all-completions "" table))
             (ann (funcall ann-fn (car candidates))))
        (should (stringp ann))))))
```

## Implementation Notes for ge-mol-mxfu

1. **File location**: `lisp/test/gastown-live-integration-test.el`
2. **Tags**: Use `:tags '(:live)` on all tests — excluded from `eldev test`
3. **Live test runner**: `eldev -p -dtT test --tags :live` (separate CI job)
4. **Default-directory**: Always bind to `(expand-file-name "~/gt")` for tests
   that invoke `gt` CLI
5. **Daemon approach**: Prefer `emacsclient -e` over tmux key-sending for
   assertions (more deterministic, no timing issues)
6. **Polecat reader**: Skip with `(skip-unless (not (gastown-live--polecat-reader-broken-p)))`
   until Bug 1 is fixed, or write a test that documents the known failure

## Menu Symbol Lists (for test file)

```elisp
(defconst gastown-live-test-top-menus
  '(gastown
    gastown-formula-menu
    gastown-work-menu
    gastown-agent-management
    gastown-comm-menu
    gastown-services
    gastown-workspace-menu
    gastown-config-menu
    gastown-diagnostics
    gastown-convoy
    gastown-mq
    gastown-synthesis-menu
    gastown-wl)
  "Top-level transient menus reachable from the main gastown menu.")

(defconst gastown-live-test-sub-menus
  '(gastown-witness
    gastown-refinery
    gastown-session-menu
    gastown-quota-menu
    gastown-scheduler-menu
    gastown-crew-menu
    gastown-namepool-menu
    gastown-worktree-menu
    gastown-account-menu
    gastown-config-values-menu
    gastown-directive
    gastown-hooks-menu)
  "Sub-menus reached from category menus.")

(defconst gastown-live-test-readers
  '(gastown-reader-rig-name
    gastown-reader-formula-name
    gastown-reader-mail-address
    gastown-reader-merge-strategy
    gastown-reader-convoy-id
    gastown-reader-crew-name
    gastown-reader-bead-id
    gastown-reader-agent-target)
  "Reader functions to test (excludes gastown-reader-polecat-address — see Bug 1).")
```
