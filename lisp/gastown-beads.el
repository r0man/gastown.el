;;; gastown-beads.el --- Gastown injection into beads.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Implements the Forge-style extension pattern: gastown.el hooks into
;; beads.el without beads knowing about gastown.
;;
;; This module provides three integration points:
;;
;;   1. Transient dispatch injection: adds a "Gas Town" entry to the beads
;;      transient dispatch prefix whenever beads is loaded.  Key: "'"
;;      (apostrophe), chosen to follow the Forge convention and avoid
;;      conflicts with existing beads keybindings.
;;
;;   2. Section hook injection: adds `gastown-insert-work-queue' to
;;      `beads-status-sections-hook' when beads-section.el is loaded.
;;
;;   3. `gastown-insert-work-queue': renders active polecat work queue
;;      as a collapsible section in the beads-status buffer.  Requires
;;      `beads-section' (from be-blg); silently returns nil if not loaded.
;;
;; All injection is conditional and guarded against double-execution.
;; This follows the Forge pattern: forge.el injects into magit-dispatch
;; without magit knowing about forge.
;;
;; Usage:
;;
;;   (require 'gastown-beads)

;;; Code:

(require 'gastown)

;; Forward declarations for optional beads-section infrastructure
(defvar beads-status-sections-hook)
(declare-function magit-insert-section "magit-section")
(declare-function magit-insert-heading "magit-section")
(declare-function gastown-work-queue "magit-section")

;;; ============================================================
;;; Guards (prevent double-injection)
;;; ============================================================

(defvar gastown-beads--dispatch-injected nil
  "Non-nil when Gas Town entry has been injected into beads dispatch.")

(defvar gastown-beads--section-hook-injected nil
  "Non-nil when `gastown-insert-work-queue' has been added to section hook.")

;;; ============================================================
;;; Transient Dispatch Injection
;;; ============================================================

(defun gastown-beads--inject-dispatch ()
  "Inject Gas Town entry into beads transient dispatch prefix.

Appends a Gas Town entry bound to \"'\" (apostrophe) after the
\"q\" (Quit) suffix in the beads dispatch.  Following the Forge
pattern: this key avoids all existing beads keybindings.

Safe to call if beads is not loaded — returns nil in that case.
Protected against double-injection by `gastown-beads--dispatch-injected'."
  (when (and (not gastown-beads--dispatch-injected)
             (featurep 'beads)
             (fboundp 'transient-append-suffix))
    (transient-append-suffix 'beads "q"
      '("'" "Gas Town" gastown))
    (setq gastown-beads--dispatch-injected t)))

;;; ============================================================
;;; Work Queue Data Fetching
;;; ============================================================

(defun gastown-beads--fetch-agents ()
  "Fetch active polecats from Gas Town via `gt status --json'.

Returns a list of polecat alists with keys: name, rig, running, info.
Returns nil on error or when gt is not available."
  (condition-case nil
      (let* ((data (gastown-command-status! :json t)))
        (when data
          (let ((polecats nil))
            (dolist (rig (append (alist-get 'rigs data) nil))
              (let ((rig-name (or (alist-get 'name rig) "")))
                (dolist (agent (append (alist-get 'agents rig) nil))
                  (when (equal (alist-get 'role agent) "polecat")
                    (push (list (cons 'rig rig-name)
                                (cons 'name (or (alist-get 'name agent) ""))
                                (cons 'running (alist-get 'running agent))
                                (cons 'info (or (alist-get 'agent_info agent) "")))
                          polecats)))))
            (nreverse polecats))))
    (error nil)))

;;; ============================================================
;;; Polecat Line Rendering
;;; ============================================================

(defun gastown-beads--format-polecat-line (polecat)
  "Format a single POLECAT entry as a display string.

POLECAT is an alist with keys: name, rig, running, info.
Returns a propertized string with running indicator, name, and rig."
  (let* ((name (or (alist-get 'name polecat) "unknown"))
         (rig (or (alist-get 'rig polecat) ""))
         (running (alist-get 'running polecat))
         (indicator (if running
                        (propertize "●" 'face 'success)
                      (propertize "○" 'face 'shadow))))
    (format "  %s %-12s %s" indicator name rig)))

;;; ============================================================
;;; Work Queue Section (requires beads-section.el)
;;; ============================================================

;;;###autoload
(defun gastown-insert-work-queue ()
  "Insert Gas Town work queue section into beads-status buffer.

Fetches active polecats across all rigs via `gt status --json' and
renders them as a collapsible magit-section.

This function is intended for use in `beads-status-sections-hook'.
It silently returns nil if `beads-section' is not loaded (be-blg
pending).

Visual format:
  ▼ Gas Town Work Queue                 [via gastown.el]
    ● jasper     beads_el
    ○ nux        gastown_el"
  (when (featurep 'beads-section)
    (let ((agents (gastown-beads--fetch-agents)))
      (magit-insert-section (gastown-work-queue)
        (magit-insert-heading
          (concat (propertize "Gas Town Work Queue"
                              'face 'magit-section-heading)
                  (propertize "                 [via gastown.el]"
                              'face 'shadow)))
        (if agents
            (dolist (agent agents)
              (insert (gastown-beads--format-polecat-line agent) "\n"))
          (insert (propertize "  (no active polecats)\n" 'face 'shadow)))))))

;;; ============================================================
;;; Section Hook Injection
;;; ============================================================

(defun gastown-beads--inject-section-hook ()
  "Register `gastown-insert-work-queue' in `beads-status-sections-hook'.

Safe to call when `beads-section' is not loaded — returns nil in
that case.  Protected against double-injection by
`gastown-beads--section-hook-injected'."
  (when (and (not gastown-beads--section-hook-injected)
             (boundp 'beads-status-sections-hook))
    (add-hook 'beads-status-sections-hook #'gastown-insert-work-queue)
    (setq gastown-beads--section-hook-injected t)))

;;; ============================================================
;;; After-load Handler
;;; ============================================================

(defun gastown-beads--after-load (_filename)
  "Perform pending injections after a file is loaded.
Called via `after-load-functions' with the loaded FILENAME."
  (gastown-beads--inject-dispatch)
  (gastown-beads--inject-section-hook))

(add-hook 'after-load-functions #'gastown-beads--after-load)

;; Also inject immediately in case beads/beads-section are already loaded
(gastown-beads--inject-dispatch)
(gastown-beads--inject-section-hook)

(provide 'gastown-beads)
;;; gastown-beads.el ends here
