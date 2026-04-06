;;; gastown-command-mol.el --- Molecule workflow commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt mol' subcommands.
;; Provides molecule attach, detach, step management, and progress tracking.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Mol Attach Command

(gastown-defcommand gastown-command-mol-attach (gastown-command-global-options)
  ((pinned-bead-id
    :initarg :pinned-bead-id
    :type (or null string)
    :initform nil
    :documentation "Pinned bead ID (optional, auto-detected from cwd)."
    :positional 1
    :option-type :string
    :key "p"
    :transient-description "Pinned bead ID"
    :class transient-option
    :prompt "Pinned bead ID (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1)
   (molecule-id
    :initarg :molecule-id
    :type (or null string)
    :initform nil
    :documentation "Molecule ID to attach."
    :positional 2
    :option-type :string
    :key "m"
    :transient-description "Molecule ID (required)"
    :class transient-option
    :prompt "Molecule ID: "
    :transient-group "Arguments"
    :level 1
    :order 2))
  :documentation "Represents gt mol attach command.
Attach a molecule to a pinned bead."
  :cli-command "mol attach")


;;; Mol Attach-From-Mail Command

(gastown-defcommand gastown-command-mol-attach-from-mail (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Mail ID containing the molecule attachment."
    :positional 1
    :option-type :string
    :key "m"
    :transient-description "Mail ID (required)"
    :class transient-option
    :prompt "Mail ID: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt mol attach-from-mail command.
Attach a molecule from a mail message."
  :cli-command "mol attach-from-mail")


;;; Mol Attachment Command

(gastown-defcommand gastown-command-mol-attachment (gastown-command-global-options)
  ((bead-id
    :initarg :bead-id
    :type (or null string)
    :initform nil
    :documentation "Bead ID to check attachment status for."
    :positional 1
    :option-type :string
    :key "b"
    :transient-description "Bead ID (optional)"
    :class transient-option
    :prompt "Bead ID (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt mol attachment command.
Show attachment status of a pinned bead."
  :cli-command "mol attachment")


;;; Mol Await-Signal Command

(gastown-defcommand gastown-command-mol-await-signal (gastown-command-global-options)
  ((signal-name
    :initarg :signal-name
    :type (or null string)
    :initform nil
    :documentation "Signal name to wait for."
    :positional 1
    :option-type :string
    :key "s"
    :transient-description "Signal name (required)"
    :class transient-option
    :prompt "Signal name: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (timeout
    :initarg :timeout
    :type (or null string)
    :initform nil
    :documentation "Timeout duration (e.g. 5m, 1h)."
    :long-option "timeout"
    :option-type :string
    :key "t"
    :transient-description "Timeout"
    :class transient-option
    :argument "--timeout="
    :prompt "Timeout (e.g. 5m): "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt mol await-signal command.
Wait for activity feed signal with timeout."
  :cli-command "mol await-signal")


;;; Mol Burn Command

(gastown-defcommand gastown-command-mol-burn (gastown-command-global-options)
  ()
  :documentation "Represents gt mol burn command.
Burn current molecule without creating a digest."
  :cli-command "mol burn")


;;; Mol Current Command

(gastown-defcommand gastown-command-mol-current (gastown-command-global-options)
  ()
  :documentation "Represents gt mol current command.
Show what agent should be working on."
  :cli-command "mol current")


;;; Mol DAG Command

(gastown-defcommand gastown-command-mol-dag (gastown-command-global-options)
  ((molecule-id
    :initarg :molecule-id
    :type (or null string)
    :initform nil
    :documentation "Molecule ID to visualize."
    :positional 1
    :option-type :string
    :key "m"
    :transient-description "Molecule ID (optional)"
    :class transient-option
    :prompt "Molecule ID (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt mol dag command.
Visualize molecule dependency DAG."
  :cli-command "mol dag")


;;; Mol Detach Command

(gastown-defcommand gastown-command-mol-detach (gastown-command-global-options)
  ((bead-id
    :initarg :bead-id
    :type (or null string)
    :initform nil
    :documentation "Bead ID to detach molecule from (optional)."
    :positional 1
    :option-type :string
    :key "b"
    :transient-description "Bead ID (optional)"
    :class transient-option
    :prompt "Bead ID (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt mol detach command.
Detach molecule from a pinned bead."
  :cli-command "mol detach")


;;; Mol Progress Command

(gastown-defcommand gastown-command-mol-progress (gastown-command-global-options)
  ()
  :documentation "Represents gt mol progress command.
Show progress through a molecule's steps."
  :cli-command "mol progress")


;;; Mol Squash Command

(gastown-defcommand gastown-command-mol-squash (gastown-command-global-options)
  ()
  :documentation "Represents gt mol squash command.
Compress molecule into a digest."
  :cli-command "mol squash")


;;; Mol Status Command

(gastown-defcommand gastown-command-mol-status (gastown-command-global-options)
  ((agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent to show hook status for (optional)."
    :positional 1
    :option-type :string
    :key "a"
    :transient-description "Agent (optional)"
    :class transient-option
    :prompt "Agent (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt mol status command.
Show what's on an agent's hook."
  :cli-command "mol status")


;;; Mol Step Done Command

(gastown-defcommand gastown-command-mol-step-done (gastown-command-global-options)
  ((step-id
    :initarg :step-id
    :type (or null string)
    :initform nil
    :documentation "Step ID to complete."
    :positional 1
    :option-type :string
    :key "s"
    :transient-description "Step ID (required)"
    :class transient-option
    :prompt "Step ID: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt mol step done command.
Complete current step and auto-continue to next."
  :cli-command "mol step done")


;;; Mol Step Await-Signal Command

(gastown-defcommand gastown-command-mol-step-await-signal (gastown-command-global-options)
  ((signal-name
    :initarg :signal-name
    :type (or null string)
    :initform nil
    :documentation "Signal name to wait for."
    :positional 1
    :option-type :string
    :key "s"
    :transient-description "Signal name (required)"
    :class transient-option
    :prompt "Signal name: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (timeout
    :initarg :timeout
    :type (or null string)
    :initform nil
    :documentation "Timeout duration (e.g. 5m, 1h)."
    :long-option "timeout"
    :option-type :string
    :key "t"
    :transient-description "Timeout"
    :class transient-option
    :argument "--timeout="
    :prompt "Timeout (e.g. 5m): "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt mol step await-signal command.
Wait for activity feed signal with timeout."
  :cli-command "mol step await-signal")


;;; Mol Step Await-Event Command

(gastown-defcommand gastown-command-mol-step-await-event (gastown-command-global-options)
  ((channel
    :initarg :channel
    :type (or null string)
    :initform nil
    :documentation "Event channel name."
    :positional 1
    :option-type :string
    :key "c"
    :transient-description "Channel (required)"
    :class transient-option
    :prompt "Channel: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (timeout
    :initarg :timeout
    :type (or null string)
    :initform nil
    :documentation "Timeout duration (e.g. 5m, 1h)."
    :long-option "timeout"
    :option-type :string
    :key "t"
    :transient-description "Timeout"
    :class transient-option
    :argument "--timeout="
    :prompt "Timeout (e.g. 5m): "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt mol step await-event command.
Wait for a file-based event on a named channel."
  :cli-command "mol step await-event")


;;; Mol Step Emit-Event Command

(gastown-defcommand gastown-command-mol-step-emit-event (gastown-command-global-options)
  ((channel
    :initarg :channel
    :type (or null string)
    :initform nil
    :documentation "Event channel name."
    :positional 1
    :option-type :string
    :key "c"
    :transient-description "Channel (required)"
    :class transient-option
    :prompt "Channel: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (payload
    :initarg :payload
    :type (or null string)
    :initform nil
    :documentation "Event payload data."
    :positional 2
    :option-type :string
    :key "p"
    :transient-description "Payload (optional)"
    :class transient-option
    :prompt "Payload: "
    :transient-group "Arguments"
    :level 2
    :order 2))
  :documentation "Represents gt mol step emit-event command.
Emit a file-based event on a named channel."
  :cli-command "mol step emit-event")


;;; Transient Menus

;;;###autoload (autoload 'gastown-mol-attach "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-attach "gastown-mol-attach"
  "Attach a molecule to a pinned bead.")

;;;###autoload (autoload 'gastown-mol-attach-from-mail "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-attach-from-mail "gastown-mol-attach-from-mail"
  "Attach molecule from mail.")

;;;###autoload (autoload 'gastown-mol-attachment "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-attachment "gastown-mol-attachment"
  "Show attachment status.")

;;;###autoload (autoload 'gastown-mol-await-signal "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-await-signal "gastown-mol-await-signal"
  "Wait for activity feed signal.")

;;;###autoload (autoload 'gastown-mol-burn "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-burn "gastown-mol-burn"
  "Burn current molecule.")

;;;###autoload (autoload 'gastown-mol-current "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-current "gastown-mol-current"
  "Show current work item.")

;;;###autoload (autoload 'gastown-mol-dag "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-dag "gastown-mol-dag"
  "Visualize molecule DAG.")

;;;###autoload (autoload 'gastown-mol-detach "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-detach "gastown-mol-detach"
  "Detach molecule from bead.")

;;;###autoload (autoload 'gastown-mol-progress "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-progress "gastown-mol-progress"
  "Show molecule progress.")

;;;###autoload (autoload 'gastown-mol-squash "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-squash "gastown-mol-squash"
  "Squash molecule into digest.")

;;;###autoload (autoload 'gastown-mol-status "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-status "gastown-mol-status"
  "Show hook status.")

;;;###autoload (autoload 'gastown-mol-step-done "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-step-done "gastown-mol-step-done"
  "Complete current step.")

;;;###autoload (autoload 'gastown-mol-step-await-signal "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-step-await-signal "gastown-mol-step-await-signal"
  "Wait for signal in step.")

;;;###autoload (autoload 'gastown-mol-step-await-event "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-step-await-event "gastown-mol-step-await-event"
  "Wait for event in step.")

;;;###autoload (autoload 'gastown-mol-step-emit-event "gastown-command-mol" nil t)
(beads-meta-define-transient gastown-command-mol-step-emit-event "gastown-mol-step-emit-event"
  "Emit event in step.")

;;; Mol Step Dispatch Transient

;;;###autoload (autoload 'gastown-mol-step "gastown-command-mol" nil t)
(transient-define-prefix gastown-mol-step ()
  "Molecule step operations."
  ["Step Commands"
   ("d" "Complete step" gastown-mol-step-done)
   ("s" "Await signal" gastown-mol-step-await-signal)
   ("e" "Await event" gastown-mol-step-await-event)
   ("E" "Emit event" gastown-mol-step-emit-event)])

;;; Mol Dispatch Transient

;;;###autoload (autoload 'gastown-mol "gastown-command-mol" nil t)
(transient-define-prefix gastown-mol ()
  "Agent molecule workflow commands."
  ["View"
   ("s" "Hook status" gastown-mol-status)
   ("c" "Current work" gastown-mol-current)
   ("p" "Progress" gastown-mol-progress)
   ("d" "DAG" gastown-mol-dag)
   ("A" "Attachment" gastown-mol-attachment)]
  ["Attach"
   ("a" "Attach molecule" gastown-mol-attach)
   ("m" "Attach from mail" gastown-mol-attach-from-mail)
   ("D" "Detach" gastown-mol-detach)]
  ["Step Operations"
   ("S" "Step..." gastown-mol-step)]
  ["Lifecycle"
   ("w" "Await signal" gastown-mol-await-signal)
   ("q" "Squash" gastown-mol-squash)
   ("b" "Burn" gastown-mol-burn)])

(provide 'gastown-command-mol)
;;; gastown-command-mol.el ends here
