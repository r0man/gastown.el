# Research: Gastown.el Implementation

**Feature**: 001-gastown-porcelain
**Date**: 2026-01-03

## Research Summary

This document captures research findings that inform the implementation of gastown.el.

---

## 1. Gastown CLI Output Format

### Decision
Parse Gastown CLI text output directly; no JSON mode available.

### Rationale
- Gastown (Go CLI) does not document JSON output format
- CLI designed for human-readable terminal output
- Text parsing is standard approach for Emacs porcelains (Magit parses git text output)

### Alternatives Considered
- **Request JSON flag from Gastown**: Would require upstream changes; not in scope
- **Structured logging parsers**: Overkill for line-based CLI output

### Implementation Approach
```elisp
;; Parse line-based output into alists
(defun gastown-parse-convoy (line)
  "Parse convoy from 'gt convoy list' output."
  (let ((parts (split-string line "|" t " ")))
    (list (cons 'id (nth 0 parts))
          (cons 'name (nth 1 parts))
          (cons 'status (nth 2 parts)))))
```

### Key CLI Commands to Parse
| Command | Purpose | Expected Output Format |
|---------|---------|------------------------|
| `gt status` | Workspace overview | Key: Value lines |
| `gt convoy list` | List convoys | Tabular with headers |
| `gt convoy status <id>` | Convoy details | Structured text |
| `gt agents` | Agent status | Name: Status lines |

---

## 2. Emacs Porcelain Architecture (Magit Patterns)

### Decision
Use magit-section.el for buffer structure; derive mode from magit-mode.

### Rationale
- Magit-section provides collapsible sections, navigation, and keyboard handling
- Mature, well-tested library with active maintenance
- Users familiar with Magit will immediately understand the interface
- Significantly reduces boilerplate code

### Key Patterns Adopted

#### Status Buffer Composition (Hook-based)
```elisp
(defcustom gastown-status-sections-hook
  '(gastown-insert-workspace-header
    gastown-insert-convoys-section
    gastown-insert-tasks-section
    gastown-insert-agents-section)
  "Hooks run to insert sections into the status buffer.")
```

#### Section Hierarchy
```
Root: gastown-workspace
├── Workspace Header (path, status)
├── Convoys Section
│   └── Convoy items (collapsible)
├── Tasks Section
│   └── Task items (by status)
└── Agents Section
    └── Agent items (running/stopped)
```

#### Process Management
- Synchronous calls for quick operations (status queries)
- Asynchronous with sentinels for long operations (start, shutdown)
- Process buffer for logging and debugging

### Alternatives Considered
- **Custom buffer management**: More work, less familiar to users
- **tabulated-list-mode**: Better for flat lists, poor for hierarchical data

---

## 3. Transient.el Menu System

### Decision
Use transient.el for all command menus with hierarchical organization.

### Rationale
- Standard for Magit-style interfaces (transient.el extracted from Magit)
- Provides discoverable command interface with inline help
- Supports argument collection with infixes
- Already a dependency via Magit compatibility

### Menu Structure
```
gastown-dispatch (main menu, bound to ?)
├── Workflow: prime, start, shutdown
├── Convoys: create, list, view
├── Tasks: assign, list
└── Logging: view logs, refresh
```

### Key Implementation Patterns
```elisp
(transient-define-prefix gastown-dispatch ()
  "Main Gastown command dispatcher."
  ["Gastown"
   ["Workflow"
    ("p" "Prime (Mayor)" gastown-prime)
    ("s" "Start" gastown-start)]
   ["Convoys"
    ("c" "Create" gastown-convoy-create)]])
```

---

## 4. Keybinding Conventions

### Decision
Follow Magit conventions with Gastown-specific adaptations.

### Rationale
- Muscle memory for existing Magit users
- Consistent with broader Emacs ecosystem
- Proven ergonomic patterns

### Keybinding Map
| Key | Action | Magit Equivalent |
|-----|--------|------------------|
| `g` | Refresh buffer | `g` (refresh) |
| `RET` | Visit/expand at point | `RET` (visit) |
| `?` | Show main menu | `?` (dispatch) |
| `TAB` | Toggle section | `TAB` (toggle) |
| `p`/`n` | Navigate sections | `p`/`n` (prev/next) |
| `c c` | Create convoy | `c c` (commit create) |
| `s s` | Start agents | `r r` (rebase) |
| `s x` | Shutdown agents | - |
| `t a` | Assign task (sling) | - |
| `l l` | View logs | `l l` (log) |

---

## 5. Package Distribution

### Decision
MELPA distribution with transient.el as declared dependency.

### Rationale
- MELPA is standard channel for Emacs packages
- Automatic dependency resolution
- Easy installation via `M-x package-install`
- Version management and updates handled automatically

### Package Metadata
```elisp
;; Package-Requires: ((emacs "26.1") (transient "0.4.0") (magit-section "3.0.0"))
```

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| emacs | 26.1+ | Base requirement |
| transient | 0.4.0+ | Menu system |
| magit-section | 3.0.0+ | Buffer sections |

---

## 6. Error Handling Strategy

### Decision
Graceful degradation with user-friendly messages.

### Rationale
- Users need clear feedback when things go wrong
- Should not crash or leave Emacs in bad state
- Errors should be actionable

### Error Categories
| Error | Detection | User Message |
|-------|-----------|--------------|
| CLI missing | `(executable-find "gt")` | "Gastown CLI (gt) not found. Install from..." |
| Not a workspace | `gt status` fails | "Not in a Gastown workspace. Run 'gt install' first." |
| Daemon not running | `gt status` indicates | "Gastown daemon not running. Run 'gt start'." |
| Command failed | Non-zero exit | Show stderr in message buffer |

---

## 7. Testing Strategy

### Decision
ERT for unit tests, integration tests against mock CLI.

### Rationale
- ERT is standard Emacs testing framework
- Mock CLI responses for reproducible tests
- Integration tests verify full workflows

### Test Categories
1. **Unit tests**: Parsing functions, data transformations
2. **Integration tests**: Buffer creation, section insertion
3. **Mock tests**: CLI interaction with canned responses

### Test Structure
```
test/
├── gastown-core-test.el      # CLI parsing, process functions
├── gastown-status-test.el    # Buffer creation, sections
├── gastown-convoy-test.el    # Convoy operations
└── test-helper.el            # Mock utilities
```

---

## Outstanding Questions

None. All NEEDS CLARIFICATION items from Technical Context have been resolved.
