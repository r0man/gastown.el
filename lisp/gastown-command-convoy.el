;;; gastown-command-convoy.el --- Convoy commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt convoy' subcommands.
;; Provides convoy listing and status tracking.

;;; Code:

(require 'gastown-command)
(require 'gastown-reader)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Convoy List Command

(gastown-defcommand gastown-command-convoy-list (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Filter by rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Filters"
    :level 1
    :order 1)
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Filter by status"
    :long-option "status"
    :option-type :string
    :key "s"
    :transient "Filter by status"
    :class transient-option
    :argument "--status="
    :prompt "Status: "
    :transient-choices ("open" "closed")
    :transient-group "Filters"
    :level 1
    :order 2))
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
    :transient-reader gastown-reader-convoy-id
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
    :documentation "Convoy title"
    :long-option "title"
    :option-type :string
    :key "t"
    :transient "Convoy title"
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


;;; Convoy Add Command

(gastown-defcommand gastown-command-convoy-add (gastown-command-global-options)
  ((convoy-id
    :initarg :convoy-id
    :type (or null string)
    :initform nil
    :documentation "Convoy ID to add issues to."
    :positional 1
    :option-type :string
    :key "c"
    :transient "Convoy ID (required)"
    :class transient-option
    :prompt "Convoy ID: "
    :transient-reader gastown-reader-convoy-id
    :transient-group "Required"
    :level 1
    :order 1)
   (issue-ids
    :initarg :issue-ids
    :type (or null string)
    :initform nil
    :documentation "Issue IDs to add."
    :positional 2
    :option-type :string
    :key "i"
    :transient "Issue IDs (required)"
    :class transient-option
    :prompt "Issue IDs: "
    :transient-group "Required"
    :level 1
    :order 2))
  :documentation "Represents gt convoy add command.
Add issues to an existing convoy."
  :cli-command "convoy add")


;;; Convoy Check Command

(gastown-defcommand gastown-command-convoy-check (gastown-command-global-options)
  ((convoy-id
    :initarg :convoy-id
    :type (or null string)
    :initform nil
    :documentation "Convoy ID to check (optional — checks all if omitted)."
    :positional 1
    :option-type :string
    :key "c"
    :transient "Convoy ID"
    :class transient-option
    :prompt "Convoy ID: "
    :transient-reader gastown-reader-convoy-id
    :transient-group "Options"
    :level 1
    :order 1)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Preview what would close without acting."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt convoy check command.
Check and auto-close completed convoys."
  :cli-command "convoy check")


;;; Convoy Close Command

(gastown-defcommand gastown-command-convoy-close (gastown-command-global-options)
  ((convoy-id
    :initarg :convoy-id
    :type (or null string)
    :initform nil
    :documentation "Convoy ID to close."
    :positional 1
    :option-type :string
    :key "c"
    :transient "Convoy ID (required)"
    :class transient-option
    :prompt "Convoy ID: "
    :transient-reader gastown-reader-convoy-id
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Close even if tracked issues are still open."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2)
   (reason
    :initarg :reason
    :type (or null string)
    :initform nil
    :documentation "Reason for closing the convoy."
    :long-option "reason"
    :option-type :string
    :key "r"
    :transient "Reason"
    :class transient-option
    :argument "--reason="
    :prompt "Reason: "
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt convoy close command.
Close a convoy."
  :cli-command "convoy close")


;;; Convoy Land Command

(gastown-defcommand gastown-command-convoy-land (gastown-command-global-options)
  ((convoy-id
    :initarg :convoy-id
    :type (or null string)
    :initform nil
    :documentation "Convoy ID to land."
    :positional 1
    :option-type :string
    :key "c"
    :transient "Convoy ID (required)"
    :class transient-option
    :prompt "Convoy ID: "
    :transient-reader gastown-reader-convoy-id
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Land even if tracked issues are not all closed."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would happen without acting."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 3))
  :documentation "Represents gt convoy land command.
Land an owned convoy (cleanup worktrees, close convoy)."
  :cli-command "convoy land")


;;; Convoy Launch Command

(gastown-defcommand gastown-command-convoy-launch (gastown-command-global-options)
  ((convoy-id
    :initarg :convoy-id
    :type (or null string)
    :initform nil
    :documentation "Convoy ID (or epic/task ID) to launch."
    :positional 1
    :option-type :string
    :key "c"
    :transient "Convoy/epic/task ID (required)"
    :class transient-option
    :prompt "ID: "
    :transient-reader gastown-reader-convoy-id
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Launch even with warnings."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt convoy launch command.
Launch a staged convoy: transition to open and dispatch Wave 1."
  :cli-command "convoy launch")


;;; Convoy Stage Command

(gastown-defcommand gastown-command-convoy-stage (gastown-command-global-options)
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Epic ID, task IDs, or convoy ID to stage."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Epic/task/convoy ID (required)"
    :class transient-option
    :prompt "ID: "
    :transient-group "Required"
    :level 1
    :order 1)
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Human-readable title for the convoy."
    :long-option "title"
    :option-type :string
    :key "t"
    :transient "Title"
    :class transient-option
    :argument "--title="
    :prompt "Title: "
    :transient-group "Options"
    :level 2
    :order 2)
   (launch
    :initarg :launch
    :type boolean
    :initform nil
    :documentation "Launch the convoy immediately after staging."
    :long-option "launch"
    :option-type :boolean
    :key "l"
    :transient "--launch"
    :class transient-switch
    :argument "--launch"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt convoy stage command.
Analyze dependencies, compute waves, and create a staged convoy."
  :cli-command "convoy stage")


;;; Convoy Stranded Command

(gastown-defcommand gastown-command-convoy-stranded (gastown-command-global-options)
  ()
  :documentation "Represents gt convoy stranded command.
Find stranded convoys (ready work, stuck, or empty) needing attention."
  :cli-command "convoy stranded")


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

;;;###autoload (autoload 'gastown-convoy-add "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-add "gastown-convoy-add"
  "Add issues to a convoy.")

;;;###autoload (autoload 'gastown-convoy-check "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-check "gastown-convoy-check"
  "Check and auto-close completed convoys.")

;;;###autoload (autoload 'gastown-convoy-close "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-close "gastown-convoy-close"
  "Close a convoy.")

;;;###autoload (autoload 'gastown-convoy-land "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-land "gastown-convoy-land"
  "Land an owned convoy.")

;;;###autoload (autoload 'gastown-convoy-launch "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-launch "gastown-convoy-launch"
  "Launch a staged convoy.")

;;;###autoload (autoload 'gastown-convoy-stage "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-stage "gastown-convoy-stage"
  "Stage a convoy (analyze dependencies and compute waves).")

;;;###autoload (autoload 'gastown-convoy-stranded "gastown-command-convoy" nil t)
(beads-meta-define-transient gastown-command-convoy-stranded "gastown-convoy-stranded"
  "Find stranded convoys needing attention.")

;;; Convoy Dispatch Transient

;;;###autoload (autoload 'gastown-convoy "gastown-command-convoy" nil t)
(transient-define-prefix gastown-convoy ()
  "Track batches of work across rigs."
  ["Convoy Info"
   ("l" "List convoys" gastown-convoy-list)
   ("s" "Convoy status" gastown-convoy-status)
   ("S" "Stranded convoys" gastown-convoy-stranded)]
  ["Convoy Lifecycle"
   ("c" "Create convoy" gastown-convoy-create)
   ("a" "Add issues" gastown-convoy-add)
   ("t" "Stage convoy" gastown-convoy-stage)
   ("L" "Launch convoy" gastown-convoy-launch)
   ("n" "Land convoy" gastown-convoy-land)
   ("x" "Close convoy" gastown-convoy-close)]
  ["Maintenance"
   ("k" "Check/auto-close" gastown-convoy-check)])

(provide 'gastown-command-convoy)
;;; gastown-command-convoy.el ends here
