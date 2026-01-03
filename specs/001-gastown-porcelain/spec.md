# Feature Specification: Gastown.el - Emacs Porcelain for Gastown

**Feature Branch**: `001-gastown-porcelain`
**Created**: 2026-01-03
**Status**: Draft
**Input**: User description: "Develop gastown.el, a Magit like Emacs porcelain for Gastown https://github.com/steveyegge/gastown"

## Clarifications

### Session 2026-01-03

- Q: What triggers the status buffer refresh? → A: Manual refresh only (user presses `g` like Magit)
- Q: How should gastown.el be distributed? → A: MELPA (standard Emacs package repository)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Gastown Status (Priority: P1)

As an Emacs user working on a Gastown-managed project, I want to see a status buffer displaying the current state of my workspace including active convoys, assigned tasks (sling), and agent status, so that I can understand my multi-agent workflow at a glance.

**Why this priority**: This is the foundational feature - like Magit's status buffer, it provides the central hub for all Gastown operations and is essential for any useful interaction with the system.

**Independent Test**: Can be fully tested by running `M-x gastown-status` in a Gastown-managed project directory and verifying the buffer displays current convoys, tasks, and agent states. Delivers immediate value by providing visibility into the multi-agent system.

**Acceptance Scenarios**:

1. **Given** I am in a Gastown-managed project, **When** I invoke `gastown-status`, **Then** I see a buffer displaying active convoys with their descriptions
2. **Given** the status buffer is open, **When** I have tasks assigned via sling, **Then** I see my assigned tasks listed with their status (pending/in-progress/complete)
3. **Given** agents are running in the workspace, **When** I view the status buffer, **Then** I see the agent states (Mayor, Polecats, Witness, etc.)
4. **Given** I am not in a Gastown-managed project, **When** I invoke `gastown-status`, **Then** I see an appropriate message indicating Gastown is not initialized

---

### User Story 2 - Navigate and Interact with Convoys (Priority: P2)

As an Emacs user, I want to navigate between convoys in the status buffer and perform actions like creating, viewing details, and managing convoy lifecycle, so that I can organize my work without leaving Emacs.

**Why this priority**: Convoys are the primary work organization unit in Gastown. After seeing status, users need to manage their work groupings effectively.

**Independent Test**: Can be tested by navigating to a convoy in the status buffer, pressing enter to view details, and using keybindings to create new convoys. Delivers value by enabling convoy management entirely within Emacs.

**Acceptance Scenarios**:

1. **Given** the status buffer shows convoys, **When** I press RET on a convoy, **Then** I see a detailed view of that convoy including its tasks and assigned agents
2. **Given** I am in the status buffer, **When** I press a key to create a convoy (e.g., `c c`), **Then** I am prompted for convoy details and a new convoy is created
3. **Given** I am viewing a convoy, **When** I press a key to list tasks, **Then** I see all tasks (molecules) associated with that convoy

---

### User Story 3 - Execute Gastown Commands (Priority: P2)

As an Emacs user, I want to execute common Gastown CLI commands through Emacs keybindings and transient menus (similar to Magit's approach), so that I can manage agents and workflows efficiently.

**Why this priority**: Direct command execution is essential for productive use. Users should not need to switch to a terminal for common operations.

**Independent Test**: Can be tested by pressing the transient menu key (e.g., `?`) and selecting commands like `gt start`, `gt shutdown`, or `gt sling`. Delivers value by providing keyboard-driven Gastown control.

**Acceptance Scenarios**:

1. **Given** I am in the gastown-status buffer, **When** I press `?` or `h`, **Then** I see a transient menu showing available commands organized by category
2. **Given** I want to start agents, **When** I select the start command from the menu, **Then** `gt start` is executed and output is displayed
3. **Given** I want to assign a task, **When** I invoke the sling command, **Then** I am prompted for task details and the task is assigned

---

### User Story 4 - Enter Mayor Session (Priority: P3)

As an Emacs user, I want to enter an interactive Mayor session from within Emacs, so that I can coordinate complex multi-agent work using natural language without leaving my editor.

**Why this priority**: The Mayor session (`gt prime`) is the recommended workflow for complex coordination. While important, basic status and command execution provide immediate value first.

**Independent Test**: Can be tested by invoking the prime command and verifying an interactive session opens where the user can describe work and see coordination happen. Delivers value by enabling the full Gastown workflow from Emacs.

**Acceptance Scenarios**:

1. **Given** I am in a Gastown project, **When** I invoke the prime command, **Then** an interactive buffer/session opens for Mayor coordination
2. **Given** I am in a Mayor session, **When** I type a work description and submit, **Then** the Mayor processes the request and agents are coordinated
3. **Given** I am in a Mayor session, **When** I want to exit, **Then** I can cleanly close the session and return to normal editing

---

### User Story 5 - View Agent and Task Logs (Priority: P3)

As an Emacs user, I want to view logs from agents and task execution, so that I can debug issues and monitor progress without switching to terminal.

**Why this priority**: Debugging and monitoring are important for understanding system behavior but are secondary to core operations.

**Independent Test**: Can be tested by selecting an agent or task and viewing its log output in a dedicated buffer. Delivers value by providing observability within Emacs.

**Acceptance Scenarios**:

1. **Given** agents are running, **When** I select an agent and request logs, **Then** I see the agent's log output in a buffer
2. **Given** a task has completed, **When** I view task details, **Then** I can see the execution log and outcome

---

### Edge Cases

- What happens when the Gastown CLI (`gt`) is not installed or not in PATH?
- How does the system handle when the Gastown daemon (Deacon) is not running?
- What happens when network connectivity is lost during a Mayor session?
- How does the buffer handle very long convoy lists or task lists (pagination/scrolling)?
- What happens when a user tries to execute a command while another is in progress?
- How does the system handle Gastown configuration errors or invalid workspace state?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a `gastown-status` command that displays a buffer showing current workspace state
- **FR-002**: System MUST display active convoys with their names, descriptions, and status in the status buffer
- **FR-003**: System MUST display assigned tasks (sling) with their status (pending, in-progress, completed)
- **FR-004**: System MUST display agent status (Mayor, Polecats, Witness, Refinery, Deacon) when running
- **FR-005**: System MUST provide keyboard navigation within the status buffer (move between sections, items)
- **FR-006**: System MUST provide a transient menu system (similar to Magit) for discovering and executing commands
- **FR-007**: System MUST allow creating new convoys with user-provided descriptions
- **FR-008**: System MUST allow viewing detailed information about a selected convoy
- **FR-009**: System MUST execute Gastown CLI commands (`gt start`, `gt shutdown`, `gt convoy create`, `gt sling`, etc.) from within Emacs
- **FR-010**: System MUST display command output in appropriate buffers
- **FR-011**: System MUST provide access to an interactive Mayor session (`gt prime`)
- **FR-012**: System MUST provide manual refresh via `g` keybinding (no auto-refresh)
- **FR-013**: System MUST detect when not in a Gastown-managed project and display appropriate messaging
- **FR-014**: System MUST provide keybindings following Emacs conventions (similar to Magit patterns)
- **FR-015**: System MUST provide syntax highlighting and visual formatting for the status buffer
- **FR-016**: System MUST allow viewing logs for agents and tasks
- **FR-017**: System MUST gracefully handle missing Gastown CLI with clear error messages

### Key Entities

- **Status Buffer**: The central view displaying workspace state, modeled after Magit's status buffer
- **Convoy**: A grouped set of related tasks in Gastown; displayed as expandable sections
- **Task (Molecule)**: Individual work items assigned to agents; shown with status indicators
- **Agent**: AI workers (Mayor, Polecats, Witness, Refinery, Deacon) shown with running/stopped status
- **Transient Menu**: Popup menu system for command discovery and execution (using transient.el)
- **Log Buffer**: Buffer displaying agent or task execution logs

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view complete Gastown workspace status within 2 seconds of invoking the command
- **SC-002**: Users can execute any common Gastown operation (start, stop, convoy create, sling) in 3 keystrokes or fewer from the status buffer
- **SC-003**: The status buffer refreshes completely within 2 seconds when user presses `g`
- **SC-004**: Users report they can accomplish 80% of daily Gastown tasks without leaving Emacs
- **SC-005**: New users can discover available commands through the transient menu system without consulting documentation
- **SC-006**: Error states (missing CLI, daemon not running, invalid workspace) are clearly communicated with actionable messages
- **SC-007**: The interface follows Magit conventions closely enough that Magit users feel immediately familiar with navigation and keybindings

## Assumptions

- Users have Gastown CLI (`gt`) installed and available in their PATH
- Users are familiar with basic Emacs usage and Magit-style interfaces
- The target Emacs version supports transient.el (Emacs 26+, or transient installed as a dependency)
- Gastown provides sufficient CLI output for parsing workspace state (or has a machine-readable output mode)
- Users operate in a single Gastown workspace per Emacs session initially (multi-workspace support can be added later)
- Package will be distributed via MELPA with transient.el as a declared dependency

## Out of Scope

- Direct integration with Claude Code or AI agents beyond what Gastown CLI exposes
- Creating a full IDE experience (code editing, debugging, etc. remain in standard Emacs)
- Mobile or non-Emacs interfaces
- Modifying Gastown's core functionality or CLI
