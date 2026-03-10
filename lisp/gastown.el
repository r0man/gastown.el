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

(defun gastown--error (format-string &rest args)
  "Display error message to user.
FORMAT-STRING and ARGS are passed to `format'."
  (let ((msg (apply #'format format-string args)))
    (apply #'gastown--log 'error "ERROR: %s" (list msg))
    (user-error "Gas Town: %s" msg)))

(defun gastown--display-error-buffer (command exit-code stdout stderr)
  "Display detailed error information in *gastown-errors* buffer.
COMMAND is the command string that was executed.
EXIT-CODE is the process exit code.
STDOUT is the standard output from the process.
STDERR is the standard error output from the process."
  (let ((buf (get-buffer-create "*gastown-errors*"))
        (inhibit-read-only t))
    (with-current-buffer buf
      (erase-buffer)
      (special-mode)
      (setq buffer-read-only nil)
      (insert (propertize "Gas Town Command Error\n"
                          'face '(:weight bold :height 1.2))
              (propertize (make-string 60 ?=) 'face 'shadow)
              "\n\n")
      (insert (propertize "Time: " 'face 'bold)
              (format-time-string "%Y-%m-%d %H:%M:%S")
              "\n\n")
      (insert (propertize "Command:\n" 'face 'bold)
              (propertize command 'face 'font-lock-string-face)
              "\n\n")
      (insert (propertize "Exit Code: " 'face 'bold)
              (propertize (format "%d" exit-code)
                          'face 'error)
              "\n\n")
      (insert (propertize "Standard Output:\n" 'face 'bold)
              (propertize (make-string 40 ?-) 'face 'shadow)
              "\n")
      (if (and stdout (not (string-empty-p (string-trim stdout))))
          (insert stdout "\n")
        (insert (propertize "(empty)\n" 'face 'shadow)))
      (insert "\n")
      (insert (propertize "Standard Error:\n" 'face 'bold)
              (propertize (make-string 40 ?-) 'face 'shadow)
              "\n")
      (if (and stderr (not (string-empty-p (string-trim stderr))))
          (insert stderr "\n")
        (insert (propertize "(empty)\n" 'face 'shadow)))
      (setq buffer-read-only t)
      (goto-char (point-min)))
    (display-buffer buf)))

;;;###autoload
(defun gastown-show-debug-buffer ()
  "Show the *gastown-debug* buffer in another window.
Enables debug logging if not already enabled."
  (interactive)
  (unless gastown-enable-debug
    (setq gastown-enable-debug t)
    (message "Debug logging enabled"))
  (let ((buf (get-buffer-create "*gastown-debug*")))
    (display-buffer buf)))

;;;###autoload
(defun gastown-clear-debug-buffer ()
  "Clear the *gastown-debug* buffer."
  (interactive)
  (when-let ((buf (get-buffer "*gastown-debug*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)))
    (message "Debug buffer cleared")))

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
   ("W" "Work commands..." gastown-work-menu)]
  ["Agents & Communication"
   ("a" "Agent management..." gastown-agent-management)
   ("C" "Communication..." gastown-comm-menu)]
  ["Infrastructure"
   ("U" "Services..." gastown-services)
   ("K" "Workspace..." gastown-workspace-menu)
   ("G" "Config..." gastown-config-menu)]
  ["Diagnostics"
   ("D" "Diagnostics..." gastown-diagnostics)])

(provide 'gastown)
;;; gastown.el ends here
