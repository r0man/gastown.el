---
name: gastown
description: Gas Town multi-agent workspace manager. Use when working with gt CLI commands, managing rigs/polecats/witnesses/refineries, dispatching work (gt sling), agent communication (gt nudge, gt mail), Dolt server operations, or understanding Gas Town architecture.
---

# gt (Gas Town) Expert

`gt` manages multi-agent workspaces called **rigs**. It coordinates agent spawning,
work distribution, and communication across distributed teams of AI agents.

## When to Use This Skill

Invoke this skill when:
- Using `gt` CLI commands (sling, nudge, hook, done, status, etc.)
- Managing Gas Town agents (polecats, witness, refinery, deacon, mayor)
- Understanding rig architecture and agent roles
- Dispatching work with `gt sling` or formulas
- Agent communication via `gt nudge` or `gt mail`
- Managing the Dolt server
- Running `gt prime` for context recovery
- Using `gt done` to complete work

## Architecture Overview

```
Town (~/.gt/ or ~/gt/)
├── mayor/              ← Global coordinator (Chief of Staff)
├── deacon/             ← Town-level watchdog (manages witness + refinery)
├── <rig>/              ← A project workspace (e.g., gastown_el/)
│   ├── .beads/         ← Issue tracking (Dolt-backed)
│   ├── polecats/       ← Worker agents (ephemeral sessions, persistent identity)
│   │   └── <name>/     ← Individual polecat worktree
│   ├── refinery/       ← Merge queue processor
│   └── witness/        ← Per-rig polecat health monitor
```

## Agent Roles

| Role | Purpose |
|------|---------|
| **Polecat** | Worker agent. Gets assigned issues, implements, runs `gt done` |
| **Witness** | Per-rig health monitor. Nudges stuck polecats, handles cleanup |
| **Refinery** | Merge queue processor. Merges completed polecat branches to main |
| **Mayor** | Town-level coordinator. Routes cross-rig work, handles escalations |
| **Deacon** | Town-level watchdog. Manages witness + refinery health |
| **Overseer** | Human stakeholder. Receives critical escalations |

## The Propulsion Principle (GUPP)

**If you find work on your hook, YOU RUN IT.** No confirmation. No waiting.

The hook is your durability primitive — work survives session restarts,
context compaction, and handoffs.

```bash
gt hook          # Check what's on your hook
gt mol current   # Show current step in attached molecule
```

## Work Dispatch (gt sling)

`gt sling` is THE unified work dispatch command:

```bash
# Sling issue to a rig (auto-spawns polecat)
gt sling ge-abc gastown_el

# Sling to specific polecat
gt sling ge-abc gastown_el/furiosa

# Sling to mayor
gt sling ge-abc mayor

# Sling to crew member
gt sling ge-abc gastown_el --crew roman

# With formula (molecule workflow)
gt sling ge-abc gastown_el --formula shiny --var base_branch=main

# Control merge strategy
gt sling ge-abc gastown_el --merge=direct  # Push to main directly
gt sling ge-abc gastown_el --merge=mr      # Merge queue (default)
gt sling ge-abc gastown_el --merge=local   # Keep on feature branch

# Skip auto-convoy creation
gt sling ge-abc gastown_el --no-convoy
```

## Hook Management

```bash
# Show what's on your hook
gt hook
gt mol status   # Same thing

# Attach work to your hook
gt hook gt-abc

# Attach work to another agent's hook
gt hook gt-abc gastown_el/furiosa

# Remove work from hook
gt unsling
gt hook --clear
```

## Completing Work (gt done)

**MANDATORY final step for polecats:**

```bash
# Standard completion
gt done

# With explicit exit status
gt done --status ESCALATED   # Hit a blocker, needs human
gt done --status DEFERRED    # Work paused, issue still open

# Skip MR creation (for no-code changes)
gt done --cleanup-status clean

# Pre-verified (ran gates after rebasing)
gt done --pre-verified
```

`gt done` automatically:
1. Submits branch to merge queue
2. Notifies Witness with exit outcome
3. Syncs worktree to main
4. Transitions polecat to IDLE

## Agent Communication

### Nudge (Ephemeral — Preferred)

```bash
# Send ephemeral message (no permanent record, free)
gt nudge gastown_el/furiosa "Check your mail"
gt nudge witness "Polecat alpha seems stuck"
gt nudge mayor "Status update"
gt nudge deacon "session-started"

# With explicit message flag
gt nudge gastown_el/furiosa -m "Start on the login fix"

# Multi-line via stdin
gt nudge gastown_el/furiosa --stdin <<'EOF'
Status update:
- Task 1: complete
- Task 2: blocked
EOF

# Delivery modes
gt nudge target "msg" --mode wait-idle   # Default: wait for idle
gt nudge target "msg" --mode queue       # Queue for next session
gt nudge target "msg" --mode immediate   # Interrupt now (emergency only)

# Force through DND
gt nudge target "msg" --force

# Broadcast to all workers
gt broadcast "Merge freeze starts Thursday"
```

**Role shortcuts:** `mayor`, `deacon`, `witness`, `refinery` (expand to session names)

### Mail (Persistent — Use Sparingly)

Every `gt mail send` creates a permanent bead + Dolt commit. Use nudge instead
unless the message MUST survive the recipient's session death.

```bash
# View inbox
gt mail inbox

# Read message
gt mail read <mail-id>

# Send mail
gt mail send gastown_el/witness -s "HELP: auth bug" -m "Short message"

# Multi-line (ALWAYS use --stdin for complex messages)
gt mail send mayor/ -s "BLOCKED: dependency" --stdin <<'BODY'
Issue: ge-abc
Problem: Cannot proceed without X
Tried: approaches 1, 2, 3
Question: How should we handle Y?
BODY

# Send to human
gt mail send --human -s "Need approval" -m "Context..."

# Self-note
gt mail send --self -s "Remember" -m "Check X before pushing"
```

**Mail budget: 0-1 messages per polecat session.** Default to nudge.

## Escalation

```bash
# Standard escalation (preferred over mail)
gt escalate "Auth service is down" -s HIGH

# Critical (notifies Overseer)
gt escalate "Data loss risk" -s CRITICAL

# With detail
gt escalate "Blocker on ge-abc" -s HIGH -m "Tried: X, Y, Z. Need: access to prod"
```

Severity levels: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`

## Molecule/Formula Workflow

```bash
# List available formulas
gt formula list

# Show formula details
gt formula show shiny-enterprise

# Check your current step
gt mol current

# Show execution progress
gt mol progress

# Complete current step
gt mol step done

# Show molecule DAG
gt mol dag
```

## Session Management

```bash
# Load full role context (after compaction/new session)
gt prime
gt prime --hook    # With hook status

# Handoff to fresh session
gt handoff -s "Subject" -m "Context for next session"

# Check for handoff messages
gt resume

# View session checkpoints
gt checkpoint list

# Peek at another polecat's output
gt peek gastown_el/alpha

# Check all agent sessions
gt agents
```

## Status and Health

```bash
# Overall town status
gt status

# Unified health dashboard
gt vitals

# Run health checks
gt doctor

# Show recent agent activity
gt trail

# Real-time activity feed
gt feed

# Show what's ready across town
gt ready

# Find orphaned polecat work
gt orphans
```

## Convoy Tracking

Convoys track batches of work across rigs:

```bash
# List convoys
gt convoy list

# Show convoy details
gt convoy show <convoy-id>

# Start dashboard
gt dashboard
```

## Dolt Server Operations

**The Dolt server on port 3307 is the data plane. It is fragile.**

```bash
# Check server health
gt dolt status

# Start/stop
gt dolt start
gt dolt stop

# Clean up orphan test databases
gt dolt cleanup

# BEFORE restarting, collect diagnostics:
kill -QUIT $(cat ~/gt/.dolt-data/dolt.pid)    # Goroutine dump
gt dolt status 2>&1 | tee /tmp/dolt-hang-$(date +%s).log
# THEN: gt escalate -s HIGH "Dolt: <symptom>"
```

Port assignments:
- `3307` — Gas Town production (NEVER touch arbitrarily)
- `3308` — beads.el development
- `3309` — gastown.el development

## Services

```bash
# Bring up all services
gt up

# Bring down all services
gt down

# Manage daemon
gt daemon start
gt daemon stop
gt daemon status

# Start Gas Town
gt start
```

## Rig Management

```bash
# List rigs
gt rig list

# Show rig details
gt rig show gastown_el

# Create worktree in another rig
gt worktree <rig>

# Initialize a new rig
gt init
```

## Polecat Management

```bash
# List polecats
gt polecat list

# Show polecat details
gt polecat show furiosa

# Spawn a new polecat
gt polecat spawn <rig>

# View polecat session
gt session list
```

## Witness Operations

```bash
# Check witness status
gt witness status

# Start/stop witness
gt witness start
gt witness stop
```

## Costs and Diagnostics

```bash
# Show session costs
gt costs

# Show command metrics
gt metrics

# View town activity log
gt log

# Patrol digest
gt patrol digest
```

## Memory

```bash
# Store a memory (persists across sessions)
gt remember "key" "value"

# Retrieve
gt memories
gt memories search "auth"

# Forget
gt forget "key"
```

## Git Operations

```bash
# Commit with automatic agent identity
gt commit -m "feat: add feature"

# Find stale branches
gt prune-branches --dry-run
gt prune-branches
```

## Key Concepts

### The Hook

The "hook" is your durability primitive — a persistent record of what you're
working on. Survives:
- Context compaction
- Session restarts (via `gt handoff`)
- Crashes

Work on your hook = your current assignment.

### Wisps vs Beads

- **Bead**: Permanent issue. Tracked indefinitely.
- **Wisp**: Ephemeral issue. Auto-cleaned by TTL (short-lived tasks).

Molecules are attached to beads (or wisps for ephemerals).

### Merge Queue Workflow

```
Polecat implements → git push → gt done → Refinery MR → merged to main
```

Work is NOT landed until it's on `main` OR in the Refinery MQ.

### PR Workflow (longeye and similar repos)

```
Implement → Create PR → Monitor CI → Address feedback → CI green + approved → gt done
```

### Directory Discipline

**YOUR WORKTREE:** `<rig>/polecats/<name>/<repo>/`
**NEVER edit:** `<rig>/` directly (not a git working tree)

```bash
pwd    # Always verify you're in your worktree
git status && git add <files> && git commit -m "..." && git push
gt done
```

## Startup Protocol

```bash
gt prime --hook    # Load context + check hook
gt hook           # What's on my hook?
gt mol current    # What step am I on?
```

If hook has work → EXECUTE. No announcement. No waiting.
If hook empty → check mail: `gt mail inbox`

## Common Patterns

### Complete a Polecat Session

```bash
# Quality gates (must all pass)
eldev -p -dtT lint
eldev -p -dtT test
eldev -p -dtT compile

# Git
git status
git add <specific-files>
git commit -m "feat: ..."
git push

# Signal done
gt done
```

### Escalate a Blocker

```bash
gt escalate "Cannot proceed: X is unavailable" -s HIGH -m "Details: ..."
# Then: gt done --status ESCALATED
```

### Hand Off to Fresh Session

```bash
gt handoff -s "Working on ge-abc" -m "Current step: 3 of 5. Next: implement Y."
```

### Check System Health

```bash
gt vitals       # Everything at once
gt dolt status  # Dolt specifically
gt agents       # All active agents
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `gt prime` | Load role context (run after compaction) |
| `gt hook` | Show/attach work on hook |
| `gt mol current` | Current molecule step |
| `gt sling <bead> <target>` | Dispatch work to agent |
| `gt done` | Signal work complete (MANDATORY final step) |
| `gt done --status ESCALATED` | Signal blocker |
| `gt nudge <target> "msg"` | Ephemeral agent message |
| `gt mail send <addr>` | Persistent mail (sparingly) |
| `gt escalate "desc" -s HIGH` | Escalate critical blocker |
| `gt handoff -m "context"` | Hand off to fresh session |
| `gt status` | Town overview |
| `gt vitals` | Health dashboard |
| `gt agents` | List agent sessions |
| `gt trail` | Recent activity |
| `gt peek <agent>` | View agent output |
| `gt dolt status` | Dolt server health |
| `gt formula list` | Available formulas |
| `gt convoy list` | Track work batches |
