# gastown.el - Emacs Mode Design Document

> Research deliverable for ga-jzx: Emacs mode design for Gas Town

## Executive Summary

This document outlines the design for `gastown.el`, an Emacs major mode for
interacting with Gas Town, a multi-agent workspace manager. The mode follows
established Emacs patterns from magit (transient menus, status buffers),
projectile (project detection), and tabulated-list-mode (structured data views).

## Design Philosophy

### Core Principles

1. **Keyboard-Driven Flow**: All operations accessible via transient menus
2. **Discoverability**: Commands visible in popup menus (recall < recognition)
3. **"Modes are Apps"**: gastown.el is a complete interface, not just key bindings
4. **Context-Awareness**: Menus adapt based on current rig/role
5. **JSON Integration**: Leverage `--json` flags for structured data parsing

### What Needs Emacs UI vs Shell Access

| Category | Emacs UI (Rich) | Shell Access (Simple) |
|----------|-----------------|----------------------|
| Status views | ✓ gt status, convoy list, polecat list | |
| Issue management | ✓ bd list, bd show, bd graph | |
| Mail | ✓ Inbox, read, compose | |
| Live feeds | ✓ gt feed, activity stream | |
| Agent control | | gt sling, gt handoff |
| Services | | gt up, gt down |
| Diagnostics | ✓ gt doctor output | gt log (partial) |

## Architecture Overview

```
gastown.el (entry point)
├── gastown-core.el          Core utilities, JSON parsing, process execution
├── gastown-transient.el     Main transient menu definitions
├── gastown-status.el        Status buffer (like magit-status)
├── gastown-convoy.el        Convoy list/status buffers
├── gastown-polecat.el       Polecat list/management
├── gastown-beads.el         Issue tracking interface (bd integration)
├── gastown-mail.el          Mail inbox/compose/read
├── gastown-feed.el          Real-time activity feed
└── gastown-faces.el         Custom faces for status indicators
```

## Command Mapping

### gt Commands → Emacs Functions

#### Work Management
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt convoy list` | `gastown-convoy-list` | tabulated-list |
| `gt convoy status <id>` | `gastown-convoy-status` | special-mode |
| `gt hook` | `gastown-hook-show` | minibuffer/popup |
| `gt sling <bead> <target>` | `gastown-sling` | transient dispatch |
| `gt mol status` | `gastown-mol-status` | special-mode |
| `gt mq list` | `gastown-mq-list` | tabulated-list |

#### Agent Management
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt polecat list [rig]` | `gastown-polecat-list` | tabulated-list |
| `gt polecat status <name>` | `gastown-polecat-status` | special-mode |
| `gt session list` | `gastown-session-list` | tabulated-list |
| `gt agents` | `gastown-agents-menu` | transient popup |
| `gt peek <rig/polecat>` | `gastown-peek` | special-mode (output) |

#### Communication
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt mail inbox` | `gastown-mail-inbox` | tabulated-list |
| `gt mail read <id>` | `gastown-mail-read` | special-mode |
| `gt mail send` | `gastown-mail-compose` | message-mode derived |
| `gt nudge <target> <msg>` | `gastown-nudge` | minibuffer |
| `gt broadcast <msg>` | `gastown-broadcast` | minibuffer |

#### Services
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt status` | `gastown-status` | special-mode (main) |
| `gt up` | `gastown-up` | async process |
| `gt down` | `gastown-down` | async process |
| `gt doctor` | `gastown-doctor` | compilation-mode derived |

#### Workspace
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt rig list` | `gastown-rig-list` | tabulated-list |
| `gt crew list` | `gastown-crew-list` | tabulated-list |

#### Diagnostics
| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `gt feed` | `gastown-feed` | special-mode (streaming) |
| `gt log` | `gastown-log` | special-mode |
| `gt audit` | `gastown-audit` | tabulated-list |

### bd Commands → Emacs Functions

| Command | Emacs Function | Buffer Type |
|---------|---------------|-------------|
| `bd list` | `gastown-beads-list` | tabulated-list |
| `bd show <id>` | `gastown-beads-show` | special-mode |
| `bd ready` | `gastown-beads-ready` | tabulated-list |
| `bd blocked` | `gastown-beads-blocked` | tabulated-list |
| `bd graph <id>` | `gastown-beads-graph` | special-mode (ASCII) |
| `bd create` | `gastown-beads-create` | transient + minibuffer |
| `bd update <id>` | `gastown-beads-update` | transient dispatch |
| `bd close <id>` | `gastown-beads-close` | command |

## Transient Menu Structure

### Main Entry Point: `M-x gastown` or `C-c g`

```
Gas Town
─────────────────────────────────────────
Status      s  Show town status
Convoy      c  Convoy management
Polecats    p  Polecat management
Beads       b  Issue tracking
Mail        m  Messaging
Feed        f  Activity feed
─────────────────────────────────────────
Services
  Up        U  Start all services
  Down      D  Stop all services
  Doctor    !  Run diagnostics
─────────────────────────────────────────
Workspace
  Rigs      r  Manage rigs
  Crew      w  Crew management
```

### Convoy Transient (`C-c g c`)

```
Convoy Management
─────────────────────────────────────────
View
  List      l  Show all convoys
  Status    s  Show convoy status
─────────────────────────────────────────
Actions
  Create    c  Create new convoy
  Add       a  Add issues to convoy
```

### Beads Transient (`C-c g b`)

```
Beads (Issue Tracking)
─────────────────────────────────────────
View
  List      l  List all issues
  Ready     r  Show ready work
  Blocked   B  Show blocked issues
  Graph     g  Dependency graph
─────────────────────────────────────────
Actions
  Create    c  Create issue
  Update    u  Update issue
  Close     x  Close issue
  Sync      S  Sync with remote
─────────────────────────────────────────
Filters (infix)
  -s        --status=    Filter by status
  -t        --type=      Filter by type
  -p        --priority=  Filter by priority
  -a        --assignee=  Filter by assignee
```

### Polecat Transient (`C-c g p`)

```
Polecat Management
─────────────────────────────────────────
View
  List      l  List polecats
  Status    s  Polecat status
  Peek      P  View session output
─────────────────────────────────────────
Actions
  Add       a  Add polecat
  Nuke      X  Destroy polecat
  Nudge     n  Send message
─────────────────────────────────────────
Context
  --rig=    r  Target rig
```

## Buffer Designs

### gastown-status-mode (Main Dashboard)

```
Gas Town: ~/gt
══════════════════════════════════════════════════════════════

Services
  Daemon    ● running (pid 12345)
  Deacon    ● running (gt-deacon)
  Mayor     ● running (gt-mayor)

Rigs (3)
  gastown     2 polecats  ● witness  ● refinery
  beads       1 polecat   ● witness  ● refinery
  greenplace  0 polecats  ○ witness  ○ refinery

Active Convoys (2)
  hq-cv-abc   "Feature: Auth system"     3/5 complete
  hq-cv-def   "Bugfix: Memory leak"      1/2 complete

Recent Activity
  12:34  gastown/furiosa    ✓ Closed gt-abc
  12:32  beads/crew/joe     → Started bd-xyz
  12:30  mayor              🎯 Slung work to greenplace

[s]tatus refresh  [c]onvoy  [p]olecat  [b]eads  [m]ail
```

**Key bindings:**
- `g` - Refresh buffer
- `RET` - Drill into item at point
- `s` - Sling work (context-aware)
- `c` - Convoy transient
- `p` - Polecat transient
- `b` - Beads transient
- `m` - Mail transient

### gastown-convoy-list-mode (Tabulated List)

```
Convoy List
────────────────────────────────────────────────────────────

ID          Name                     Progress  Status  Updated
hq-cv-abc   Feature: Auth system     3/5       active  2m ago
hq-cv-def   Bugfix: Memory leak      1/2       active  15m ago
hq-cv-ghi   Refactor: Database       5/5       landed  1h ago

[RET] details  [g] refresh  [c] create  [a] add issues
```

### gastown-beads-list-mode (Tabulated List)

```
Issues
────────────────────────────────────────────────────────────

ID       Pri  Type    Status       Assignee        Title
gt-abc   P1   bug     in_progress  gastown/furiosa Fix auth crash
gt-def   P2   task    open         -               Add tests
gt-ghi   P2   feature blocked      -               New dashboard
bd-xyz   P3   chore   open         beads/crew/joe  Update deps

[RET] show  [c] create  [u] update  [x] close  [g] refresh
[r] ready  [B] blocked  [G] graph
```

### gastown-mail-inbox-mode (Tabulated List)

```
Inbox: mayor/
────────────────────────────────────────────────────────────

  From                 Subject                        Date
● gastown/witness      Status: polecats healthy       12:34
● gastown/refinery     Merged: gt-abc                 12:30
○ beads/crew/joe       Question about API             12:15

[RET] read  [c] compose  [r] reply  [d] delete  [g] refresh
```

### gastown-feed-mode (Streaming)

```
Activity Feed                                    [Following]
────────────────────────────────────────────────────────────

12:34:56  +  gastown/furiosa  created gt-abc
12:34:58  →  gastown/furiosa  claimed gt-abc
12:35:12  ✓  gastown/furiosa  closed gt-abc
12:35:15  ⚙  gastown/refinery merge_started gt-abc
12:35:45  ✓  gastown/refinery merged gt-abc

[p] pause  [f] follow  [g] refresh  [q] quit
```

## JSON Integration Strategy

All commands with `--json` support should be called with JSON output for
reliable parsing:

```elisp
(defun gastown--run-json (program &rest args)
  "Run PROGRAM with ARGS, parsing JSON output."
  (with-temp-buffer
    (apply #'call-process program nil t nil (append args '("--json")))
    (goto-char (point-min))
    (json-read)))

;; Example usage:
(defun gastown-convoy-list-entries ()
  "Get convoy list as tabulated-list entries."
  (let ((convoys (gastown--run-json "gt" "convoy" "list")))
    (mapcar (lambda (c)
              (list (alist-get 'id c)
                    (vector (alist-get 'id c)
                            (alist-get 'name c)
                            (format "%d/%d"
                                    (alist-get 'completed c)
                                    (alist-get 'total c))
                            (alist-get 'status c)
                            (alist-get 'updated c))))
            convoys)))
```

## Context Detection

Following projectile's pattern, detect context from directory:

```elisp
(defun gastown-detect-context ()
  "Detect Gas Town context from current directory."
  (let ((dir (locate-dominating-file default-directory ".beads")))
    (when dir
      (cond
       ;; Town root
       ((file-exists-p (expand-file-name "mayor/town.json" dir))
        '(town . nil))
       ;; Rig root
       ((file-exists-p (expand-file-name "config.json" dir))
        `(rig . ,(file-name-nondirectory (directory-file-name dir))))
       ;; Polecat worktree
       ((string-match "polecats/\\([^/]+\\)" dir)
        `(polecat . ,(match-string 1 dir)))
       ;; Crew worktree
       ((string-match "crew/\\([^/]+\\)" dir)
        `(crew . ,(match-string 1 dir)))
       (t '(unknown . nil))))))
```

## Real-Time Features

### Feed Watching

Use process filters for streaming output:

```elisp
(defun gastown-feed-start ()
  "Start watching the activity feed."
  (let ((proc (start-process "gt-feed" "*gastown-feed*"
                             "gt" "feed" "--plain" "--follow")))
    (set-process-filter proc #'gastown-feed-filter)))

(defun gastown-feed-filter (proc string)
  "Filter for feed output - parse and display events."
  (with-current-buffer (process-buffer proc)
    (goto-char (point-max))
    (insert (gastown-feed-format-event string))
    (goto-char (point-max))))
```

### Session Peek

```elisp
(defun gastown-peek (target)
  "View recent output from TARGET session."
  (interactive (list (gastown-read-polecat "Peek at: ")))
  (let ((output (shell-command-to-string
                  (format "gt peek %s" target))))
    (with-current-buffer (get-buffer-create "*gastown-peek*")
      (erase-buffer)
      (insert output)
      (gastown-peek-mode)
      (pop-to-buffer (current-buffer)))))
```

## Implementation Phases

### Phase 1: Core Infrastructure
- [ ] `gastown-core.el` - Process execution, JSON parsing, context detection
- [ ] `gastown-faces.el` - Faces for status indicators (●/○, priorities)
- [ ] Basic transient menu entry point

### Phase 2: Status Views (Read-Only)
- [ ] `gastown-status.el` - Main dashboard buffer
- [ ] `gastown-convoy.el` - Convoy list and status views
- [ ] `gastown-polecat.el` - Polecat list and status views
- [ ] `gastown-beads.el` - Issue list, show, ready, blocked

### Phase 3: Actions
- [ ] Transient menus for all command groups
- [ ] `gastown-sling` - Work dispatch with target completion
- [ ] `gastown-beads-create/update/close` - Issue management

### Phase 4: Communication
- [ ] `gastown-mail.el` - Inbox, read, compose, reply
- [ ] `gastown-nudge` - Send nudge messages
- [ ] `gastown-broadcast` - Broadcast to workers

### Phase 5: Real-Time
- [ ] `gastown-feed.el` - Streaming activity feed
- [ ] Auto-refresh for status buffers
- [ ] Notifications integration

### Phase 6: Polish
- [ ] Customization options (faces, key bindings)
- [ ] Integration with other Emacs packages (embark, consult)
- [ ] Performance optimization for large workspaces

## Dependencies

Required packages:
- `transient` (built into Emacs 28+)
- `tabulated-list` (built-in)
- `json` (built-in)

Optional enhancements:
- `embark` - Action menus on any item
- `consult` - Enhanced completion
- `orderless` - Flexible matching

## Key Bindings Summary

### Global
- `C-c g` - Main Gas Town transient menu

### Status Buffer
- `g` - Refresh
- `RET` - Drill into item
- `s` - Sling work
- `c` - Convoy menu
- `p` - Polecat menu
- `b` - Beads menu
- `m` - Mail menu
- `?` - Help

### List Buffers (tabulated-list)
- `g` - Refresh
- `RET` - Show details
- `n/p` - Next/previous line
- `s` - Sort by column
- `/` - Filter

### Transient Menus
- Standard transient navigation
- `C-g` - Quit
- `?` - Help

## Conclusion

gastown.el should provide a magit-like experience for Gas Town operations.
The design prioritizes:

1. **Familiarity** - Following established Emacs patterns
2. **Discoverability** - All operations visible in transient menus
3. **Efficiency** - Keyboard-driven with minimal friction
4. **Reliability** - JSON-based parsing for structured data
5. **Extensibility** - Modular architecture for future growth

The phased implementation allows for incremental delivery while building
toward a complete Gas Town interface in Emacs.
