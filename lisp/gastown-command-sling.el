;;; gastown-command-sling.el --- Sling command for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines the `gastown-command-sling' EIEIO class for the
;; `gt sling' command — the unified work dispatch command.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Sling Command

(eval-and-compile
  (gastown-defcommand gastown-command-sling (gastown-command-global-options)
    ((bead-id
      :initarg :bead-id
      :type (or null string)
      :initform nil
      :documentation "Bead ID to assign."
      :positional 1
      :option-type :string
      :key "b"
      :transient "Bead ID (required)"
      :class transient-option
      :prompt "Bead ID: "
      :transient-group "Required"
      :level 1
      :order 1)
     (rig
      :initarg :rig
      :type (or null string)
      :initform nil
      :documentation "Target rig (--rig)."
      :long-option "rig"
      :option-type :string
      :key "r"
      :transient "--rig"
      :class transient-option
      :argument "--rig="
      :prompt "Rig: "
      :transient-group "Options"
      :level 1
      :order 2)
     (polecat
      :initarg :polecat
      :type (or null string)
      :initform nil
      :documentation "Target polecat name (--polecat)."
      :long-option "polecat"
      :option-type :string
      :key "p"
      :transient "--polecat"
      :class transient-option
      :argument "--polecat="
      :prompt "Polecat: "
      :transient-group "Options"
      :level 1
      :order 3)
     (force
      :initarg :force
      :type boolean
      :initform nil
      :documentation "Force assign even if polecat is busy (--force)."
      :long-option "force"
      :option-type :boolean
      :key "f"
      :transient "--force"
      :class transient-switch
      :argument "--force"
      :transient-group "Options"
      :level 2
      :order 4))
    :documentation "Represents gt sling command.
Assigns work to an agent — the unified work dispatch command."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-sling))
  "Return \"sling\" as the CLI subcommand name."
  "sling")

;;; Transient Menu

;;;###autoload (autoload 'gastown-sling "gastown-command-sling" nil t)
(beads-meta-define-transient gastown-command-sling "gastown-sling"
  "Assign work to an agent (dispatch).")

(provide 'gastown-command-sling)
;;; gastown-command-sling.el ends here
