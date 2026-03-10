;;; gastown-command-rig.el --- Rig management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt rig' subcommands.
;; Provides rig listing, docking, undocking, and management.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Rig List Command

(gastown-defcommand gastown-command-rig-list (gastown-command-global-options)
  ((status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Filter by rig status (--status)."
    :long-option "status"
    :option-type :string
    :key "s"
    :transient "--status"
    :class transient-option
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
    :documentation "Sort order (--order)."
    :long-option "order"
    :option-type :string
    :key "o"
    :transient "--order"
    :class transient-option
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
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig name: "
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
    :key "r"
    :transient "Rig name"
    :class transient-option
    :prompt "Rig name: "
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt rig status command.
Show detailed status for a specific rig."
  :cli-command "rig status")


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

;;; Rig Dispatch Transient

;;;###autoload (autoload 'gastown-rig "gastown-command-rig" nil t)
(transient-define-prefix gastown-rig ()
  "Manage rigs in the workspace."
  ["Rig Status"
   ("l" "List rigs" gastown-rig-list)
   ("s" "Rig status" gastown-rig-status)]
  ["Rig Lifecycle"
   ("S" "Start rig" gastown-rig-start)
   ("x" "Stop rig" gastown-rig-stop)
   ("r" "Restart rig" gastown-rig-restart)
   ("R" "Reboot rig" gastown-rig-reboot)]
  ["Rig State"
   ("d" "Dock rig" gastown-rig-dock)
   ("u" "Undock rig" gastown-rig-undock)
   ("p" "Park rig" gastown-rig-park)
   ("P" "Unpark rig" gastown-rig-unpark)])

(provide 'gastown-command-rig)
;;; gastown-command-rig.el ends here
