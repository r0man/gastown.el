;;; gastown-command-polecat.el --- Polecat management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt polecat' subcommands.
;; Provides polecat listing, nuking, peeking, and nudging.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Polecat List Command

(eval-and-compile
  (gastown-defcommand gastown-command-polecat-list (gastown-command-global-options)
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
    :documentation "Represents gt polecat list command.
Lists polecats with name, status, hooked work, and session info."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-polecat-list))
  "Return \"polecat list\" as the CLI subcommand name."
  "polecat list")

;;; Polecat Nuke Command

(eval-and-compile
  (gastown-defcommand gastown-command-polecat-nuke (gastown-command-global-options)
    ((polecat-name
      :initarg :polecat-name
      :type (or null string)
      :initform nil
      :documentation "Polecat name to nuke."
      :positional 1
      :option-type :string
      :key "p"
      :transient "Polecat name (required)"
      :class transient-option
      :prompt "Polecat name: "
      :transient-group "Required"
      :level 1
      :order 1)
     (rig
      :initarg :rig
      :type (or null string)
      :initform nil
      :documentation "Rig containing the polecat (--rig)."
      :long-option "rig"
      :option-type :string
      :key "r"
      :transient "--rig"
      :class transient-option
      :argument "--rig="
      :prompt "Rig: "
      :transient-group "Options"
      :level 1
      :order 2))
    :documentation "Represents gt polecat nuke command.
Terminates a polecat's session and cleans up its worktree."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-polecat-nuke))
  "Return \"polecat nuke\" as the CLI subcommand name."
  "polecat nuke")

;;; Transient Menus

;;;###autoload (autoload 'gastown-polecat-list "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-list "gastown-polecat-list"
  "List all polecats.")

;;;###autoload (autoload 'gastown-polecat-nuke "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-nuke "gastown-polecat-nuke"
  "Nuke a polecat (terminate and clean up).")

;;; Polecat Dispatch Transient

;;;###autoload (autoload 'gastown-polecat "gastown-command-polecat" nil t)
(transient-define-prefix gastown-polecat ()
  "Manage polecats (worker agents)."
  ["Polecat Commands"
   ("l" "List polecats" gastown-polecat-list)
   ("n" "Nuke polecat" gastown-polecat-nuke)
   ("p" "Peek at polecat" gastown-peek)
   ("N" "Nudge polecat" gastown-nudge)])

(provide 'gastown-command-polecat)
;;; gastown-command-polecat.el ends here
