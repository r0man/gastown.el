---
name: beads
description: Git-backed issue tracker for multi-session work with dependencies and persistent memory across conversation compaction. Use when work spans sessions, has blockers, or needs context recovery after compaction.
---

# bd (beads) Expert

`bd` is a git-backed issue tracker with first-class dependency support, designed
for AI agents and multi-session workflows. It uses Dolt for version-controlled
storage with automatic sync.

## When to Use This Skill

Invoke this skill when:
- Creating, updating, or closing issues (`bd create`, `bd update`, `bd close`)
- Working with issue dependencies (`bd dep`, `bd blocked`, `bd graph`)
- Finding ready work (`bd ready`)
- Managing multi-session workflows with context recovery
- Working with `.beads/` config or Dolt database
- Using `bd mol`, `bd formula`, or `bd prime` commands

## Core Workflow

```bash
# Check what's ready to work on
bd ready

# Create an issue
bd create "Fix login bug" --description="Details" --type bug --priority 1

# Claim work (atomic)
bd update bd-abc --claim

# Work on it, then close
bd close bd-abc --reason "Fixed"
```

## Issue Types

| Type | Purpose |
|------|---------|
| `bug` | Something broken |
| `feature` | New functionality |
| `task` | Work item (tests, docs, refactoring) |
| `epic` | Large feature with subtasks |
| `chore` | Maintenance (dependencies, tooling) |
| `message` | Agent mail (internal) |

## Priorities

| Level | Meaning |
|-------|---------|
| `0` | Critical (security, data loss, broken builds) |
| `1` | High (major features, important bugs) |
| `2` | Medium (default) |
| `3` | Low (polish, optimization) |
| `4` | Backlog (future ideas) |

## Valid Statuses

`open`, `in_progress`, `blocked`, `deferred`, `closed`, `pinned`, `hooked`

There is NO `done` or `complete` status.

## Creating Issues

```bash
# Basic
bd create "Issue title"

# With all options
bd create "Issue title" \
  --description="Detailed context" \
  --type task \
  --priority 2 \
  --assignee "alice" \
  --json

# Link to parent issue (discovered during work on parent)
bd create "Found bug" \
  --description="Details" \
  --priority 1 \
  --deps discovered-from:bd-123 \
  --json

# Quick capture (outputs only the ID)
bd q "Quick note title"
```

## Updating Issues

```bash
# Claim work atomically (sets assignee + in_progress)
bd update bd-42 --claim

# Update priority
bd update bd-42 --priority 1

# Update status
bd update bd-42 --status blocked

# Add notes (persist findings across sessions)
bd update bd-42 --notes "Found root cause: ..."

# Add design document
bd update bd-42 --design "Architecture: ..."

# Multiple fields at once
bd update bd-42 --claim --priority 1 --notes "Starting now"
```

## Closing Issues

```bash
# Close with reason
bd close bd-42 --reason "Completed implementation"

# Close multiple
bd close bd-42 bd-43 --reason "Done"

# Close a step bead (no-changes case)
bd close bd-xyz --reason="no-changes: already implemented"
```

## Finding Work

```bash
# Show unblocked, open issues (ready to work on)
bd ready

# Show all open issues
bd list --status open

# Show blocked issues
bd blocked

# Search by text
bd search "login bug"

# Filter by label
bd list --label "priority-1"

# Show all issues (any status)
bd list
```

## Dependencies

**CRITICAL: Direction matters.** Think "X needs Y" not "X comes before Y".

```bash
# A depends on B (A needs B to be done first)
bd dep add A B   # "A needs B"

# NOT temporal order:
# WRONG: bd dep add phase1 phase2
# RIGHT: bd dep add phase2 phase1  (phase2 needs phase1)

# Remove dependency
bd dep remove A B

# Show dependency tree
bd dep tree bd-42

# Visualize all dependencies
bd graph

# What's blocked?
bd blocked
```

## Showing Issues

```bash
# Show details
bd show bd-42

# Show with JSON output
bd show bd-42 --json

# Show children of an epic
bd children bd-epic-1

# Show issue history
bd history bd-42
```

## Labels

```bash
# Add label
bd label add bd-42 "needs-review"

# Remove label
bd label rm bd-42 "needs-review"

# Common labels: bug, feature, good-first-issue, priority-0, blocked,
#                desire-path, discovered, needs-review
```

## Desire Paths

When a command fails but your intuition felt right, file a desire-path bead:

```bash
bd create "Add alias for common workflow" --type task \
  --label desire-path \
  --description "Expected 'bd X' to work but it doesn't. Context: ..."
```

## Molecule/Formula Workflow

Molecules are workflow templates (formulas) attached to a bead:

```bash
# Check your current step
bd mol current

# List formulas
bd formula list

# Show formula details
bd formula show shiny

# Pour a formula into a molecule wisp
bd formula run shiny --var key=value
```

## Sync & Persistence

```bash
# Push beads to remote
bd dolt push

# Pull from remote
bd dolt pull

# Check sync status
bd vc status

# Auto-commits on every write — no manual export needed
```

## Context Recovery (After Compaction)

```bash
# Get full workflow context
bd prime

# Find your in-progress work
bd list --status in_progress

# Recover a compacted issue's full history
bd restore bd-42
```

## Output Formats

```bash
# JSON output (for scripting/agents)
bd show bd-42 --json
bd ready --json
bd list --json

# Quiet (errors only)
bd -q close bd-42
```

## Routing

Prefix-based routing automatically directs commands to the right rig:

```bash
bd show ge-abc    # Routes to gastown_el rig
bd show hq-abc    # Routes to town-level beads
bd show -xyz      # Routes based on prefix
```

Debug routing: `BD_DEBUG_ROUTING=1 bd show <id>`

## Configuration

```bash
# Show effective backend identity
bd context

# Show database info
bd info

# Run health checks
bd doctor

# Where is .beads/ located?
bd where
```

## Common Patterns

### Agent Workflow

```bash
# 1. Find work
bd ready --json

# 2. Claim atomically (prevents race conditions)
bd update bd-42 --claim

# 3. Persist findings (survives session death)
bd update bd-42 --notes "Root cause: X. Fix: Y."

# 4. Discover new work during implementation
bd create "Found related bug" \
  --priority 1 \
  --deps discovered-from:bd-42

# 5. Complete
bd close bd-42 --reason "Implemented fix, tests pass"
```

### Epic with Subtasks

```bash
# Create epic
bd create "Big feature" --type epic

# Create subtasks
bd create "Subtask 1" --type task --deps discovered-from:bd-epic
bd create "Subtask 2" --type task --deps discovered-from:bd-epic

# Add blocking dependency (subtasks block parent)
bd dep add bd-epic bd-sub1
bd dep add bd-epic bd-sub2
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd ready` | Show unblocked work |
| `bd create "title"` | Create issue |
| `bd update <id> --claim` | Claim issue atomically |
| `bd show <id>` | Show issue details |
| `bd close <id>` | Close issue |
| `bd dep add A B` | A depends on B (A needs B) |
| `bd blocked` | Show blocked issues |
| `bd graph` | Visualize dependencies |
| `bd prime` | Get workflow context |
| `bd dolt push` | Sync to remote |
| `bd search "text"` | Search issues |
| `bd history <id>` | Show issue history |
| `bd mol current` | Current molecule step |
| `bd formula list` | List formulas |
