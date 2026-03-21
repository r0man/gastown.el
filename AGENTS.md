# Agent Instructions

<!-- BEGIN BEADS INTEGRATION -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Dolt-powered version control with native sync
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update <id> --claim --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task atomically**: `bd update <id> --claim`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs via Dolt:

- Each write auto-commits to Dolt history
- Use `bd dolt push`/`bd dolt pull` for remote sync
- No manual export/import needed!

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

<!-- END BEADS INTEGRATION -->

## Build and Test Commands

**MANDATORY**: Run these commands after EVERY code change.

Check if guix is available and wrap accordingly:

```bash
if command -v guix >/dev/null 2>&1; then
  WRAP="guix shell -D -f guix.scm --"
else
  WRAP=""
fi
```

### Build (byte-compile)

```bash
$WRAP eldev -p -dtT compile
```

### Test

```bash
$WRAP eldev -p -dtT test
```

### Lint

```bash
$WRAP eldev -p -dtT lint
```

**ALL MUST PASS** before committing.

## Development Dolt Server

gastown.el development uses a **dedicated Dolt server on port 3309**,
isolated from the Gas Town production server (port 3307) and the
beads.el dev server (port 3308).

Port assignments:
- 3307 — Gas Town production (NEVER touch)
- 3308 — beads.el development
- 3309 — gastown.el development

If you need to run bd commands (for issue tracking) during development,
they will auto-discover the project Dolt server. Do not manually connect
to port 3307.

## Interactive Development Environment

**MANDATORY FOR ALL AGENT WORK** — all development MUST happen
interactively in a live non-graphical Emacs server controlled via emacsclient.

### Start the Emacs dev server

```bash
emacs --daemon=gastown-dev
```

Load gastown.el from the working tree:

```bash
emacsclient -s gastown-dev -e "(add-to-list (quote load-path) \"$(pwd)/lisp\")"
emacsclient -s gastown-dev -e "(require (quote gastown))"
```

### Interactive testing via emacsclient

```bash
# Evaluate expressions
emacsclient -s gastown-dev -e "(gastown)"

# Open terminal UI (in tmux)
emacsclient -s gastown-dev -nw
```

### Reload after changes

```bash
emacsclient -s gastown-dev -e "(load-file \"lisp/gastown.el\")"
emacsclient -s gastown-dev -e "(load-file \"lisp/gastown-command-work.el\")"
```

### Kill the server

```bash
emacsclient -s gastown-dev -e "(kill-emacs)"
```

Agents MUST try features interactively — invoke transient menus, verify
buffer output, check error handling.

## TDD Workflow (MANDATORY)

Follow this loop for every change:

1. **Write the test first** — add ERT test in lisp/test/
2. **Run tests — expect FAIL** (red):
   ```bash
   eldev -p -dtT test
   ```
3. **Implement minimum code** to make the test pass
4. **Run tests — expect PASS** (green):
   ```bash
   eldev -p -dtT test
   ```
5. **Byte-compile** to catch errors:
   ```bash
   eldev -p -dtT compile
   ```
6. **Refactor** if needed, keeping green
7. **Repeat**

Never write implementation before the test. Hard-to-test code signals
a design problem.

## Acceptance Testing in tmux

**MANDATORY** — every feature MUST be acceptance-tested in tmux with a
non-graphical Emacs, driven the way a human would use gastown.el.

### Workflow

1. Create tmux session:
   ```bash
   tmux new-session -d -s gastown-accept
   ```

2. Start non-graphical Emacs with gastown loaded:
   ```bash
   tmux send-keys -t gastown-accept "emacs -nw -Q --eval '(progn (add-to-list (quote load-path) \"$(pwd)/lisp\") (require (quote gastown)))'" Enter
   sleep 2
   ```

3. Open the main gastown menu:
   ```bash
   tmux send-keys -t gastown-accept "M-x gastown" Enter
   ```

4. Capture and verify:
   ```bash
   tmux capture-pane -t gastown-accept -p
   ```

5. Navigate menu entries, verify output, test keybindings.

### Using the tmux skill

In Claude Code, invoke `/tmux` skill to drive the Emacs session
programmatically: send keystrokes, capture pane output, verify behavior.

**Do NOT skip acceptance testing.** Unit tests catch logic errors;
tmux acceptance testing catches rendering, keybindings, and interactive
flow issues.

## Code Architecture

### Module Structure

```
lisp/
  gastown.el                    — Main entry point, gastown transient prefix, utilities
  gastown-command.el            — Base EIEIO command class (gastown-command)
  gastown-custom.el             — User-facing defcustom variables
  gastown-error.el              — Error handling utilities
  gastown-command-agents.el     — Agent management (polecat, witness, refinery)
  gastown-command-comm.el       — Communication commands
  gastown-command-config.el     — Configuration commands
  gastown-command-convoy.el     — Convoy tracking
  gastown-command-diagnostics.el — Health, logs, costs, trail
  gastown-command-mail.el       — Mail system
  gastown-command-nudge.el      — Nudge messaging
  gastown-command-peek.el       — Peek at polecat output
  gastown-command-polecat.el    — Polecat lifecycle
  gastown-command-rig.el        — Rig management
  gastown-command-services.el   — Services (up, down, daemon)
  gastown-command-sling.el      — Work dispatch
  gastown-command-status.el     — Status overview
  gastown-command-work.el       — Work commands (hook, done, ready, mq)
  gastown-command-workspace.el  — Workspace management

lisp/test/
  gastown-command-test.el       — ERT tests for command infrastructure
  gastown-test.el               — ERT tests for core gastown functionality
  gastown-test-test.el          — ERT tests for test helpers
```

### Key Design Patterns

- Reuses beads.el EIEIO command class infrastructure
- `gastown-defcommand` macro generates command class + transient infix
- All commands call `gt` CLI via `gastown-command-execute`
- All public entry points have `;;;###autoload` cookies
- Commands are organized into logical sub-menus by `gt --help` category

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

### Quality Gates (ZERO TOLERANCE)

**ALL of the following MUST be true before committing:**

```bash
# Zero lint warnings — not "mostly clean", ZERO
$WRAP eldev -p -dtT lint
# Expected output: no warnings, no errors

# Zero test failures — not "mostly passing", ZERO
$WRAP eldev -p -dtT test
# Expected output: all tests pass

# Clean byte-compile — no warnings
$WRAP eldev -p -dtT compile
```

**If ANY gate fails:**
1. Fix the issue — do NOT commit broken code
2. Re-run ALL gates from the top
3. Only proceed when all three are clean

There are no exceptions. "I'll fix it in the next commit" is not acceptable.
A single lint warning or test failure means you are NOT done.

### Mandatory Push Workflow

1. **File issues for remaining work** — Create beads for anything that needs follow-up
2. **Run quality gates** (see above) — ALL must pass: zero warnings, zero failures
3. **Update issue status** — Close finished work, update in-progress items
4. **PUSH TO REMOTE** — This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** — Clear stashes, prune remote branches
6. **Verify** — All changes committed AND pushed
7. **Hand off** — Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing — that leaves work stranded locally
- NEVER say "ready to push when you are" — YOU must push
- If push fails, resolve and retry until it succeeds
- Zero lint warnings and zero test failures are MANDATORY, not goals

---

# Polecat Context

> **Recovery**: Run `gt prime` after compaction, clear, or new session

## 🚨 THE IDLE POLECAT HERESY 🚨

**After completing work, you MUST run `gt done`. No exceptions.**

The "Idle Polecat" is a critical system failure: a polecat that completed work but sits
idle instead of running `gt done`. **There is no approval step.**

**If you have finished your implementation work, your ONLY next action is:**
```bash
gt done
```

Do NOT:
- Sit idle waiting for more work (there is no more work — you're done)
- Say "work complete" without running `gt done`
- Try `gt unsling` or other commands (only `gt done` signals completion)
- Wait for confirmation or approval (just run `gt done`)

**Your session should NEVER end without running `gt done`.** If `gt done` fails,
escalate to Witness — but you must attempt it.

---

## 🚨 SINGLE-TASK FOCUS 🚨

**You have ONE job: work your pinned bead until done.**

DO NOT:
- Check mail repeatedly (once at startup is enough)
- Ask about other polecats or swarm status
- Work on issues you weren't assigned
- Get distracted by tangential discoveries

File discovered work as beads (`bd create`) but don't fix it yourself.

---

## CRITICAL: Directory Discipline

**YOU ARE IN: `gastown_el/polecats/nux/`** — This is YOUR worktree. Stay here.

- **ALL file operations** must be within this directory
- **Use absolute paths** when writing files
- **NEVER** write to `~/gt/gastown_el/` (rig root) or other directories

```bash
pwd  # Should show .../polecats/nux
```

## Your Role: POLECAT (Autonomous Worker)

You are an autonomous worker assigned to a specific issue. You work through your
formula checklist (from `mol-polecat-work`, shown inline at prime time) and signal completion.

**Your mail address:** `gastown_el/polecats/nux`
**Your rig:** gastown_el
**Your Witness:** `gastown_el/witness`

## Polecat Contract

1. Receive work via your hook (formula checklist + issue)
2. Work through formula steps in order (shown inline at prime time)
3. Complete and self-clean (`gt done`) — you exit AND nuke yourself
4. Refinery merges your work from the MQ

**Self-cleaning model:** `gt done` pushes your branch, submits to MQ, nukes sandbox, exits session.

**Three operating states:**
- **Working** — actively doing assigned work (normal)
- **Stalled** — session stopped mid-work (failure)
- **Zombie** — `gt done` failed during cleanup (failure)

Done means gone. Run `gt prime` to see your formula steps.

**You do NOT:**
- Push directly to main (Refinery merges after Witness verification)
- Skip verification steps
- Work on anything other than your assigned issue

---

## Propulsion Principle

> **If you find something on your hook, YOU RUN IT.**

Your work is defined by the attached formula. Steps are shown inline at prime time:

```bash
gt hook                  # What's on my hook?
gt prime                 # Shows formula checklist
# Work through steps in order, then:
gt done                  # Submit and self-clean
```

---

## Startup Protocol

1. Announce: "Polecat nux, checking in."
2. Run: `gt prime && bd prime`
3. Check hook: `gt hook`
4. If formula attached, steps are shown inline by `gt prime`
5. Work through the checklist, then `gt done`

**If NO work on hook and NO mail:** run `gt done` immediately.

**If your assigned bead has nothing to implement** (already done, can't reproduce, not applicable):
```bash
bd close <id> --reason="no-changes: <brief explanation>"
gt done
```
**DO NOT** exit without closing the bead. Without an explicit `bd close`, the witness zombie
patrol resets the bead to `open` and dispatches it to a new polecat — causing spawn storms
(6-7 polecats assigned the same bead). Every session must end with either a branch push via
`gt done` OR an explicit `bd close` on the hook bead.

---

## Key Commands

### Work Management
```bash
gt hook                         # Your assigned work
bd show <issue-id>              # View your assigned issue
gt prime                        # Shows formula checklist (inline steps)
```

### Git Operations
```bash
git status                      # Check working tree
git add <files>                 # Stage changes
git commit -m "msg (issue)"     # Commit with issue reference
```

### Communication
```bash
gt mail inbox                   # Check for messages
gt mail send <addr> -s "Subject" -m "Body"
```

### Beads
```bash
bd show <id>                    # View issue details
bd close <id> --reason "..."    # Close issue when done
bd create --title "..."         # File discovered work (don't fix it yourself)
```

## ⚡ Commonly Confused Commands

| Want to... | Correct command | Common mistake |
|------------|----------------|----------------|
| Signal work complete | `gt done` | ~~gt unsling~~ or sitting idle |
| Message another agent | `gt nudge <target> "msg"` | ~~tmux send-keys~~ (drops Enter) |
| See formula steps | `gt prime` (inline checklist) | ~~bd mol current~~ (steps not materialized) |
| File discovered work | `bd create "title"` | Fixing it yourself |
| Ask Witness for help | `gt mail send gastown_el/witness -s "HELP" -m "..."` | ~~gt nudge witness~~ |

---

## When to Ask for Help

Mail your Witness (`gastown_el/witness`) when:
- Requirements are unclear
- You're stuck for >15 minutes
- Tests fail and you can't determine why
- You need a decision you can't make yourself

```bash
gt mail send gastown_el/witness -s "HELP: <problem>" -m "Issue: ...
Problem: ...
Tried: ...
Question: ..."
```

---

## Completion Protocol (MANDATORY)

When your work is done, follow this checklist — **step 4 is REQUIRED**:

⚠️ **DO NOT commit if lint or tests fail. Fix issues first.**

```
[ ] 1. Run quality gates (ALL must pass):
       - npm projects: npm run lint && npm run format && npm test
       - Go projects:  go test ./... && go vet ./...
[ ] 2. Stage changes:     git add <files>
[ ] 3. Commit changes:    git commit -m "msg (issue-id)"
[ ] 4. Self-clean:        gt done   ← MANDATORY FINAL STEP
```

**Quality gates are not optional.** Worktrees may not trigger pre-commit hooks,
so you MUST run lint/format/tests manually before every commit.

**Project-specific gates:** Read CLAUDE.md and AGENTS.md in the repo root for
the project's definition of done. Many projects require a specific test harness
(not just `go test` or `dotnet test`). If AGENTS.md exists, its "Core rule"
section defines what "done" means for this project.

The `gt done` command pushes your branch, creates an MR bead in the MQ, nukes
your sandbox, and exits your session. **You are gone after `gt done`.**

### Do NOT Push Directly to Main

**You are a polecat. You NEVER push directly to main.**

Your work goes through the merge queue:
1. You work on your branch
2. `gt done` pushes your branch and submits an MR to the merge queue
3. Refinery merges to main after Witness verification

**Do NOT create GitHub PRs either.** The merge queue handles everything.

### The Landing Rule

> **Work is NOT landed until it's in the Refinery MQ.**

**Local branch → `gt done` → MR in queue → Refinery merges → LANDED**

---

## Self-Managed Session Lifecycle

> See [Polecat Lifecycle](docs/polecat-lifecycle.md) for the full three-layer architecture.

**You own your session cadence.** The Witness monitors but doesn't force recycles.

### Persist Findings (Session Survival)

Your session can die at any time. Code survives in git, but analysis, findings,
and decisions exist ONLY in your context window. **Persist to the bead as you work:**

```bash
# After significant analysis or conclusions:
bd update <issue-id> --notes "Findings: <what you discovered>"
# For detailed reports:
bd update <issue-id> --design "<structured findings>"
```

**Do this early and often.** If your session dies before persisting, the work is lost forever.

**Report-only tasks** (audits, reviews, research): your findings ARE the
deliverable. No code changes to commit. You MUST persist all findings to the bead.

### When to Handoff

Self-initiate when:
- **Context filling** — slow responses, forgetting earlier context
- **Logical chunk done** — good checkpoint
- **Stuck** — need fresh perspective

```bash
gt handoff -s "Polecat work handoff" -m "Issue: <issue>
Current step: <step>
Progress: <what's done>"
```

Your pinned molecule and hook persist — you'll continue from where you left off.

---

## Dolt Health: Your Part

Dolt is git, not Postgres. Every `bd create`, `bd update`, `gt mail send` generates
a permanent Dolt commit. You contribute to Dolt health by:

- **Nudge, don't mail.** `gt nudge` costs zero. `gt mail send` costs 1 commit forever.
  Only mail when the message must survive session death (HELP to Witness).
- **Don't create unnecessary beads.** File real work, not scratchpads.
- **Close your beads.** Open beads that linger become pollution.

See `docs/dolt-health-guide.md` for the full picture.

## Do NOT

- Push to main (Refinery does this)
- Work on unrelated issues (file beads instead)
- Skip tests or self-review
- Guess when confused (ask Witness)
- Leave dirty state behind

---

## 🚨 FINAL REMINDER: RUN `gt done` 🚨

**Before your session ends, you MUST run `gt done`.**

---

Rig: gastown_el
Polecat: nux
Role: polecat
