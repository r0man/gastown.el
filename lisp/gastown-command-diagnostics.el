;;; gastown-command-diagnostics.el --- Diagnostic commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for diagnostic commands:
;; gt vitals, gt doctor, gt log, gt activity, gt info, gt whoami, etc.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)
(require 'gastown-reader)

(require 'transient)

(defvar gastown-executable)

;;; Vitals Command

(gastown-defcommand gastown-command-vitals (gastown-command-global-options)
  ()
  :documentation "Represents gt vitals command.
Shows unified health dashboard.")


;;; Doctor Command

(gastown-defcommand gastown-command-doctor (gastown-command-global-options)
  ((fix
    :initarg :fix
    :type boolean
    :initform nil
    :documentation "Attempt to fix issues"
    :long-option "fix"
    :option-type :boolean
    :transient-key "f"
    :transient transient-switch
    :argument "--fix"
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt doctor command.
Diagnose and optionally fix Gas Town issues.")


;;; Log Command

(gastown-defcommand gastown-command-log (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Filters"
    :level 1
    :order 1)
   (lines
    :initarg :lines
    :type (or null integer)
    :initform nil
    :documentation "Number of log lines"
    :long-option "lines"
    :short-option "n"
    :option-type :integer
    :transient-key "n"
    :transient transient-option
    :argument "--lines="
    :prompt "Lines: "
    :transient-group "Options"
    :level 2
    :order 2)
   (follow
    :initarg :follow
    :type boolean
    :initform nil
    :documentation "Follow log output"
    :long-option "follow"
    :short-option "f"
    :option-type :boolean
    :transient-key "f"
    :transient transient-switch
    :argument "--follow"
    :transient-group "Options"
    :level 1
    :order 3))
  :documentation "Represents gt log command.
Show Gas Town logs.")


;;; Activity Command

(gastown-defcommand gastown-command-activity (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Filters"
    :level 1
    :order 1))
  :documentation "Represents gt activity command.
Show recent agent activity.")


;;; Info Command

(gastown-defcommand gastown-command-info (gastown-command-global-options)
  ()
  :documentation "Represents gt info command.
Show Gas Town workspace information.")


;;; Whoami Command

(gastown-defcommand gastown-command-whoami (gastown-command-global-options)
  ()
  :documentation "Represents gt whoami command.
Show current identity for mail commands.")


;;; Costs Command

(gastown-defcommand gastown-command-costs (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Filters"
    :level 1
    :order 1))
  :documentation "Represents gt costs command.
Show cost metrics.")


;;; Trail Command

(gastown-defcommand gastown-command-trail (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Filters"
    :level 1
    :order 1))
  :documentation "Represents gt trail command.
Show recent agent activity trail.")


;;; Version Command

(gastown-defcommand gastown-command-version (gastown-command-global-options)
  ()
  :documentation "Represents gt version command.
Print version information.")


;;; Transient Menus

;;;###autoload (autoload 'gastown-vitals "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-vitals "gastown-vitals"
  "Show Gas Town health dashboard.")

;;;###autoload (autoload 'gastown-doctor "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-doctor "gastown-doctor"
  "Diagnose and fix Gas Town issues.")

;;;###autoload (autoload 'gastown-log "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-log "gastown-log"
  "Show Gas Town logs.")

;;;###autoload (autoload 'gastown-activity "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-activity "gastown-activity"
  "Show recent agent activity.")

;;;###autoload (autoload 'gastown-info "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-info "gastown-info"
  "Show Gas Town workspace information.")

;;;###autoload (autoload 'gastown-whoami "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-whoami "gastown-whoami"
  "Show current identity.")

;;;###autoload (autoload 'gastown-costs "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-costs "gastown-costs"
  "Show cost metrics.")

;;;###autoload (autoload 'gastown-trail "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-trail "gastown-trail"
  "Show recent agent activity trail.")

;;;###autoload (autoload 'gastown-version "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-version "gastown-version"
  "Print Gas Town version.")

;;; Additional Diagnostic Commands

(gastown-defcommand gastown-command-audit (gastown-command-global-options)
  ()
  :documentation "Represents gt audit command.
Audit Gas Town configuration and state.")


(gastown-defcommand gastown-command-checkpoint (gastown-command-global-options)
  ()
  :documentation "Represents gt checkpoint command.
Create a checkpoint snapshot.")


;;; Checkpoint Subcommands

(gastown-defcommand gastown-command-checkpoint-clear (gastown-command-global-options)
  ()
  :documentation "Represents gt checkpoint clear command.
Clear the checkpoint file."
  :cli-command "checkpoint clear")


(gastown-defcommand gastown-command-checkpoint-read (gastown-command-global-options)
  ()
  :documentation "Represents gt checkpoint read command.
Read and display the current checkpoint."
  :cli-command "checkpoint read")


(gastown-defcommand gastown-command-checkpoint-write (gastown-command-global-options)
  ()
  :documentation "Represents gt checkpoint write command.
Write a checkpoint of current session state."
  :cli-command "checkpoint write")


(gastown-defcommand gastown-command-dashboard (gastown-command-global-options)
  ()
  :documentation "Represents gt dashboard command.
Show the Gas Town dashboard.")


(gastown-defcommand gastown-command-feed (gastown-command-global-options)
  ()
  :documentation "Represents gt feed command.
Show activity feed.")


(gastown-defcommand gastown-command-heartbeat (gastown-command-global-options)
  ()
  :documentation "Represents gt heartbeat command.
Show agent heartbeats.")


(gastown-defcommand gastown-command-health (gastown-command-global-options)
  ()
  :documentation "Represents gt health command.
Show overall health status.")


(gastown-defcommand gastown-command-metrics (gastown-command-global-options)
  ()
  :documentation "Represents gt metrics command.
Show performance metrics.")


(gastown-defcommand gastown-command-patrol (gastown-command-global-options)
  ()
  :documentation "Represents gt patrol command.
Run patrol checks.")


(gastown-defcommand gastown-command-prime (gastown-command-global-options)
  ()
  :documentation "Represents gt prime command.
Load full role context.")


(gastown-defcommand gastown-command-seance (gastown-command-global-options)
  ()
  :documentation "Represents gt seance command.
Investigate past sessions.")


(gastown-defcommand gastown-command-repair (gastown-command-global-options)
  ()
  :documentation "Represents gt repair command.
Repair database identity and configuration issues.")


(gastown-defcommand gastown-command-stale (gastown-command-global-options)
  ()
  :documentation "Represents gt stale command.
Show stale resources.")


(gastown-defcommand gastown-command-thanks (gastown-command-global-options)
  ()
  :documentation "Represents gt thanks command.
Send thanks to an agent.")


(gastown-defcommand gastown-command-upgrade (gastown-command-global-options)
  ()
  :documentation "Represents gt upgrade command.
Upgrade Gas Town.")


;;; Additional Misc Commands

(gastown-defcommand gastown-command-cycle (gastown-command-global-options)
  ()
  :documentation "Represents gt cycle command.
Cycle to a fresh session.")


;;; Cycle Subcommands

(gastown-defcommand gastown-command-cycle-next (gastown-command-global-options)
  ()
  :documentation "Represents gt cycle next command.
Cycle to next account."
  :cli-command "cycle next")


(gastown-defcommand gastown-command-cycle-prev (gastown-command-global-options)
  ()
  :documentation "Represents gt cycle prev command.
Cycle to previous account."
  :cli-command "cycle prev")


(gastown-defcommand gastown-command-krc (gastown-command-global-options)
  ()
  :documentation "Represents gt krc command.
Show krc information.")


(gastown-defcommand gastown-command-tap (gastown-command-global-options)
  ()
  :documentation "Represents gt tap command.
Tap into agent output.")


(gastown-defcommand gastown-command-town (gastown-command-global-options)
  ()
  :documentation "Represents gt town command.
Show town information.")


(gastown-defcommand gastown-command-warrant (gastown-command-global-options)
  ()
  :documentation "Represents gt warrant command.
Show or manage warrants.")


;;; Transients for Additional Diagnostic Commands

;;;###autoload (autoload 'gastown-audit "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-audit "gastown-audit"
  "Audit Gas Town configuration and state.")

;;;###autoload (autoload 'gastown-checkpoint "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-checkpoint "gastown-checkpoint"
  "Create a checkpoint snapshot.")

;;;###autoload (autoload 'gastown-checkpoint-clear "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-checkpoint-clear "gastown-checkpoint-clear"
  "Clear checkpoint file.")

;;;###autoload (autoload 'gastown-checkpoint-read "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-checkpoint-read "gastown-checkpoint-read"
  "Read current checkpoint.")

;;;###autoload (autoload 'gastown-checkpoint-write "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-checkpoint-write "gastown-checkpoint-write"
  "Write current checkpoint.")

;;; Checkpoint Dispatch Transient

;;;###autoload (autoload 'gastown-checkpoint-menu "gastown-command-diagnostics" nil t)
(transient-define-prefix gastown-checkpoint-menu ()
  "Manage session checkpoints."
  ["Checkpoint"
   ("r" "Read checkpoint" gastown-checkpoint-read)
   ("w" "Write checkpoint" gastown-checkpoint-write)
   ("c" "Clear checkpoint" gastown-checkpoint-clear)])

;;;###autoload (autoload 'gastown-dashboard "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-dashboard "gastown-dashboard"
  "Show the Gas Town dashboard.")

;;;###autoload (autoload 'gastown-feed "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-feed "gastown-feed"
  "Show activity feed.")

;;;###autoload (autoload 'gastown-heartbeat "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-heartbeat "gastown-heartbeat"
  "Show agent heartbeats.")

;;;###autoload (autoload 'gastown-health "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-health "gastown-health"
  "Show overall health status.")

;;;###autoload (autoload 'gastown-metrics "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-metrics "gastown-metrics"
  "Show performance metrics.")

;;;###autoload (autoload 'gastown-patrol "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-patrol "gastown-patrol"
  "Run patrol checks.")

;;;###autoload (autoload 'gastown-prime "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-prime "gastown-prime"
  "Load full role context.")

;;;###autoload (autoload 'gastown-seance "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-seance "gastown-seance"
  "Investigate past sessions.")

;;;###autoload (autoload 'gastown-stale "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-stale "gastown-stale"
  "Show stale resources.")

;;;###autoload (autoload 'gastown-thanks "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-thanks "gastown-thanks"
  "Send thanks to an agent.")

;;;###autoload (autoload 'gastown-upgrade "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-upgrade "gastown-upgrade"
  "Upgrade Gas Town.")

;;;###autoload (autoload 'gastown-cycle "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-cycle "gastown-cycle"
  "Cycle to a fresh session.")

;;;###autoload (autoload 'gastown-cycle-next "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-cycle-next "gastown-cycle-next"
  "Cycle to next account.")

;;;###autoload (autoload 'gastown-cycle-prev "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-cycle-prev "gastown-cycle-prev"
  "Cycle to previous account.")

;;;###autoload (autoload 'gastown-krc "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-krc "gastown-krc"
  "Show krc information.")

;;;###autoload (autoload 'gastown-tap "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-tap "gastown-tap"
  "Tap into agent output.")

;;;###autoload (autoload 'gastown-town "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-town "gastown-town"
  "Show town information.")

;;;###autoload (autoload 'gastown-warrant "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-warrant "gastown-warrant"
  "Show or manage warrants.")

;;; Diagnostics Dispatch Transient

;;;###autoload (autoload 'gastown-diagnostics "gastown-command-diagnostics" nil t)
(transient-define-prefix gastown-diagnostics ()
  "Gas Town diagnostics and monitoring."
  ["Health & Status"
   ("v" "Vitals" gastown-vitals)
   ("h" "Health" gastown-health)
   ("d" "Doctor (diagnose/fix)" gastown-doctor)
   ("D" "Dashboard" gastown-dashboard)
   ("H" "Heartbeat" gastown-heartbeat)]
  ["Monitoring"
   ("l" "Log" gastown-log)
   ("a" "Activity" gastown-activity)
   ("f" "Feed" gastown-feed)
   ("t" "Trail" gastown-trail)
   ("p" "Patrol" gastown-patrol)]
  ["Information"
   ("i" "Info" gastown-info)
   ("w" "Whoami" gastown-whoami)
   ("V" "Version" gastown-version)
   ("T" "Town" gastown-town)
   ("P" "Prime (context)" gastown-prime)]
  ["Metrics & Costs"
   ("c" "Costs" gastown-costs)
   ("m" "Metrics" gastown-metrics)
   ("s" "Stale" gastown-stale)
   ("A" "Audit" gastown-audit)]
  ["Tools"
   ("C" "Checkpoint" gastown-checkpoint)
   ("S" "Seance" gastown-seance)
   ("k" "Krc" gastown-krc)
   ("e" "Tap" gastown-tap)
   ("g" "Upgrade" gastown-upgrade)
   ("K" "Thanks" gastown-thanks)
   ("W" "Warrant" gastown-warrant)
   ("y" "Cycle" gastown-cycle)])

(provide 'gastown-command-diagnostics)
;;; gastown-command-diagnostics.el ends here
