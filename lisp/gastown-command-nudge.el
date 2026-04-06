;;; gastown-command-nudge.el --- Nudge command for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines the `gastown-command-nudge' EIEIO class for the
;; `gt nudge' command — send a synchronous message to any Gas Town worker.

;;; Code:

(require 'gastown-command)
(require 'gastown-context)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Nudge Command

(gastown-defcommand gastown-command-nudge (gastown-command-global-options)
  ((target
    :initarg :target
    :type (or null string)
    :initform nil
    :documentation "Target agent to nudge."
    :positional 1
    :option-type :string
    :transient-key "t"
    :transient transient-option
    :prompt "Target (rig/agent): "
    :transient-reader gastown-reader-agent-target
    :transient-group "Required"
    :level 1
    :order 1)
   (message-text
    :initarg :message-text
    :type (or null string)
    :initform nil
    :documentation "Nudge message text."
    :positional 2
    :option-type :string
    :transient-key "m"
    :transient transient-option
    :prompt "Message: "
    :transient-group "Required"
    :level 1
    :order 2))
  :documentation "Represents gt nudge command.
Send a synchronous message to any Gas Town worker.")


;;; Transient Menu

;;;###autoload (autoload 'gastown-nudge "gastown-command-nudge" nil t)
(beads-meta-define-transient gastown-command-nudge "gastown-nudge"
  "Nudge a Gas Town worker.")

(provide 'gastown-command-nudge)
;;; gastown-command-nudge.el ends here
