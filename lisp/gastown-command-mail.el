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
    :documentation "Show all messages including read"
    :long-option "all"
    :option-type :boolean
    :key "a"
    :transient "Show all messages including read"
    :class transient-switch
    :argument "--all"
    :transient-group "Options"
    :level 1
    :order 1)
   (unread
    :initarg :unread
    :type boolean
    :initform nil
    :documentation "Show only unread messages"
    :long-option "unread"
    :short-option "u"
    :option-type :boolean
    :key "u"
    :transient "Show only unread messages"
    :class transient-switch
    :argument "--unread"
    :transient-group "Filters"
    :level 1
    :order 2)
   (from
    :initarg :from
    :type (or null string)
    :initform nil
    :documentation "Filter to messages from this sender"
    :long-option "from"
    :option-type :string
    :key "f"
    :transient "Filter to messages from this sender"
    :class transient-option
    :argument "--from="
    :prompt "From: "
    :transient-group "Filters"
    :level 1
    :order 3)
   (priority
    :initarg :priority
    :type (or null string)
    :initform nil
    :documentation "Filter by priority tag"
    :long-option "priority"
    :option-type :string
    :key "p"
    :transient "Filter by priority tag"
    :class transient-option
    :argument "--priority="
    :prompt "Priority: "
    :transient-choices ("low" "normal" "high" "critical")
    :transient-group "Filters"
    :level 1
    :order 4)
   (order
    :initarg :order
    :type (or null string)
    :initform nil
    :documentation "Sort order"
    :long-option "order"
    :option-type :string
    :key "o"
    :transient "Sort order"
    :class transient-option
    :argument "--order="
    :prompt "Order: "
    :transient-choices ("newest" "oldest")
    :transient-group "Options"
    :level 1
    :order 5)
   (limit
    :initarg :limit
    :type (or null integer)
    :initform nil
    :documentation "Maximum number of messages to show"
    :long-option "limit"
    :option-type :string
    :key "l"
    :transient "Maximum number of messages to show"
    :class transient-option
    :argument "--limit="
    :prompt "Limit: "
    :transient-group "Options"
    :level 1
    :order 6))
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
    :documentation "Mail subject"
    :long-option "subject"
    :short-option "s"
    :option-type :string
    :key "s"
    :transient "Mail subject"
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
    :documentation "Message body"
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
