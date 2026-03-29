;;; gastown.el --- Magit-like interface for Gas Town workspace manager -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; Author: Gas Town Contributors
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1") (transient "0.10.1") (sesman "0.3.2") (magit-section "3.3.0") (vui "1.0.0"))
;; Keywords: tools, processes
;; URL: https://github.com/r0man/gastown.el

;;; Commentary:

;; gastown.el provides a Magit-style Emacs porcelain for the Gas Town
;; (`gt') CLI workspace manager.  It offers:
;;
;; - Transient menus for all gt CLI commands
;; - Keyboard-driven UI for managing Gas Town workspaces
;; - Agent management (polecats, witnesses, refineries)
;; - Work dispatch and tracking (sling, convoys, merge queue)
;; - Communication (mail, nudge, broadcast)
;; - Service management (up, down, daemon)
;; - Diagnostics (vitals, doctor, logs, costs)
;;
;; The architecture reuses beads.el's EIEIO command class infrastructure
;; for automatic transient generation from slot metadata.
;;
;; Usage:
;;
;;   M-x gastown RET          ; Open main transient menu
;;   M-x gastown-status RET   ; Show workspace status
;;   M-x gastown-vitals RET   ; Show health dashboard
;;
;; See README.md for full documentation.

;;; Code:

(require 'gastown-custom)
(require 'gastown-types)
(require 'transient)
(require 'gastown-command-agents)
(require 'gastown-command-comm)
(require 'gastown-command-config)
(require 'gastown-command-convoy)
(require 'gastown-command-diagnostics)
(require 'gastown-command-formula)
(require 'gastown-command-mail)
(require 'gastown-command-nudge)
(require 'gastown-command-peek)
(require 'gastown-command-polecat)
(require 'gastown-command-rig)
(require 'gastown-command-services)
(require 'gastown-command-sling)
(require 'gastown-command-status)
(require 'gastown-status-buffer)
(require 'gastown-command-work)
(require 'gastown-command-ready)
(require 'gastown-whats-new)
(require 'gastown-command-workspace)
(require 'gastown-tabulated)
(require 'gastown-polecat-detail)

;;; Variables

(defvar gastown--project-cache (make-hash-table :test 'equal)
  "Cache of Gas Town workspace directories.")

;;; Utilities

(defun gastown--log (level format-string &rest args)
  "Log message to *gastown-debug* buffer if debug is enabled.
LEVEL is one of `error', `info', or `verbose'.
FORMAT-STRING and ARGS are passed to `format'."
  (when gastown-enable-debug
    (when (or (eq level 'error)
              (and (eq gastown-debug-level 'info)
                   (memq level '(error info)))
              (eq gastown-debug-level 'verbose))
      (let* ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S"))
             (level-str (if (eq level 'verbose) "DEBUG" (upcase (symbol-name level))))
             (msg (apply #'format format-string args))
             (log-line (format "%s [%-5s] %s\n" timestamp level-str msg))
             (buf (get-buffer-create "*gastown-debug*")))
        (with-current-buffer buf
          (goto-char (point-max))
          (let ((inhibit-read-only t))
            (insert log-line)))))))

;;; Main Transient Menu

;;;###autoload (autoload 'gastown "gastown" nil t)
(transient-define-prefix gastown ()
  "Gas Town — Manage multi-agent workspaces from Emacs.

This is the main entry point for gastown.el, providing keyboard-driven
access to all gt CLI commands organized by category."
  ["Status"
   ("s" "Status" gastown-status)
   ("v" "Vitals" gastown-vitals)
   ("i" "Info" gastown-info)
   ("w" "Whoami" gastown-whoami)]
  ["Work Management"
   ("d" "Done" gastown-done)
   ("h" "Hook" gastown-hook)
   ("r" "Ready" gastown-ready)
   ("S" "Sling (dispatch)" gastown-sling)
   ("f" "Formula..." gastown-formula-menu)
   ("W" "Work commands..." gastown-work-menu)]
  ["Agents & Communication"
   ("a" "Agent management..." gastown-agent-management)
   ("m" "Mail" gastown-mail)
   ("n" "Nudge" gastown-nudge)
   ("C" "Communication..." gastown-comm-menu)]
  ["Infrastructure"
   ("U" "Services..." gastown-services)
   ("K" "Workspace..." gastown-workspace-menu)
   ("G" "Config..." gastown-config-menu)]
  ["Diagnostics"
   ("D" "Diagnostics..." gastown-diagnostics)])

(provide 'gastown)
;;; gastown.el ends here
