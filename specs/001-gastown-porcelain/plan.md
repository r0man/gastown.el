# Implementation Plan: Gastown.el - Emacs Porcelain for Gastown

**Branch**: `001-gastown-porcelain` | **Date**: 2026-01-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-gastown-porcelain/spec.md`

## Summary

Develop gastown.el, a Magit-like Emacs porcelain for Gastown (the multi-agent orchestrator for Claude Code). The package will provide a status buffer displaying workspace state (convoys, tasks, agents), transient menus for command discovery, and keybinding-driven interaction following Magit conventions. Distribution via MELPA with transient.el as a dependency.

## Technical Context

**Language/Version**: Emacs Lisp (Elisp) for Emacs 26.1+
**Primary Dependencies**: transient.el (menus), cl-lib (utilities)
**Storage**: N/A (reads from Gastown CLI `gt`, no persistent storage)
**Testing**: ERT (Emacs Lisp Regression Testing) + buttercup for BDD-style tests
**Target Platform**: Emacs 26.1+ on Linux, macOS, Windows
**Project Type**: Single Emacs package (MELPA distribution)
**Performance Goals**: Status buffer display within 2 seconds (SC-001), refresh within 2 seconds (SC-003)
**Constraints**: Must parse Gastown CLI text output (no documented JSON mode); Gastown CLI (`gt`) must be installed
**Scale/Scope**: Single Gastown workspace per Emacs session (initially)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Note**: Project constitution is a template with placeholders. No specific gates defined. Proceeding with standard Emacs package best practices:

- [x] Single package structure (library-first)
- [x] CLI integration via shell commands (text in/out protocol)
- [x] ERT tests for core functionality
- [x] Human-readable output with clear error messages
- [x] Simple structure, YAGNI principles

## Project Structure

### Documentation (this feature)

```text
specs/001-gastown-porcelain/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (CLI interface contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
gastown.el               # Main entry point, autoloads, customization
lisp/
├── gastown-core.el      # Core utilities, CLI execution, process management
├── gastown-status.el    # Status buffer implementation
├── gastown-convoy.el    # Convoy management functions
├── gastown-transient.el # Transient menu definitions
├── gastown-faces.el     # Font-lock faces and highlighting
└── gastown-log.el       # Log buffer viewing

test/
├── gastown-core-test.el
├── gastown-status-test.el
└── gastown-convoy-test.el

Cask                     # Development dependencies
Makefile                 # Build/test automation
README.md                # User documentation
```

**Structure Decision**: Single Emacs package with modular lisp files following Magit's organizational pattern. Each major feature area (status, convoy, transient menus) gets its own file for maintainability.

## Complexity Tracking

No violations requiring justification. Package follows standard Emacs package conventions.
