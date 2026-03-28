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
    :order 2))
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
    ;; gt mail send uses -m (short option), so :long-option "m" generates --m
    ;; for direct CLI invocation and :argument "-m=" overrides the transient prefix.
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


;;; Mail Archive Command

(gastown-defcommand gastown-command-mail-archive (gastown-command-global-options)
  ((mail-ids
    :initarg :mail-ids
    :type (or null string)
    :initform nil
    :documentation "Message ID(s) to archive."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Message ID(s)"
    :class transient-option
    :prompt "Message IDs: "
    :transient-group "Options"
    :level 1
    :order 1)
   (stale
    :initarg :stale
    :type boolean
    :initform nil
    :documentation "Archive messages sent before session start."
    :long-option "stale"
    :option-type :boolean
    :key "s"
    :transient "--stale"
    :class transient-switch
    :argument "--stale"
    :transient-group "Options"
    :level 1
    :order 2)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be archived without archiving."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Options"
    :level 1
    :order 3))
  :documentation "Represents gt mail archive command.
Archive one or more messages."
  :cli-command "mail archive")


;;; Mail Check Command

(gastown-defcommand gastown-command-mail-check (gastown-command-global-options)
  ((inject
    :initarg :inject
    :type boolean
    :initform nil
    :documentation "Output format for Claude Code hooks."
    :long-option "inject"
    :option-type :boolean
    :key "i"
    :transient "--inject"
    :class transient-switch
    :argument "--inject"
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt mail check command.
Check for new mail."
  :cli-command "mail check")


;;; Mail Claim Command

(gastown-defcommand gastown-command-mail-claim (gastown-command-global-options)
  ((queue-name
    :initarg :queue-name
    :type (or null string)
    :initform nil
    :documentation "Queue name to claim from (optional)."
    :positional 1
    :option-type :string
    :key "q"
    :transient "Queue name"
    :class transient-option
    :prompt "Queue name: "
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt mail claim command.
Claim the oldest unclaimed message from a work queue."
  :cli-command "mail claim")


;;; Mail Clear Command

(gastown-defcommand gastown-command-mail-clear (gastown-command-global-options)
  ((target
    :initarg :target
    :type (or null string)
    :initform nil
    :documentation "Target inbox to clear (optional, defaults to self)."
    :positional 1
    :option-type :string
    :key "t"
    :transient "Target (optional)"
    :class transient-option
    :prompt "Target: "
    :transient-group "Options"
    :level 1
    :order 1))
  :documentation "Represents gt mail clear command.
Clear all messages from an inbox."
  :cli-command "mail clear")


;;; Mail Delete Command

(gastown-defcommand gastown-command-mail-delete (gastown-command-global-options)
  ((mail-ids
    :initarg :mail-ids
    :type (or null string)
    :initform nil
    :documentation "Message ID(s) to delete."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Message ID(s) (required)"
    :class transient-option
    :prompt "Message IDs: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt mail delete command.
Delete (acknowledge) one or more messages."
  :cli-command "mail delete")


;;; Mail Directory Command

(gastown-defcommand gastown-command-mail-directory (gastown-command-global-options)
  ()
  :documentation "Represents gt mail directory command.
List all valid mail recipient addresses in the town."
  :cli-command "mail directory")


;;; Mail Drain Command

(gastown-defcommand gastown-command-mail-drain (gastown-command-global-options)
  ()
  :documentation "Represents gt mail drain command.
Bulk-archive stale protocol messages."
  :cli-command "mail drain")


;;; Mail Hook Command

(gastown-defcommand gastown-command-mail-hook (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Mail message ID to attach to hook."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Mail ID (required)"
    :class transient-option
    :prompt "Mail ID: "
    :transient-group "Required"
    :level 1
    :order 1)
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Replace existing incomplete hooked bead."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt mail hook command.
Attach a mail message to your hook."
  :cli-command "mail hook")


;;; Mail Mark-Unread Command

(gastown-defcommand gastown-command-mail-mark-unread (gastown-command-global-options)
  ((mail-ids
    :initarg :mail-ids
    :type (or null string)
    :initform nil
    :documentation "Message ID(s) to mark as unread."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Message ID(s) (required)"
    :class transient-option
    :prompt "Message IDs: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt mail mark-unread command.
Mark one or more messages as unread."
  :cli-command "mail mark-unread")


;;; Mail Peek Command

(gastown-defcommand gastown-command-mail-peek (gastown-command-global-options)
  ()
  :documentation "Represents gt mail peek command.
Display a compact preview of the first unread message."
  :cli-command "mail peek")


;;; Mail Release Command

(gastown-defcommand gastown-command-mail-release (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Message ID to release."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Message ID (required)"
    :class transient-option
    :prompt "Message ID: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt mail release command.
Release a previously claimed message back to its queue."
  :cli-command "mail release")


;;; Mail Reply Command

(gastown-defcommand gastown-command-mail-reply (gastown-command-global-options)
  ((mail-id
    :initarg :mail-id
    :type (or null string)
    :initform nil
    :documentation "Message ID to reply to."
    :positional 1
    :option-type :string
    :key "i"
    :transient "Message ID (required)"
    :class transient-option
    :prompt "Message ID: "
    :transient-group "Required"
    :level 1
    :order 1)
   (message-body
    :initarg :message-body
    :type (or null string)
    :initform nil
    :documentation "Reply message body."
    :long-option "message"
    :option-type :string
    :key "m"
    :transient "Message body"
    :class transient-option
    :argument "--message="
    :prompt "Message: "
    :transient-group "Options"
    :level 1
    :order 2)
   (subject
    :initarg :subject
    :type (or null string)
    :initform nil
    :documentation "Override reply subject."
    :long-option "subject"
    :option-type :string
    :key "s"
    :transient "Subject override"
    :class transient-option
    :argument "--subject="
    :prompt "Subject: "
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt mail reply command.
Reply to a specific message."
  :cli-command "mail reply")


;;; Mail Search Command

(gastown-defcommand gastown-command-mail-search (gastown-command-global-options)
  ((query
    :initarg :query
    :type (or null string)
    :initform nil
    :documentation "Search query (regex pattern)."
    :positional 1
    :option-type :string
    :key "q"
    :transient "Query (required)"
    :class transient-option
    :prompt "Query: "
    :transient-group "Required"
    :level 1
    :order 1)
   (from
    :initarg :from
    :type (or null string)
    :initform nil
    :documentation "Filter by sender address."
    :long-option "from"
    :option-type :string
    :key "f"
    :transient "From"
    :class transient-option
    :argument "--from="
    :prompt "From: "
    :transient-group "Filters"
    :level 1
    :order 2))
  :documentation "Represents gt mail search command.
Search inbox for messages matching a pattern."
  :cli-command "mail search")


;;; Mail Thread Command

(gastown-defcommand gastown-command-mail-thread (gastown-command-global-options)
  ((thread-id
    :initarg :thread-id
    :type (or null string)
    :initform nil
    :documentation "Thread ID to view."
    :positional 1
    :option-type :string
    :key "t"
    :transient "Thread ID (required)"
    :class transient-option
    :prompt "Thread ID: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt mail thread command.
View all messages in a conversation thread."
  :cli-command "mail thread")


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

;;;###autoload (autoload 'gastown-mail-archive "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-archive "gastown-mail-archive"
  "Archive messages.")

;;;###autoload (autoload 'gastown-mail-check "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-check "gastown-mail-check"
  "Check for new mail.")

;;;###autoload (autoload 'gastown-mail-claim "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-claim "gastown-mail-claim"
  "Claim a message from a queue.")

;;;###autoload (autoload 'gastown-mail-clear "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-clear "gastown-mail-clear"
  "Clear all messages from an inbox.")

;;;###autoload (autoload 'gastown-mail-delete "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-delete "gastown-mail-delete"
  "Delete messages.")

;;;###autoload (autoload 'gastown-mail-directory "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-directory "gastown-mail-directory"
  "List all valid mail recipient addresses.")

;;;###autoload (autoload 'gastown-mail-drain "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-drain "gastown-mail-drain"
  "Bulk-archive stale protocol messages.")

;;;###autoload (autoload 'gastown-mail-hook "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-hook "gastown-mail-hook"
  "Attach a mail message to your hook.")

;;;###autoload (autoload 'gastown-mail-mark-unread "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-mark-unread "gastown-mail-mark-unread"
  "Mark messages as unread.")

;;;###autoload (autoload 'gastown-mail-peek "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-peek "gastown-mail-peek"
  "Preview first unread message.")

;;;###autoload (autoload 'gastown-mail-release "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-release "gastown-mail-release"
  "Release a claimed queue message.")

;;;###autoload (autoload 'gastown-mail-reply "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-reply "gastown-mail-reply"
  "Reply to a message.")

;;;###autoload (autoload 'gastown-mail-search "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-search "gastown-mail-search"
  "Search messages.")

;;;###autoload (autoload 'gastown-mail-thread "gastown-command-mail" nil t)
(beads-meta-define-transient gastown-command-mail-thread "gastown-mail-thread"
  "View a message thread.")

;;; Mail Dispatch Transient

;;;###autoload (autoload 'gastown-mail "gastown-command-mail" nil t)
(transient-define-prefix gastown-mail ()
  "Agent messaging system."
  ["Read"
   ("i" "Inbox" gastown-mail-inbox)
   ("r" "Read message" gastown-mail-read)
   ("p" "Peek (preview)" gastown-mail-peek)
   ("t" "Thread" gastown-mail-thread)
   ("/" "Search" gastown-mail-search)
   ("D" "Directory" gastown-mail-directory)]
  ["Write"
   ("s" "Send message" gastown-mail-send)
   ("R" "Reply" gastown-mail-reply)
   ("h" "Hook message" gastown-mail-hook)]
  ["Manage"
   ("m" "Mark read" gastown-mail-mark-read)
   ("u" "Mark unread" gastown-mail-mark-unread)
   ("a" "Archive" gastown-mail-archive)
   ("d" "Delete" gastown-mail-delete)
   ("c" "Clear inbox" gastown-mail-clear)
   ("C" "Check mail" gastown-mail-check)]
  ["Queue"
   ("q" "Claim" gastown-mail-claim)
   ("e" "Release" gastown-mail-release)
   ("n" "Drain stale" gastown-mail-drain)])

(provide 'gastown-command-mail)
;;; gastown-command-mail.el ends here
