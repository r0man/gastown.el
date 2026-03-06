;;; gastown-command-work.el --- Work management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for work management commands:
;; gt done, gt hook, gt ready, gt escalate, gt broadcast, gt handoff,
;; gt unsling, gt mq, etc.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Done Command

(eval-and-compile
  (gastown-defcommand gastown-command-done (gastown-command-global-options)
    ((cleanup-status
      :initarg :cleanup-status
      :type (or null string)
      :initform nil
      :documentation "Override cleanup status (--cleanup-status)."
      :long-option "cleanup-status"
      :option-type :string
      :key "c"
      :transient "--cleanup-status"
      :class transient-option
      :argument "--cleanup-status="
      :prompt "Cleanup status: "
      :transient-choices ("clean" "dirty")
      :transient-group "Options"
      :level 2
      :order 1)
     (status
      :initarg :status
      :type (or null string)
      :initform nil
      :documentation "Override completion status (--status)."
      :long-option "status"
      :option-type :string
      :key "s"
      :transient "--status"
      :class transient-option
      :argument "--status="
      :prompt "Status: "
      :transient-choices ("COMPLETED" "DEFERRED" "ESCALATED")
      :transient-group "Options"
      :level 2
      :order 2))
    :documentation "Represents gt done command.
Signal work ready for merge queue."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-done))
  "Return \"done\" as the CLI subcommand name."
  "done")

;;; Hook Command

(eval-and-compile
  (gastown-defcommand gastown-command-hook (gastown-command-global-options)
    ()
    :documentation "Represents gt hook command.
Show or attach work on a hook."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-hook))
  "Return \"hook\" as the CLI subcommand name."
  "hook")

;;; Ready Command

(eval-and-compile
  (gastown-defcommand gastown-command-ready (gastown-command-global-options)
    ()
    :documentation "Represents gt ready command.
Show work ready across town."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-ready))
  "Return \"ready\" as the CLI subcommand name."
  "ready")

;;; Escalate Command

(eval-and-compile
  (gastown-defcommand gastown-command-escalate (gastown-command-global-options)
    ((description
      :initarg :description
      :type (or null string)
      :initform nil
      :documentation "Brief description of the issue."
      :positional 1
      :option-type :string
      :key "d"
      :transient "Description (required)"
      :class transient-option
      :prompt "Description: "
      :transient-group "Required"
      :level 1
      :order 1)
     (severity
      :initarg :severity
      :type (or null string)
      :initform nil
      :documentation "Severity level (-s, --severity)."
      :long-option "severity"
      :short-option "s"
      :option-type :string
      :key "s"
      :transient "--severity"
      :class transient-option
      :argument "--severity="
      :prompt "Severity: "
      :transient-choices ("LOW" "MEDIUM" "HIGH" "CRITICAL")
      :transient-group "Options"
      :level 1
      :order 2)
     (message-body
      :initarg :message-body
      :type (or null string)
      :initform nil
      :documentation "Detailed message (-m)."
      :long-option "m"
      :option-type :string
      :key "m"
      :transient "Message"
      :class transient-option
      :argument "-m="
      :prompt "Details: "
      :transient-group "Options"
      :level 1
      :order 3))
    :documentation "Represents gt escalate command.
Escalation system for critical issues."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-escalate))
  "Return \"escalate\" as the CLI subcommand name."
  "escalate")

;;; Broadcast Command

(eval-and-compile
  (gastown-defcommand gastown-command-broadcast (gastown-command-global-options)
    ((message-text
      :initarg :message-text
      :type (or null string)
      :initform nil
      :documentation "Broadcast message text."
      :positional 1
      :option-type :string
      :key "m"
      :transient "Message (required)"
      :class transient-option
      :prompt "Message: "
      :transient-group "Required"
      :level 1
      :order 1))
    :documentation "Represents gt broadcast command.
Send a nudge message to all workers."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-broadcast))
  "Return \"broadcast\" as the CLI subcommand name."
  "broadcast")

;;; Handoff Command

(eval-and-compile
  (gastown-defcommand gastown-command-handoff (gastown-command-global-options)
    ((subject
      :initarg :subject
      :type (or null string)
      :initform nil
      :documentation "Handoff subject (-s)."
      :long-option "s"
      :option-type :string
      :key "s"
      :transient "Subject"
      :class transient-option
      :argument "-s="
      :prompt "Subject: "
      :transient-group "Required"
      :level 1
      :order 1)
     (message-body
      :initarg :message-body
      :type (or null string)
      :initform nil
      :documentation "Handoff message (-m)."
      :long-option "m"
      :option-type :string
      :key "m"
      :transient "Message"
      :class transient-option
      :argument "-m="
      :prompt "Message: "
      :transient-group "Required"
      :level 1
      :order 2))
    :documentation "Represents gt handoff command.
Hand off to a fresh session, work continues from hook."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-handoff))
  "Return \"handoff\" as the CLI subcommand name."
  "handoff")

;;; Unsling Command

(eval-and-compile
  (gastown-defcommand gastown-command-unsling (gastown-command-global-options)
    ((target
      :initarg :target
      :type (or null string)
      :initform nil
      :documentation "Target agent to unsling work from."
      :positional 1
      :option-type :string
      :key "t"
      :transient "Target"
      :class transient-option
      :prompt "Target (rig/agent): "
      :transient-group "Required"
      :level 1
      :order 1))
    :documentation "Represents gt unsling command.
Remove work from an agent's hook."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-unsling))
  "Return \"unsling\" as the CLI subcommand name."
  "unsling")

;;; MQ List Command

(eval-and-compile
  (gastown-defcommand gastown-command-mq-list (gastown-command-global-options)
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
      :order 1))
    :documentation "Represents gt mq list command.
List merge queue entries."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-mq-list))
  "Return \"mq list\" as the CLI subcommand name."
  "mq list")

;;; Transient Menus

;;;###autoload (autoload 'gastown-done "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-done "gastown-done"
  "Signal work ready for merge queue.")

;;;###autoload (autoload 'gastown-hook "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-hook "gastown-hook"
  "Show or attach work on a hook.")

;;;###autoload (autoload 'gastown-ready "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-ready "gastown-ready"
  "Show work ready across town.")

;;;###autoload (autoload 'gastown-escalate "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-escalate "gastown-escalate"
  "Escalate a critical issue.")

;;;###autoload (autoload 'gastown-broadcast "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-broadcast "gastown-broadcast"
  "Broadcast message to all workers.")

;;;###autoload (autoload 'gastown-handoff "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-handoff "gastown-handoff"
  "Hand off to a fresh session.")

;;;###autoload (autoload 'gastown-unsling "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-unsling "gastown-unsling"
  "Remove work from an agent's hook.")

;;;###autoload (autoload 'gastown-mq-list "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-mq-list "gastown-mq-list"
  "List merge queue entries.")

;;; Simple Work Commands

(eval-and-compile
  (gastown-defcommand gastown-command-bead (gastown-command-global-options)
    ()
    :documentation "Represents gt bead command.
Show bead information."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-bead))
  "Return \"bead\" as the CLI subcommand name."
  "bead")

(eval-and-compile
  (gastown-defcommand gastown-command-cat (gastown-command-global-options)
    ()
    :documentation "Represents gt cat command.
Show bead content."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-cat))
  "Return \"cat\" as the CLI subcommand name."
  "cat")

(eval-and-compile
  (gastown-defcommand gastown-command-cleanup (gastown-command-global-options)
    ()
    :documentation "Represents gt cleanup command.
Clean up Gas Town resources."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-cleanup))
  "Return \"cleanup\" as the CLI subcommand name."
  "cleanup")

(eval-and-compile
  (gastown-defcommand gastown-command-close (gastown-command-global-options)
    ()
    :documentation "Represents gt close command.
Close a bead."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-close))
  "Return \"close\" as the CLI subcommand name."
  "close")

(eval-and-compile
  (gastown-defcommand gastown-command-commit (gastown-command-global-options)
    ()
    :documentation "Represents gt commit command.
Commit work to git."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-commit))
  "Return \"commit\" as the CLI subcommand name."
  "commit")

(eval-and-compile
  (gastown-defcommand gastown-command-compact (gastown-command-global-options)
    ()
    :documentation "Represents gt compact command.
Compact context for a session."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-compact))
  "Return \"compact\" as the CLI subcommand name."
  "compact")

(eval-and-compile
  (gastown-defcommand gastown-command-forget (gastown-command-global-options)
    ()
    :documentation "Represents gt forget command.
Remove a memory entry."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-forget))
  "Return \"forget\" as the CLI subcommand name."
  "forget")

(eval-and-compile
  (gastown-defcommand gastown-command-formula (gastown-command-global-options)
    ()
    :documentation "Represents gt formula command.
Manage workflow formulas."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-formula))
  "Return \"formula\" as the CLI subcommand name."
  "formula")

(eval-and-compile
  (gastown-defcommand gastown-command-memories (gastown-command-global-options)
    ()
    :documentation "Represents gt memories command.
Show agent memories."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-memories))
  "Return \"memories\" as the CLI subcommand name."
  "memories")

(eval-and-compile
  (gastown-defcommand gastown-command-mol (gastown-command-global-options)
    ()
    :documentation "Represents gt mol command.
Manage molecules and workflow steps."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-mol))
  "Return \"mol\" as the CLI subcommand name."
  "mol")

(eval-and-compile
  (gastown-defcommand gastown-command-orphans (gastown-command-global-options)
    ()
    :documentation "Represents gt orphans command.
Show orphaned agents."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-orphans))
  "Return \"orphans\" as the CLI subcommand name."
  "orphans")

(eval-and-compile
  (gastown-defcommand gastown-command-prune-branches (gastown-command-global-options)
    ()
    :documentation "Represents gt prune-branches command.
Prune stale git branches."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-prune-branches))
  "Return \"prune-branches\" as the CLI subcommand name."
  "prune-branches")

(eval-and-compile
  (gastown-defcommand gastown-command-release (gastown-command-global-options)
    ()
    :documentation "Represents gt release command.
Release a bead or resource."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-release))
  "Return \"release\" as the CLI subcommand name."
  "release")

(eval-and-compile
  (gastown-defcommand gastown-command-remember (gastown-command-global-options)
    ()
    :documentation "Represents gt remember command.
Add a memory entry."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-remember))
  "Return \"remember\" as the CLI subcommand name."
  "remember")

(eval-and-compile
  (gastown-defcommand gastown-command-resume (gastown-command-global-options)
    ()
    :documentation "Represents gt resume command.
Resume a session."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-resume))
  "Return \"resume\" as the CLI subcommand name."
  "resume")

(eval-and-compile
  (gastown-defcommand gastown-command-scheduler (gastown-command-global-options)
    ()
    :documentation "Represents gt scheduler command.
Show scheduler status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-scheduler))
  "Return \"scheduler\" as the CLI subcommand name."
  "scheduler")

(eval-and-compile
  (gastown-defcommand gastown-command-show (gastown-command-global-options)
    ()
    :documentation "Represents gt show command.
Show a bead."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-show))
  "Return \"show\" as the CLI subcommand name."
  "show")

(eval-and-compile
  (gastown-defcommand gastown-command-synthesis (gastown-command-global-options)
    ()
    :documentation "Represents gt synthesis command.
Synthesize work from multiple sources."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-synthesis))
  "Return \"synthesis\" as the CLI subcommand name."
  "synthesis")

(eval-and-compile
  (gastown-defcommand gastown-command-wl (gastown-command-global-options)
    ()
    :documentation "Represents gt wl command.
Show work list."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-wl))
  "Return \"wl\" as the CLI subcommand name."
  "wl")

;;; Transients for Simple Work Commands

;;;###autoload (autoload 'gastown-bead "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-bead "gastown-bead"
  "Show bead information.")

;;;###autoload (autoload 'gastown-cat "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-cat "gastown-cat"
  "Show bead content.")

;;;###autoload (autoload 'gastown-cleanup "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-cleanup "gastown-cleanup"
  "Clean up Gas Town resources.")

;;;###autoload (autoload 'gastown-close "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-close "gastown-close"
  "Close a bead.")

;;;###autoload (autoload 'gastown-commit "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-commit "gastown-commit"
  "Commit work to git.")

;;;###autoload (autoload 'gastown-compact "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-compact "gastown-compact"
  "Compact context for a session.")

;;;###autoload (autoload 'gastown-forget "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-forget "gastown-forget"
  "Remove a memory entry.")

;;;###autoload (autoload 'gastown-formula "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-formula "gastown-formula"
  "Manage workflow formulas.")

;;;###autoload (autoload 'gastown-memories "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-memories "gastown-memories"
  "Show agent memories.")

;;;###autoload (autoload 'gastown-mol "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-mol "gastown-mol"
  "Manage molecules and workflow steps.")

;;;###autoload (autoload 'gastown-orphans "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-orphans "gastown-orphans"
  "Show orphaned agents.")

;;;###autoload (autoload 'gastown-prune-branches "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-prune-branches "gastown-prune-branches"
  "Prune stale git branches.")

;;;###autoload (autoload 'gastown-release "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-release "gastown-release"
  "Release a bead or resource.")

;;;###autoload (autoload 'gastown-remember "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-remember "gastown-remember"
  "Add a memory entry.")

;;;###autoload (autoload 'gastown-resume "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-resume "gastown-resume"
  "Resume a session.")

;;;###autoload (autoload 'gastown-scheduler "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-scheduler "gastown-scheduler"
  "Show scheduler status.")

;;;###autoload (autoload 'gastown-show "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-show "gastown-show"
  "Show a bead.")

;;;###autoload (autoload 'gastown-synthesis "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-synthesis "gastown-synthesis"
  "Synthesize work from multiple sources.")

;;;###autoload (autoload 'gastown-wl "gastown-command-work" nil t)
(beads-meta-define-transient gastown-command-wl "gastown-wl"
  "Show work list.")

;;; MQ Dispatch Transient

;;;###autoload (autoload 'gastown-mq "gastown-command-work" nil t)
(transient-define-prefix gastown-mq ()
  "Manage the Gas Town merge queue."
  ["Merge Queue"
   ("l" "List merge queue" gastown-mq-list)])

;;; Work Management Dispatch Transient

;;;###autoload (autoload 'gastown-work-menu "gastown-command-work" nil t)
(transient-define-prefix gastown-work-menu ()
  "Gas Town work management commands."
  ["Dispatch"
   ("S" "Sling (dispatch work)" gastown-sling)
   ("d" "Done (signal complete)" gastown-done)
   ("h" "Hook" gastown-hook)
   ("r" "Ready (available work)" gastown-ready)
   ("H" "Handoff" gastown-handoff)
   ("u" "Unsling" gastown-unsling)]
  ["Beads & Tracking"
   ("b" "Bead" gastown-bead)
   ("s" "Show bead" gastown-show)
   ("c" "Cat (bead content)" gastown-cat)
   ("C" "Close bead" gastown-close)]
  ["Molecules & Formulas"
   ("m" "Molecule" gastown-mol)
   ("f" "Formula" gastown-formula)
   ("y" "Synthesis" gastown-synthesis)
   ("q" "Merge queue" gastown-mq)
   ("v" "Convoy" gastown-convoy)]
  ["Memory & Context"
   ("M" "Memories" gastown-memories)
   ("R" "Remember" gastown-remember)
   ("F" "Forget" gastown-forget)
   ("k" "Compact" gastown-compact)
   ("e" "Resume" gastown-resume)]
  ["Maintenance"
   ("o" "Orphans" gastown-orphans)
   ("p" "Prune branches" gastown-prune-branches)
   ("l" "Cleanup" gastown-cleanup)
   ("L" "Release" gastown-release)
   ("g" "Commit" gastown-commit)
   ("w" "Work list" gastown-wl)
   ("T" "Scheduler" gastown-scheduler)])

(provide 'gastown-command-work)
;;; gastown-command-work.el ends here
