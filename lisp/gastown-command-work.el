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
  (gastown-defcommand gastown-command-done (gastown-command)
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
  (gastown-defcommand gastown-command-hook (gastown-command-json)
    ()
    :documentation "Represents gt hook command.
Show or attach work on a hook."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-hook))
  "Return \"hook\" as the CLI subcommand name."
  "hook")

;;; Ready Command

(eval-and-compile
  (gastown-defcommand gastown-command-ready (gastown-command-json)
    ()
    :documentation "Represents gt ready command.
Show work ready across town."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-ready))
  "Return \"ready\" as the CLI subcommand name."
  "ready")

;;; Escalate Command

(eval-and-compile
  (gastown-defcommand gastown-command-escalate (gastown-command)
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
  (gastown-defcommand gastown-command-broadcast (gastown-command)
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
  (gastown-defcommand gastown-command-handoff (gastown-command)
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
  (gastown-defcommand gastown-command-unsling (gastown-command)
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
  (gastown-defcommand gastown-command-mq-list (gastown-command-json)
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

(provide 'gastown-command-work)
;;; gastown-command-work.el ends here
