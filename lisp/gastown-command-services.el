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
(require 'gastown-reader)

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
    :transient-reader gastown-reader-rig-name
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
    :transient-reader gastown-reader-rig-name
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

;;; Extended Dolt Subcommands

(gastown-defcommand gastown-command-dolt-dump (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt dump command.
Dump Dolt server goroutine stacks for debugging."
  :cli-command "dolt dump")


(gastown-defcommand gastown-command-dolt-fix-metadata (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt fix-metadata command.
Update metadata.json in all rig .beads directories."
  :cli-command "dolt fix-metadata")


(gastown-defcommand gastown-command-dolt-flatten (gastown-command-global-options)
  ((database
    :initarg :database
    :type (or null string)
    :initform nil
    :documentation "Database name to flatten (optional, defaults to all)."
    :positional 1
    :option-type :string
    :key "d"
    :transient "Database (optional)"
    :class transient-option
    :prompt "Database (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt dolt flatten command.
Flatten database history to a single commit (NUCLEAR OPTION)."
  :cli-command "dolt flatten")


(gastown-defcommand gastown-command-dolt-init (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt init command.
Initialize and repair Dolt workspace configuration."
  :cli-command "dolt init")


(gastown-defcommand gastown-command-dolt-init-rig (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name to initialize."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt dolt init-rig command.
Initialize a new rig database."
  :cli-command "dolt init-rig")


(gastown-defcommand gastown-command-dolt-kill-imposters (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt kill-imposters command.
Kill dolt servers hijacking this workspace's port."
  :cli-command "dolt kill-imposters")


(gastown-defcommand gastown-command-dolt-list (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt list command.
List available rig databases."
  :cli-command "dolt list")


(gastown-defcommand gastown-command-dolt-logs (gastown-command-global-options)
  ((follow
    :initarg :follow
    :type boolean
    :initform nil
    :documentation "Follow log output."
    :long-option "follow"
    :option-type :boolean
    :key "f"
    :transient "--follow"
    :class transient-switch
    :argument "--follow"
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt dolt logs command.
View Dolt server logs."
  :cli-command "dolt logs")


(gastown-defcommand gastown-command-dolt-migrate (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt migrate command.
Migrate existing dolt databases to centralized data directory."
  :cli-command "dolt migrate")


(gastown-defcommand gastown-command-dolt-migrate-wisps (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt migrate-wisps command.
Migrate agent beads from issues to wisps table."
  :cli-command "dolt migrate-wisps")


(gastown-defcommand gastown-command-dolt-rebase (gastown-command-global-options)
  ((database
    :initarg :database
    :type (or null string)
    :initform nil
    :documentation "Database name to rebase (optional, defaults to all)."
    :positional 1
    :option-type :string
    :key "d"
    :transient "Database (optional)"
    :class transient-option
    :prompt "Database (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt dolt rebase command.
Surgical compaction: squash old commits, keep recent ones."
  :cli-command "dolt rebase")


(gastown-defcommand gastown-command-dolt-recover (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt recover command.
Detect and recover from Dolt read-only state."
  :cli-command "dolt recover")


(gastown-defcommand gastown-command-dolt-restart (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt restart command.
Restart the Dolt server (kills imposters)."
  :cli-command "dolt restart")


(gastown-defcommand gastown-command-dolt-rollback (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt rollback command.
Restore .beads directories from a migration backup."
  :cli-command "dolt rollback")


(gastown-defcommand gastown-command-dolt-sql (gastown-command-global-options)
  ((database
    :initarg :database
    :type (or null string)
    :initform nil
    :documentation "Database to connect to."
    :long-option "db"
    :option-type :string
    :key "d"
    :transient "Database"
    :class transient-option
    :argument "--db="
    :prompt "Database: "
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt dolt sql command.
Open Dolt SQL shell."
  :cli-command "dolt sql")


(gastown-defcommand gastown-command-dolt-sync (gastown-command-global-options)
  ()
  :documentation "Represents gt dolt sync command.
Push Dolt databases to DoltHub remotes."
  :cli-command "dolt sync")


;;; Transients for Extended Dolt Subcommands

;;;###autoload (autoload 'gastown-dolt-dump "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-dump "gastown-dolt-dump"
  "Dump Dolt goroutine stacks.")

;;;###autoload (autoload 'gastown-dolt-fix-metadata "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-fix-metadata "gastown-dolt-fix-metadata"
  "Fix metadata.json files.")

;;;###autoload (autoload 'gastown-dolt-flatten "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-flatten "gastown-dolt-flatten"
  "Flatten database history (NUCLEAR).")

;;;###autoload (autoload 'gastown-dolt-init "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-init "gastown-dolt-init"
  "Initialize Dolt workspace.")

;;;###autoload (autoload 'gastown-dolt-init-rig "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-init-rig "gastown-dolt-init-rig"
  "Initialize new rig database.")

;;;###autoload (autoload 'gastown-dolt-kill-imposters "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-kill-imposters "gastown-dolt-kill-imposters"
  "Kill imposter Dolt servers.")

;;;###autoload (autoload 'gastown-dolt-list "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-list "gastown-dolt-list"
  "List Dolt databases.")

;;;###autoload (autoload 'gastown-dolt-logs "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-logs "gastown-dolt-logs"
  "View Dolt server logs.")

;;;###autoload (autoload 'gastown-dolt-migrate "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-migrate "gastown-dolt-migrate"
  "Migrate Dolt databases.")

;;;###autoload (autoload 'gastown-dolt-migrate-wisps "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-migrate-wisps "gastown-dolt-migrate-wisps"
  "Migrate wisps table.")

;;;###autoload (autoload 'gastown-dolt-rebase "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-rebase "gastown-dolt-rebase"
  "Rebase Dolt history.")

;;;###autoload (autoload 'gastown-dolt-recover "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-recover "gastown-dolt-recover"
  "Recover from read-only state.")

;;;###autoload (autoload 'gastown-dolt-restart "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-restart "gastown-dolt-restart"
  "Restart Dolt server.")

;;;###autoload (autoload 'gastown-dolt-rollback "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-rollback "gastown-dolt-rollback"
  "Rollback Dolt migration.")

;;;###autoload (autoload 'gastown-dolt-sql "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-sql "gastown-dolt-sql"
  "Open Dolt SQL shell.")

;;;###autoload (autoload 'gastown-dolt-sync "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-dolt-sync "gastown-dolt-sync"
  "Sync to DoltHub.")

;;; Dolt Dispatch Transient

;;;###autoload (autoload 'gastown-dolt-menu "gastown-command-services" nil t)
(transient-define-prefix gastown-dolt-menu ()
  "Manage the Dolt SQL server."
  ["Dolt Server"
   ("s" "Status" gastown-dolt-status)
   ("l" "Logs" gastown-dolt-logs)
   ("L" "List databases" gastown-dolt-list)]
  ["Lifecycle"
   ("S" "Start server" gastown-dolt-start)
   ("x" "Stop server" gastown-dolt-stop)
   ("r" "Restart server" gastown-dolt-restart)
   ("k" "Kill imposters" gastown-dolt-kill-imposters)]
  ["Maintenance"
   ("c" "Cleanup orphans" gastown-dolt-cleanup)
   ("R" "Rebase history" gastown-dolt-rebase)
   ("m" "Migrate" gastown-dolt-migrate)
   ("w" "Migrate wisps" gastown-dolt-migrate-wisps)
   ("y" "Sync to DoltHub" gastown-dolt-sync)]
  ["Diagnostics"
   ("d" "Dump stacks" gastown-dolt-dump)
   ("v" "Recover" gastown-dolt-recover)
   ("q" "SQL shell" gastown-dolt-sql)]
  ["Setup"
   ("i" "Init workspace" gastown-dolt-init)
   ("I" "Init rig" gastown-dolt-init-rig)
   ("f" "Fix metadata" gastown-dolt-fix-metadata)]
  ["Danger"
   ("F" "Flatten history (NUCLEAR)" gastown-dolt-flatten)
   ("b" "Rollback migration" gastown-dolt-rollback)])


;;; Quota Subcommands

(gastown-defcommand gastown-command-quota-clear (gastown-command-global-options)
  ((handle
    :initarg :handle
    :type (or null string)
    :initform nil
    :documentation "Account handle to clear (optional, clears all if omitted)."
    :positional 1
    :option-type :string
    :key "h"
    :transient "Handle (optional)"
    :class transient-option
    :prompt "Handle (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt quota clear command.
Mark account(s) as available again."
  :cli-command "quota clear")


(gastown-defcommand gastown-command-quota-rotate (gastown-command-global-options)
  ()
  :documentation "Represents gt quota rotate command.
Swap blocked sessions to available accounts."
  :cli-command "quota rotate")


(gastown-defcommand gastown-command-quota-scan (gastown-command-global-options)
  ()
  :documentation "Represents gt quota scan command.
Detect rate-limited sessions."
  :cli-command "quota scan")


(gastown-defcommand gastown-command-quota-status (gastown-command-global-options)
  ()
  :documentation "Represents gt quota status command.
Show account quota status."
  :cli-command "quota status")


(gastown-defcommand gastown-command-quota-watch (gastown-command-global-options)
  ()
  :documentation "Represents gt quota watch command.
Monitor sessions and rotate proactively before hard 429."
  :cli-command "quota watch")


;;; Transients for Quota Subcommands

;;;###autoload (autoload 'gastown-quota-clear "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota-clear "gastown-quota-clear"
  "Mark accounts as available.")

;;;###autoload (autoload 'gastown-quota-rotate "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota-rotate "gastown-quota-rotate"
  "Rotate blocked sessions.")

;;;###autoload (autoload 'gastown-quota-scan "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota-scan "gastown-quota-scan"
  "Scan for rate-limited sessions.")

;;;###autoload (autoload 'gastown-quota-status "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota-status "gastown-quota-status"
  "Show quota status.")

;;;###autoload (autoload 'gastown-quota-watch "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-quota-watch "gastown-quota-watch"
  "Watch and rotate proactively.")

;;; Quota Dispatch Transient

;;;###autoload (autoload 'gastown-quota-menu "gastown-command-services" nil t)
(transient-define-prefix gastown-quota-menu ()
  "Manage account quota rotation."
  ["Status"
   ("s" "Quota status" gastown-quota-status)
   ("S" "Scan sessions" gastown-quota-scan)]
  ["Actions"
   ("r" "Rotate sessions" gastown-quota-rotate)
   ("c" "Clear account" gastown-quota-clear)
   ("w" "Watch and rotate" gastown-quota-watch)])


;;; Scheduler Subcommands

(gastown-defcommand gastown-command-scheduler-clear (gastown-command-global-options)
  ((bead-id
    :initarg :bead-id
    :type (or null string)
    :initform nil
    :documentation "Bead ID to remove from scheduler (optional, clears all if omitted)."
    :positional 1
    :option-type :string
    :key "b"
    :transient "Bead ID (optional)"
    :class transient-option
    :prompt "Bead ID (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt scheduler clear command.
Remove beads from the scheduler."
  :cli-command "scheduler clear")


(gastown-defcommand gastown-command-scheduler-list (gastown-command-global-options)
  ()
  :documentation "Represents gt scheduler list command.
List all scheduled beads with titles, rig, blocked status."
  :cli-command "scheduler list")


(gastown-defcommand gastown-command-scheduler-pause (gastown-command-global-options)
  ()
  :documentation "Represents gt scheduler pause command.
Pause all scheduler dispatch (town-wide)."
  :cli-command "scheduler pause")


(gastown-defcommand gastown-command-scheduler-resume (gastown-command-global-options)
  ()
  :documentation "Represents gt scheduler resume command.
Resume scheduler dispatch."
  :cli-command "scheduler resume")


(gastown-defcommand gastown-command-scheduler-run (gastown-command-global-options)
  ()
  :documentation "Represents gt scheduler run command.
Manually trigger scheduler dispatch."
  :cli-command "scheduler run")


(gastown-defcommand gastown-command-scheduler-status (gastown-command-global-options)
  ()
  :documentation "Represents gt scheduler status command.
Show scheduler state: pending, capacity, active polecats."
  :cli-command "scheduler status")


;;; Transients for Scheduler Subcommands

;;;###autoload (autoload 'gastown-scheduler-clear "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-clear "gastown-scheduler-clear"
  "Remove beads from scheduler.")

;;;###autoload (autoload 'gastown-scheduler-list "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-list "gastown-scheduler-list"
  "List scheduled beads.")

;;;###autoload (autoload 'gastown-scheduler-pause "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-pause "gastown-scheduler-pause"
  "Pause scheduler.")

;;;###autoload (autoload 'gastown-scheduler-resume "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-resume "gastown-scheduler-resume"
  "Resume scheduler.")

;;;###autoload (autoload 'gastown-scheduler-run "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-run "gastown-scheduler-run"
  "Trigger scheduler dispatch.")

;;;###autoload (autoload 'gastown-scheduler-status "gastown-command-services" nil t)
(beads-meta-define-transient gastown-command-scheduler-status "gastown-scheduler-status"
  "Show scheduler status.")

;;; Scheduler Dispatch Transient

;;;###autoload (autoload 'gastown-scheduler-menu "gastown-command-services" nil t)
(transient-define-prefix gastown-scheduler-menu ()
  "Manage the capacity-controlled dispatch scheduler."
  ["Status"
   ("s" "Scheduler status" gastown-scheduler-status)
   ("l" "List scheduled" gastown-scheduler-list)]
  ["Control"
   ("r" "Run dispatch" gastown-scheduler-run)
   ("p" "Pause" gastown-scheduler-pause)
   ("R" "Resume" gastown-scheduler-resume)
   ("c" "Clear beads" gastown-scheduler-clear)])


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
   ("q" "Quota..." gastown-quota-menu)
   ("H" "Scheduler..." gastown-scheduler-menu)])

(provide 'gastown-command-services)
;;; gastown-command-services.el ends here
