;;; gastown-command-workspace.el --- Workspace commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for workspace management commands:
;; gt crew, gt git-init, gt init, gt install, gt namepool, gt worktree.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Crew Command

(gastown-defcommand gastown-command-crew (gastown-command-global-options)
  ()
  :documentation "Represents gt crew command.
Manage the Gas Town crew.")


;;; Git-Init Command

(gastown-defcommand gastown-command-git-init (gastown-command-global-options)
  ()
  :documentation "Represents gt git-init command.
Initialize a git repository for Gas Town."
  :cli-command "git-init")

;;; Init Command

(gastown-defcommand gastown-command-init (gastown-command-global-options)
  ()
  :documentation "Represents gt init command.
Initialize a Gas Town workspace.")


;;; Install Command

(gastown-defcommand gastown-command-install (gastown-command-global-options)
  ()
  :documentation "Represents gt install command.
Install Gas Town components.")


;;; Namepool Command

(gastown-defcommand gastown-command-namepool (gastown-command-global-options)
  ()
  :documentation "Represents gt namepool command.
Manage agent name pools.")


;;; Worktree Command

(gastown-defcommand gastown-command-worktree (gastown-command-global-options)
  ()
  :documentation "Represents gt worktree command.
Manage git worktrees.")


;;; Transient Menus

;;;###autoload (autoload 'gastown-crew "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew "gastown-crew"
  "Manage the Gas Town crew.")

;;;###autoload (autoload 'gastown-git-init "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-git-init "gastown-git-init"
  "Initialize a git repository for Gas Town.")

;;;###autoload (autoload 'gastown-init "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-init "gastown-init"
  "Initialize a Gas Town workspace.")

;;;###autoload (autoload 'gastown-install "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-install "gastown-install"
  "Install Gas Town components.")

;;;###autoload (autoload 'gastown-namepool "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool "gastown-namepool"
  "Manage agent name pools.")

;;;###autoload (autoload 'gastown-worktree "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-worktree "gastown-worktree"
  "Manage git worktrees.")

;;; Workspace Dispatch Transient

;;;###autoload (autoload 'gastown-workspace-menu "gastown-command-workspace" nil t)
(transient-define-prefix gastown-workspace-menu ()
  "Manage Gas Town workspace structure."
  ["Rigs & Polecats"
   ("r" "Rig management" gastown-rig)
   ("p" "Polecat management" gastown-polecat)
   ("c" "Crew" gastown-crew)]
  ["Git & Worktrees"
   ("w" "Worktree" gastown-worktree)
   ("g" "Git init" gastown-git-init)]
  ["Setup"
   ("i" "Init workspace" gastown-init)
   ("I" "Install" gastown-install)
   ("n" "Name pool" gastown-namepool)])

(provide 'gastown-command-workspace)
;;; gastown-command-workspace.el ends here
