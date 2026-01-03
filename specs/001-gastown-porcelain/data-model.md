# Data Model: Gastown.el

**Feature**: 001-gastown-porcelain
**Date**: 2026-01-03

## Overview

Gastown.el is a read-only interface to the Gastown multi-agent orchestrator. It does not persist its own data; all state is read from the Gastown CLI. This document defines the internal data structures used to represent Gastown entities within Emacs.

---

## Entities

### 1. Workspace

Represents the Gastown workspace context.

| Field | Type | Description |
|-------|------|-------------|
| `path` | string | Absolute path to workspace root |
| `initialized` | boolean | Whether Gastown is set up in this directory |
| `daemon-running` | boolean | Whether Deacon (daemon) is active |

**Source**: `gt status` command output

### 2. Convoy

A grouped set of related tasks.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique convoy identifier |
| `name` | string | Human-readable convoy name |
| `description` | string | Convoy description/purpose |
| `status` | symbol | One of: `active`, `paused`, `completed` |
| `task-count` | integer | Number of tasks in convoy |
| `created-at` | string | ISO timestamp of creation |

**Source**: `gt convoy list` and `gt convoy status <id>` commands

**State Transitions**:
```
active -> paused -> active (toggle)
active -> completed (all tasks done)
```

### 3. Task (Molecule)

Individual work items assigned to agents.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique task identifier |
| `title` | string | Task title |
| `description` | string | Task description |
| `status` | symbol | One of: `pending`, `in-progress`, `completed`, `failed` |
| `assignee` | string | Agent name assigned to task |
| `convoy-id` | string | Parent convoy ID (may be nil) |
| `created-at` | string | ISO timestamp |
| `updated-at` | string | ISO timestamp of last update |

**Source**: `gt sling list` and task detail commands

**State Transitions**:
```
pending -> in-progress (agent starts work)
in-progress -> completed (success)
in-progress -> failed (error)
failed -> pending (retry)
```

### 4. Agent

AI workers in the Gastown system.

| Field | Type | Description |
|-------|------|-------------|
| `name` | symbol | Agent role: `mayor`, `polecat`, `witness`, `refinery`, `deacon` |
| `status` | symbol | One of: `running`, `stopped`, `error` |
| `pid` | integer | Process ID if running |
| `uptime` | string | Duration since start |

**Source**: `gt agents` and `gt peek <agent>` commands

**Agent Types**:
- **Mayor**: AI coordinator with full workspace context
- **Polecat**: Worker agents that execute tasks
- **Witness**: Monitors worker health and lifecycle
- **Refinery**: Handles merge queues and code review
- **Deacon**: Daemon managing agent lifecycle

### 5. LogEntry

Entries from agent or task logs.

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | ISO timestamp |
| `level` | symbol | One of: `debug`, `info`, `warn`, `error` |
| `source` | string | Agent name or task ID |
| `message` | string | Log message content |

**Source**: Log files in workspace or `gt` log commands

---

## Internal Structures

### Section Types (for magit-section)

| Type Symbol | Value | Description |
|-------------|-------|-------------|
| `gastown-root` | directory | Root section for workspace |
| `convoys` | nil | Container for convoy sections |
| `convoy` | convoy-id | Individual convoy |
| `tasks` | nil | Container for task sections |
| `task` | task-id | Individual task |
| `agents` | nil | Container for agent sections |
| `agent` | agent-name | Individual agent |

### Buffer Registry

| Buffer Pattern | Purpose |
|----------------|---------|
| `*gastown-status: <path>*` | Status buffer for workspace |
| `*gastown-convoy: <id>*` | Convoy detail view |
| `*gastown-logs: <source>*` | Log viewing buffer |
| `*gastown-process*` | Process output log |
| `*gastown-mayor*` | Interactive Mayor session |

---

## Data Flow

```
┌─────────────────┐
│  Gastown CLI    │
│  (gt commands)  │
└────────┬────────┘
         │ text output
         ▼
┌─────────────────┐
│  Parser Layer   │
│  (gastown-core) │
└────────┬────────┘
         │ alists
         ▼
┌─────────────────┐
│  Buffer Layer   │
│  (gastown-status)│
└────────┬────────┘
         │ magit-sections
         ▼
┌─────────────────┐
│  Display Layer  │
│  (user sees)    │
└─────────────────┘
```

---

## Relationships

```
Workspace (1) ─────< Convoy (many)
                         │
                         │ contains
                         ▼
Convoy (1) ────────< Task (many)
                         │
                         │ assigned to
                         ▼
Agent (1) ─────────< Task (many)
```

---

## Validation Rules

### Convoy
- `id` must be non-empty string
- `name` must be non-empty string
- `status` must be one of defined symbols

### Task
- `id` must be non-empty string
- `title` must be non-empty string
- `status` must be one of defined symbols
- `assignee` may be nil (unassigned)

### Agent
- `name` must be one of defined agent types
- `status` must be one of defined symbols
