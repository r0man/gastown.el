# PRD: Formula Lifecycle Integration in beads.el / gastown.el

## Problem Statement

Users working with Gas Town formulas must leave Emacs and use the CLI to invoke
`gt formula run`, `gt sling --formula`, and `--var k=v` arguments. There is no
first-class Emacs UI for formula discovery, interactive variable filling,
execution, or output viewing. This creates workflow fragmentation for Emacs-first
users who want to manage their issue tracking and formula dispatch from a single
environment.

The formula system is a core Gas Town workflow primitive but it has no Emacs
face. The goal is to make Emacs (via beads.el and gastown.el) the primary
interface for formula-driven workflows.

## Goals

1. Discovery: Users can browse and search all available formulas from Emacs
   with name, description, and variable count visible
2. Interactive filling: Users can fill formula --var key=value pairs via a
   transient menu (one option per var, grouped required/optional, runs on RET)
3. Dual execution: Support both gt formula run (local) and gt sling --formula
   (dispatch to agent) from Emacs, clearly separated
4. Output visibility: Formula execution output shown in a read-only Emacs
   buffer (magit-process style)
5. beads.el integration: Formula dispatch accessible from all three natural
   surfaces: beads dispatch transient, issue detail buffer, beads-status section
6. History: Re-running a formula pre-fills previous variable values

## Non-Goals (V1)

- Formula authoring/editing within Emacs
- Real-time streaming output
- Modifying the bd/gt formula engine
- Batch multi-issue formula dispatch
- Boolean/enum type-aware var prompts (all vars treated as strings in V1)

## User Stories / Scenarios

1. Issue dispatch: From a beads.el issue buffer, press f to dispatch a
   formula on the current issue (auto-fills --on <bead-id>)
2. Formula browsing: Open gastown formula menu, press l to see all formulas
   with descriptions, select one to proceed
3. Variable filling: After picking a formula, a transient opens showing all
   vars as options; fill required ones, optionally fill others, press RET to run
4. Local run: Press r in formula menu, pick formula, fill vars, output
   appears in *gastown-formula: <name>* buffer
5. Agent dispatch: Press d, pick formula, pick rig, fill vars, sling
   dispatches to chosen rig
6. Re-run: Re-invoke formula; transient pre-fills previous var values

## Constraints

- Follow gastown-defcommand + beads-meta-define-transient patterns
- beads.el integration must be injection-style (forge pattern, no beads source changes)
- All new code needs ERT tests (TDD: test first)
- New modules in lisp/ following existing naming conventions
- Dynamic transient generation (vars are runtime-fetched) requires transient-define-prefix + fset
- Cap transient at 10 vars; fall back to sequential prompts for overflow

## Open Questions (Resolved)

1. Does gt formula show --json expose required and default for all vars?
   Confirmed yes (verified against mol-idea-to-plan: required, default, description fields present)
2. How to handle formulas with >10 variables in a transient?
   Cap at 10; fall back to sequential prompts for overflow
3. How to extract current bead ID from beads.el context for --on pre-fill?
   Use beads-current-issue or transient buffer-local variable
4. Should gastown-sling-formula be in gastown-command-sling.el or a new module?
   Add to gastown-command-sling.el to keep sling logic together

## Rough Approach

New infrastructure:
- gastown-formula-var EIEIO class (gastown-types.el)
- Enhanced completion caching for formula list + var metadata (gastown-completion.el)
- gastown-formula-var-transient: dynamic transient generator (gastown-command-formula.el)
- Formula output buffer (*gastown-formula: <name>*, read-only, special-mode)

Enhanced existing:
- gastown-formula-run: add var transient + output buffer
- gastown-formula-menu: add d dispatch, S status

New commands:
- gastown-sling-formula: formula -> rig -> vars -> gt sling
- gastown-formula-status: poll convoy status for dispatched run
- gastown-sling-formula-on-issue: gastown-sling-formula with --on <bead> pre-filled

beads injection (gastown-beads.el):
- Gas Town sub-menu: add f Formula entry
- Issue buffer: inject f Dispatch formula suffix
- beads-status: gastown-insert-formula-section hook

## Clarifications from Human Review

Q: Variable UX - sequential wizard vs transient menu vs hybrid?
A: Transient menu - all vars shown as transient options, user fills before executing.

Q: Output buffer type - compilation, comint, or read-only?
A: Read-only display buffer (magit-process style).

Q: beads.el integration scope - dispatch only, + issue buffer, or all surfaces?
A: All surfaces - dispatch menu + issue buffer + beads-status section.

Q: Run vs Sling - formula run only, sling only, or both?
A: Both, clearly separated: r Run locally and d Dispatch to agent.

Q: Sling scope - new command or improve existing sling transient?
A: New dedicated command gastown-sling-formula.

Q: Quick formula - default per-rig or always show picker?
A: Always show picker.
