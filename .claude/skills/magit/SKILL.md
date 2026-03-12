---
name: magit
description: Expert guide for working with and extending the magit Emacs Git porcelain. Use when implementing magit-section, magit-mode, git process handling, buffer management, transient menus, or any magit extension.
---

# Magit Developer Reference

Magit is a complete text-based Git user interface for Emacs. This skill covers
internal APIs for extending and working with magit programmatically.

## When to Use This Skill

Invoke when:
- Building magit extensions or plugins
- Working with `magit-section` hierarchical buffer API
- Defining transient commands that integrate with magit
- Calling git via magit's process/git layer
- Managing magit buffers programmatically
- Implementing refresh functions for custom magit modes

## Core Architecture

Magit has three layers:

1. **magit-section** — Generic collapsible section tree for Emacs buffers
2. **magit-mode** — Buffer lifecycle, display, and refresh management
3. **Git integration** — Process management and git command wrappers

**Key design principle**: Buffers are entirely regenerated on refresh (no
incremental updates). Section visibility is preserved via identity matching
(type + value chain).

## Section API (magit-section)

### Section Object

```elisp
;; Section EIEIO slots:
;; - type    (symbol)   — e.g., 'file, 'hunk, 'commit, 'branch
;; - value   (any)      — e.g., filename, commit hash (forms identity with type)
;; - start   (position) — buffer start of section
;; - content (position) — end of heading / start of body
;; - end     (position) — buffer end of section
;; - hidden  (bool)     — collapsed?
;; - children (list)    — child sections
;; - parent  (section)  — parent section
;; - washer  (function) — deferred content generator (called on first expand)
;; - keymap  (keymap)   — section-specific keybindings
```

### Creating Sections

```elisp
;; magit-insert-section — core macro for all section creation
(magit-insert-section (TYPE &optional VALUE HIDE)
  ;; Insert heading text here (not hidden)
  (insert "Section heading\n")
  ;; Insert body content here (collapsed when HIDE is non-nil)
  (magit-insert-section (child-type child-value)
    (insert "Child content\n")))

;; Example: file section
(magit-insert-section (file "README.md")
  (insert (propertize "README.md" 'face 'magit-filename))
  (insert "\n")
  ;; Hunk children
  (magit-insert-section (hunk)
    (magit-git-insert "diff" "--" "README.md")))

;; With washer (defer content until section is first expanded):
(magit-insert-section (commits nil t) ; HIDE=t initially
  (insert "Unpushed commits\n")
  (magit-section-set-washer #'my-insert-commits))
```

### Querying Sections

```elisp
(magit-section-value section)     ; Section's value (e.g., filename, hash)
(magit-section-type section)      ; Section's type symbol
(magit-section-children section)  ; List of child sections
(magit-section-parent section)    ; Parent section
magit-section-root                ; Root section of current buffer

;; Get section at point
(magit-current-section)

;; Match section against type spec
(magit-section-match 'file section)           ; Exact type match
(magit-section-match '(hunk file) section)    ; Parent context match

;; Walk sections
(magit-walk-sections (lambda (section) ...) root)
```

### Visibility Control

```elisp
(magit-section-show section)             ; Expand (runs washer if needed)
(magit-section-hide section)             ; Collapse
(magit-section-toggle section)           ; Toggle
(magit-section-show-children section)    ; Expand all children
(magit-section-hide-children section)    ; Collapse all children
(magit-section-cycle section)            ; Cycle: collapsed→expanded→children-collapsed
```

### Section Identity & Visibility Preservation

Visibility state is preserved across refreshes using section identity:
a chain of `(type . value)` pairs from root to section.

```elisp
;; Sections with matching identity restore their old visibility on refresh.
;; Use stable, meaningful values — not buffer positions.
;; Example identity chain: ((status) (file . "README.md") (hunk . 1))
```

## Transient Integration

Magit uses the `transient` library (same team) for command menus.

### Defining a Transient

```elisp
;; Prefix = the menu
(transient-define-prefix my-command-menu ()
  "My command transient menu"
  [["Actions"
    ("a" "Action A" my-action-a)
    ("b" "Action B" my-action-b)]
   ["Options"
    ("-f" "Flag" "--flag")
    ("-v" "Verbose" "--verbose")]])

;; Infix = toggleable option/argument
(transient-define-argument my-command:--format ()
  :description "Output format"
  :class 'transient-option
  :argument "--format="
  :choices '("short" "medium" "full"))

;; Switch = simple on/off flag
(transient-define-argument my-command:--stat ()
  :description "Show statistics"
  :class 'transient-switch
  :argument "--stat")

;; Suffix = the actual command
(transient-define-suffix my-action-a ()
  :description "Perform action A"
  (interactive)
  (let ((args (transient-args transient-current-command)))
    (magit-call-git "my-git-command" args)))
```

### Extending Existing Magit Transients

```elisp
;; Add to existing magit transient
(transient-append-suffix 'magit-dispatch '(0 -1)
  ["My Extension"
   ("X" "My command" my-command-menu)])

;; Insert before specific key
(transient-insert-suffix 'magit-log "l"
  ["My log variant"
   ("m" "My log" my-log-command)])
```

### Reading Transient Args in Suffix

```elisp
(defun my-suffix ()
  (interactive)
  (let* ((args (transient-args 'my-command-menu))
         (verbose (member "--verbose" args))
         (format (transient-arg-value "--format=" args)))
    (magit-run-git "my-cmd" args)))
```

## Process & Git Integration

### Getting Values (synchronous)

```elisp
;; Single string result (trimmed)
(magit-git-string "rev-parse" "--short" "HEAD")
;; => "abc1234"

;; List of lines
(magit-git-lines "branch" "--list")
;; => ("main" "feature/foo" "fix/bar")

;; Null-separated items (e.g., for filenames with spaces)
(magit-git-items "ls-files" "-z")

;; Insert output at point (into current buffer)
(magit-git-insert "diff" "--stat" "HEAD")

;; Boolean: did git succeed?
(magit-git-success "diff" "--quiet")
;; => t or nil
```

### Running Git for Effect

```elisp
;; Synchronous — blocks, returns exit code, logs to process buffer
(magit-call-git "add" "--" "README.md")

;; Asynchronous — returns process object, triggers refresh when done
(magit-run-git "push" "origin" "HEAD")

;; Asynchronous with custom sentinel/filter
(magit-start-git nil "fetch" "--all")

;; Low-level: run any program
(magit-run-git-async "rebase" "--interactive" "HEAD~3")
```

### Process Buffer

```elisp
;; Show the process log buffer
(magit-process-buffer)

;; Accessible via `$` in magit buffers
;; Contains all git commands run and their output
```

### Argument Handling

All git functions accept flat or nested lists — nil is silently dropped:

```elisp
;; These are equivalent:
(magit-git-string "log" "--oneline" "-5")
(magit-git-string "log" (list "--oneline" "-5"))
(magit-git-string "log" "--oneline" nil "-5")  ; nil dropped
```

## Buffer Management

### Creating/Setting Up Buffers

```elisp
;; magit-mode-setup is the central function for all magit buffer creation
(magit-mode-setup #'my-custom-mode)
;; Sets magit-refresh-function and magit-refresh-args, then calls refresh

;; Find existing buffer for mode+repository
(magit-mode-get-buffer 'magit-status-mode (magit-toplevel) t)
;; Arguments: MODE, REPOSITORY, CREATE-IF-MISSING
```

### Buffer Display

```elisp
;; Display buffer (like display-buffer but selects it)
(magit-display-buffer some-buffer)

;; Built-in display functions (set magit-display-buffer-function):
;; - magit-display-buffer-traditional (default)
;; - magit-display-buffer-same-window-except-diff-v1
;; - magit-display-buffer-fullframe-status-v1
;; - magit-display-buffer-fullcolumn-most-v1
```

### Buffer-Local State

```elisp
;; Every magit buffer has these buffer-local variables:
magit-refresh-function   ; Function to regenerate content
magit-refresh-args       ; Arguments passed to refresh function
magit--default-directory ; Repository root (stable across let-bindings)
```

### Refresh Mechanism

```elisp
;; Trigger refresh of current buffer + status buffer
(magit-refresh)

;; Refresh all magit buffers
(magit-refresh-all)

;; After git commands, magit-process-sentinel auto-refreshes the relevant buffers
```

### Defining a Custom Mode

```elisp
(define-derived-mode my-magit-mode magit-mode "My Magit"
  "Custom magit-derived mode."
  :group 'my-extension)

(defun my-magit-mode-refresh-buffer ()
  "Regenerate buffer content."
  (magit-insert-section (my-root)
    (magit-insert-section (info nil)
      (insert "My custom section\n")
      (magit-git-insert "log" "--oneline" "-5"))))

(defun my-magit ()
  "Open my custom magit buffer."
  (interactive)
  (magit-mode-setup #'my-magit-mode))

;; Register refresh function:
(defvar-local magit-refresh-function 'my-magit-mode-refresh-buffer)
```

## Extending the Status Buffer

```elisp
;; Add custom section to magit-status
(defun my-insert-custom-section ()
  (magit-insert-section (my-section)
    (magit-insert-heading "My Custom Section:")
    (insert "Content here\n")))

;; Hook it in
(add-hook 'magit-status-sections-hook #'my-insert-custom-section)

;; Control position (t = append, nil = prepend)
(add-hook 'magit-status-sections-hook #'my-insert-custom-section t)
```

## Key Entry Points

```
magit-status       — Main status buffer (C-x g)
magit-dispatch     — Main command menu (? in magit buffers)
magit-log          — Commit history with options (l)
magit-diff         — Diff with options (d)
magit-commit       — Commit transient (c)
magit-branch       — Branch operations (b)
magit-push         — Push operations (P)
magit-pull         — Pull operations (F)
magit-merge        — Merge operations (m)
magit-rebase       — Rebase operations (r)
magit-stash        — Stash operations (z)
magit-refresh      — Refresh buffer (g)
magit-refresh-all  — Refresh all buffers (G)
```

## Common Buffer Keybindings

```
TAB    — Toggle section expansion
RET    — Visit thing at point
w      — Copy section value to kill ring
$      — Show process buffer
g      — Refresh
G      — Refresh all
?      — Show dispatch menu
```

## Module Structure

```
magit-section.el       — Section library (hierarchical collapsible sections)
magit-mode.el          — Mode base class, buffer lifecycle, refresh
magit-git.el           — Git value-getting functions
magit-process.el       — Git effect functions, process management
magit-status.el        — Status buffer and sections
magit-log.el           — Log buffer and formatting
magit-diff.el          — Diff buffer, hunks, staging
magit-commit.el        — Commit transient and modes
magit-branch.el        — Branch operations
magit-remote.el        — Remote management
magit-stash.el         — Stash operations
magit-apply.el         — Patch/hunk application
magit-blame.el         — Blame overlays
magit-extras.el        — Additional commands
git-commit.el          — Commit message editing mode
```

## Quick Reference

| Function | Purpose |
|----------|---------|
| `magit-insert-section` | Create collapsible section |
| `magit-insert-heading` | Insert non-collapsible heading line |
| `magit-git-insert` | Insert git output at point |
| `magit-git-string` | Get single string from git |
| `magit-git-lines` | Get list of lines from git |
| `magit-git-items` | Get null-separated items from git |
| `magit-call-git` | Run git synchronously (for effect) |
| `magit-run-git` | Run git asynchronously (for effect) |
| `magit-current-section` | Section at point |
| `magit-section-value` | Get section value |
| `magit-section-type` | Get section type |
| `magit-section-match` | Match section type |
| `magit-refresh` | Refresh current + status buffer |
| `magit-mode-setup` | Create/switch to magit buffer |
| `magit-display-buffer` | Display a magit buffer |
| `transient-define-prefix` | Define menu |
| `transient-define-suffix` | Define action |
| `transient-define-argument` | Define option |
| `transient-args` | Read selected options in suffix |

## Reference

- Manual: https://magit.vc/manual/magit/
- Section manual: https://magit.vc/manual/magit-section/
- Transient manual: https://magit.vc/manual/transient/
- Source: https://github.com/magit/magit
