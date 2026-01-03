# Tasks: Gastown.el - Emacs Porcelain for Gastown

**Input**: Design documents from `/specs/001-gastown-porcelain/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Tests are OPTIONAL - not explicitly requested in spec. Included as Phase 8 if desired.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md structure:
- `gastown.el` - Main entry point at repository root
- `lisp/` - Feature modules
- `test/` - Test files
- `Cask`, `Makefile` - Build configuration

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Emacs package structure

- [ ] T001 Create project directory structure per plan.md (lisp/, test/)
- [ ] T002 Create Cask file with dependencies (emacs "26.1", transient "0.4.0", magit-section "3.0.0") in Cask
- [ ] T003 [P] Create Makefile with test and lint targets in Makefile
- [ ] T004 [P] Create .gitignore for Emacs byte-compilation artifacts in .gitignore

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create main entry point with package metadata and autoloads in gastown.el
- [ ] T006 Implement CLI availability check `gastown-available-p` in lisp/gastown-core.el
- [ ] T007 Implement synchronous CLI execution `gastown-call-process` in lisp/gastown-core.el
- [ ] T008 Implement CLI output capture `gastown-call-process-with-output` in lisp/gastown-core.el
- [ ] T009 Implement async CLI execution with sentinels `gastown-run-async` in lisp/gastown-core.el
- [ ] T010 Implement error handling utilities and user messages in lisp/gastown-core.el
- [ ] T011 [P] Define customization group `gastown` and user options in gastown.el
- [ ] T012 [P] Create face definitions for status buffer in lisp/gastown-faces.el

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View Gastown Status (Priority: P1) 🎯 MVP

**Goal**: Display status buffer showing workspace state, convoys, tasks, and agents

**Independent Test**: Run `M-x gastown-status` in a Gastown-managed project and verify buffer displays convoys, tasks, and agent states

### Implementation for User Story 1

- [ ] T013 [US1] Implement `gt status` output parser `gastown-parse-status` in lisp/gastown-core.el
- [ ] T014 [US1] Implement `gt convoy list` output parser `gastown-parse-convoy-list` in lisp/gastown-core.el
- [ ] T015 [US1] Implement `gt agents` output parser `gastown-parse-agents` in lisp/gastown-core.el
- [ ] T016 [US1] Implement task list parser `gastown-parse-task-list` in lisp/gastown-core.el
- [ ] T017 [US1] Define `gastown-status-mode` derived from magit-section-mode in lisp/gastown-status.el
- [ ] T018 [US1] Implement status buffer keymap with `g` refresh, `TAB` toggle, `p`/`n` navigation in lisp/gastown-status.el
- [ ] T019 [US1] Implement `gastown-status-sections-hook` customization in lisp/gastown-status.el
- [ ] T020 [US1] Implement `gastown-insert-workspace-header` section inserter in lisp/gastown-status.el
- [ ] T021 [US1] Implement `gastown-insert-convoys-section` with collapsible convoy items in lisp/gastown-status.el
- [ ] T022 [US1] Implement `gastown-insert-tasks-section` with status indicators in lisp/gastown-status.el
- [ ] T023 [US1] Implement `gastown-insert-agents-section` with running/stopped status in lisp/gastown-status.el
- [ ] T024 [US1] Implement `gastown-status-refresh-buffer` refresh function in lisp/gastown-status.el
- [ ] T025 [US1] Implement main entry point `gastown-status` interactive command in lisp/gastown-status.el
- [ ] T026 [US1] Implement error state handling when not in Gastown workspace in lisp/gastown-status.el
- [ ] T027 [US1] Implement error state handling when CLI not found in lisp/gastown-status.el
- [ ] T028 [US1] Apply syntax highlighting faces to status buffer sections in lisp/gastown-status.el

**Checkpoint**: User Story 1 complete - `M-x gastown-status` displays full workspace status

---

## Phase 4: User Story 2 - Navigate and Interact with Convoys (Priority: P2)

**Goal**: Enable convoy navigation, detail viewing, and creation

**Independent Test**: Navigate to a convoy in status buffer, press RET to view details, press `c c` to create new convoy

### Implementation for User Story 2

- [ ] T029 [US2] Implement `gt convoy status <id>` output parser in lisp/gastown-core.el
- [ ] T030 [US2] Create convoy detail buffer mode `gastown-convoy-mode` in lisp/gastown-convoy.el
- [ ] T031 [US2] Implement `gastown-convoy-show` to display convoy details in lisp/gastown-convoy.el
- [ ] T032 [US2] Implement `gastown-visit-item` for RET on convoy in status buffer in lisp/gastown-status.el
- [ ] T033 [US2] Implement `gastown-convoy-create` with minibuffer prompts in lisp/gastown-convoy.el
- [ ] T034 [US2] Execute `gt convoy create` command from convoy create function in lisp/gastown-convoy.el
- [ ] T035 [US2] Add convoy keybindings `c c` (create) to status mode keymap in lisp/gastown-status.el
- [ ] T036 [US2] Implement convoy detail buffer refresh and navigation in lisp/gastown-convoy.el

**Checkpoint**: User Story 2 complete - convoy viewing and creation works independently

---

## Phase 5: User Story 3 - Execute Gastown Commands (Priority: P2)

**Goal**: Provide transient menus for command discovery and execution

**Independent Test**: Press `?` in status buffer, see transient menu, execute `gt start` via menu

### Implementation for User Story 3

- [ ] T037 [US3] Define main dispatch prefix `gastown-dispatch` in lisp/gastown-transient.el
- [ ] T038 [US3] Define workflow group (prime, start, shutdown) in transient dispatch in lisp/gastown-transient.el
- [ ] T039 [US3] Define convoy group (create, list, view) in transient dispatch in lisp/gastown-transient.el
- [ ] T040 [US3] Define task group (assign/sling, list) in transient dispatch in lisp/gastown-transient.el
- [ ] T041 [US3] Implement `gastown-start` command executing `gt start` async in lisp/gastown-transient.el
- [ ] T042 [US3] Implement `gastown-shutdown` command executing `gt shutdown` async in lisp/gastown-transient.el
- [ ] T043 [US3] Implement `gastown-sling-assign` with prompts for task details in lisp/gastown-transient.el
- [ ] T044 [US3] Define transient infixes for sling options (title, description, priority) in lisp/gastown-transient.el
- [ ] T045 [US3] Add command keybindings `?`/`h` (dispatch), `s s` (start), `s x` (shutdown) in lisp/gastown-status.el
- [ ] T046 [US3] Implement process output display in `*gastown-process*` buffer in lisp/gastown-core.el
- [ ] T047 [US3] Implement status buffer refresh after command completion via sentinel in lisp/gastown-core.el

**Checkpoint**: User Story 3 complete - transient menus work and commands execute

---

## Phase 6: User Story 4 - Enter Mayor Session (Priority: P3)

**Goal**: Launch interactive Mayor session from Emacs

**Independent Test**: Invoke prime command, verify interactive buffer opens for Mayor coordination

### Implementation for User Story 4

- [ ] T048 [US4] Create `gastown-mayor-mode` for interactive session buffer in lisp/gastown-core.el
- [ ] T049 [US4] Implement `gastown-prime` to start `gt prime` process in lisp/gastown-core.el
- [ ] T050 [US4] Attach process to `*gastown-mayor*` buffer with input/output handling in lisp/gastown-core.el
- [ ] T051 [US4] Implement send input function for Mayor session in lisp/gastown-core.el
- [ ] T052 [US4] Implement `C-c C-c` to cleanly exit Mayor session in lisp/gastown-core.el
- [ ] T053 [US4] Add `p` keybinding (prime) to dispatch menu in lisp/gastown-transient.el

**Checkpoint**: User Story 4 complete - Mayor session works interactively

---

## Phase 7: User Story 5 - View Agent and Task Logs (Priority: P3)

**Goal**: Display logs from agents and task execution

**Independent Test**: Select an agent, view its log output in dedicated buffer

### Implementation for User Story 5

- [ ] T054 [US5] Create `gastown-log-mode` for log viewing buffer in lisp/gastown-log.el
- [ ] T055 [US5] Implement `gastown-view-agent-logs` with agent selection in lisp/gastown-log.el
- [ ] T056 [US5] Implement `gastown-view-task-logs` with task selection in lisp/gastown-log.el
- [ ] T057 [US5] Parse log output and apply highlighting in lisp/gastown-log.el
- [ ] T058 [US5] Add log viewing keybindings `l l` (logs) to status mode in lisp/gastown-status.el
- [ ] T059 [US5] Add log viewing group to transient dispatch in lisp/gastown-transient.el

**Checkpoint**: User Story 5 complete - log viewing works independently

---

## Phase 8: Tests (OPTIONAL - if requested)

**Purpose**: ERT tests for core functionality

- [ ] T060 [P] Create test helper with mock CLI utilities in test/test-helper.el
- [ ] T061 [P] Unit tests for status parser functions in test/gastown-core-test.el
- [ ] T062 [P] Unit tests for convoy parser functions in test/gastown-core-test.el
- [ ] T063 [P] Unit tests for agent parser functions in test/gastown-core-test.el
- [ ] T064 [P] Integration tests for status buffer creation in test/gastown-status-test.el
- [ ] T065 [P] Integration tests for convoy operations in test/gastown-convoy-test.el

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, refinement, and MELPA preparation

- [ ] T066 [P] Write README.md with installation and usage instructions in README.md
- [ ] T067 [P] Add MELPA recipe file for package submission
- [ ] T068 Ensure all public functions have docstrings
- [ ] T069 Add Commentary section to gastown.el for package documentation
- [ ] T070 Byte-compile all files and fix any warnings
- [ ] T071 Run quickstart.md validation to verify development workflow

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 (P1) should complete first as MVP
  - US2 (P2) and US3 (P2) can proceed in parallel after US1
  - US4 (P3) and US5 (P3) can proceed in parallel after US2/US3
- **Tests (Phase 8)**: Can start after Foundational, parallel with user stories
- **Polish (Phase 9)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: After Foundational - No dependencies on other stories
- **User Story 2 (P2)**: After Foundational - Uses parsers from US1 but independently testable
- **User Story 3 (P2)**: After Foundational - Uses core infrastructure, independently testable
- **User Story 4 (P3)**: After Foundational - Independent interactive feature
- **User Story 5 (P3)**: After Foundational - Independent log viewing feature

### Within Each User Story

- Parsers before buffer/display code
- Mode definition before section inserters
- Section inserters before main entry point
- Error handling integrated throughout

### Parallel Opportunities

- T003, T004: Setup tasks can run in parallel
- T011, T012: Foundational customization and faces in parallel
- T013-T016: All parsers for US1 can run in parallel
- T029-T036: US2 convoy tasks are sequential within story
- T037-T047: US3 transient tasks are sequential within story
- T060-T065: All test tasks can run in parallel
- T066, T067: Documentation tasks can run in parallel

---

## Parallel Example: User Story 1 Parsers

```bash
# Launch all parser implementations together:
Task: "Implement gt status output parser gastown-parse-status in lisp/gastown-core.el"
Task: "Implement gt convoy list output parser gastown-parse-convoy-list in lisp/gastown-core.el"
Task: "Implement gt agents output parser gastown-parse-agents in lisp/gastown-core.el"
Task: "Implement task list parser gastown-parse-task-list in lisp/gastown-core.el"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (4 tasks)
2. Complete Phase 2: Foundational (8 tasks)
3. Complete Phase 3: User Story 1 (16 tasks)
4. **STOP and VALIDATE**: Test `M-x gastown-status` independently
5. Deploy/demo if ready - users can see workspace status

### Incremental Delivery

1. Setup + Foundational → Foundation ready (12 tasks)
2. Add User Story 1 → Test independently → **MVP! Users can view status** (28 tasks total)
3. Add User Story 2 → Test independently → Users can manage convoys (36 tasks total)
4. Add User Story 3 → Test independently → Users have full command access (47 tasks total)
5. Add User Story 4 → Test independently → Users can use Mayor session (53 tasks total)
6. Add User Story 5 → Test independently → Users can view logs (59 tasks total)
7. Polish → Ready for MELPA submission (71 tasks total)

### Suggested MVP Scope

**User Story 1 (P1)** provides immediate value:
- Users can see workspace status
- Convoys, tasks, and agents visible
- Manual refresh with `g`
- Foundation for all other features

This is a complete, usable feature that delivers the core promise of gastown.el.

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Emacs Lisp uses lexical-binding: t in all files
- Follow Magit patterns for section navigation and keybindings
