;;; gastown-command-agents.el --- Agent management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for agent management commands:
;; gt agents, gt witness, gt refinery, gt mayor, gt session, etc.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)
(require 'gastown-reader)

(require 'transient)

(defvar gastown-executable)

;;; Agents List Command

(gastown-defcommand gastown-command-agents (gastown-command-global-options)
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
    :order 1))
  :documentation "Represents gt agents command.
Lists all Gas Town agent sessions.")


;;; Witness Status Command

(gastown-defcommand gastown-command-witness-status (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig to check witness status for"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig to check witness status for"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt witness status command.
Shows witness health and monitoring status.")


;;; Refinery Status Command

(gastown-defcommand gastown-command-refinery-status (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig to check refinery status for"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig to check refinery status for"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery status command.
Shows merge queue processor status.")


;;; Session List Command

(gastown-defcommand gastown-command-session-list (gastown-command-global-options)
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
   (role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Filter by role"
    :long-option "role"
    :option-type :string
    :key "R"
    :transient "Filter by role"
    :class transient-option
    :argument "--role="
    :prompt "Role: "
    :transient-choices ("polecat" "witness" "refinery" "crew")
    :transient-group "Filters"
    :level 1
    :order 2)
   (running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Show only running sessions"
    :long-option "running"
    :option-type :boolean
    :key "u"
    :transient "Show only running sessions"
    :class transient-switch
    :argument "--running"
    :transient-group "Filters"
    :level 1
    :order 3)
   (order
    :initarg :order
    :type (or null string)
    :initform nil
    :documentation "Sort order"
    :long-option "order"
    :option-type :string
    :key "o"
    :transient "Sort order"
    :class transient-option
    :argument "--order="
    :prompt "Order: "
    :transient-choices ("name" "rig" "status")
    :transient-group "Options"
    :level 1
    :order 4))
  :documentation "Represents gt session list command.
Lists polecat sessions.")


;;; Witness Subcommands

(gastown-defcommand gastown-command-witness-attach (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt witness attach command.
Attach to witness tmux session for a rig."
  :cli-command "witness attach")


(gastown-defcommand gastown-command-witness-start (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (required)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent alias to run the witness with."
    :long-option "agent"
    :option-type :string
    :key "a"
    :transient "Agent alias"
    :class transient-option
    :argument "--agent="
    :prompt "Agent: "
    :transient-group "Options"
    :level 2
    :order 2)
   (foreground
    :initarg :foreground
    :type boolean
    :initform nil
    :documentation "Run in foreground."
    :long-option "foreground"
    :option-type :boolean
    :key "f"
    :transient "--foreground"
    :class transient-switch
    :argument "--foreground"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt witness start command.
Start the witness for a rig."
  :cli-command "witness start")


(gastown-defcommand gastown-command-witness-stop (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (required)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt witness stop command.
Stop a running witness."
  :cli-command "witness stop")


(gastown-defcommand gastown-command-witness-restart (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (required)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent alias to run the witness with."
    :long-option "agent"
    :option-type :string
    :key "a"
    :transient "Agent alias"
    :class transient-option
    :argument "--agent="
    :prompt "Agent: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt witness restart command.
Restart the witness for a rig."
  :cli-command "witness restart")


;;; Refinery Subcommands

(gastown-defcommand gastown-command-refinery-attach (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery attach command.
Attach to a running refinery's Claude session."
  :cli-command "refinery attach")


(gastown-defcommand gastown-command-refinery-start (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1)
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent alias to run the refinery with."
    :long-option "agent"
    :option-type :string
    :key "a"
    :transient "Agent alias"
    :class transient-option
    :argument "--agent="
    :prompt "Agent: "
    :transient-group "Options"
    :level 2
    :order 2)
   (foreground
    :initarg :foreground
    :type boolean
    :initform nil
    :documentation "Run in foreground."
    :long-option "foreground"
    :option-type :boolean
    :key "f"
    :transient "--foreground"
    :class transient-switch
    :argument "--foreground"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt refinery start command.
Start the refinery for a rig."
  :cli-command "refinery start")


(gastown-defcommand gastown-command-refinery-stop (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery stop command.
Stop a running refinery."
  :cli-command "refinery stop")


(gastown-defcommand gastown-command-refinery-restart (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1)
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent alias to run the refinery with."
    :long-option "agent"
    :option-type :string
    :key "a"
    :transient "Agent alias"
    :class transient-option
    :argument "--agent="
    :prompt "Agent: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt refinery restart command.
Restart the refinery for a rig."
  :cli-command "refinery restart")


(gastown-defcommand gastown-command-refinery-blocked (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery blocked command.
List MRs blocked by open tasks."
  :cli-command "refinery blocked")


(gastown-defcommand gastown-command-refinery-claim (gastown-command-global-options)
  ((mr-id
    :initarg :mr-id
    :type (or null string)
    :initform nil
    :documentation "Merge request ID to claim."
    :positional 1
    :option-type :string
    :key "m"
    :transient "MR ID (required)"
    :class transient-option
    :prompt "MR ID: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt refinery claim command.
Claim a merge request for processing."
  :cli-command "refinery claim")


(gastown-defcommand gastown-command-refinery-queue (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery queue command.
Show the merge queue for a rig."
  :cli-command "refinery queue")


(gastown-defcommand gastown-command-refinery-ready (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1)
   (all
    :initarg :all
    :type boolean
    :initform nil
    :documentation "Show all open MRs (claimed, blocked, etc.)."
    :long-option "all"
    :option-type :boolean
    :key "a"
    :transient "--all"
    :class transient-switch
    :argument "--all"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt refinery ready command.
List merge requests ready for processing."
  :cli-command "refinery ready")


(gastown-defcommand gastown-command-refinery-release (gastown-command-global-options)
  ((mr-id
    :initarg :mr-id
    :type (or null string)
    :initform nil
    :documentation "Merge request ID to release."
    :positional 1
    :option-type :string
    :key "m"
    :transient "MR ID (required)"
    :class transient-option
    :prompt "MR ID: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt refinery release command.
Release a claimed MR back to the queue."
  :cli-command "refinery release")


(gastown-defcommand gastown-command-refinery-unclaimed (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, inferred from cwd)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt refinery unclaimed command.
List unclaimed MRs available for claiming."
  :cli-command "refinery unclaimed")


;;; Session Subcommands

(gastown-defcommand gastown-command-session-at (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt session at command.
Attach to a running polecat session."
  :cli-command "session at")


(gastown-defcommand gastown-command-session-capture (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (lines
    :initarg :lines
    :type (or null integer)
    :initform nil
    :documentation "Number of lines to capture."
    :long-option "lines"
    :option-type :string
    :key "n"
    :transient "Lines to capture"
    :class transient-option
    :argument "--lines="
    :prompt "Lines: "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt session capture command.
Capture recent output from a polecat session."
  :cli-command "session capture")


(gastown-defcommand gastown-command-session-check (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt session check command.
Check if polecat tmux sessions are alive and healthy."
  :cli-command "session check")


(gastown-defcommand gastown-command-session-inject (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (message
    :initarg :message
    :type (or null string)
    :initform nil
    :documentation "Message to inject."
    :long-option "message"
    :option-type :string
    :key "m"
    :transient "Message"
    :class transient-option
    :argument "--message="
    :prompt "Message: "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt session inject command.
Send a message to a polecat session (prefer gt nudge)."
  :cli-command "session inject")


(gastown-defcommand gastown-command-session-restart (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force immediate shutdown."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt session restart command.
Restart a polecat session (stop + start)."
  :cli-command "session restart")


(gastown-defcommand gastown-command-session-start (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (issue
    :initarg :issue
    :type (or null string)
    :initform nil
    :documentation "Issue ID to work on."
    :long-option "issue"
    :option-type :string
    :key "i"
    :transient "Issue ID"
    :class transient-option
    :argument "--issue="
    :prompt "Issue ID: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt session start command.
Start a new tmux session for a polecat."
  :cli-command "session start")


(gastown-defcommand gastown-command-session-status (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt session status command.
Show detailed status for a polecat session."
  :cli-command "session status")


(gastown-defcommand gastown-command-session-stop (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force immediate shutdown."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt session stop command.
Stop a running polecat session."
  :cli-command "session stop")


;;; Transient Menus

;;;###autoload (autoload 'gastown-agents "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-agents "gastown-agents"
  "List all Gas Town agent sessions.")

;;;###autoload (autoload 'gastown-witness-status "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-witness-status "gastown-witness-status"
  "Show witness status.")

;;;###autoload (autoload 'gastown-refinery-status "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-status "gastown-refinery-status"
  "Show refinery status.")

;;;###autoload (autoload 'gastown-session-list "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-list "gastown-session-list"
  "List polecat sessions.")

;;; Transient Menus for Witness

;;;###autoload (autoload 'gastown-witness-attach "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-witness-attach "gastown-witness-attach"
  "Attach to witness tmux session.")

;;;###autoload (autoload 'gastown-witness-start "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-witness-start "gastown-witness-start"
  "Start the witness for a rig.")

;;;###autoload (autoload 'gastown-witness-stop "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-witness-stop "gastown-witness-stop"
  "Stop the witness.")

;;;###autoload (autoload 'gastown-witness-restart "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-witness-restart "gastown-witness-restart"
  "Restart the witness.")

;;; Witness Dispatch Transient

;;;###autoload (autoload 'gastown-witness "gastown-command-agents" nil t)
(transient-define-prefix gastown-witness ()
  "Manage the Witness agent."
  ["Witness"
   ("s" "Status" gastown-witness-status)
   ("a" "Attach" gastown-witness-attach)
   ("S" "Start" gastown-witness-start)
   ("x" "Stop" gastown-witness-stop)
   ("r" "Restart" gastown-witness-restart)])

;;; Transient Menus for Refinery

;;;###autoload (autoload 'gastown-refinery-attach "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-attach "gastown-refinery-attach"
  "Attach to the refinery session.")

;;;###autoload (autoload 'gastown-refinery-start "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-start "gastown-refinery-start"
  "Start the refinery for a rig.")

;;;###autoload (autoload 'gastown-refinery-stop "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-stop "gastown-refinery-stop"
  "Stop the refinery.")

;;;###autoload (autoload 'gastown-refinery-restart "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-restart "gastown-refinery-restart"
  "Restart the refinery.")

;;;###autoload (autoload 'gastown-refinery-blocked "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-blocked "gastown-refinery-blocked"
  "List blocked MRs.")

;;;###autoload (autoload 'gastown-refinery-claim "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-claim "gastown-refinery-claim"
  "Claim a merge request for processing.")

;;;###autoload (autoload 'gastown-refinery-queue "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-queue "gastown-refinery-queue"
  "Show the merge queue.")

;;;###autoload (autoload 'gastown-refinery-ready "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-ready "gastown-refinery-ready"
  "List MRs ready for processing.")

;;;###autoload (autoload 'gastown-refinery-release "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-release "gastown-refinery-release"
  "Release a claimed MR back to the queue.")

;;;###autoload (autoload 'gastown-refinery-unclaimed "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-refinery-unclaimed "gastown-refinery-unclaimed"
  "List unclaimed MRs.")

;;; Refinery Dispatch Transient

;;;###autoload (autoload 'gastown-refinery "gastown-command-agents" nil t)
(transient-define-prefix gastown-refinery ()
  "Manage the Refinery agent."
  ["Refinery Status"
   ("s" "Status" gastown-refinery-status)
   ("q" "Queue" gastown-refinery-queue)
   ("r" "Ready" gastown-refinery-ready)
   ("b" "Blocked" gastown-refinery-blocked)
   ("u" "Unclaimed" gastown-refinery-unclaimed)]
  ["Refinery Ops"
   ("a" "Attach" gastown-refinery-attach)
   ("S" "Start" gastown-refinery-start)
   ("x" "Stop" gastown-refinery-stop)
   ("R" "Restart" gastown-refinery-restart)]
  ["MR Management"
   ("c" "Claim MR" gastown-refinery-claim)
   ("e" "Release MR" gastown-refinery-release)])

;;; Transient Menus for Session

;;;###autoload (autoload 'gastown-session-at "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-at "gastown-session-at"
  "Attach to a running polecat session.")

;;;###autoload (autoload 'gastown-session-capture "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-capture "gastown-session-capture"
  "Capture recent output from a polecat session.")

;;;###autoload (autoload 'gastown-session-check "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-check "gastown-session-check"
  "Check polecat session health.")

;;;###autoload (autoload 'gastown-session-inject "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-inject "gastown-session-inject"
  "Send a message to a polecat session.")

;;;###autoload (autoload 'gastown-session-restart "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-restart "gastown-session-restart"
  "Restart a polecat session.")

;;;###autoload (autoload 'gastown-session-start "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-start "gastown-session-start"
  "Start a new polecat session.")

;;;###autoload (autoload 'gastown-session-status "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-status "gastown-session-status"
  "Show detailed polecat session status.")

;;;###autoload (autoload 'gastown-session-stop "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-session-stop "gastown-session-stop"
  "Stop a running polecat session.")

;;; Session Dispatch Transient

;;;###autoload (autoload 'gastown-session-menu "gastown-command-agents" nil t)
(transient-define-prefix gastown-session-menu ()
  "Manage polecat sessions."
  ["Session Info"
   ("l" "List sessions" gastown-session-list)
   ("s" "Session status" gastown-session-status)
   ("c" "Check health" gastown-session-check)]
  ["Session Ops"
   ("a" "Attach" gastown-session-at)
   ("C" "Capture output" gastown-session-capture)
   ("i" "Inject message" gastown-session-inject)]
  ["Lifecycle"
   ("S" "Start session" gastown-session-start)
   ("x" "Stop session" gastown-session-stop)
   ("r" "Restart session" gastown-session-restart)])

;;; Additional Agent Commands

(gastown-defcommand gastown-command-boot (gastown-command-global-options)
  ()
  :documentation "Represents gt boot command.
Boot an agent.")


(gastown-defcommand gastown-command-callbacks (gastown-command-global-options)
  ()
  :documentation "Represents gt callbacks command.
Show or manage callbacks.")


(gastown-defcommand gastown-command-deacon (gastown-command-global-options)
  ()
  :documentation "Represents gt deacon command.
Manage deacon agents.")


(gastown-defcommand gastown-command-dog (gastown-command-global-options)
  ()
  :documentation "Represents gt dog command.
Manage dog agents.")


(gastown-defcommand gastown-command-mayor (gastown-command-global-options)
  ()
  :documentation "Represents gt mayor command.
Interact with the mayor agent.")


(gastown-defcommand gastown-command-role (gastown-command-global-options)
  ()
  :documentation "Represents gt role command.
Show or manage agent roles.")


(gastown-defcommand gastown-command-signal (gastown-command-global-options)
  ()
  :documentation "Represents gt signal command.
Send a signal to an agent.")


;;; Transients for Additional Agent Commands

;;;###autoload (autoload 'gastown-boot "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-boot "gastown-boot"
  "Boot an agent.")

;;;###autoload (autoload 'gastown-callbacks "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-callbacks "gastown-callbacks"
  "Show or manage callbacks.")

;;;###autoload (autoload 'gastown-deacon "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-deacon "gastown-deacon"
  "Manage deacon agents.")

;;;###autoload (autoload 'gastown-dog "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-dog "gastown-dog"
  "Manage dog agents.")

;;;###autoload (autoload 'gastown-mayor "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-mayor "gastown-mayor"
  "Interact with the mayor agent.")

;;;###autoload (autoload 'gastown-role "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-role "gastown-role"
  "Show or manage agent roles.")

;;;###autoload (autoload 'gastown-signal "gastown-command-agents" nil t)
(beads-meta-define-transient gastown-command-signal "gastown-signal"
  "Send a signal to an agent.")

;;; Agent Management Dispatch Transient

;;;###autoload (autoload 'gastown-agent-management "gastown-command-agents" nil t)
(transient-define-prefix gastown-agent-management ()
  "Manage Gas Town agents."
  ["Agents & Sessions"
   ("a" "List agents" gastown-agents)
   ("s" "Sessions..." gastown-session-menu)
   ("r" "Role" gastown-role)]
  ["Subsystems"
   ("w" "Witness..." gastown-witness)
   ("R" "Refinery..." gastown-refinery)
   ("m" "Mayor" gastown-mayor)
   ("p" "Polecat" gastown-polecat)]
  ["Lifecycle"
   ("b" "Boot agent" gastown-boot)
   ("d" "Deacon" gastown-deacon)
   ("D" "Dog" gastown-dog)
   ("c" "Callbacks" gastown-callbacks)
   ("S" "Signal" gastown-signal)])

(provide 'gastown-command-agents)
;;; gastown-command-agents.el ends here
