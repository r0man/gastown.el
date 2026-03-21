;;; gastown-custom.el --- Customization variables for gastown -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This file contains all user-customizable variables for gastown.el.
;; Users can configure these via M-x customize-group RET gastown RET
;; or by setting them in their Emacs configuration.

;;; Code:

;;; Customization Group

(defgroup gastown nil
  "Magit-like interface for Gas Town workspace manager."
  :group 'tools
  :prefix "gastown-")

;;; Executable

(defcustom gastown-executable "gt"
  "Path to the gt executable.
This can be either a simple command name (e.g., \"gt\") if it's
in your PATH, or a full path to the executable."
  :type 'string
  :group 'gastown)

;;; Debug Settings

(defcustom gastown-enable-debug nil
  "Enable debug logging to *gastown-debug* buffer.
When enabled, all gt commands and their output will be logged
for troubleshooting purposes."
  :type 'boolean
  :group 'gastown)

(defcustom gastown-debug-level 'info
  "Debug logging level.
- `error': Only log errors
- `info': Log commands and important events (default)
- `verbose': Log everything including command output"
  :type '(choice (const :tag "Error only" error)
                 (const :tag "Info (commands and events)" info)
                 (const :tag "Verbose (all output)" verbose))
  :group 'gastown)

(provide 'gastown-custom)
;;; gastown-custom.el ends here
