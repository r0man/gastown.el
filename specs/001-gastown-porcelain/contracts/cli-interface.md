# CLI Interface Contract: Gastown.el

**Feature**: 001-gastown-porcelain
**Date**: 2026-01-03

## Overview

This document defines the contract between gastown.el and the Gastown CLI (`gt`). It specifies which commands gastown.el will invoke and how their output will be interpreted.

---

## CLI Prerequisites

| Requirement | Check |
|-------------|-------|
| `gt` in PATH | `(executable-find "gt")` returns non-nil |
| Gastown workspace | `gt status` exits with code 0 |
| Go 1.23+ runtime | Handled by `gt` itself |

---

## Command Contracts

### 1. Status Check

**Command**: `gt status`

**Purpose**: Verify workspace initialization and get overview.

**Expected Exit Codes**:
- `0`: Success, workspace is valid
- Non-zero: Not a Gastown workspace or error

**Output Format** (expected):
```
Workspace: /path/to/workspace
Status: active
Daemon: running
Agents: 3 active
Convoys: 2 active
```

**Parser Contract**:
```elisp
;; Returns alist or nil on error
(defun gastown-parse-status (output)
  "Parse gt status output into alist.")
```

---

### 2. List Convoys

**Command**: `gt convoy list`

**Purpose**: Get all convoys in workspace.

**Expected Exit Codes**:
- `0`: Success (may return empty list)
- Non-zero: Error

**Output Format** (expected):
```
ID          Name           Status    Tasks
convoy-001  Feature Work   active    5
convoy-002  Bug Fixes      paused    3
```

**Parser Contract**:
```elisp
;; Returns list of convoy alists
(defun gastown-parse-convoy-list (output)
  "Parse gt convoy list output.")
```

---

### 3. Convoy Details

**Command**: `gt convoy status <id>`

**Purpose**: Get detailed information about a specific convoy.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Convoy not found or error

**Output Format** (expected):
```
Convoy: convoy-001
Name: Feature Work
Description: Implement new features
Status: active
Created: 2026-01-03T10:00:00Z
Tasks:
  - task-001: Implement login (in-progress)
  - task-002: Add tests (pending)
```

---

### 4. List Tasks

**Command**: `gt sling list` (or equivalent)

**Purpose**: Get all assigned tasks.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Error

**Output Format** (expected):
```
ID         Title              Status       Assignee
task-001   Implement login    in-progress  polecat-1
task-002   Add tests          pending      unassigned
```

---

### 5. Agent Status

**Command**: `gt agents`

**Purpose**: Get status of all agents.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Error

**Output Format** (expected):
```
Agent      Status    PID     Uptime
mayor      running   12345   2h 30m
polecat-1  running   12346   2h 29m
witness    stopped   -       -
```

---

### 6. Start Agents

**Command**: `gt start`

**Purpose**: Start Gastown agents.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Error (already running, config error, etc.)

**Behavior**: Asynchronous - gastown.el will run this async and monitor output.

---

### 7. Shutdown Agents

**Command**: `gt shutdown`

**Purpose**: Graceful shutdown of all agents.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Error

**Behavior**: Asynchronous - may take several seconds.

---

### 8. Create Convoy

**Command**: `gt convoy create --name "<name>" --description "<desc>"`

**Purpose**: Create a new convoy.

**Expected Exit Codes**:
- `0`: Success, convoy created
- Non-zero: Error

**Output on Success**:
```
Created convoy: convoy-003
```

---

### 9. Assign Task (Sling)

**Command**: `gt sling <bead> <rig>` (exact syntax TBD based on Gastown docs)

**Purpose**: Assign work to an agent.

**Expected Exit Codes**:
- `0`: Success
- Non-zero: Error

---

### 10. Enter Mayor Session

**Command**: `gt prime`

**Purpose**: Enter interactive Mayor session.

**Behavior**: Interactive process - gastown.el will create a dedicated buffer with process attached.

**Exit**: User-initiated or via `C-c C-c` in Emacs.

---

## Error Handling Contract

### Standard Error Format
All commands should output errors to stderr in a parseable format:
```
Error: <error message>
```

### Common Error Conditions

| Condition | Detection | gastown.el Response |
|-----------|-----------|---------------------|
| CLI not found | `executable-find` returns nil | User message with install instructions |
| Not a workspace | `gt status` exit != 0 | User message: "Run gt install" |
| Daemon not running | Status shows daemon stopped | User message: "Run gt start" |
| Command failed | Non-zero exit code | Show stderr in message |

---

## Version Compatibility

| Gastown Version | gastown.el Support |
|-----------------|-------------------|
| 0.1.x | Target version |

**Note**: Output format may vary. Parser functions should be resilient to minor variations.
