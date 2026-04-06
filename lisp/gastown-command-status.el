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

(gastown-defcommand gastown-command-status (gastown-command-global-options)
  ((fast
    :initarg :fast
    :type boolean
    :initform nil
    :documentation "Skip mail lookups for faster execution"
    :long-option "fast"
    :option-type :boolean
    :key "f"
    :transient-description "Skip mail lookups for faster execution"
    :class transient-switch
    :argument "--fast"
    :transient-group "Options"
    :level 1
    :order 1)
   (watch
    :initarg :watch
    :type boolean
    :initform nil
    :documentation "Watch mode: refresh status continuously"
    :long-option "watch"
    :short-option "w"
    :option-type :boolean
    :key "w"
    :transient-description "Watch mode: refresh status continuously"
    :class transient-switch
    :argument "--watch"
    :transient-group "Options"
    :level 1
    :order 2)
   (interval
    :initarg :interval
    :type (or null integer)
    :initform nil
    :documentation "Refresh interval in seconds"
    :long-option "interval"
    :short-option "n"
    :option-type :integer
    :key "n"
    :transient-description "Refresh interval in seconds"
    :class transient-option
    :argument "--interval="
    :prompt "Interval (seconds): "
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt status command.
Shows town name, registered rigs, polecats, and witness status.")


;;; Options Transient

;;;###autoload (autoload 'gastown-status-options "gastown-command-status" nil t)
(beads-meta-define-transient gastown-command-status "gastown-status-options"
  "Gas Town status options (fast, watch, interval).")

(provide 'gastown-command-status)
;;; gastown-command-status.el ends here
