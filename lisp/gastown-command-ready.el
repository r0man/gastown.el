;;; gastown-command-ready.el --- Rich interactive ready buffer using vui.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides a rich, interactive Emacs-native ready buffer for `gt ready --json'
;; output.  It uses vui.el declarative components to render output matching
;; the CLI format with additional Emacs enhancements:
;;
;;   - Immediately shows a spinner while fetching `gt ready --json'
;;   - Renders output matching CLI format (status icon, priority tag, ID, title)
;;   - Issues are grouped by source (rig/town) with item counts
;;   - Clickable issue IDs: RET or click opens beads-show for that issue
;;   - Priority-based faces: P0=red, P1=orange, P2=default, P3/P4=dim
;;   - Auto-refresh: w key toggles watch mode
;;   - g to refresh, q to quit
;;   - Collapsible source sections
;;
;; Key bindings in gastown-ready-mode:
;;   g   - Refresh
;;   w   - Toggle watch mode
;;   RET - Open issue at point in beads
;;   q   - Quit window

;;; Code:

(require 'vui)
(require 'gastown-command)
(require 'gastown-command-work)
(require 'gastown-types)
(require 'beads-command-show)

;;; ============================================================
;;; Customization
;;; ============================================================

(defgroup gastown-ready-buffer nil
  "Faces and settings for the Gas Town ready buffer."
  :group 'gastown
  :prefix "gastown-ready-")

(defcustom gastown-ready-refresh-interval nil
  "Seconds between auto-refreshes while the ready buffer is visible.
Set to nil to disable auto-refresh."
  :type '(choice (integer :tag "Seconds")
                 (const :tag "Disabled" nil))
  :group 'gastown-ready-buffer)

;;; ============================================================
;;; Faces
;;; ============================================================

(defface gastown-ready-priority-critical
  '((t :foreground "red" :weight bold))
  "Face for priority 0 (critical)."
  :group 'gastown-ready-buffer)

(defface gastown-ready-priority-high
  '((t :foreground "orange" :weight bold))
  "Face for priority 1 (high)."
  :group 'gastown-ready-buffer)

(defface gastown-ready-priority-medium
  '((t))
  "Face for priority 2 (medium)."
  :group 'gastown-ready-buffer)

(defface gastown-ready-priority-low
  '((t :inherit shadow))
  "Face for priority 3-4 (low/backlog)."
  :group 'gastown-ready-buffer)

(defface gastown-ready-section-header
  '((t :weight bold))
  "Face for source section headers."
  :group 'gastown-ready-buffer)

(defface gastown-ready-issue-id
  '((t :inherit link))
  "Face for clickable issue IDs."
  :group 'gastown-ready-buffer)

(defface gastown-ready-status-icon
  '((t :inherit shadow))
  "Face for status icons."
  :group 'gastown-ready-buffer)

;;; ============================================================
;;; Constants
;;; ============================================================

(defconst gastown-ready-buffer-name "*gastown-ready*"
  "Name of the Gas Town ready buffer.")

(defconst gastown-ready--status-icons
  '(("open"        . "○")
    ("in_progress" . "◐")
    ("blocked"     . "●")
    ("closed"      . "✓")
    ("deferred"    . "❄"))
  "Mapping from issue status string to display icon.")

;;; ============================================================
;;; Mode
;;; ============================================================

(defvar-keymap gastown-ready-mode-map
  :parent vui-mode-map
  "g"   #'gastown-ready-refresh
  "q"   #'quit-window
  "w"   #'gastown-ready-toggle-watch
  "RET" #'gastown-ready-show-issue)

(define-derived-mode gastown-ready-mode vui-mode "GT-Ready"
  "Major mode for the Gas Town ready buffer (vui.el based).

Displays ready work across town with progressive loading,
collapsible source sections, and clickable issue IDs.

Key bindings:
\\{gastown-ready-mode-map}"
  :group 'gastown-ready-buffer
  (setq truncate-lines t)
  (add-hook 'kill-buffer-hook #'gastown-ready--cancel-watch nil t))

;;; ============================================================
;;; Buffer-Local State
;;; ============================================================

(defvar-local gastown-ready--watch-timer nil
  "Auto-refresh timer, or nil when watch mode is off.")

(defvar-local gastown-ready--watch-interval nil
  "Effective refresh interval (seconds) for this buffer's watch timer.")

;;; ============================================================
;;; Priority Helpers
;;; ============================================================

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

;;; ============================================================
;;; Status Icon Helper
;;; ============================================================

(defun gastown-ready--status-icon (status)
  "Return the display icon for STATUS string."
  (or (cdr (assoc status gastown-ready--status-icons)) "○"))

;;; ============================================================
;;; Count Issues Helper
;;; ============================================================

(defun gastown-ready--count-issues (sources)
  "Return (total p1-count p2-count) across all SOURCES.
SOURCES is a list of `gastown-ready-source' objects."
  (let ((total 0) (p1 0) (p2 0))
    (dolist (source sources)
      (dolist (issue (oref source issues))
        (cl-incf total)
        (let ((pri (oref issue priority)))
          (cond ((eql pri 1) (cl-incf p1))
                ((eql pri 2) (cl-incf p2))))))
    (list total p1 p2)))

;;; ============================================================
;;; Parse Data Helper
;;; ============================================================

(defun gastown-ready--parse-data (data)
  "Parse raw JSON DATA alist into a list of `gastown-ready-source' objects."
  (mapcar #'gastown-ready-source-from-json
          (gastown-types--json-list (alist-get 'sources data))))

;;; ============================================================
;;; Async Data Fetch
;;; ============================================================

(defun gastown-ready--async-fetch (resolve reject)
  "Start async `gt ready --json' fetch.
RESOLVE is called with a list of `gastown-ready-source' objects on success.
REJECT is called with an error message string on failure."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-ready-fetch"
     :command (list exe "ready" "--json")
     :filter (lambda (_proc chunk)
               (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (if (string-prefix-p "finished" event)
                     (condition-case err
                         (let ((json-array-type 'list)
                               (json-object-type 'alist))
                           (funcall resolve
                                    (gastown-ready--parse-data
                                     (json-read-from-string output))))
                       (error (funcall reject (error-message-string err))))
                   (funcall reject (format "Process ended: %s" (string-trim event)))))
     :connection-type 'pipe)))

;;; ============================================================
;;; vnode Builders
;;; ============================================================

(defun gastown-ready--issue-vnode (issue)
  "Build a vnode for a single ISSUE (`gastown-ready-issue')."
  (let* ((id       (or (oref issue id) ""))
         (title    (or (oref issue title) ""))
         (priority (oref issue priority))
         (status   (or (oref issue status) "open"))
         (pri-tag  (gastown-ready--format-priority-tag priority))
         (icon     (propertize (gastown-ready--status-icon status)
                               'face 'gastown-ready-status-icon))
         (id-str   (propertize id
                               'face 'gastown-ready-issue-id
                               'gastown-ready-issue-id id)))
    (vui-hstack :spacing 1
      (vui-text icon)
      (vui-text pri-tag)
      (vui-button id-str
        :no-decoration t
        :help-echo (format "RET: open %s in beads" id)
        :on-click (let ((issue-id id))
                    (lambda () (beads-show issue-id))))
      (vui-text title))))

(defun gastown-ready--footer-vnode (sources)
  "Build a footer vnode summarizing SOURCES."
  (cl-destructuring-bind (total p1 p2)
      (gastown-ready--count-issues sources)
    (when (> total 0)
      (vui-vstack
       (vui-newline)
       (vui-text (format "Total: %d item%s ready (%d P1, %d P2)"
                         total (if (= total 1) "" "s") p1 p2))
       (vui-text (propertize "Status: ○ open  ◐ in_progress  ● blocked  ✓ closed  ❄ deferred"
                             'face 'gastown-ready-status-icon))))))

;;; ============================================================
;;; Source Widget (collapsible, with local state)
;;; ============================================================

(vui-defcomponent gastown-ready-source-widget (source)
  "Collapsible source section component.
SOURCE is a `gastown-ready-source' object."
  :state ((collapsed nil))
  :render
  (let* ((name   (or (oref source name) "unknown"))
         (issues (oref source issues))
         (count  (length issues))
         (header (if (> count 0)
                     (format "%s/ (%d item%s)"
                             name count (if (= count 1) "" "s"))
                   (format "%s/ (none)" name))))
    (vui-vstack
     (vui-button (propertize header 'face 'gastown-ready-section-header)
       :no-decoration t
       :face 'gastown-ready-section-header
       :help-echo (if collapsed "Expand section" "Collapse section")
       :on-click (lambda () (vui-set-state :collapsed (not collapsed))))
     (unless collapsed
       (when issues
         (apply #'vui-vstack
                (mapcar #'gastown-ready--issue-vnode issues)))))))

;;; ============================================================
;;; Full Content vnode
;;; ============================================================

(defun gastown-ready--full-content-vnode (sources)
  "Build the complete ready view vnode from SOURCES list."
  (apply #'vui-vstack
         (propertize "📋 Ready work across town:"
                     'face 'gastown-ready-section-header)
         (vui-newline)
         (append
          (mapcar (lambda (source)
                    (vui-component 'gastown-ready-source-widget
                      :source source
                      :key (oref source name)))
                  sources)
          (list (gastown-ready--footer-vnode sources)))))

;;; ============================================================
;;; Sync App Component (for gastown-ready--render / tests)
;;; ============================================================

(vui-defcomponent gastown-ready-sync-app (sources)
  "Static ready render component — no async loading.
Used by `gastown-ready--render' for synchronous rendering in tests."
  :render
  (gastown-ready--full-content-vnode sources))

;;; ============================================================
;;; Async App Component (progressive loading)
;;; ============================================================

(vui-defcomponent gastown-ready-app ()
  "Root async component for the Gas Town ready buffer.

Fetches `gt ready --json' asynchronously, shows spinner while loading,
renders issues grouped by source on success."
  :state ((refresh-tick 0))
  :render
  (let* ((result (vui-use-async (list 'ready refresh-tick)
                   #'gastown-ready--async-fetch))
         (status  (plist-get result :status))
         (sources (plist-get result :data))
         (err     (plist-get result :error)))
    (cond
     ((eq status 'pending)
      (vui-text (propertize "⏳ Loading ready work…"
                            'face 'gastown-ready-status-icon)))
     (err
      (vui-vstack
       (vui-text (propertize "Error loading ready work:" 'face 'error))
       (vui-text (propertize (or err "unknown error") 'face 'error))
       (vui-newline)
       (vui-button "[Retry]"
         :on-click (let ((tick refresh-tick))
                     (lambda ()
                       (vui-set-state :refresh-tick (1+ tick)))))))
     (sources
      (gastown-ready--full-content-vnode sources))
     (t
      (vui-text (propertize "No ready work found."
                            'face 'gastown-ready-status-icon))))))

;;; ============================================================
;;; Synchronous Render (for testing)
;;; ============================================================

(defun gastown-ready--render (data)
  "Render ready DATA (raw JSON alist) into the current buffer synchronously.

DATA must be a raw JSON alist with a `sources' key.  The buffer is erased
and re-rendered via vui-mount.  Used by tests and direct refresh."
  (let ((sources (gastown-ready--parse-data data)))
    (vui-mount
     (vui-component 'gastown-ready-sync-app :sources sources)
     (buffer-name))))

;;; ============================================================
;;; Watch Mode
;;; ============================================================

(defun gastown-ready--cancel-watch ()
  "Cancel the watch timer if active."
  (when gastown-ready--watch-timer
    (cancel-timer gastown-ready--watch-timer)
    (setq gastown-ready--watch-timer nil)))

(defun gastown-ready--start-watch (buf interval)
  "Start auto-refresh timer for BUF with INTERVAL seconds."
  (gastown-ready--cancel-watch)
  (with-current-buffer buf
    (setq gastown-ready--watch-timer
          (run-with-timer
           interval interval
           (lambda ()
             (when (and (buffer-live-p buf)
                        (get-buffer-window buf))
               (vui-mount
                (vui-component 'gastown-ready-app)
                gastown-ready-buffer-name)))))))

;;; ============================================================
;;; Interactive Commands
;;; ============================================================

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
  (vui-mount
   (vui-component 'gastown-ready-app)
   gastown-ready-buffer-name))

;;;###autoload
(defun gastown-ready-toggle-watch ()
  "Toggle auto-refresh watch mode for the ready buffer."
  (interactive)
  (if gastown-ready--watch-timer
      (progn
        (gastown-ready--cancel-watch)
        (message "Watch mode disabled"))
    (let* ((buf (current-buffer))
           (interval (or gastown-ready--watch-interval
                         gastown-ready-refresh-interval
                         30)))
      (gastown-ready--start-watch buf interval)
      (message "Watch mode enabled (refresh every %ds)" interval))))

;;; ============================================================
;;; Override gastown-command-execute-interactive
;;; ============================================================

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-ready))
  "Show ready work in a dedicated buffer instead of a terminal."
  (gastown-ready))

;;; ============================================================
;;; Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-ready ()
  "Show ready work across town in a dedicated buffer (async, vui-based)."
  (interactive)
  (let ((buf (get-buffer-create gastown-ready-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-ready-mode)
        (gastown-ready-mode))
      (when (and gastown-ready-refresh-interval
                 (not gastown-ready--watch-timer))
        (gastown-ready--start-watch buf gastown-ready-refresh-interval)))
    (vui-mount
     (vui-component 'gastown-ready-app)
     gastown-ready-buffer-name)
    (pop-to-buffer gastown-ready-buffer-name)))

(provide 'gastown-command-ready)
;;; gastown-command-ready.el ends here
