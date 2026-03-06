;;; gastown-command-comm.el --- Communication commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for additional communication commands
;; (gt dnd, gt notify) and the gastown-comm-menu dispatch transient that
;; groups all communication commands in one place.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; DND Command

(gastown-defcommand gastown-command-dnd (gastown-command-global-options)
  ()
  :documentation "Represents gt dnd command.
Toggle do-not-disturb mode.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-dnd))
  "Return \"dnd\" as the CLI subcommand name."
  "dnd")

;;; Notify Command

(gastown-defcommand gastown-command-notify (gastown-command-global-options)
  ()
  :documentation "Represents gt notify command.
Send a notification.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-notify))
  "Return \"notify\" as the CLI subcommand name."
  "notify")

;;; Transient Menus

;;;###autoload (autoload 'gastown-dnd "gastown-command-comm" nil t)
(beads-meta-define-transient gastown-command-dnd "gastown-dnd"
  "Toggle do-not-disturb mode.")

;;;###autoload (autoload 'gastown-notify "gastown-command-comm" nil t)
(beads-meta-define-transient gastown-command-notify "gastown-notify"
  "Send a notification.")

;;; Communication Dispatch Transient

;;;###autoload (autoload 'gastown-comm-menu "gastown-command-comm" nil t)
(transient-define-prefix gastown-comm-menu ()
  "Gas Town communication commands."
  ["Messaging"
   ("m" "Mail" gastown-mail)
   ("n" "Nudge" gastown-nudge)
   ("b" "Broadcast" gastown-broadcast)
   ("N" "Notify" gastown-notify)]
  ["Coordination"
   ("e" "Escalate" gastown-escalate)
   ("p" "Peek" gastown-peek)
   ("d" "DND (do not disturb)" gastown-dnd)])

(provide 'gastown-command-comm)
;;; gastown-command-comm.el ends here
