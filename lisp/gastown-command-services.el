;;; gastown-command-services.el --- Service management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for service management commands:
;; gt up, gt down, gt daemon, gt start, gt shutdown, etc.
;; These are simple commands that run in terminal by default.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Up Command

(gastown-defcommand gastown-command-up (gastown-command-global-options)
  ()
  :documentation "Represents gt up command.
Brings up all Gas Town services.")


;;; Down Command

(gastown-defcommand gastown-command-down (gastown-command-global-options)
  ()
  :documentation "Represents gt down command.
Stops all Gas Town services.")


;;; Shutdown Command

(gastown-defcommand gastown-command-shutdown (gastown-command-global-options)
  ((force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force shutdown without cleanup"
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "Force shutdown without cleanup"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt shutdown command.
Shutdown Gas Town with cleanup.")


;;; Daemon Status Command

(gastown-defcommand gastown-command-daemon-status (gastown-command-global-options)
  ()
  :documentation "Represents gt daemon status command.
Shows the Gas Town daemon status.")


;;; Transient Menus

;;;###autoload (autoload 'gastown-up "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-up "gastown-up"
  "Bring up all Gas Town services.")

;;;###autoload (autoload 'gastown-down "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-down "gastown-down"
  "Stop all Gas Town services.")

;;;###autoload (autoload 'gastown-shutdown "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-shutdown "gastown-shutdown"
  "Shutdown Gas Town with cleanup.")

;;;###autoload (autoload 'gastown-daemon-status "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-status "gastown-daemon-status"
  "Show Gas Town daemon status.")

;;; Daemon Subcommands

(gastown-defcommand gastown-command-daemon-start (gastown-command-global-options)
  ()
  :documentation "Represents gt daemon start command.
Start the Gas Town daemon in the background."
  :cli-command "daemon start")


(gastown-defcommand gastown-command-daemon-stop (gastown-command-global-options)
  ()
  :documentation "Represents gt daemon stop command.
Stop the running Gas Town daemon."
  :cli-command "daemon stop")


(gastown-defcommand gastown-command-daemon-logs (gastown-command-global-options)
  ((lines
    :initarg :lines
    :type (or null string)
    :initform nil
    :documentation "Number of lines to show."
    :long-option "lines"
    :option-type :string
    :key "n"
    :transient "Lines to show"
    :class transient-option
    :argument "--lines="
    :prompt "Lines: "
    :transient-group "Options"
    :level 1
    :order 1)
   (follow
    :initarg :follow
    :type boolean
    :initform nil
    :documentation "Follow log output in real time."
    :long-option "follow"
    :option-type :boolean
    :key "f"
    :transient "--follow"
    :class transient-switch
    :argument "--follow"
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt daemon logs command.
View the daemon log file."
  :cli-command "daemon logs")


(gastown-defcommand gastown-command-daemon-rotate-logs (gastown-command-global-options)
  ((force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Rotate all logs regardless of size."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt daemon rotate-logs command.
Rotate all daemon-managed log files."
  :cli-command "daemon rotate-logs")


(gastown-defcommand gastown-command-daemon-clear-backoff (gastown-command-global-options)
  ((agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent name to clear backoff for."
    :positional 1
    :option-type :string
    :key "a"
    :transient "Agent name (required)"
    :class transient-option
    :prompt "Agent: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt daemon clear-backoff command.
Clear crash loop backoff for an agent."
  :cli-command "daemon clear-backoff")


(gastown-defcommand gastown-command-daemon-enable-supervisor (gastown-command-global-options)
  ()
  :documentation "Represents gt daemon enable-supervisor command.
Configure launchd/systemd for daemon auto-restart."
  :cli-command "daemon enable-supervisor")


;;; Transients for Daemon Subcommands

;;;###autoload (autoload 'gastown-daemon-start "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-start "gastown-daemon-start"
  "Start the Gas Town daemon.")

;;;###autoload (autoload 'gastown-daemon-stop "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-stop "gastown-daemon-stop"
  "Stop the Gas Town daemon.")

;;;###autoload (autoload 'gastown-daemon-logs "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-logs "gastown-daemon-logs"
  "View daemon logs.")

;;;###autoload (autoload 'gastown-daemon-rotate-logs "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-rotate-logs "gastown-daemon-rotate-logs"
  "Rotate daemon log files.")

;;;###autoload (autoload 'gastown-daemon-clear-backoff "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-clear-backoff "gastown-daemon-clear-backoff"
  "Clear crash loop backoff for an agent.")

;;;###autoload (autoload 'gastown-daemon-enable-supervisor "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-daemon-enable-supervisor "gastown-daemon-enable-supervisor"
  "Configure launchd/systemd for daemon auto-restart.")

;;; Daemon Dispatch Transient

;;;###autoload (autoload 'gastown-daemon-menu "gastown-command-services" nil t)
(transient-define-prefix gastown-daemon-menu ()
  "Manage the Gas Town background daemon."
  ["Daemon Status"
   ("s" "Status" gastown-daemon-status)
   ("l" "Logs" gastown-daemon-logs)]
  ["Daemon Lifecycle"
   ("S" "Start daemon" gastown-daemon-start)
   ("x" "Stop daemon" gastown-daemon-stop)]
  ["Maintenance"
   ("r" "Rotate logs" gastown-daemon-rotate-logs)
   ("c" "Clear backoff" gastown-daemon-clear-backoff)
   ("e" "Enable supervisor" gastown-daemon-enable-supervisor)])

;;; Emergency Stop Commands

(gastown-defcommand gastown-command-estop (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Freeze only this rig instead of the whole town."
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Scope"
    :level 1
    :order 1)
   (reason
    :initarg :reason
    :type (or null string)
    :initform nil
    :documentation "Reason for the emergency stop."
    :long-option "reason"
    :option-type :string
    :key "m"
    :transient "Reason"
    :class transient-option
    :argument "--reason="
    :prompt "Reason: "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt estop command.
Emergency stop — freeze all agent sessions.")


(gastown-defcommand gastown-command-thaw (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Thaw only this rig instead of the whole town."
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Scope"
    :level 1
    :order 1))
  :documentation "Represents gt thaw command.
Resume agent sessions frozen by gt estop.")


;;; Transients for Emergency Stop Commands

;;;###autoload (autoload 'gastown-estop "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-estop "gastown-estop"
  "Emergency stop — freeze all agents.")

;;;###autoload (autoload 'gastown-thaw "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-thaw "gastown-thaw"
  "Resume agents frozen by estop.")

;;; Additional Service Commands

(gastown-defcommand gastown-command-dolt (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt command.
Manage the Dolt database server.")


(gastown-defcommand gastown-command-maintain (gastown-command-global-options)
  ()
  :documentation "Represents gt maintain command.
Run maintenance tasks.")


(gastown-defcommand gastown-command-quota (gastown-command-global-options)
  ()
  :documentation "Represents gt quota command.
Show or manage resource quotas.")


(gastown-defcommand gastown-command-reaper (gastown-command-global-options)
  ()
  :documentation "Represents gt reaper command.
Manage the reaper process.")


(gastown-defcommand gastown-command-start (gastown-command-global-options)
  ()
  :documentation "Represents gt start command.
Start a specific service.")


;;; Transients for Additional Service Commands

;;;###autoload (autoload 'gastown-dolt "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt "gastown-dolt"
  "Manage the Dolt database server.")

;;;###autoload (autoload 'gastown-maintain "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-maintain "gastown-maintain"
  "Run maintenance tasks.")

;;;###autoload (autoload 'gastown-quota "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota "gastown-quota"
  "Show or manage resource quotas.")

;;;###autoload (autoload 'gastown-reaper "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-reaper "gastown-reaper"
  "Manage the reaper process.")

;;;###autoload (autoload 'gastown-start "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-start "gastown-start"
  "Start a specific service.")

;;; Dolt Subcommands

(gastown-defcommand gastown-command-dolt-status (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt status command.
Show Dolt server status."
  :cli-command "dolt status")


(gastown-defcommand gastown-command-dolt-start (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt start command.
Start the Dolt server."
  :cli-command "dolt start")


(gastown-defcommand gastown-command-dolt-stop (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt stop command.
Stop the Dolt server."
  :cli-command "dolt stop")


(gastown-defcommand gastown-command-dolt-cleanup (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt cleanup command.
Remove orphaned databases from .dolt-data/."
  :cli-command "dolt cleanup")


;;; Transients for Dolt Subcommands

;;;###autoload (autoload 'gastown-dolt-status "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-status "gastown-dolt-status"
  "Show Dolt server status.")

;;;###autoload (autoload 'gastown-dolt-start "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-start "gastown-dolt-start"
  "Start the Dolt server.")

;;;###autoload (autoload 'gastown-dolt-stop "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-stop "gastown-dolt-stop"
  "Stop the Dolt server.")

;;;###autoload (autoload 'gastown-dolt-cleanup "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-cleanup "gastown-dolt-cleanup"
  "Remove orphaned Dolt databases.")

;;; Dolt Dispatch Transient

;;;###autoload (autoload 'gastown-dolt-menu "gastown-command-services" nil t)
(transient-define-prefix gastown-dolt-menu ()
  "Manage the Dolt SQL server."
  ["Dolt Server"
   ("s" "Status" gastown-dolt-status)
   ("S" "Start server" gastown-dolt-start)
   ("x" "Stop server" gastown-dolt-stop)
   ("c" "Cleanup orphans" gastown-dolt-cleanup)])

;;; Services Dispatch Transient

;;;###autoload (autoload 'gastown-services "gastown-command-services" nil t)
(transient-define-prefix gastown-services ()
  "Manage Gas Town services."
  ["Lifecycle"
   ("u" "Up (start all)" gastown-up)
   ("d" "Down (stop all)" gastown-down)
   ("s" "Start service" gastown-start)
   ("S" "Shutdown (with cleanup)" gastown-shutdown)]
  ["Emergency"
   ("E" "E-stop (freeze all)" gastown-estop)
   ("T" "Thaw (resume frozen)" gastown-thaw)]
  ["Management"
   ("D" "Daemon..." gastown-daemon-menu)
   ("o" "Dolt server..." gastown-dolt-menu)
   ("m" "Maintain" gastown-maintain)
   ("r" "Reaper" gastown-reaper)
   ("q" "Quota" gastown-quota)])

(provide 'gastown-command-services)
;;; gastown-command-services.el ends here
