;;; gastown-beads.el --- Gastown injection into beads.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Implements the Forge-style extension pattern: gastown.el hooks into
;; beads.el without beads knowing about gastown.
;;
;; This module provides five integration points:
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
;;   4. Issue buffer formula key: adds "f" -> `gastown-sling-formula-on-issue'
;;      to `beads-show-mode-map' when beads-show is loaded.  Pre-fills
;;      the bead ID from the buffer's `beads-show--issue-id' variable.
;;
;;   5. Formula status section: adds `gastown-insert-formula-section' to
;;      `beads-status-sections-hook' when beads-section.el is loaded.
;;      Shows recent formula dispatches with convoy status.
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
(require 'gastown-types)

;; Forward declarations for optional beads-section infrastructure
(defvar beads-status-sections-hook)
(declare-function magit-insert-section "magit-section")
(declare-function magit-insert-heading "magit-section")
(declare-function gastown-work-queue "magit-section")
(declare-function gastown-formula-section "magit-section")
(declare-function gastown-sling-formula-on-issue "gastown-command-sling")

;; Forward declarations for beads-show context
(defvar beads-show--issue-id)
(defvar beads-show-mode-map)
(declare-function beads-list--current-issue-id "beads-list")

;;; ============================================================
;;; Guards (prevent double-injection)
;;; ============================================================

(defvar gastown-beads--dispatch-injected nil
  "Non-nil when Gas Town entry has been injected into beads dispatch.")

(defvar gastown-beads--section-hook-injected nil
  "Non-nil when `gastown-insert-work-queue' has been added to section hook.")

(defvar gastown-beads--formula-issue-key-injected nil
  "Non-nil when formula `f' key has been injected into `beads-show-mode-map'.")

(defvar gastown-beads--formula-section-injected nil
  "Non-nil when `gastown-insert-formula-section' has been added to section hook.")

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

Returns a list of `gastown-agent' objects with the rig name stored
in a buffer-local alist.  Returns nil on error or when gt is not available."
  (condition-case nil
      (let* ((status (gastown-gt-status-from-json (gastown-command-status! :json t))))
        (when status
          (let ((polecats nil))
            (dolist (rig (oref status rigs))
              (dolist (agent (oref rig agents))
                (when (equal (oref agent role) "polecat")
                  ;; Store rig name alongside agent using a cons pair
                  (push (cons (oref rig name) agent) polecats))))
            (nreverse polecats))))
    (error nil)))

;;; ============================================================
;;; Polecat Line Rendering
;;; ============================================================

(defun gastown-beads--format-polecat-line (rig-agent)
  "Format a single polecat entry as a display string.

RIG-AGENT is a cons of (rig-name . gastown-agent).
Returns a propertized string with running indicator, name, and rig."
  (let* ((rig-name (car rig-agent))
         (agent    (cdr rig-agent))
         (name     (or (oref agent name) "unknown"))
         (running  (oref agent running))
         (indicator (if running
                        (propertize "●" 'face 'success)
                      (propertize "○" 'face 'shadow))))
    (format "  %s %-12s %s" indicator name rig-name)))

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
;;; Issue Buffer Formula Key Injection (Surface 2)
;;; ============================================================

(defun gastown-beads--dispatch-formula-on-current-issue ()
  "Dispatch a formula on the issue currently shown in the beads-show buffer.
Reads the bead ID from `beads-show--issue-id' and calls
`gastown-sling-formula-on-issue'.
Signals an error if not in a beads-show buffer."
  (interactive)
  (let ((issue-id (and (boundp 'beads-show--issue-id) beads-show--issue-id)))
    (unless issue-id
      (user-error "Not in a beads issue buffer (no beads-show--issue-id)"))
    (require 'gastown-command-sling)
    (gastown-sling-formula-on-issue issue-id)))

(defun gastown-beads--inject-formula-issue-key ()
  "Add `f' key to `beads-show-mode-map' for formula dispatch.
Binds `f' -> `gastown-beads--dispatch-formula-on-current-issue'.
Safe to call when beads-show is not loaded — returns nil.
Protected by `gastown-beads--formula-issue-key-injected'."
  (when (and (not gastown-beads--formula-issue-key-injected)
             (boundp 'beads-show-mode-map))
    (define-key beads-show-mode-map (kbd "f")
      #'gastown-beads--dispatch-formula-on-current-issue)
    (setq gastown-beads--formula-issue-key-injected t)))


;;; ============================================================
;;; Formula Status Section (Surface 3)
;;; ============================================================

;;;###autoload
(defun gastown-insert-formula-section ()
  "Insert Gas Town formula dispatch section into beads-status buffer.

Shows recent formula dispatches from `gastown-formula--recent-convoy-ids'.
Requires `beads-section' (from be-blg); silently returns nil if not loaded.

Visual format:
  ▼ Gas Town Formula Dispatches             [via gastown.el]
    hq-cv-abc123   mol-polecat-work   (running)"
  (when (and (featurep 'beads-section)
             (boundp 'gastown-formula--recent-convoy-ids)
             gastown-formula--recent-convoy-ids)
    (magit-insert-section (gastown-formula-section)
      (magit-insert-heading
        (concat (propertize "Gas Town Formula Dispatches"
                            'face 'magit-section-heading)
                (propertize "         [via gastown.el]"
                            'face 'shadow)))
      (dolist (convoy-id (seq-take gastown-formula--recent-convoy-ids 5))
        (insert (format "  %s\n" (propertize convoy-id 'face 'default)))))))

(defun gastown-beads--inject-formula-section ()
  "Register `gastown-insert-formula-section' in `beads-status-sections-hook'.
Safe to call when `beads-section' is not loaded — returns nil.
Protected against double-injection by `gastown-beads--formula-section-injected'."
  (when (and (not gastown-beads--formula-section-injected)
             (boundp 'beads-status-sections-hook))
    (add-hook 'beads-status-sections-hook #'gastown-insert-formula-section)
    (setq gastown-beads--formula-section-injected t)))


;;; ============================================================
;;; After-load Handler
;;; ============================================================

(defun gastown-beads--after-load (_filename)
  "Perform pending injections after a file is loaded.
Called via `after-load-functions' with the loaded FILENAME."
  (gastown-beads--inject-dispatch)
  (gastown-beads--inject-section-hook)
  (gastown-beads--inject-formula-issue-key)
  (gastown-beads--inject-formula-section))

(add-hook 'after-load-functions #'gastown-beads--after-load)

;; Also inject immediately in case beads/beads-section are already loaded
(gastown-beads--inject-dispatch)
(gastown-beads--inject-section-hook)
(gastown-beads--inject-formula-issue-key)
(gastown-beads--inject-formula-section)

(provide 'gastown-beads)
;;; gastown-beads.el ends here
