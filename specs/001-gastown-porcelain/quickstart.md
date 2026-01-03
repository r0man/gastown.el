# Quickstart: gastown.el Development

**Feature**: 001-gastown-porcelain
**Date**: 2026-01-03

## Prerequisites

### Required
- Emacs 26.1 or later
- Gastown CLI (`gt`) installed and in PATH
- Go 1.23+ (for Gastown)

### Development Tools
- Cask (for dependency management)
- Make (for build automation)

## Installation (Development)

```bash
# Clone the repository
git clone https://github.com/yourusername/gastown.el.git
cd gastown.el

# Install dependencies via Cask
cask install

# Run tests
make test
```

## Project Structure

```
gastown.el/
├── gastown.el               # Main entry point, autoloads
├── lisp/
│   ├── gastown-core.el      # CLI execution, parsing
│   ├── gastown-status.el    # Status buffer
│   ├── gastown-convoy.el    # Convoy management
│   ├── gastown-transient.el # Menu definitions
│   ├── gastown-faces.el     # Highlighting
│   └── gastown-log.el       # Log viewing
├── test/
│   ├── gastown-core-test.el
│   ├── gastown-status-test.el
│   └── test-helper.el
├── Cask                     # Dependencies
├── Makefile                 # Build automation
└── README.md
```

## Key Files to Implement

### 1. gastown.el (Entry Point)

```elisp
;;; gastown.el --- Emacs porcelain for Gastown -*- lexical-binding: t -*-

;; Author: Your Name
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (transient "0.4.0") (magit-section "3.0.0"))
;; Keywords: tools, processes
;; URL: https://github.com/yourusername/gastown.el

;;; Commentary:
;; A Magit-like interface for the Gastown multi-agent orchestrator.

;;; Code:

(require 'gastown-core)
(require 'gastown-status)
(require 'gastown-transient)

;;;###autoload
(defun gastown-status ()
  "Show Gastown workspace status."
  (interactive)
  (gastown-status--show default-directory))

(provide 'gastown)
;;; gastown.el ends here
```

### 2. gastown-core.el (CLI Layer)

Key functions to implement:
- `gastown-call-process` - Synchronous CLI execution
- `gastown-run-async` - Async execution with sentinels
- `gastown-parse-*` - Output parsing functions
- `gastown-available-p` - Check CLI availability

### 3. gastown-status.el (Status Buffer)

Key functions to implement:
- `gastown-status-mode` - Major mode definition
- `gastown-status-refresh-buffer` - Buffer refresh
- `gastown-insert-*-section` - Section insertion hooks

### 4. gastown-transient.el (Menus)

Key definitions:
- `gastown-dispatch` - Main menu
- `gastown-convoy-menu` - Convoy operations
- `gastown-process-menu` - Agent control

## Development Workflow

### 1. Start with Core Layer
```elisp
;; Test CLI execution
(gastown-call-process '("status"))
(gastown-available-p)
```

### 2. Build Status Buffer
```elisp
;; Test section insertion
M-x gastown-status
```

### 3. Add Transient Menus
```elisp
;; Test menu display
M-x gastown-dispatch
```

### 4. Run Tests
```bash
make test
# or
cask exec ert-runner
```

## Testing Without Gastown

For development without a running Gastown instance, create mock responses:

```elisp
;; In test/test-helper.el
(defun gastown-test--mock-status ()
  "Return mock status output."
  "Workspace: /tmp/test
Status: active
Daemon: running")

(defun gastown-test--with-mock-cli (mock-fn body)
  "Execute BODY with CLI calls mocked by MOCK-FN."
  (cl-letf (((symbol-function 'gastown-call-process-with-output) mock-fn))
    (funcall body)))
```

## Keybindings Reference

| Key | Command | Description |
|-----|---------|-------------|
| `g` | `gastown-refresh` | Refresh buffer |
| `?` | `gastown-dispatch` | Show main menu |
| `RET` | `gastown-visit-item` | Visit at point |
| `TAB` | `magit-section-toggle` | Toggle section |
| `c c` | `gastown-convoy-create` | Create convoy |
| `s s` | `gastown-start` | Start agents |
| `s x` | `gastown-shutdown` | Shutdown agents |

## Resources

- [Magit Manual](https://magit.vc/manual/magit/)
- [Magit-Section Manual](https://magit.vc/manual/magit-section/)
- [Transient Manual](https://magit.vc/manual/transient/)
- [Gastown Repository](https://github.com/steveyegge/gastown)
