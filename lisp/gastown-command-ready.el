;;; gastown-command-ready.el --- Dedicated buffer for gt ready output -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides a dedicated Emacs buffer for `gt ready --json' output.
;; Issues are grouped by source (rig/town) and displayed in a
;; special-mode buffer matching the CLI rendering, with Emacs-native
;; interactivity: clicking or pressing RET on an issue ID opens it
;; with `beads-show'.
;;
;; Key bindings in gastown-ready-mode:
;;   g   - Refresh
;;   RET - Open issue at point in beads
;;   q   - Quit window

;;; Code:

(require 'gastown-command)
(require 'gastown-command-work)
(require 'beads-command-show)

;;; Faces

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
  '((t :inherit shadow))
  "Face for priority 3-4 (low/backlog)."
  :group 'gastown)

(defface gastown-ready-section-header
  '((t :weight bold))
  "Face for source section headers."
  :group 'gastown)

(defface gastown-ready-issue-id
  '((t :inherit link))
  "Face for clickable issue IDs."
  :group 'gastown)

;;; Mode

(defvar gastown-ready-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "g")   #'gastown-ready-refresh)
    (define-key map (kbd "RET") #'gastown-ready-show-issue)
    map)
  "Keymap for `gastown-ready-mode'.")

(define-derived-mode gastown-ready-mode special-mode "GT-Ready"
  "Major mode for displaying Gas Town ready work.

\\{gastown-ready-mode-map}"
  (setq truncate-lines t)
  (hl-line-mode 1))

;;; Priority helpers

(defun gastown-ready--priority-face (priority)
  "Return face for PRIORITY integer."
  (pcase priority
    (0 'gastown-ready-priority-critical)
    (1 'gastown-ready-priority-high)
    (2 'gastown-ready-priority-medium)
    (_ 'gastown-ready-priority-low)))

(defun gastown-ready--format-priority-tag (priority)
  "Return propertized '[PN]' tag for PRIORITY."
  (let* ((str (format "[P%s]" (if (numberp priority) priority "?")))
         (face (gastown-ready--priority-face priority)))
    (propertize str 'face face)))

;;; Rendering

(defun gastown-ready--insert-issue (issue)
  "Insert a single ISSUE line into the current buffer."
  (let* ((id       (or (alist-get 'id issue) ""))
         (title    (or (alist-get 'title issue) ""))
         (priority (alist-get 'priority issue))
         (pri-tag  (gastown-ready--format-priority-tag priority))
         (id-btn   (propertize id
                               'face 'gastown-ready-issue-id
                               'gastown-ready-issue-id id
                               'mouse-face 'highlight
                               'help-echo (format "RET: open %s in beads" id)
                               'keymap (let ((m (make-sparse-keymap))
                                             (issue-id id))
                                         (define-key m [mouse-1]
                                           (lambda (_e) (interactive "e")
                                             (beads-show issue-id)))
                                         m))))
    (insert "  " pri-tag " " id-btn " " title "\n")))

(defun gastown-ready--count-issues (sources)
  "Return (total p1-count p2-count) across all SOURCES."
  (let ((total 0) (p1 0) (p2 0))
    (seq-doseq (source sources)
      (let ((issues (or (alist-get 'issues source) [])))
        (seq-doseq (issue issues)
          (cl-incf total)
          (let ((pri (alist-get 'priority issue)))
            (cond ((eql pri 1) (cl-incf p1))
                  ((eql pri 2) (cl-incf p2)))))))
    (list total p1 p2)))

(defun gastown-ready--render (data)
  "Render ready DATA into the current buffer."
  (let* ((inhibit-read-only t)
         (sources (or (alist-get 'sources data) [])))
    (erase-buffer)
    (insert (propertize "📋 Ready work across town:\n\n"
                        'face 'gastown-ready-section-header))
    (seq-doseq (source sources)
      (let* ((name   (or (alist-get 'name source) "unknown"))
             (issues (or (alist-get 'issues source) []))
             (count  (length issues))
             (header (if (> count 0)
                         (format "%s/ (%d item%s)"
                                 name count (if (= count 1) "" "s"))
                       (format "%s/ (none)" name))))
        (insert (propertize header 'face 'gastown-ready-section-header) "\n")
        (seq-doseq (issue issues)
          (gastown-ready--insert-issue issue))
        (when (> count 0) (insert "\n"))))
    (cl-destructuring-bind (total p1 p2)
        (gastown-ready--count-issues sources)
      (when (> total 0)
        (insert (format "Total: %d item%s ready (%d P1, %d P2)\n"
                        total (if (= total 1) "" "s") p1 p2))))
    (goto-char (point-min))))

;;; Interactive commands

(defun gastown-ready-show-issue ()
  "Open the issue at point in beads."
  (interactive)
  (let ((id (get-text-property (point) 'gastown-ready-issue-id)))
    (if id
        (beads-show id)
      (user-error "No issue at point"))))

(defun gastown-ready-refresh ()
  "Refresh the *gastown-ready* buffer."
  (interactive)
  (let* ((cmd  (gastown-command-ready :json t))
         (exec (gastown-command-execute cmd))
         (data (oref exec result)))
    (gastown-ready--render data)
    (message "Ready: refreshed")))

;;; Override gastown-command-execute-interactive

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-ready))
  "Show ready work in a dedicated buffer instead of a terminal."
  (gastown-ready))

;;; Entry point

;;;###autoload
(defun gastown-ready ()
  "Show ready work across town in a dedicated buffer."
  (interactive)
  (let* ((buf  (get-buffer-create "*gastown-ready*"))
         (cmd  (gastown-command-ready :json t))
         (exec (gastown-command-execute cmd))
         (data (oref exec result)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-ready-mode)
        (gastown-ready-mode))
      (gastown-ready--render data))
    (pop-to-buffer buf)))

(provide 'gastown-command-ready)
;;; gastown-command-ready.el ends here
