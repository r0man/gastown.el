;;; gastown-context.el --- Context-aware helpers for Gas Town commands -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides context-aware reader functions for Gas Town transient commands.
;;
;; When invoked with point on a beads issue or Gas Town agent section,
;; commands auto-fill their primary argument instead of prompting.
;;
;; ## Issue context (beads-issue-at-point)
;;
;; `gastown--beads-issue-at-point' is a safe wrapper around
;; `beads-issue-at-point' (from beads.el / be-33r).  It returns the
;; issue ID string at point in a beads buffer, or nil when unavailable.
;;
;; Until be-33r lands on beads.el main, the wrapper degrades gracefully:
;; - Falls back to reading from `beads-issue-section' directly if loaded
;; - Returns nil otherwise
;;
;; ## Agent context (gastown-agent-at-point)
;;
;; `gastown-agent-at-point' reads the target string from the current
;; section in a `gastown-status-mode' buffer:
;;
;; - `gastown-polecat-section' → \"rig-name/polecat-name\"
;; - `gastown-agent-section' with rig parent → \"rig-name/agent-name\"
;; - `gastown-agent-section' without rig parent → \"agent-name\" (global)
;;
;; ## Reader functions (transient protocol)
;;
;; `gastown-reader-bead-id' and `gastown-reader-agent-target' follow the
;; transient reader protocol — they receive (PROMPT INITIAL-INPUT HISTORY)
;; and return a string.  Wire them to command slots via :transient-reader.
;;
;; ## Pattern
;;
;;   (defun gastown--read-bead-or-prompt (prompt)
;;     (or (gastown--beads-issue-at-point) (read-string prompt)))
;;
;; Usage:
;;
;;   (require 'gastown-context)

;;; Code:

(require 'eieio)

;; Forward declarations for optional beads infrastructure (be-33r)
(declare-function beads-issue-at-point "beads-section" ())

;; Forward declarations for gastown-status-buffer section types
(declare-function magit-current-section "magit-section" ())
(defvar gastown-polecat-section)
(defvar gastown-agent-section)
(defvar gastown-rig-section)

;;; ============================================================
;;; Issue context: beads-issue-at-point wrapper
;;; ============================================================

(defun gastown--beads-issue-at-point ()
  "Return the beads issue ID at point, or nil.

This is a safe wrapper around `beads-issue-at-point' (from be-33r).
When `beads-issue-at-point' is available, delegates to it.

Fallback: when `beads-section' is loaded but `beads-issue-at-point'
is not yet available, reads from `beads-issue-section' at point directly.

Returns nil when not in a beads buffer or no issue is at point."
  (cond
   ;; Primary: use beads-issue-at-point when available (be-33r)
   ((fboundp 'beads-issue-at-point)
    (beads-issue-at-point))
   ;; Fallback: read from beads-issue-section directly if beads-section loaded
   ((and (featurep 'beads-section)
         (fboundp 'magit-current-section))
    (when-let* ((section (magit-current-section))
                (_ (object-of-class-p section
                                      (intern "beads-issue-section")))
                (issue (oref section issue)))
      (oref issue id)))
   ;; Not available
   (t nil)))

;;; ============================================================
;;; Agent context: gastown-agent-at-point
;;; ============================================================

(defun gastown-agent-at-point ()
  "Return the Gas Town agent target string at point, or nil.

Reads the current section in a `gastown-status-mode' buffer and
constructs the target string used by `gt peek', `gt nudge', etc.:

- `gastown-polecat-section' → \"rig-name/polecat-name\"
- `gastown-agent-section' with rig parent → \"rig-name/agent-name\"
- `gastown-agent-section' without rig parent → \"agent-name\"

Returns nil when not in a gastown buffer or no agent section is at point."
  (when (and (featurep 'gastown-status-buffer)
             (fboundp 'magit-current-section))
    (when-let* ((section (magit-current-section)))
      (cond
       ;; Polecat section: rig-name and polecat (gastown-agent) both present
       ((object-of-class-p section 'gastown-polecat-section)
        (let* ((polecat  (oref section polecat))
               (rig-name (oref section rig-name))
               (name     (oref polecat name)))
          (when (and rig-name name)
            (format "%s/%s" rig-name name))))
       ;; Agent section: check parent for rig context
       ((object-of-class-p section 'gastown-agent-section)
        (let* ((agent   (oref section agent))
               (name    (oref agent name))
               (parent  (oref section parent))
               (rig-name
                (when (and parent
                           (object-of-class-p parent 'gastown-rig-section))
                  (oref (oref parent rig) name))))
          (when name
            (if rig-name
                (format "%s/%s" rig-name name)
              name))))
       (t nil)))))

;;; ============================================================
;;; Composite readers
;;; ============================================================

(defun gastown--read-bead-or-prompt (prompt)
  "Return the beads issue ID at point, or read one with PROMPT.

Uses `gastown--beads-issue-at-point' to detect context.  Falls back
to `read-string' with PROMPT when no issue is at point."
  (or (gastown--beads-issue-at-point)
      (read-string prompt)))

(defun gastown--read-agent-or-prompt (prompt)
  "Return the Gas Town agent target at point, or read one with PROMPT.

Uses `gastown-agent-at-point' to detect context.  Falls back to
`read-string' with PROMPT when no agent section is at point."
  (or (gastown-agent-at-point)
      (read-string prompt)))

;;; ============================================================
;;; Transient reader functions
;;; ============================================================

(defun gastown-reader-bead-id (prompt &optional _initial-input _history)
  "Transient reader for a beads issue ID.

Returns the issue ID at point when available; otherwise prompts with
PROMPT.  INITIAL-INPUT and HISTORY are accepted but ignored.

Wire this to a command slot via `:transient-reader gastown-reader-bead-id'."
  (gastown--read-bead-or-prompt prompt))

(defun gastown-reader-agent-target (prompt &optional _initial-input _history)
  "Transient reader for a Gas Town agent target string.

Returns the agent target at point when available (e.g., \"gastown_el/nux\");
otherwise prompts with PROMPT.  INITIAL-INPUT and HISTORY are accepted
but ignored.

Wire this to a command slot via `:transient-reader gastown-reader-agent-target'."
  (gastown--read-agent-or-prompt prompt))

(provide 'gastown-context)
;;; gastown-context.el ends here
