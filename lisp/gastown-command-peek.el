;;; gastown-command-peek.el --- Peek command for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines the `gastown-command-peek' EIEIO class for the
;; `gt peek' command — view recent output from a polecat or crew session.

;;; Code:

(require 'gastown-command)
(require 'gastown-context)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Peek Command

(gastown-defcommand gastown-command-peek (gastown-command-global-options)
  ((target
    :initarg :target
    :type (or null string)
    :initform nil
    :documentation "Target agent to peek at (rig/polecat format)."
    :positional 1
    :option-type :string
    :key "t"
    :transient-description "Target (required)"
    :class transient-option
    :prompt "Target (rig/polecat): "
    :transient-reader gastown-reader-agent-target
    :transient-group "Required"
    :level 1
    :order 1)
   (lines
    :initarg :lines
    :type (or null integer)
    :initform nil
    :documentation "Number of lines to show"
    :long-option "lines"
    :short-option "n"
    :option-type :integer
    :key "n"
    :transient-description "Number of lines to show"
    :class transient-option
    :argument "--lines="
    :prompt "Lines: "
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt peek command.
View recent output from a polecat or crew session.")


;;; Transient Menu

;;;###autoload (autoload 'gastown-peek "gastown-command-peek" nil t)
(beads-meta-define-transient gastown-command-peek "gastown-peek"
  "View recent output from a polecat or crew session.")

(provide 'gastown-command-peek)
;;; gastown-command-peek.el ends here
