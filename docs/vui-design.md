# UI Design: vui.el vs Native Emacs Modes for gastown.el / beads.el

*Research completed: 2026-03-10*

## Summary

After studying vui.el's architecture, its five "Built with VUI" projects, and
the current gastown.el UI code, the recommendation is:

- **Keep all existing native-mode UIs** — they are the right tool for their jobs
- **Use vui.el for new read/write dashboard views** where state, interactivity,
  and composable sections are needed
- **The primary candidate for vui.el** in gastown.el is an enhanced status view;
  in beads.el, a detail/inspect view for individual beads with inline editing

---

## 1. vui.el Architecture and API

vui.el is a React-like component library for Emacs buffers. It wraps `widget.el`
with a virtual DOM, reconciler, component instances, local state, hooks, and
context — the same mental model as React, adapted to Emacs.

### Core primitives

| Primitive | Purpose |
|-----------|---------|
| `vui-defcomponent` | Declare a component with local state, lifecycle hooks, render |
| `vui-mount` | Mount a component tree into a buffer with full reactivity |
| `vui-render` | Stateless render (no reactive re-renders) |
| `vui-set-state` | Update state, schedule a re-render |
| `vui-batch` | Multiple state updates → single re-render |
| `vui-use-effect` | Side effects triggered by dependency changes |
| `vui-use-memo` | Memoized computed values |
| `vui-use-async` | Async data loading with status/data/error |
| `vui-defcontext` | Context providers for deep prop propagation |

### Layout primitives

`vui-vstack`, `vui-hstack`, `vui-box`, `vui-table`, `vui-list` — compose
arbitrary 2D layouts. `vui-table` supports column specs with `:grow`, `:min-width`,
`:align`, `:border`, automatically sizing columns.

### Interactive primitives

`vui-button`, `vui-field`, `vui-checkbox`, `vui-select` — all wired to `widget.el`
but described declaratively. `vui-collapsible` (in `vui-components.el`) gives
expand/collapse sections with indent accumulation via context.

### Design philosophy

- **Declarative**: `render = f(props, state)` — same inputs, same output
- **Unidirectional data flow**: data flows down as props; events bubble up via callbacks
- **Emacs-native**: respects point, markers, keymaps, faces; `vui-mode` derives from `special-mode`
- **Component isolation**: state is local; shared state flows through context

---

## 2. "Built with VUI" — Key Findings

### 2.1 vulpea-ui (sidebar for org notes)

A per-frame sidebar showing outline, backlinks, stats for the active note.

**Patterns worth adopting:**

- **Widget registry**: components register with a name, predicate, and order; the
  host assembles the displayed list dynamically. Enables plug-in extensibility.
- **Context for current domain object**: `vui-defcontext` passes the active note
  to all widgets without prop-drilling.
- **Children-as-lambda**: the `vulpea-ui-widget` wrapper takes `children` as a
  `(lambda () ...)` to defer rendering when collapsed.
- **`vui-use-memo` keyed on buffer-modified-tick**: expensive computations (outline
  parse, backlink queries) only re-run when the source buffer changes.
- **Soft vs hard refresh**: `vui-update-props` preserves memos; `vui-update`
  invalidates them. Use soft refresh for data updates, hard refresh for structural changes.

### 2.2 vulpea-journal (calendar UI)

Registers four sidebar widgets; the most complex is a 7-column `vui-table`
calendar with per-cell face computation.

**Patterns worth adopting:**

- **`vui-table` for grids**: even a calendar is just a table — rows are weeks,
  cells are `vui-button` or `""`. No custom drawing needed.
- **Effect for state reset**: when the selected month changes, an effect resets
  `view-month`/`view-year` to nil, re-centering the calendar. This "sync derived
  state back to nil" pattern is clean and avoids stale state.
- **`vui-batch` for atomic multi-field updates**: month navigation updates both
  month and year simultaneously without an intermediate render.

### 2.3 brb (wine club management — most complex)

Two full CRUD UIs: a multi-event dashboard and a per-event planner with tabs,
async balance loading, and inline editing persisted to disk.

**Patterns worth adopting:**

- **Context-as-state-bus**: 6–8 contexts defined at the file top; root component
  holds all state and provides it via nested providers. Deeply nested components
  call `(use-brb-plan-actions)` to get mutation functions — equivalent to a
  React context+reducer pattern.
- **Actions plist**: instead of passing many callback props, assemble one
  `(list :add-wine fn :remove-wine fn ...)` plist and distribute via context.
  Child components call `(funcall (plist-get actions :key) arg)`.
- **`vui-use-async` with refresh counter**: load data asynchronously; the key
  includes a `refresh-counter` state variable; incrementing it invalidates the
  cache and forces a reload.
- **`vui-button` cells in tables for inline editing**: table cells that should be
  editable are buttons showing current values; clicking opens a minibuffer prompt;
  result is passed to the appropriate action. Gives a spreadsheet-like UX without
  editable fields in-table.
- **Tab routing in state**: `(tab "plan")` in `:state`; `(pcase tab ...)` in
  `:render`. Clean, no extra machinery needed.
- **`:on-mount` for initialization**: load initial data once; use `vui-batch` to
  set all state fields in one re-render.

### 2.4 unicode-inspector (live character inspector)

Input field → live `vui-table` of Unicode properties. Demonstrates the minimal
viable vui app pattern.

**Patterns worth adopting:**

- **Minimal component**: single state var, single `vui-field`, one table. Not
  every vui app needs to be complex.
- **`vui-render` for sub-views without state**: when a secondary buffer has no
  reactive state, skip `vui-mount` and use stateless `vui-render`.
- **`vui-list` with key function**: for lists where individual items may change
  but the list is long, pass a key function to the reconciler so only changed
  items are re-rendered.
- **Pre-propertized strings as table cells**: `vui-table` accepts both vnodes and
  plain strings; strings are inserted with their text-properties intact.

### 2.5 eijiro-search (Japanese dictionary search)

Single component app: search field + options → ripgrep → parsed results table.

**Patterns worth adopting:**

- **`vui-use-effect` as search trigger**: the entire search logic lives in an
  effect keyed on the query and all options. When any input changes, the effect
  fires and updates state with results.
- **All four form primitives in one component**: `vui-field`, `vui-select`,
  `vui-checkbox ×2` — the full form-building pattern.

---

## 3. Comparison: vui.el vs Native Modes

### 3.1 `tabulated-list-mode` (currently used)

**Strengths:**
- Built-in, zero deps
- Excellent for homogeneous tabular data (list of rigs, sessions, mail)
- Column headers, sorting, keyboard navigation all free
- `tabulated-list-get-id` at point — trivial action dispatch
- Scales to thousands of rows (efficient string-based rendering)

**Weaknesses:**
- All rows must have the same column schema — no heterogeneous sections
- No collapsible groups
- No interactive fields — all edits go through minibuffer commands
- Re-rendering requires repopulating `tabulated-list-entries` and calling
  `tabulated-list-print t` — no reconciler, no point preservation
- No composability — can't mix tables with other content in the same buffer

**When to prefer:** Homogeneous lists (rig list, session list, mail inbox). Any
view that is purely "select an item, then do something". Fast tabular browsing.
gastown.el's existing tabulated views (`gastown-tabulated.el`) are correct and
should not be replaced.

### 3.2 `magit-section-mode` (currently used)

**Strengths:**
- Rich collapsible tree with arbitrary content
- `magit-section-value-if` for context-sensitive actions
- Keymaps per section type
- Hook-based extension model (`magit-status-sections-hook`)
- Efficient redraw via section-aware refresh
- Widely understood by Emacs power users (magit familiarity)

**Weaknesses:**
- Imperative rendering: sections are inserted with `magit-insert-section` and
  `insert` calls — reads like assembly, not a view definition
- Hard to share logic between sections (must factor into insert- functions)
- No local state — all "state" lives outside the buffer
- Auto-refresh requires manual timer setup + full buffer redraw
- No interactive form elements
- `magit` as a dependency is heavy

**When to prefer:** Read-only structured views where the collapsible tree IS the
UI (like `gastown-status-buffer.el`). The status buffer uses magit-section well:
rigs fold, agents fold, sections are independently collapsible. This is the right
tool here. The real cost is the magit dependency, but we already have it.

### 3.3 `transient.el` (currently used)

**Strengths:**
- Best-in-class command dispatch with key hints
- Built-in prefix/suffix/group structure
- Infix arguments (flags, values) wired to commands
- Persistent state across invocations
- History, help, error handling all free

**Weaknesses:**
- A menu launcher, not a buffer UI — wrong tool for displaying state
- Can't render structured content (tables, sections, formatted text)
- No composability with buffer UIs

**When to prefer:** Command dispatch menus — exactly how gastown.el uses it. All
`gastown-defcommand` invocations remain correct. Never use transient for displaying
content.

### 3.4 `widget.el`

**Strengths:**
- Built-in interactive fields, buttons, checkboxes
- Works in any buffer mode
- Used internally by Customize

**Weaknesses:**
- Highly imperative: build widget trees by calling `widget-create`, position-dependent
- No reconciler — full teardown/rebuild on refresh
- No layout primitives — must manually `insert` spacing, newlines
- No component abstraction
- Cursor position lost on refresh unless carefully preserved
- API surface is complex and poorly documented

**When to prefer:** Rarely. vui.el is widget.el with everything you'd want layered
on top. If you need interactive elements in a buffer, use vui.el — it wraps
widget.el and adds reconciliation, layout, and component abstraction.

### 3.5 `vui.el`

**Strengths:**
- Declarative: views are pure functions of data
- Local state + lifecycle hooks (mount, update, unmount) eliminate manual lifecycle management
- Context for shared state avoids prop-drilling in deep trees
- Reconciler preserves point across re-renders
- `vui-use-async` for async data loading with built-in loading/error states
- `vui-use-memo` for performance — expensive computations only re-run when deps change
- `vui-table` for 2D grids including calendars, scoreboards, matrices
- `vui-collapsible` for expandable sections without imperative magit-section
- `vui-defcontext` for plug-in registries and deep state distribution
- Composable: helper functions return vnodes; no need to be a component
- Developer tools: `vui-inspect`, `vui-report-timing`, `vui-debug-show`

**Weaknesses:**
- External dependency (not built-in, requires Emacs 29.1+)
- Performance ceiling lower than `tabulated-list-mode` for large homogeneous lists
  (reconciler overhead vs direct string rendering)
- Mental model is React-like — Emacs Lisp programmers may not be familiar
- `vui-mode` derives from `special-mode`: works with `q`/`g`, but less discoverable
  than `tabulated-list-mode` for keyboard navigation

**When to prefer:**
- Heterogeneous buffer UIs (mixed sections, tables, interactive elements)
- Views with local state that need reactive updates (counters, filters, tab switching)
- UIs where inline editing matters (buttons that open prompts, fields)
- Sidebar / companion buffer patterns (like vulpea-ui)
- Dashboard views that compose multiple distinct data sections

---

## 4. Decision Matrix

| UI view | Current | Recommendation | Rationale |
|---------|---------|----------------|-----------|
| Transient command menus | transient | Keep transient | Perfect fit, no replacement needed |
| Rig list | tabulated-list | Keep | Homogeneous table; sorting/navigation free |
| Session list | tabulated-list | Keep | Same; `tabulated-list-get-id` is clean |
| Convoy list | tabulated-list | Keep | Same |
| Mail inbox | tabulated-list | Keep | Same |
| Status overview buffer | magit-section | Keep, optional vui future | Current magit-section is correct; vui could improve if we need inline edits or async refresh |
| **Bead detail view (new)** | – | **vui.el** | Mixed: header, fields, notes, deps, actions — composable + stateful |
| **Issue board / kanban (new)** | – | **vui.el** | Multi-column state, drag-to-status, filter controls |
| **Rig detail / dashboard (new)** | – | **vui.el** | Mixed sections, async data, collapsible polecat list |
| **Cost/trail inspector (new)** | – | **vui.el** | Table + filters + collapsible detail = composable |

---

## 5. Design Recommendation: Porcelain Architecture

### 5.1 Guiding principle

**Use native modes for browse/act and vui.el for view/edit/interact.**

- `tabulated-list-mode`: browsing homogeneous lists and dispatching actions
- `magit-section-mode`: read-only structured overviews with collapsible trees
- `transient.el`: command dispatch and argument collection
- `vui.el`: complex views with local state, mixed content, or inline editing

These are not competing alternatives — they are complementary. A polecat's workflow
naturally uses all four: `M-x gastown` opens transient; `g` runs status in
magit-section; `l` opens a tabulated rig list; `RET` on a rig opens a vui detail view.

### 5.2 What beads.el porcelain should look like

**Issue list**: keep `tabulated-list-mode`. Fast, sortable, discoverable.

**Bead detail view** (`bd show <id>` → Emacs buffer): use `vui.el`.

Proposed component tree:
```
brb-bead-detail (root, state: tab, edit-mode, dirty)
├── brb-bead-header (title, status, priority, type badges)
├── brb-bead-tabs (overview / notes / deps / history)
│   ├── overview tab:
│   │   ├── brb-bead-meta-section (assignee, labels, dates as vui-field buttons)
│   │   └── brb-bead-description (markdown preview via vui-text, edit button)
│   ├── deps tab:
│   │   └── brb-bead-deps-table (vui-table with clickable bead links)
│   └── notes tab:
│       └── brb-bead-notes-field (vui-field, submit saves to bd)
└── brb-bead-actions-bar (close, block, assign buttons → transient or minibuffer)
```

Key patterns to use:
- `vui-defcontext` for the bead plist and actions plist (avoid prop-drilling)
- `vui-use-async` to load bead data from `bd show --json`
- `vui-button` cells for editable fields (status, priority, assignee)
- `vui-use-memo` keyed on bead-id for dep graph rendering

### 5.3 What gastown.el porcelain should look like

**Status buffer**: keep `magit-section-mode`. It's correct. Consider migrating to
vui.el only if we need:
- Inline edit of rig/agent properties
- Auto-refresh with per-section async loading (separate polecat states loading
  independently) — this is where vui.el's `vui-use-async` per component shines

**Enhanced status buffer with vui.el** (future):
```
gastown-status-app (root, state: refresh-tick, expanded-rigs)
├── gastown-global-agents (mayor, deacon — vui-hstack of status badges)
└── vui-list of gastown-rig-section (one per rig, keyed by rig name)
    └── gastown-rig-section (state: expanded, state: data)
        ├── vui-use-async for rig data (loads independently per rig)
        ├── vui-collapsible header
        ├── gastown-witness-row
        ├── gastown-refinery-row
        └── vui-list of gastown-polecat-row (keyed by polecat id)
```

Advantage over magit-section: each rig section loads its async data independently,
so a slow rig doesn't block the others. Collapsed rigs don't load at all (defer
via `children-as-lambda` pattern from vulpea-ui).

**Convoy view**: could be reimplemented in vui.el for live progress display
(percentage bar, elapsed time updating via timer effect). Currently tabulated-list;
acceptable to stay there for simple status snapshots.

**Polecat detail view** (new): vui.el. Show polecat state, hook, recent bead
history, tmux session status, mail count. Click polecat name → open tmux window.
Model on vulpea-ui's widget registry: polecat plugins register information panels.

---

## 6. Migration Strategy

### Phase 1: Add vui.el as a dep, build one small view (low risk)

Add vui.el to `guix.scm` + `Eldev` dependencies. Build `gastown-polecat-detail`
as the first vui.el view. This is a new buffer — no existing code at risk.

### Phase 2: Bead detail view in beads.el

`bd show` currently prints JSON or plain text. Add `bd-bead-detail-show-buffer`
using vui.el. Wire it as the `RET` action in the beads tabulated-list view.

### Phase 3: Optional status buffer migration

If the magit-section status buffer becomes a maintenance burden, or if per-rig
async loading becomes desirable, migrate. Not urgent — the current implementation
works well.

### Phase 4: Sidebar for active bead context (aspirational)

A vulpea-ui-style sidebar showing the active bead, its deps, and quick actions,
visible while editing code. Uses the vui widget-registry pattern for extensibility.

---

## 7. Anti-Patterns to Avoid

1. **Don't replace tabulated-list-mode with vui.el for homogeneous lists.**
   tabulated-list is faster, more keyboard-discoverable, and has sorting for free.

2. **Don't use vui.el for command menus.** That's transient's job.

3. **Don't use widget.el directly.** Use vui.el instead — it wraps widget.el with
   everything you'd want.

4. **Don't mix imperative insertion with vui.el.** Either a buffer is a vui buffer
   or it isn't. Don't `insert` text inside a vui component.

5. **Don't skip `vui-batch` for multi-field updates.** Each `vui-set-state` outside
   a batch schedules a separate re-render. For two or more simultaneous state
   changes, always batch.

6. **Don't call `vui-set-state` from async callbacks without `vui-with-async-context`
   or `vui-async-callback`.** The current buffer may have changed; these macros
   capture the right buffer/instance at creation time.

7. **Don't make a component for a helper that has no state.** Helper functions that
   return vnodes from arguments are simpler and sufficient. Components exist for
   local state, lifecycle hooks, and memoized identity — not just code organization.

---

## 8. References

- [vui.el source](https://github.com/d12frosted/vui.el)
- [vulpea-ui](https://github.com/d12frosted/vulpea-ui) — sidebar widget registry pattern
- [vulpea-journal](https://github.com/d12frosted/vulpea-journal) — calendar, effect-based state reset
- [brb](https://github.com/d12frosted/brb) — context-as-state-bus, async with refresh counter, tab routing
- [unicode-inspector.el](https://github.com/zonuexe/unicode-inspector.el) — minimal vui app pattern
- [eijiro-search.el](https://github.com/zonuexe/eijiro-search.el) — use-effect as search trigger, full form primitives
