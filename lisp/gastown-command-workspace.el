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


;;; Crew Subcommands

(gastown-defcommand gastown-command-crew-add (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Name for the crew workspace."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, defaults to current rig)."
    :positional 2
    :option-type :string
    :key "r"
    :transient "Rig (optional)"
    :class transient-option
    :prompt "Rig: "
    :transient-group "Arguments"
    :level 2
    :order 2))
  :documentation "Represents gt crew add command.
Create a crew workspace without starting a session."
  :cli-command "crew add")


(gastown-defcommand gastown-command-crew-at (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name to attach to."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew at command.
Attach to an existing crew session."
  :cli-command "crew at")


(gastown-defcommand gastown-command-crew-list (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name."
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig filter"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt crew list command.
List crew workspaces with status."
  :cli-command "crew list")


(gastown-defcommand gastown-command-crew-pristine (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew pristine command.
Reset crew workspace to a clean state."
  :cli-command "crew pristine")


(gastown-defcommand gastown-command-crew-refresh (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew refresh command.
Context cycle with handoff mail."
  :cli-command "crew refresh")


(gastown-defcommand gastown-command-crew-remove (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name to remove."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew remove command.
Remove a crew workspace."
  :cli-command "crew remove")


(gastown-defcommand gastown-command-crew-rename (gastown-command-global-options)
  ((old-name
    :initarg :old-name
    :type (or null string)
    :initform nil
    :documentation "Current crew member name."
    :positional 1
    :option-type :string
    :key "o"
    :transient "Old name (required)"
    :class transient-option
    :prompt "Old name: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (new-name
    :initarg :new-name
    :type (or null string)
    :initform nil
    :documentation "New name for the crew member."
    :positional 2
    :option-type :string
    :key "n"
    :transient "New name (required)"
    :class transient-option
    :prompt "New name: "
    :transient-group "Arguments"
    :level 1
    :order 2))
  :documentation "Represents gt crew rename command.
Rename a crew workspace."
  :cli-command "crew rename")


(gastown-defcommand gastown-command-crew-restart (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name to restart."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew restart command.
Kill and restart a crew session fresh."
  :cli-command "crew restart")


(gastown-defcommand gastown-command-crew-start (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name to start."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (optional)"
    :class transient-option
    :prompt "Name (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1)
   (resume
    :initarg :resume
    :type boolean
    :initform nil
    :documentation "Resume previous session instead of starting fresh."
    :long-option "resume"
    :option-type :boolean
    :key "r"
    :transient "--resume"
    :class transient-switch
    :argument "--resume"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt crew start command.
Start crew workers in a rig."
  :cli-command "crew start")


(gastown-defcommand gastown-command-crew-status (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name (optional)."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (optional)"
    :class transient-option
    :prompt "Name (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt crew status command.
Show crew workspace status."
  :cli-command "crew status")


(gastown-defcommand gastown-command-crew-stop (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew member name to stop."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt crew stop command.
Stop a crew session."
  :cli-command "crew stop")


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


;;; Namepool Subcommands

(gastown-defcommand gastown-command-namepool-add (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Custom name to add to the pool."
    :positional 1
    :option-type :string
    :key "n"
    :transient "Name (required)"
    :class transient-option
    :prompt "Name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt namepool add command.
Add a custom name to the pool."
  :cli-command "namepool add")


(gastown-defcommand gastown-command-namepool-create (gastown-command-global-options)
  ((theme-name
    :initarg :theme-name
    :type (or null string)
    :initform nil
    :documentation "Name for the new theme."
    :positional 1
    :option-type :string
    :key "t"
    :transient "Theme name (required)"
    :class transient-option
    :prompt "Theme name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt namepool create command.
Create a custom name theme."
  :cli-command "namepool create")


(gastown-defcommand gastown-command-namepool-delete (gastown-command-global-options)
  ((theme-name
    :initarg :theme-name
    :type (or null string)
    :initform nil
    :documentation "Theme name to delete."
    :positional 1
    :option-type :string
    :key "t"
    :transient "Theme name (required)"
    :class transient-option
    :prompt "Theme name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt namepool delete command.
Delete a custom name theme."
  :cli-command "namepool delete")


(gastown-defcommand gastown-command-namepool-reset (gastown-command-global-options)
  ()
  :documentation "Represents gt namepool reset command.
Reset the pool state (release all names)."
  :cli-command "namepool reset")


(gastown-defcommand gastown-command-namepool-set (gastown-command-global-options)
  ((theme-name
    :initarg :theme-name
    :type (or null string)
    :initform nil
    :documentation "Theme name to set."
    :positional 1
    :option-type :string
    :key "t"
    :transient "Theme name (required)"
    :class transient-option
    :prompt "Theme name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt namepool set command.
Set the namepool theme for this rig."
  :cli-command "namepool set")


(gastown-defcommand gastown-command-namepool-themes (gastown-command-global-options)
  ()
  :documentation "Represents gt namepool themes command.
List available themes and their names."
  :cli-command "namepool themes")


;;; Worktree Command

(gastown-defcommand gastown-command-worktree (gastown-command-global-options)
  ()
  :documentation "Represents gt worktree command.
Manage git worktrees.")


;;; Worktree Subcommands

(gastown-defcommand gastown-command-worktree-list (gastown-command-global-options)
  ()
  :documentation "Represents gt worktree list command.
List all cross-rig worktrees owned by current crew member."
  :cli-command "worktree list")


(gastown-defcommand gastown-command-worktree-remove (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name of the worktree to remove."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt worktree remove command.
Remove a cross-rig worktree."
  :cli-command "worktree remove")


;;; Transient Menus

;;;###autoload (autoload 'gastown-crew "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew "gastown-crew"
  "Manage the Gas Town crew.")

;;;###autoload (autoload 'gastown-crew-add "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-add "gastown-crew-add"
  "Add a crew workspace.")

;;;###autoload (autoload 'gastown-crew-at "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-at "gastown-crew-at"
  "Attach to crew session.")

;;;###autoload (autoload 'gastown-crew-list "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-list "gastown-crew-list"
  "List crew workspaces.")

;;;###autoload (autoload 'gastown-crew-pristine "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-pristine "gastown-crew-pristine"
  "Reset crew workspace.")

;;;###autoload (autoload 'gastown-crew-refresh "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-refresh "gastown-crew-refresh"
  "Refresh crew context.")

;;;###autoload (autoload 'gastown-crew-remove "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-remove "gastown-crew-remove"
  "Remove crew workspace.")

;;;###autoload (autoload 'gastown-crew-rename "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-rename "gastown-crew-rename"
  "Rename crew workspace.")

;;;###autoload (autoload 'gastown-crew-restart "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-restart "gastown-crew-restart"
  "Restart crew session.")

;;;###autoload (autoload 'gastown-crew-start "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-start "gastown-crew-start"
  "Start crew session.")

;;;###autoload (autoload 'gastown-crew-status "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-status "gastown-crew-status"
  "Show crew status.")

;;;###autoload (autoload 'gastown-crew-stop "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-crew-stop "gastown-crew-stop"
  "Stop crew session.")

;;; Crew Dispatch Transient

;;;###autoload (autoload 'gastown-crew-menu "gastown-command-workspace" nil t)
(transient-define-prefix gastown-crew-menu ()
  "Manage crew workers."
  ["Info"
   ("l" "List crew" gastown-crew-list)
   ("s" "Status" gastown-crew-status)]
  ["Session Lifecycle"
   ("S" "Start" gastown-crew-start)
   ("x" "Stop" gastown-crew-stop)
   ("R" "Restart" gastown-crew-restart)
   ("a" "Attach" gastown-crew-at)
   ("r" "Refresh context" gastown-crew-refresh)]
  ["Workspace Management"
   ("+" "Add workspace" gastown-crew-add)
   ("-" "Remove workspace" gastown-crew-remove)
   ("n" "Rename workspace" gastown-crew-rename)
   ("P" "Pristine reset" gastown-crew-pristine)])

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

;;;###autoload (autoload 'gastown-namepool-add "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-add "gastown-namepool-add"
  "Add a custom name.")

;;;###autoload (autoload 'gastown-namepool-create "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-create "gastown-namepool-create"
  "Create a custom theme.")

;;;###autoload (autoload 'gastown-namepool-delete "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-delete "gastown-namepool-delete"
  "Delete a custom theme.")

;;;###autoload (autoload 'gastown-namepool-reset "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-reset "gastown-namepool-reset"
  "Reset pool state.")

;;;###autoload (autoload 'gastown-namepool-set "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-set "gastown-namepool-set"
  "Set namepool theme.")

;;;###autoload (autoload 'gastown-namepool-themes "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-namepool-themes "gastown-namepool-themes"
  "List available themes.")

;;; Namepool Dispatch Transient

;;;###autoload (autoload 'gastown-namepool-menu "gastown-command-workspace" nil t)
(transient-define-prefix gastown-namepool-menu ()
  "Manage polecat name pools."
  ["View"
   ("l" "List themes" gastown-namepool-themes)]
  ["Manage Pool"
   ("a" "Add name" gastown-namepool-add)
   ("s" "Set theme" gastown-namepool-set)
   ("r" "Reset pool" gastown-namepool-reset)]
  ["Themes"
   ("c" "Create theme" gastown-namepool-create)
   ("d" "Delete theme" gastown-namepool-delete)])

;;;###autoload (autoload 'gastown-worktree "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-worktree "gastown-worktree"
  "Manage git worktrees.")

;;;###autoload (autoload 'gastown-worktree-list "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-worktree-list "gastown-worktree-list"
  "List cross-rig worktrees.")

;;;###autoload (autoload 'gastown-worktree-remove "gastown-command-workspace" nil t)
(beads-meta-define-transient gastown-command-worktree-remove "gastown-worktree-remove"
  "Remove cross-rig worktree.")

;;; Worktree Dispatch Transient

;;;###autoload (autoload 'gastown-worktree-menu "gastown-command-workspace" nil t)
(transient-define-prefix gastown-worktree-menu ()
  "Manage cross-rig worktrees."
  ["Worktrees"
   ("l" "List worktrees" gastown-worktree-list)
   ("r" "Remove worktree" gastown-worktree-remove)])

;;; Workspace Dispatch Transient

;;;###autoload (autoload 'gastown-workspace-menu "gastown-command-workspace" nil t)
(transient-define-prefix gastown-workspace-menu ()
  "Manage Gas Town workspace structure."
  ["Rigs & Polecats"
   ("r" "Rig management" gastown-rig)
   ("p" "Polecat management" gastown-polecat)
   ("c" "Crew..." gastown-crew-menu)]
  ["Git & Worktrees"
   ("w" "Worktree..." gastown-worktree-menu)
   ("g" "Git init" gastown-git-init)]
  ["Setup"
   ("i" "Init workspace" gastown-init)
   ("I" "Install" gastown-install)
   ("n" "Name pool..." gastown-namepool-menu)])

(provide 'gastown-command-workspace)
;;; gastown-command-workspace.el ends here
