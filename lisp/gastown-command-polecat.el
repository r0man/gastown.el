;;; gastown-command-polecat.el --- Polecat management commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt polecat' subcommands.
;; Provides polecat listing, nuking, peeking, and nudging.

;;; Code:

(require 'gastown-command)
(require 'gastown-reader)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Polecat List Command

(gastown-defcommand gastown-command-polecat-list (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter by rig name"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Filter by rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Filters"
    :level 1
    :order 1))
  :documentation "Represents gt polecat list command.
Lists polecats with name, status, hooked work, and session info.")


;;; Polecat Nuke Command

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
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig containing the polecat"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig containing the polecat"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt polecat nuke command.
Terminates a polecat's session and cleans up its worktree.")


;;; Polecat Status Command

(gastown-defcommand gastown-command-polecat-status (gastown-command-global-options)
  ((polecat-name
    :initarg :polecat-name
    :type (or null string)
    :initform nil
    :documentation "Polecat name to show status for."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat name"
    :class transient-option
    :prompt "Polecat name: "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Options"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig containing the polecat"
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig containing the polecat"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt polecat status command.
Show detailed status for a polecat."
  :cli-command "polecat status")


;;; Polecat Check-Recovery Command

(gastown-defcommand gastown-command-polecat-check-recovery (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt polecat check-recovery command.
Check if polecat needs recovery vs safe to nuke."
  :cli-command "polecat check-recovery")


;;; Polecat GC Command

(gastown-defcommand gastown-command-polecat-gc (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be deleted without deleting."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt polecat gc command.
Garbage collect stale polecat branches."
  :cli-command "polecat gc")


;;; Polecat Git-State Command

(gastown-defcommand gastown-command-polecat-git-state (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt polecat git-state command.
Show git state for a polecat's worktree."
  :cli-command "polecat git-state")


;;; Polecat Identity Command

(gastown-defcommand gastown-command-polecat-identity (gastown-command-global-options)
  ()
  :documentation "Represents gt polecat identity command.
Manage polecat identity beads in rigs."
  :cli-command "polecat identity")


;;; Polecat Pool-Init Command

(gastown-defcommand gastown-command-polecat-pool-init (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (size
    :initarg :size
    :type (or null string)
    :initform nil
    :documentation "Pool size override."
    :long-option "size"
    :option-type :string
    :key "s"
    :transient "Pool size"
    :class transient-option
    :argument "--size="
    :prompt "Size: "
    :transient-group "Options"
    :level 2
    :order 2)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be created without doing it."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 3))
  :documentation "Represents gt polecat pool-init command.
Initialize a persistent polecat pool for a rig."
  :cli-command "polecat pool-init")


;;; Polecat Prune Command

(gastown-defcommand gastown-command-polecat-prune (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be pruned without doing it."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 2)
   (remote
    :initarg :remote
    :type boolean
    :initform nil
    :documentation "Also prune remote polecat branches on origin."
    :long-option "remote"
    :option-type :boolean
    :key "R"
    :transient "--remote"
    :class transient-switch
    :argument "--remote"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt polecat prune command.
Prune stale polecat branches in a rig."
  :cli-command "polecat prune")


;;; Polecat Remove Command

(gastown-defcommand gastown-command-polecat-remove (gastown-command-global-options)
  ((polecat-address
    :initarg :polecat-address
    :type (or null string)
    :initform nil
    :documentation "Polecat address (rig/name)."
    :positional 1
    :option-type :string
    :key "p"
    :transient "Polecat address (rig/name)"
    :class transient-option
    :prompt "Polecat (rig/name): "
    :transient-reader gastown-reader-polecat-address
    :transient-group "Required"
    :level 1
    :order 1)
   (all
    :initarg :all
    :type boolean
    :initform nil
    :documentation "Remove all polecats in the rig."
    :long-option "all"
    :option-type :boolean
    :key "a"
    :transient "--all"
    :class transient-switch
    :argument "--all"
    :transient-group "Options"
    :level 2
    :order 2)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force removal, bypassing checks."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt polecat remove command.
Remove one or more polecats from a rig."
  :cli-command "polecat remove")


;;; Polecat Stale Command

(gastown-defcommand gastown-command-polecat-stale (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Rig name (required)"
    :class transient-option
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
    :transient-group "Required"
    :level 1
    :order 1)
   (cleanup
    :initarg :cleanup
    :type boolean
    :initform nil
    :documentation "Automatically nuke stale polecats."
    :long-option "cleanup"
    :option-type :boolean
    :key "c"
    :transient "--cleanup"
    :class transient-switch
    :argument "--cleanup"
    :transient-group "Options"
    :level 2
    :order 2)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be cleaned without doing it."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 3)
   (threshold
    :initarg :threshold
    :type (or null string)
    :initform nil
    :documentation "Commits behind main to consider stale."
    :long-option "threshold"
    :option-type :string
    :key "t"
    :transient "Threshold"
    :class transient-option
    :argument "--threshold="
    :prompt "Threshold: "
    :transient-group "Options"
    :level 2
    :order 4))
  :documentation "Represents gt polecat stale command.
Detect stale polecats in a rig that are candidates for cleanup."
  :cli-command "polecat stale")


;;; Transient Menus

;;;###autoload (autoload 'gastown-polecat-list "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-list "gastown-polecat-list"
  "List all polecats.")

;;;###autoload (autoload 'gastown-polecat-nuke "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-nuke "gastown-polecat-nuke"
  "Nuke a polecat (terminate and clean up).")

;;;###autoload (autoload 'gastown-polecat-status "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-status "gastown-polecat-status"
  "Show detailed status for a polecat.")

;;;###autoload (autoload 'gastown-polecat-check-recovery "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-check-recovery "gastown-polecat-check-recovery"
  "Check polecat recovery status.")

;;;###autoload (autoload 'gastown-polecat-gc "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-gc "gastown-polecat-gc"
  "Garbage collect stale polecat branches.")

;;;###autoload (autoload 'gastown-polecat-git-state "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-git-state "gastown-polecat-git-state"
  "Show git state for a polecat's worktree.")

;;;###autoload (autoload 'gastown-polecat-identity "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-identity "gastown-polecat-identity"
  "Manage polecat identity beads.")

;;;###autoload (autoload 'gastown-polecat-pool-init "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-pool-init "gastown-polecat-pool-init"
  "Initialize a persistent polecat pool.")

;;;###autoload (autoload 'gastown-polecat-prune "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-prune "gastown-polecat-prune"
  "Prune stale polecat branches.")

;;;###autoload (autoload 'gastown-polecat-remove "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-remove "gastown-polecat-remove"
  "Remove polecats from a rig.")

;;;###autoload (autoload 'gastown-polecat-stale "gastown-command-polecat" nil t)
(beads-meta-define-transient gastown-command-polecat-stale "gastown-polecat-stale"
  "Detect stale polecats.")

;;; Polecat Dispatch Transient

;;;###autoload (autoload 'gastown-polecat "gastown-command-polecat" nil t)
(transient-define-prefix gastown-polecat ()
  "Manage polecats (worker agents)."
  ["Polecat Info"
   ("l" "List polecats" gastown-polecat-list)
   ("s" "Polecat status" gastown-polecat-status)
   ("g" "Git state" gastown-polecat-git-state)
   ("c" "Check recovery" gastown-polecat-check-recovery)
   ("i" "Identity" gastown-polecat-identity)]
  ["Polecat Actions"
   ("n" "Nuke polecat" gastown-polecat-nuke)
   ("D" "Remove polecat" gastown-polecat-remove)
   ("p" "Peek at polecat" gastown-peek)
   ("N" "Nudge polecat" gastown-nudge)]
  ["Maintenance"
   ("I" "Pool init" gastown-polecat-pool-init)
   ("P" "Prune branches" gastown-polecat-prune)
   ("G" "GC branches" gastown-polecat-gc)
   ("S" "Stale polecats" gastown-polecat-stale)])

(provide 'gastown-command-polecat)
;;; gastown-command-polecat.el ends here
