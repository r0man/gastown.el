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

(eval-and-compile
  (gastown-defcommand gastown-command-up (gastown-command)
    ()
    :documentation "Represents gt up command.
Brings up all Gas Town services."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-up))
  "Return \"up\" as the CLI subcommand name."
  "up")

;;; Down Command

(eval-and-compile
  (gastown-defcommand gastown-command-down (gastown-command)
    ()
    :documentation "Represents gt down command.
Stops all Gas Town services."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-down))
  "Return \"down\" as the CLI subcommand name."
  "down")

;;; Shutdown Command

(eval-and-compile
  (gastown-defcommand gastown-command-shutdown (gastown-command)
    ((force
      :initarg :force
      :type boolean
      :initform nil
      :documentation "Force shutdown without cleanup (--force)."
      :long-option "force"
      :option-type :boolean
      :key "f"
      :transient "--force"
      :class transient-switch
      :argument "--force"
      :transient-group "Options"
      :level 1
      :order 1))
    :documentation "Represents gt shutdown command.
Shutdown Gas Town with cleanup."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-shutdown))
  "Return \"shutdown\" as the CLI subcommand name."
  "shutdown")

;;; Daemon Status Command

(eval-and-compile
  (gastown-defcommand gastown-command-daemon-status (gastown-command-json)
    ()
    :documentation "Represents gt daemon status command.
Shows the Gas Town daemon status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-daemon-status))
  "Return \"daemon status\" as the CLI subcommand name."
  "daemon status")

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

;;; Services Dispatch Transient

;;;###autoload (autoload 'gastown-services "gastown-command-services" nil t)
(transient-define-prefix gastown-services ()
  "Manage Gas Town services."
  ["Service Commands"
   ("u" "Start services (up)" gastown-up)
   ("d" "Stop services (down)" gastown-down)
   ("S" "Shutdown (with cleanup)" gastown-shutdown)
   ("D" "Daemon status" gastown-daemon-status)])

(provide 'gastown-command-services)
;;; gastown-command-services.el ends here
