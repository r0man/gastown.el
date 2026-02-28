;;; gastown-command-status.el --- Status command for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines the `gastown-command-status' EIEIO class for the
;; `gt status' command.  Shows overall town status including rigs,
;; polecats, and witness status.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Status Command

(eval-and-compile
  (gastown-defcommand gastown-command-status (gastown-command-json)
    ((fast
      :initarg :fast
      :type boolean
      :initform nil
      :documentation "Skip mail lookups for faster execution (--fast)."
      :long-option "fast"
      :option-type :boolean
      :key "f"
      :transient "--fast"
      :class transient-switch
      :argument "--fast"
      :transient-group "Options"
      :level 1
      :order 1)
     (watch
      :initarg :watch
      :type boolean
      :initform nil
      :documentation "Watch mode: refresh status continuously (-w, --watch)."
      :long-option "watch"
      :short-option "w"
      :option-type :boolean
      :key "w"
      :transient "--watch"
      :class transient-switch
      :argument "--watch"
      :transient-group "Options"
      :level 1
      :order 2)
     (interval
      :initarg :interval
      :type (or null integer)
      :initform nil
      :documentation "Refresh interval in seconds (-n, --interval)."
      :long-option "interval"
      :short-option "n"
      :option-type :integer
      :key "n"
      :transient "--interval"
      :class transient-option
      :argument "--interval="
      :prompt "Interval (seconds): "
      :transient-group "Options"
      :level 2
      :order 3))
    :documentation "Represents gt status command.
Shows town name, registered rigs, polecats, and witness status."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command-status))
  "Return \"status\" as the CLI subcommand name."
  "status")

;;; Transient Menu

;;;###autoload (autoload 'gastown-status "gastown-command-status" nil t)
(beads-meta-define-transient gastown-command-status "gastown-status"
  "Show Gas Town workspace status.")

(provide 'gastown-command-status)
;;; gastown-command-status.el ends here
