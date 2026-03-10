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
    :order 2)
   (order
    :initarg :order
    :type (or null string)
    :initform nil
    :documentation "Sort order (--order)."
    :long-option "order"
    :option-type :string
    :key "o"
    :transient "--order"
    :class transient-option
    :argument "--order="
    :prompt "Order: "
    :transient-choices ("newest" "oldest")
    :transient-group "Options"
    :level 1
    :order 3)
   (limit
    :initarg :limit
    :type (or null integer)
    :initform nil
    :documentation "Maximum number of convoys to show (--limit)."
    :long-option "limit"
    :option-type :string
    :key "l"
    :transient "--limit"
    :class transient-option
    :argument "--limit="
    :prompt "Limit: "
    :transient-group "Options"
    :level 1
    :order 4))
  :documentation "Represents gt convoy list command.
Lists convoys with progress bars and status.")


;;; Convoy Status Command

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
Shows detailed status for a specific convoy.")


;;; Convoy Create Command

(gastown-defcommand gastown-command-convoy-create (gastown-command-global-options)
  ((title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Convoy title (--title)."
    :long-option "title"
    :option-type :string
    :key "t"
    :transient "--title"
    :class transient-option
    :argument "--title="
    :prompt "Title: "
    :transient-group "Options"
    :level 1
    :order 1)
   (issues
    :initarg :issues
    :type (or null string)
    :initform nil
    :documentation "Comma-separated issue IDs to track."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Issues"
    :class transient-option
    :prompt "Issue IDs (comma-separated): "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt convoy create command.
Create a new convoy tracking specified issues."
  :cli-command "convoy create")


;;; Transient Menus

;;;###autoload (autoload 'gastown-convoy-list "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-list "gastown-convoy-list"
  "List convoys.")

;;;###autoload (autoload 'gastown-convoy-status "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-status "gastown-convoy-status"
  "Show convoy status.")

;;;###autoload (autoload 'gastown-convoy-create "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-create "gastown-convoy-create"
  "Create a new convoy.")

;;; Convoy Dispatch Transient

;;;###autoload (autoload 'gastown-convoy "gastown-command-convoy" nil t)
(transient-define-prefix gastown-convoy ()
  "Track batches of work across rigs."
  ["Convoy Commands"
   ("l" "List convoys" gastown-convoy-list)
   ("s" "Convoy status" gastown-convoy-status)
   ("c" "Create convoy" gastown-convoy-create)])

(provide 'gastown-command-convoy)
;;; gastown-command-convoy.el ends here
