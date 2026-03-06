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
