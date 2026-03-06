;;; gastown-command-ready.el --- Dedicated buffer for gt ready output -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides a dedicated Emacs buffer for `gt ready --json' output with
;; full beads.el integration.  Issues are grouped by source (rig/town)
;; and displayed in tabulated-list-mode with priority/type/assignee/title
;; columns.  Pressing RET on an issue row opens it with `beads-show'.
;;
;; Key bindings in gastown-ready-mode:
;;   g   - Refresh
;;   RET - Open issue in beads
;;   q   - Quit window

;;; Code:

(require 'gastown-command)
(require 'gastown-command-work)
(require 'beads-command-show)

;;; Faces (mirroring beads-list visual style)

(defface gastown-ready-priority-critical
  '((t :foreground "red" :weight bold))
  "Face for priority 0 (critical)."
  :group 'gastown)

(defface gastown-ready-priority-high
  '((t :foreground "orange" :weight bold))
  "Face for priority 1 (high)."
  :group 'gastown)

(defface gastown-ready-priority-medium
  '((t :foreground "yellow"))
  "Face for priority 2 (medium)."
  :group 'gastown)

(defface gastown-ready-priority-low
  '((t :foreground "dim gray"))
  "Face for priority 3-4 (low/backlog)."
  :group 'gastown)

(defface gastown-ready-section-header
  '((t :weight bold :underline t))
  "Face for source section headers."
  :group 'gastown)

;;; Buffer-local state

(defvar-local gastown-ready--sources nil
  "Last fetched sources data (list of alists).")

;;; Formatting helpers

(defun gastown-ready--priority-face (priority)
  "Return face for PRIORITY integer."
  (pcase priority
    (0 'gastown-ready-priority-critical)
    (1 'gastown-ready-priority-high)
    (2 'gastown-ready-priority-medium)
    (_ 'gastown-ready-priority-low)))

(defun gastown-ready--format-priority (priority)
  "Format PRIORITY as a propertized string."
  (let ((str (if (numberp priority) (format "P%d" priority) "")))
    (propertize str 'face (gastown-ready--priority-face priority))))

(defun gastown-ready--truncate (str width)
  "Truncate STR to WIDTH characters."
  (if (and str (> (length str) width))
      (concat (substring str 0 (- width 1)) "…")
    (or str "")))

;;; Tabulated-list entry builders

(defconst gastown-ready--columns
  (vector (list "Pri"      4  nil)
          (list "ID"       10 t)
          (list "Type"     9  t)
          (list "Assignee" 24 t)
          (list "Title"    60 t))
  "Column format for `gastown-ready-mode'.")

(defun gastown-ready--section-entry (source-name)
  "Build a tabulated-list section header entry for SOURCE-NAME."
  (let ((header (propertize (format "── %s " source-name)
                            'face 'gastown-ready-section-header)))
    (list (concat "section:" source-name)
          (vector header "" "" "" ""))))

(defun gastown-ready--issue-entry (issue)
  "Build a tabulated-list entry from ISSUE alist."
  (let* ((id       (or (alist-get 'id issue) ""))
         (title    (or (alist-get 'title issue) ""))
         (type     (or (alist-get 'issue_type issue) ""))
         (priority (alist-get 'priority issue))
         (assignee (or (alist-get 'assignee issue) "")))
    (list id
          (vector (gastown-ready--format-priority priority)
                  id
                  type
                  (gastown-ready--truncate assignee 24)
                  (gastown-ready--truncate title 60)))))

(defun gastown-ready--build-entries (sources)
  "Build tabulated-list entries from SOURCES vector."
  (let (entries)
    (seq-doseq (source sources)
      (let* ((name   (or (alist-get 'name source) "unknown"))
             (issues (or (alist-get 'issues source) [])))
        (push (gastown-ready--section-entry name) entries)
        (seq-doseq (issue issues)
          (push (gastown-ready--issue-entry issue) entries))))
    (nreverse entries)))

;;; Mode definition

(defvar gastown-ready-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "g")   #'gastown-ready-refresh)
    (define-key map (kbd "RET") #'gastown-ready-show-issue)
    (define-key map (kbd "q")   #'quit-window)
    map)
  "Keymap for `gastown-ready-mode'.")

(define-derived-mode gastown-ready-mode tabulated-list-mode "Gastown-Ready"
  "Major mode for displaying Gas Town ready work.

\\{gastown-ready-mode-map}"
  (setq tabulated-list-format gastown-ready--columns)
  (setq tabulated-list-padding 1)
  (tabulated-list-init-header)
  (hl-line-mode 1))

;;; Interactive commands within the buffer

(defun gastown-ready-show-issue ()
  "Open the issue at point in beads."
  (interactive)
  (let ((id (tabulated-list-get-id)))
    (cond
     ((null id)
      (user-error "No issue at point"))
     ((string-prefix-p "section:" id)
      (user-error "Point is on a section header, not an issue"))
     (t
      (beads-show id)))))

(defun gastown-ready-refresh ()
  "Refresh the *gastown-ready* buffer."
  (interactive)
  (gastown-ready--populate-buffer))

;;; Buffer population

(defun gastown-ready--populate-buffer ()
  "Fetch gt ready --json and render into the current buffer."
  (let* ((cmd (gastown-command-ready :json t))
         (execution (gastown-command-execute cmd))
         (data (oref execution result))
         (sources (or (alist-get 'sources data) [])))
    (setq gastown-ready--sources sources)
    (setq tabulated-list-entries (gastown-ready--build-entries sources))
    (tabulated-list-print t)
    (message "Gastown ready: refreshed")))

;;; Override gastown-command-execute-interactive

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-ready))
  "Show ready work in a dedicated buffer instead of a terminal."
  (let ((buf (get-buffer-create "*gastown-ready*")))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-ready-mode)
        (gastown-ready-mode))
      (gastown-ready--populate-buffer))
    (pop-to-buffer buf)))

(provide 'gastown-command-ready)
;;; gastown-command-ready.el ends here
