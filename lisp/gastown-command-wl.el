;;; gastown-command-wl.el --- Wasteland federation commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt wl' subcommands.
;; Provides wasteland federation browsing, claiming, stamping, and sync.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)
(require 'gastown-reader)

(require 'transient)

(defvar gastown-executable)

;;; WL Browse Command

(gastown-defcommand gastown-command-wl-browse (gastown-command-global-options)
  ((filter
    :initarg :filter
    :type (or null string)
    :initform nil
    :documentation "Filter expression for browsing."
    :long-option "filter"
    :option-type :string
    :key "f"
    :transient-description "Filter"
    :class transient-option
    :argument "--filter="
    :prompt "Filter: "
    :transient-group "Options"
    :level 2
    :order 1))
  :documentation "Represents gt wl browse command.
Browse the wasteland wanted board."
  :cli-command "wl browse")


;;; WL Charsheet Command

(gastown-defcommand gastown-command-wl-charsheet (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig to show charsheet for (optional, defaults to current)."
    :positional 1
    :option-type :string
    :key "r"
    :transient-description "Rig (optional)"
    :class transient-option
    :prompt "Rig (optional): "
    :transient-reader gastown-reader-rig-name
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt wl charsheet command.
Show wasteland character sheet for a rig."
  :cli-command "wl charsheet")


;;; WL Claim Command

(gastown-defcommand gastown-command-wl-claim (gastown-command-global-options)
  ((wanted-id
    :initarg :wanted-id
    :type (or null string)
    :initform nil
    :documentation "Wanted item ID to claim."
    :positional 1
    :option-type :string
    :key "w"
    :transient-description "Wanted ID (required)"
    :class transient-option
    :prompt "Wanted ID: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt wl claim command.
Claim a wanted item on the shared wanted board."
  :cli-command "wl claim")


;;; WL Done Command

(gastown-defcommand gastown-command-wl-done (gastown-command-global-options)
  ((wanted-id
    :initarg :wanted-id
    :type (or null string)
    :initform nil
    :documentation "Wanted item ID to mark as done."
    :positional 1
    :option-type :string
    :key "w"
    :transient-description "Wanted ID (required)"
    :class transient-option
    :prompt "Wanted ID: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt wl done command.
Mark a claimed wanted item as completed."
  :cli-command "wl done")


;;; WL Join Command

(gastown-defcommand gastown-command-wl-join (gastown-command-global-options)
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig to join the wasteland federation."
    :positional 1
    :option-type :string
    :key "r"
    :transient-description "Rig (optional)"
    :class transient-option
    :prompt "Rig (optional): "
    :transient-reader gastown-reader-rig-name
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt wl join command.
Join the wasteland federation."
  :cli-command "wl join")


;;; WL Post Command

(gastown-defcommand gastown-command-wl-post (gastown-command-global-options)
  ((title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Title of the wanted item."
    :long-option "title"
    :option-type :string
    :key "t"
    :transient-description "Title (required)"
    :class transient-option
    :argument "--title="
    :prompt "Title: "
    :transient-group "Options"
    :level 1
    :order 1)
   (reward
    :initarg :reward
    :type (or null string)
    :initform nil
    :documentation "Reward offered for completing the item."
    :long-option "reward"
    :option-type :string
    :key "r"
    :transient-description "Reward"
    :class transient-option
    :argument "--reward="
    :prompt "Reward: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt wl post command.
Post a new wanted item to the wasteland board."
  :cli-command "wl post")


;;; WL Scorekeeper Command

(gastown-defcommand gastown-command-wl-scorekeeper (gastown-command-global-options)
  ()
  :documentation "Represents gt wl scorekeeper command.
Show wasteland federation scorekeeper rankings."
  :cli-command "wl scorekeeper")


;;; WL Show Command

(gastown-defcommand gastown-command-wl-show (gastown-command-global-options)
  ((wanted-id
    :initarg :wanted-id
    :type (or null string)
    :initform nil
    :documentation "Wanted item ID to show."
    :positional 1
    :option-type :string
    :key "w"
    :transient-description "Wanted ID (required)"
    :class transient-option
    :prompt "Wanted ID: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt wl show command.
Show details of a wanted item."
  :cli-command "wl show")


;;; WL Stamp Command

(gastown-defcommand gastown-command-wl-stamp (gastown-command-global-options)
  ((wanted-id
    :initarg :wanted-id
    :type (or null string)
    :initform nil
    :documentation "Wanted item ID to stamp."
    :positional 1
    :option-type :string
    :key "w"
    :transient-description "Wanted ID (required)"
    :class transient-option
    :prompt "Wanted ID: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (stamp-name
    :initarg :stamp-name
    :type (or null string)
    :initform nil
    :documentation "Stamp to apply."
    :positional 2
    :option-type :string
    :key "s"
    :transient-description "Stamp name (required)"
    :class transient-option
    :prompt "Stamp: "
    :transient-group "Arguments"
    :level 1
    :order 2))
  :documentation "Represents gt wl stamp command.
Apply a stamp to a wanted item."
  :cli-command "wl stamp")


;;; WL Stamps Command

(gastown-defcommand gastown-command-wl-stamps (gastown-command-global-options)
  ()
  :documentation "Represents gt wl stamps command.
List available wasteland stamps."
  :cli-command "wl stamps")


;;; WL Sync Command

(gastown-defcommand gastown-command-wl-sync (gastown-command-global-options)
  ()
  :documentation "Represents gt wl sync command.
Sync wasteland federation data."
  :cli-command "wl sync")


;;; Transient Menus

;;;###autoload (autoload 'gastown-wl-browse "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-browse "gastown-wl-browse"
  "Browse the wasteland wanted board.")

;;;###autoload (autoload 'gastown-wl-charsheet "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-charsheet "gastown-wl-charsheet"
  "Show wasteland character sheet.")

;;;###autoload (autoload 'gastown-wl-claim "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-claim "gastown-wl-claim"
  "Claim a wanted item.")

;;;###autoload (autoload 'gastown-wl-done "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-done "gastown-wl-done"
  "Mark wanted item as done.")

;;;###autoload (autoload 'gastown-wl-join "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-join "gastown-wl-join"
  "Join the wasteland federation.")

;;;###autoload (autoload 'gastown-wl-post "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-post "gastown-wl-post"
  "Post a wanted item.")

;;;###autoload (autoload 'gastown-wl-scorekeeper "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-scorekeeper "gastown-wl-scorekeeper"
  "Show scorekeeper rankings.")

;;;###autoload (autoload 'gastown-wl-show "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-show "gastown-wl-show"
  "Show a wanted item.")

;;;###autoload (autoload 'gastown-wl-stamp "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-stamp "gastown-wl-stamp"
  "Apply a stamp to a wanted item.")

;;;###autoload (autoload 'gastown-wl-stamps "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-stamps "gastown-wl-stamps"
  "List available stamps.")

;;;###autoload (autoload 'gastown-wl-sync "gastown-command-wl" nil t)
(beads-meta-define-transient gastown-command-wl-sync "gastown-wl-sync"
  "Sync wasteland federation data.")

;;; WL Dispatch Transient

;;;###autoload (autoload 'gastown-wl "gastown-command-wl" nil t)
(transient-define-prefix gastown-wl ()
  "Wasteland federation commands."
  ["Browse"
   ("b" "Browse board" gastown-wl-browse)
   ("s" "Show item" gastown-wl-show)
   ("c" "Charsheet" gastown-wl-charsheet)
   ("k" "Scorekeeper" gastown-wl-scorekeeper)
   ("S" "Stamps list" gastown-wl-stamps)]
  ["Actions"
   ("C" "Claim item" gastown-wl-claim)
   ("d" "Mark done" gastown-wl-done)
   ("p" "Post wanted" gastown-wl-post)
   ("t" "Stamp item" gastown-wl-stamp)]
  ["Federation"
   ("j" "Join federation" gastown-wl-join)
   ("y" "Sync data" gastown-wl-sync)])

(provide 'gastown-command-wl)
;;; gastown-command-wl.el ends here
