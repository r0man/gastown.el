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
  ()
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

;;; Rig Dispatch Transient

;;;###autoload (autoload 'gastown-rig "gastown-command-rig" nil t)
(transient-define-prefix gastown-rig ()
  "Manage rigs in the workspace."
  ["Rig Commands"
   ("l" "List rigs" gastown-rig-list)
   ("d" "Dock rig" gastown-rig-dock)
   ("u" "Undock rig" gastown-rig-undock)
   ("p" "Park rig" gastown-rig-park)
   ("P" "Unpark rig" gastown-rig-unpark)])

(provide 'gastown-command-rig)
;;; gastown-command-rig.el ends here
