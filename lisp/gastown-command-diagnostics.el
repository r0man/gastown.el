;;; gastown-command-diagnostics.el --- Diagnostic commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for diagnostic commands:
;; gt vitals, gt doctor, gt log, gt activity, gt info, gt whoami, etc.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Vitals Command

(eval-and-compile
  (gastown-defcommand gastown-command-vitals (gastown-command)
    ()
    :documentation "Represents gt vitals command.
Shows unified health dashboard."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-vitals))
  "Return \"vitals\" as the CLI subcommand name."
  "vitals")

;;; Doctor Command

(eval-and-compile
  (gastown-defcommand gastown-command-doctor (gastown-command)
    ((fix
      :initarg :fix
      :type boolean
      :initform nil
      :documentation "Attempt to fix issues (--fix)."
      :long-option "fix"
      :option-type :boolean
      :key "f"
      :transient "--fix"
      :class transient-switch
      :argument "--fix"
      :transient-group "Options"
      :level 1
      :order 1))
    :documentation "Represents gt doctor command.
Diagnose and optionally fix Gas Town issues."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-doctor))
  "Return \"doctor\" as the CLI subcommand name."
  "doctor")

;;; Log Command

(eval-and-compile
  (gastown-defcommand gastown-command-log (gastown-command)
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
     (lines
      :initarg :lines
      :type (or null integer)
      :initform nil
      :documentation "Number of log lines (-n, --lines)."
      :long-option "lines"
      :short-option "n"
      :option-type :integer
      :key "n"
      :transient "--lines"
      :class transient-option
      :argument "--lines="
      :prompt "Lines: "
      :transient-group "Options"
      :level 2
      :order 2)
     (follow
      :initarg :follow
      :type boolean
      :initform nil
      :documentation "Follow log output (-f, --follow)."
      :long-option "follow"
      :short-option "f"
      :option-type :boolean
      :key "f"
      :transient "--follow"
      :class transient-switch
      :argument "--follow"
      :transient-group "Options"
      :level 1
      :order 3))
    :documentation "Represents gt log command.
Show Gas Town logs."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-log))
  "Return \"log\" as the CLI subcommand name."
  "log")

;;; Activity Command

(eval-and-compile
  (gastown-defcommand gastown-command-activity (gastown-command)
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
    :documentation "Represents gt activity command.
Show recent agent activity."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-activity))
  "Return \"activity\" as the CLI subcommand name."
  "activity")

;;; Info Command

(eval-and-compile
  (gastown-defcommand gastown-command-info (gastown-command)
    ()
    :documentation "Represents gt info command.
Show Gas Town workspace information."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-info))
  "Return \"info\" as the CLI subcommand name."
  "info")

;;; Whoami Command

(eval-and-compile
  (gastown-defcommand gastown-command-whoami (gastown-command)
    ()
    :documentation "Represents gt whoami command.
Show current identity for mail commands."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-whoami))
  "Return \"whoami\" as the CLI subcommand name."
  "whoami")

;;; Costs Command

(eval-and-compile
  (gastown-defcommand gastown-command-costs (gastown-command)
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
    :documentation "Represents gt costs command.
Show cost metrics."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-costs))
  "Return \"costs\" as the CLI subcommand name."
  "costs")

;;; Trail Command

(eval-and-compile
  (gastown-defcommand gastown-command-trail (gastown-command)
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
    :documentation "Represents gt trail command.
Show recent agent activity trail."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-trail))
  "Return \"trail\" as the CLI subcommand name."
  "trail")

;;; Version Command

(eval-and-compile
  (gastown-defcommand gastown-command-version (gastown-command)
    ()
    :documentation "Represents gt version command.
Print version information."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-version))
  "Return \"version\" as the CLI subcommand name."
  "version")

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

(eval-and-compile
  (gastown-defcommand gastown-command-audit (gastown-command)
    ()
    :documentation "Represents gt audit command.
Audit Gas Town configuration and state."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-audit))
  "Return \"audit\" as the CLI subcommand name."
  "audit")

(eval-and-compile
  (gastown-defcommand gastown-command-checkpoint (gastown-command)
    ()
    :documentation "Represents gt checkpoint command.
Create a checkpoint snapshot."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-checkpoint))
  "Return \"checkpoint\" as the CLI subcommand name."
  "checkpoint")

(eval-and-compile
  (gastown-defcommand gastown-command-dashboard (gastown-command)
    ()
    :documentation "Represents gt dashboard command.
Show the Gas Town dashboard."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-dashboard))
  "Return \"dashboard\" as the CLI subcommand name."
  "dashboard")

(eval-and-compile
  (gastown-defcommand gastown-command-feed (gastown-command)
    ()
    :documentation "Represents gt feed command.
Show activity feed."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-feed))
  "Return \"feed\" as the CLI subcommand name."
  "feed")

(eval-and-compile
  (gastown-defcommand gastown-command-heartbeat (gastown-command)
    ()
    :documentation "Represents gt heartbeat command.
Show agent heartbeats."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-heartbeat))
  "Return \"heartbeat\" as the CLI subcommand name."
  "heartbeat")

(eval-and-compile
  (gastown-defcommand gastown-command-health (gastown-command)
    ()
    :documentation "Represents gt health command.
Show overall health status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-health))
  "Return \"health\" as the CLI subcommand name."
  "health")

(eval-and-compile
  (gastown-defcommand gastown-command-metrics (gastown-command)
    ()
    :documentation "Represents gt metrics command.
Show performance metrics."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-metrics))
  "Return \"metrics\" as the CLI subcommand name."
  "metrics")

(eval-and-compile
  (gastown-defcommand gastown-command-patrol (gastown-command)
    ()
    :documentation "Represents gt patrol command.
Run patrol checks."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-patrol))
  "Return \"patrol\" as the CLI subcommand name."
  "patrol")

(eval-and-compile
  (gastown-defcommand gastown-command-prime (gastown-command)
    ()
    :documentation "Represents gt prime command.
Load full role context."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-prime))
  "Return \"prime\" as the CLI subcommand name."
  "prime")

(eval-and-compile
  (gastown-defcommand gastown-command-seance (gastown-command)
    ()
    :documentation "Represents gt seance command.
Investigate past sessions."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-seance))
  "Return \"seance\" as the CLI subcommand name."
  "seance")

(eval-and-compile
  (gastown-defcommand gastown-command-stale (gastown-command)
    ()
    :documentation "Represents gt stale command.
Show stale resources."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-stale))
  "Return \"stale\" as the CLI subcommand name."
  "stale")

(eval-and-compile
  (gastown-defcommand gastown-command-thanks (gastown-command)
    ()
    :documentation "Represents gt thanks command.
Send thanks to an agent."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-thanks))
  "Return \"thanks\" as the CLI subcommand name."
  "thanks")

(eval-and-compile
  (gastown-defcommand gastown-command-upgrade (gastown-command)
    ()
    :documentation "Represents gt upgrade command.
Upgrade Gas Town."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-upgrade))
  "Return \"upgrade\" as the CLI subcommand name."
  "upgrade")

;;; Additional Misc Commands

(eval-and-compile
  (gastown-defcommand gastown-command-cycle (gastown-command)
    ()
    :documentation "Represents gt cycle command.
Cycle to a fresh session."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-cycle))
  "Return \"cycle\" as the CLI subcommand name."
  "cycle")

(eval-and-compile
  (gastown-defcommand gastown-command-krc (gastown-command)
    ()
    :documentation "Represents gt krc command.
Show krc information."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-krc))
  "Return \"krc\" as the CLI subcommand name."
  "krc")

(eval-and-compile
  (gastown-defcommand gastown-command-tap (gastown-command)
    ()
    :documentation "Represents gt tap command.
Tap into agent output."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-tap))
  "Return \"tap\" as the CLI subcommand name."
  "tap")

(eval-and-compile
  (gastown-defcommand gastown-command-town (gastown-command)
    ()
    :documentation "Represents gt town command.
Show town information."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-town))
  "Return \"town\" as the CLI subcommand name."
  "town")

(eval-and-compile
  (gastown-defcommand gastown-command-warrant (gastown-command)
    ()
    :documentation "Represents gt warrant command.
Show or manage warrants."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-warrant))
  "Return \"warrant\" as the CLI subcommand name."
  "warrant")

;;; Transients for Additional Diagnostic Commands

;;;###autoload (autoload 'gastown-audit "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-audit "gastown-audit"
  "Audit Gas Town configuration and state.")

;;;###autoload (autoload 'gastown-checkpoint "gastown-command-diagnostics" nil t)
(beads-meta-define-transient gastown-command-checkpoint "gastown-checkpoint"
  "Create a checkpoint snapshot.")

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
