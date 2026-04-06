;;; gastown-command-rig.el --- Rig management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt rig' subcommands.
;; Provides rig listing, docking, undocking, and management.

;;; Code:

(require 'gastown-command)
(require 'gastown-reader)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Rig List Command

(gastown-defcommand gastown-command-rig-list (gastown-command-global-options)
  ((status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Filter by rig status"
    :long-option "status"
    :option-type :string
    :transient-key "s"
    :transient transient-option
    :argument "--status="
    :prompt "Status: "
    :transient-choices ("operational" "degraded" "docked" "parked")
    :transient-group "Filters"
    :level 1
    :order 1)
   (order
    :initarg :order
    :type (or null string)
    :initform nil
    :documentation "Sort order"
    :long-option "order"
    :option-type :string
    :transient-key "o"
    :transient transient-option
    :argument "--order="
    :prompt "Order: "
    :transient-choices ("name" "status")
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt rig list command.
Lists all rigs in the workspace with status, polecat count, and crew count.")


;;; Rig Dock Command

(gastown-defcommand gastown-command-rig-dock (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to dock."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt rig dock command.
Docks a rig (makes it active).")


;;; Rig Undock Command

(gastown-defcommand gastown-command-rig-undock (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to undock."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt rig undock command.
Undocks a rig (makes it inactive).")


;;; Rig Park Command

(gastown-defcommand gastown-command-rig-park (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to park."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt rig park command.
Parks a rig (pauses all workers).")


;;; Rig Unpark Command

(gastown-defcommand gastown-command-rig-unpark (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to unpark."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt rig unpark command.
Unparks a rig (resumes workers).")


;;; Rig Start Command

(gastown-defcommand gastown-command-rig-start (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to start."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig start command.
Start witness and refinery on patrol for one or more rigs."
  :cli-command "rig start")


;;; Rig Stop Command

(gastown-defcommand gastown-command-rig-stop (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to stop."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig stop command.
Stop one or more rigs (shutdown semantics)."
  :cli-command "rig stop")


;;; Rig Restart Command

(gastown-defcommand gastown-command-rig-restart (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to restart."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig restart command.
Restart one or more rigs (stop then start)."
  :cli-command "rig restart")


;;; Rig Reboot Command

(gastown-defcommand gastown-command-rig-reboot (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to reboot."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig reboot command.
Restart witness and refinery for a rig."
  :cli-command "rig reboot")


;;; Rig Status Command

(gastown-defcommand gastown-command-rig-status (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to show status for."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig status command.
Show detailed status for a specific rig."
  :cli-command "rig status")


;;; Rig Add Command

(gastown-defcommand gastown-command-rig-add (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Rig name."
    :positional 1
    :option-type :string
    :transient-key "n"
    :transient transient-option
    :prompt "Rig name: "
    :transient-group "Required"
    :level 1
    :order 1)
   (git-url
    :initarg :git-url
    :type (or null string)
    :initform nil
    :documentation "Git repository URL."
    :positional 2
    :option-type :string
    :transient-key "u"
    :transient transient-option
    :prompt "Git URL: "
    :transient-group "Required"
    :level 1
    :order 2)
   (prefix
    :initarg :prefix
    :type (or null string)
    :initform nil
    :documentation "Beads issue prefix."
    :long-option "prefix"
    :option-type :string
    :transient-key "p"
    :transient transient-option
    :argument "--prefix="
    :prompt "Prefix: "
    :transient-group "Options"
    :level 2
    :order 3)
   (adopt
    :initarg :adopt
    :type boolean
    :initform nil
    :documentation "Adopt existing directory instead of creating new."
    :long-option "adopt"
    :option-type :boolean
    :transient-key "a"
    :transient transient-switch
    :argument "--adopt"
    :transient-group "Options"
    :level 2
    :order 4))
  :documentation "Represents gt rig add command.
Add a new rig by cloning a repository."
  :cli-command "rig add")


;;; Rig Boot Command

(gastown-defcommand gastown-command-rig-boot (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to boot."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt rig boot command.
Start witness and refinery for a rig."
  :cli-command "rig boot")


;;; Rig Config Command

(gastown-defcommand gastown-command-rig-config (gastown-command-global-options)
  ()
  :documentation "Represents gt rig config command.
View and manage rig configuration across property layers."
  :cli-command "rig config")


;;; Rig Remove Command

(gastown-defcommand gastown-command-rig-remove (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to remove."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Kill running sessions before removing."
    :long-option "force"
    :option-type :boolean
    :transient-key "f"
    :transient transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt rig remove command.
Remove a rig from the registry (does not delete files)."
  :cli-command "rig remove")


;;; Rig Reset Command

(gastown-defcommand gastown-command-rig-reset (gastown-command-global-options)
  ((handoff
    :initarg :handoff
    :type boolean
    :initform nil
    :documentation "Clear handoff content only."
    :long-option "handoff"
    :option-type :boolean
    :transient-key "H"
    :transient transient-switch
    :argument "--handoff"
    :transient-group "Reset Targets"
    :level 1
    :order 1)
   (mail
    :initarg :mail
    :type boolean
    :initform nil
    :documentation "Clear stale mail messages only."
    :long-option "mail"
    :option-type :boolean
    :transient-key "m"
    :transient transient-switch
    :argument "--mail"
    :transient-group "Reset Targets"
    :level 1
    :order 2)
   (stale
    :initarg :stale
    :type boolean
    :initform nil
    :documentation "Reset orphaned in_progress issues."
    :long-option "stale"
    :option-type :boolean
    :transient-key "s"
    :transient transient-switch
    :argument "--stale"
    :transient-group "Reset Targets"
    :level 1
    :order 3)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be reset without making changes."
    :long-option "dry-run"
    :option-type :boolean
    :transient-key "d"
    :transient transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 4))
  :documentation "Represents gt rig reset command.
Reset rig state (handoff content, mail, stale issues)."
  :cli-command "rig reset")


;;; Rig Settings Command

(gastown-defcommand gastown-command-rig-settings (gastown-command-global-options)
  ()
  :documentation "Represents gt rig settings command.
View and manage rig settings (settings/config.json)."
  :cli-command "rig settings")


;;; Rig Shutdown Command

(gastown-defcommand gastown-command-rig-shutdown (gastown-command-global-options)
  ((rig-name
    :initarg :rig-name
    :type (or null string)
    :initform nil
    :documentation "Rig name to shutdown."
    :positional 1
    :option-type :string
    :transient-key "r"
    :transient transient-option
    :prompt "Rig name: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force immediate shutdown."
    :long-option "force"
    :option-type :boolean
    :transient-key "f"
    :transient transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2)
   (nuclear
    :initarg :nuclear
    :type boolean
    :initform nil
    :documentation "DANGER: Bypass ALL safety checks (loses uncommitted work!)."
    :long-option "nuclear"
    :option-type :boolean
    :transient-key "N"
    :transient transient-switch
    :argument "--nuclear"
    :transient-group "Options"
    :level 3
    :order 3))
  :documentation "Represents gt rig shutdown command.
Gracefully stop all rig agents."
  :cli-command "rig shutdown")


;;; Transient Menus

;;;###autoload (autoload 'gastown-rig-list "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-list "gastown-rig-list"
  "List all rigs in the workspace.")

;;;###autoload (autoload 'gastown-rig-dock "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-dock "gastown-rig-dock"
  "Dock a rig (make it active).")

;;;###autoload (autoload 'gastown-rig-undock "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-undock "gastown-rig-undock"
  "Undock a rig (make it inactive).")

;;;###autoload (autoload 'gastown-rig-park "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-park "gastown-rig-park"
  "Park a rig (pause all workers).")

;;;###autoload (autoload 'gastown-rig-unpark "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-unpark "gastown-rig-unpark"
  "Unpark a rig (resume workers).")

;;;###autoload (autoload 'gastown-rig-start "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-start "gastown-rig-start"
  "Start witness and refinery for a rig.")

;;;###autoload (autoload 'gastown-rig-stop "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-stop "gastown-rig-stop"
  "Stop a rig (shutdown semantics).")

;;;###autoload (autoload 'gastown-rig-restart "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-restart "gastown-rig-restart"
  "Restart a rig (stop then start).")

;;;###autoload (autoload 'gastown-rig-reboot "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-reboot "gastown-rig-reboot"
  "Reboot witness and refinery for a rig.")

;;;###autoload (autoload 'gastown-rig-status "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-status "gastown-rig-status"
  "Show detailed status for a rig.")

;;;###autoload (autoload 'gastown-rig-add "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-add "gastown-rig-add"
  "Add a new rig by cloning a repository.")

;;;###autoload (autoload 'gastown-rig-boot "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-boot "gastown-rig-boot"
  "Start witness and refinery for a rig.")

;;;###autoload (autoload 'gastown-rig-config "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-config "gastown-rig-config"
  "View and manage rig configuration.")

;;;###autoload (autoload 'gastown-rig-remove "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-remove "gastown-rig-remove"
  "Remove a rig from the registry.")

;;;###autoload (autoload 'gastown-rig-reset "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-reset "gastown-rig-reset"
  "Reset rig state.")

;;;###autoload (autoload 'gastown-rig-settings "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-settings "gastown-rig-settings"
  "View and manage rig settings.")

;;;###autoload (autoload 'gastown-rig-shutdown "gastown-command-rig" nil t)
(beads-meta-define-transient gastown-command-rig-shutdown "gastown-rig-shutdown"
  "Gracefully stop all rig agents.")

;;; Rig Dispatch Transient

;;;###autoload (autoload 'gastown-rig "gastown-command-rig" nil t)
(transient-define-prefix gastown-rig ()
  "Manage rigs in the workspace."
  ["Rig Status"
   ("l" "List rigs" gastown-rig-list)
   ("s" "Rig status" gastown-rig-status)
   ("c" "Rig config" gastown-rig-config)
   ("C" "Rig settings" gastown-rig-settings)]
  ["Rig Lifecycle"
   ("b" "Boot rig" gastown-rig-boot)
   ("S" "Start rig" gastown-rig-start)
   ("x" "Stop rig" gastown-rig-stop)
   ("X" "Shutdown rig" gastown-rig-shutdown)
   ("r" "Restart rig" gastown-rig-restart)
   ("R" "Reboot rig" gastown-rig-reboot)]
  ["Rig State"
   ("d" "Dock rig" gastown-rig-dock)
   ("u" "Undock rig" gastown-rig-undock)
   ("p" "Park rig" gastown-rig-park)
   ("P" "Unpark rig" gastown-rig-unpark)]
  ["Registry"
   ("a" "Add rig" gastown-rig-add)
   ("D" "Remove rig" gastown-rig-remove)
   ("z" "Reset rig state" gastown-rig-reset)])

(provide 'gastown-command-rig)
;;; gastown-command-rig.el ends here
