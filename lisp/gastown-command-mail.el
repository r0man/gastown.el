;;; gastown-command-mail.el --- Mail commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt mail' subcommands.
;; Provides inbox viewing, reading, and sending messages.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Mail Inbox Command

(gastown-defcommand gastown-command-mail-inbox (gastown-command-global-options)
  ((all
    :initarg :all
    :type boolean
    :initform nil
    :documentation "Show all messages including read (--all)."
    :long-option "all"
    :option-type :boolean
    :key "a"
    :transient "--all"
    :class transient-switch
    :argument "--all"
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt mail inbox command.
Lists messages with read/unread indicators.")


;;; Mail Read Command

(gastown-defcommand gastown-command-mail-read (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Mail message ID to read."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Mail ID (required)"
    :class transient-option
    :prompt "Mail ID: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt mail read command.
Reads a specific mail message.")


;;; Mail Send Command

(gastown-defcommand gastown-command-mail-send (gastown-command-global-options)
  ((recipient
    :initarg :recipient
    :type (or null string)
    :initform nil
    :documentation "Recipient address (rig/role format)."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Recipient (required)"
    :class transient-option
    :prompt "Recipient (rig/role): "
    :transient-group "Required"
    :level 1
    :order 1)
   (subject
    :initarg :subject
    :type (or null string)
    :initform nil
    :documentation "Mail subject (-s, --subject)."
    :long-option "subject"
    :short-option "s"
    :option-type :string
    :key "s"
    :transient "--subject"
    :class transient-option
    :argument "--subject="
    :prompt "Subject: "
    :transient-group "Required"
    :level 1
    :order 2)
   (message-body
    :initarg :message-body
    :type (or null string)
    :initform nil
    :documentation "Message body (-m)."
    :long-option "m"
    :option-type :string
    :key "m"
    :transient "Message body"
    :class transient-option
    :argument "-m="
    :prompt "Message: "
    :transient-group "Content"
    :level 1
    :order 3))
  :documentation "Represents gt mail send command.
Sends a message to an agent.")


;;; Mail Mark-Read Command

(gastown-defcommand gastown-command-mail-mark-read (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Mail message ID to mark as read."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Mail ID"
    :class transient-option
    :prompt "Mail ID (or 'all'): "
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt mail mark-read command.
Mark messages as read without archiving."
  :cli-command "mail mark-read")


;;; Transient Menus

;;;###autoload (autoload 'gastown-mail-inbox "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-inbox "gastown-mail-inbox"
  "View mail inbox.")

;;;###autoload (autoload 'gastown-mail-read "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-read "gastown-mail-read"
  "Read a specific mail message.")

;;;###autoload (autoload 'gastown-mail-send "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-send "gastown-mail-send"
  "Send a mail message.")

;;;###autoload (autoload 'gastown-mail-mark-read "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-mark-read "gastown-mail-mark-read"
  "Mark messages as read.")

;;; Mail Dispatch Transient

;;;###autoload (autoload 'gastown-mail "gastown-command-mail" nil t)
(transient-define-prefix gastown-mail ()
  "Agent messaging system."
  ["Mail Commands"
   ("i" "Inbox" gastown-mail-inbox)
   ("r" "Read message" gastown-mail-read)
   ("s" "Send message" gastown-mail-send)
   ("m" "Mark as read" gastown-mail-mark-read)])

(provide 'gastown-command-mail)
;;; gastown-command-mail.el ends here
