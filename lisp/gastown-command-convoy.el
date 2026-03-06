;;; gastown-command-convoy.el --- Convoy commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt convoy' subcommands.
;; Provides convoy listing and status tracking.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Convoy List Command

(eval-and-compile
  (gastown-defcommand gastown-command-convoy-list (gastown-command-global-options)
    ((rig
      :initarg :rig
      :type (or null string)
      :initform nil
      :documentation "Filter by rig name (--rig)."
      :long-option "rig"
      :option-type :string
      :key "r"
      :transient "--rig"
      :class transient-option
      :argument "--rig="
      :prompt "Rig: "
      :transient-group "Filters"
      :level 1
      :order 1)
     (status
      :initarg :status
      :type (or null string)
      :initform nil
      :documentation "Filter by status (--status)."
      :long-option "status"
      :option-type :string
      :key "s"
      :transient "--status"
      :class transient-option
      :argument "--status="
      :prompt "Status: "
      :transient-choices ("active" "completed" "cancelled")
      :transient-group "Filters"
      :level 1
      :order 2))
    :documentation "Represents gt convoy list command.
Lists convoys with progress bars and status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-convoy-list))
  "Return \"convoy list\" as the CLI subcommand name."
  "convoy list")

;;; Convoy Status Command

(eval-and-compile
  (gastown-defcommand gastown-command-convoy-status (gastown-command-global-options)
    ((convoy-id
      :initarg :convoy-id
      :type (or null string)
      :initform nil
      :documentation "Convoy ID to show status for."
      :positional 1
      :option-type :string
      :key "c"
      :transient "Convoy ID"
      :class transient-option
      :prompt "Convoy ID: "
      :transient-group "Required"
      :level 1
      :order 1))
    :documentation "Represents gt convoy status command.
Shows detailed status for a specific convoy."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-convoy-status))
  "Return \"convoy status\" as the CLI subcommand name."
  "convoy status")

;;; Transient Menus

;;;###autoload (autoload 'gastown-convoy-list "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-list "gastown-convoy-list"
  "List convoys.")

;;;###autoload (autoload 'gastown-convoy-status "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-status "gastown-convoy-status"
  "Show convoy status.")

;;; Convoy Dispatch Transient

;;;###autoload (autoload 'gastown-convoy "gastown-command-convoy" nil t)
(transient-define-prefix gastown-convoy ()
  "Track batches of work across rigs."
  ["Convoy Commands"
   ("l" "List convoys" gastown-convoy-list)
   ("s" "Convoy status" gastown-convoy-status)])

(provide 'gastown-command-convoy)
;;; gastown-command-convoy.el ends here
