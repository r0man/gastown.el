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

(gastown-defcommand gastown-command-agents (gastown-command-global-options)
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
Lists all Gas Town agent sessions.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-agents))
  "Return \"agents\" as the CLI subcommand name."
  "agents")

;;; Witness Status Command

(gastown-defcommand gastown-command-witness-status (gastown-command-global-options)
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
Shows witness health and monitoring status.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-witness-status))
  "Return \"witness status\" as the CLI subcommand name."
  "witness status")

;;; Refinery Status Command

(gastown-defcommand gastown-command-refinery-status (gastown-command-global-options)
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
Shows merge queue processor status.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-refinery-status))
  "Return \"refinery status\" as the CLI subcommand name."
  "refinery status")

;;; Session List Command

(gastown-defcommand gastown-command-session-list (gastown-command-global-options)
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
Lists polecat sessions.")

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

;;; Additional Agent Commands

(gastown-defcommand gastown-command-boot (gastown-command-global-options)
  ()
  :documentation "Represents gt boot command.
Boot an agent.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-boot))
  "Return \"boot\" as the CLI subcommand name."
  "boot")

(gastown-defcommand gastown-command-callbacks (gastown-command-global-options)
  ()
  :documentation "Represents gt callbacks command.
Show or manage callbacks.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-callbacks))
  "Return \"callbacks\" as the CLI subcommand name."
  "callbacks")

(gastown-defcommand gastown-command-deacon (gastown-command-global-options)
  ()
  :documentation "Represents gt deacon command.
Manage deacon agents.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-deacon))
  "Return \"deacon\" as the CLI subcommand name."
  "deacon")

(gastown-defcommand gastown-command-dog (gastown-command-global-options)
  ()
  :documentation "Represents gt dog command.
Manage dog agents.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-dog))
  "Return \"dog\" as the CLI subcommand name."
  "dog")

(gastown-defcommand gastown-command-mayor (gastown-command-global-options)
  ()
  :documentation "Represents gt mayor command.
Interact with the mayor agent.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-mayor))
  "Return \"mayor\" as the CLI subcommand name."
  "mayor")

(gastown-defcommand gastown-command-role (gastown-command-global-options)
  ()
  :documentation "Represents gt role command.
Show or manage agent roles.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-role))
  "Return \"role\" as the CLI subcommand name."
  "role")

(gastown-defcommand gastown-command-signal (gastown-command-global-options)
  ()
  :documentation "Represents gt signal command.
Send a signal to an agent.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-signal))
  "Return \"signal\" as the CLI subcommand name."
  "signal")

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
   ("s" "Session list" gastown-session-list)
   ("r" "Role" gastown-role)]
  ["Subsystems"
   ("w" "Witness status" gastown-witness-status)
   ("R" "Refinery status" gastown-refinery-status)
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
