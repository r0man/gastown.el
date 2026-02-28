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
  (gastown-defcommand gastown-command-vitals (gastown-command-json)
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
  (gastown-defcommand gastown-command-activity (gastown-command-json)
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
  (gastown-defcommand gastown-command-info (gastown-command-json)
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
  (gastown-defcommand gastown-command-costs (gastown-command-json)
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
  (gastown-defcommand gastown-command-trail (gastown-command-json)
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

;;; Diagnostics Dispatch Transient

;;;###autoload (autoload 'gastown-diagnostics "gastown-command-diagnostics" nil t)
(transient-define-prefix gastown-diagnostics ()
  "Gas Town diagnostics and monitoring."
  ["Diagnostics"
   ("v" "Vitals (health dashboard)" gastown-vitals)
   ("d" "Doctor (diagnose/fix)" gastown-doctor)
   ("l" "Log" gastown-log)
   ("a" "Activity" gastown-activity)
   ("t" "Trail" gastown-trail)]
  ["Information"
   ("i" "Info" gastown-info)
   ("w" "Whoami" gastown-whoami)
   ("c" "Costs" gastown-costs)
   ("V" "Version" gastown-version)])

(provide 'gastown-command-diagnostics)
;;; gastown-command-diagnostics.el ends here
