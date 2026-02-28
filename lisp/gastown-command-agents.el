;;; gastown-command-agents.el --- Agent management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for agent management commands:
;; gt agents, gt witness, gt refinery, gt mayor, gt session, etc.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Agents List Command

(eval-and-compile
  (gastown-defcommand gastown-command-agents (gastown-command-json)
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
    :documentation "Represents gt agents command.
Lists all Gas Town agent sessions."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-agents))
  "Return \"agents\" as the CLI subcommand name."
  "agents")

;;; Witness Status Command

(eval-and-compile
  (gastown-defcommand gastown-command-witness-status (gastown-command-json)
    ((rig
      :initarg :rig
      :type (or null string)
      :initform nil
      :documentation "Rig to check witness status for (--rig)."
      :long-option "rig"
      :option-type :string
      :key "r"
      :transient "--rig"
      :class transient-option
      :argument "--rig="
      :prompt "Rig: "
      :transient-group "Options"
      :level 1
      :order 1))
    :documentation "Represents gt witness status command.
Shows witness health and monitoring status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-witness-status))
  "Return \"witness status\" as the CLI subcommand name."
  "witness status")

;;; Refinery Status Command

(eval-and-compile
  (gastown-defcommand gastown-command-refinery-status (gastown-command-json)
    ((rig
      :initarg :rig
      :type (or null string)
      :initform nil
      :documentation "Rig to check refinery status for (--rig)."
      :long-option "rig"
      :option-type :string
      :key "r"
      :transient "--rig"
      :class transient-option
      :argument "--rig="
      :prompt "Rig: "
      :transient-group "Options"
      :level 1
      :order 1))
    :documentation "Represents gt refinery status command.
Shows merge queue processor status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-refinery-status))
  "Return \"refinery status\" as the CLI subcommand name."
  "refinery status")

;;; Session List Command

(eval-and-compile
  (gastown-defcommand gastown-command-session-list (gastown-command-json)
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
    :documentation "Represents gt session list command.
Lists polecat sessions."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-session-list))
  "Return \"session list\" as the CLI subcommand name."
  "session list")

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

;;; Agent Management Dispatch Transient

;;;###autoload (autoload 'gastown-agent-management "gastown-command-agents" nil t)
(transient-define-prefix gastown-agent-management ()
  "Manage Gas Town agents."
  ["Agent Management"
   ("a" "List agents" gastown-agents)
   ("w" "Witness status" gastown-witness-status)
   ("r" "Refinery status" gastown-refinery-status)
   ("s" "Session list" gastown-session-list)])

(provide 'gastown-command-agents)
;;; gastown-command-agents.el ends here
