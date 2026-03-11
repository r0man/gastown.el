;;; gastown-status-buffer.el --- Rich interactive status buffer using vui.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the magit-section-mode implementation
;; with a vui.el declarative component that:
;;
;;   - Immediately shows a loading indicator on invocation
;;   - Fetches `gt status --json' via async process (make-process)
;;   - Once data arrives, renders the full status view declaratively
;;   - Provides context-aware actions: agent → tmux session, polecat → detail
;;   - Rig sections are collapsible (click header or press RET on header)
;;   - g → refresh, q → quit, w → watch mode toggle
;;   - `gastown-status-current-section' returns context at point for transient readers
;;
;; Entry point: `gastown-status-show-buffer' or via M-x gastown-status.
;;
;; `gastown-status--render DATA' renders synchronously into the current
;; buffer — used for testing.

;;; Code:

(require 'vui)
(require 'gastown-command-status)
(require 'gastown-types)

;; Forward declarations for optional interactive features
(declare-function gastown-mail-inbox "gastown-command-mail")
(declare-function gastown-polecat-detail-show "gastown-polecat-detail")

;;; ============================================================
;;; Faces
;;; ============================================================

(defgroup gastown-status-buffer nil
  "Faces for the Gas Town status buffer."
  :group 'gastown
  :prefix "gastown-status-")

(defface gastown-status-running
  '((t :inherit success))
  "Face for the running indicator (●)."
  :group 'gastown-status-buffer)

(defface gastown-status-stopped
  '((t :inherit shadow))
  "Face for the stopped indicator (○)."
  :group 'gastown-status-buffer)

(defface gastown-status-rig-separator
  '((t :weight bold))
  "Face for rig section headings."
  :group 'gastown-status-buffer)

(defface gastown-status-mail-indicator
  '((t :inherit warning))
  "Face for unread mail indicator (📬N)."
  :group 'gastown-status-buffer)

(defface gastown-status-link
  '((t :inherit link))
  "Face for clickable links."
  :group 'gastown-status-buffer)

;;; ============================================================
;;; Constants
;;; ============================================================

(defconst gastown-status-buffer-name "*gastown-status*"
  "Name of the Gas Town status buffer.")

(defconst gastown-status--role-icons
  '(("coordinator" . "🎩")
    ("health-check" . "🐺")
    ("witness"      . "🦉")
    ("refinery"     . "🏭")
    ("polecat"      . "😺")
    ("crew"         . "👷"))
  "Mapping from role string to display icon.")

;;; ============================================================
;;; Section Types (EIEIO data containers — no magit-section)
;;; ============================================================
;;
;; These classes serve as typed containers for context detection
;; (see `gastown-status-current-section' and gastown-context.el).
;; They are attached to buffer text via `gastown-status-section'
;; text property.

(defclass gastown-services-section ()
  nil
  "Data container for the services overview line.")

(defclass gastown-service-section ()
  ((service :initarg :service :initform nil))
  "Data container for an individual service.")

(defclass gastown-agents-section ()
  nil
  "Data container for the global agents block.")

(defclass gastown-agent-section ()
  ((agent  :initarg :agent  :initform nil)
   (parent :initarg :parent :initform nil))
  "Data container for an individual agent row.")

(defclass gastown-rig-section ()
  ((rig    :initarg :rig    :initform nil)
   (parent :initarg :parent :initform nil))
  "Data container for a rig section.")

(defclass gastown-polecat-section ()
  ((polecat  :initarg :polecat  :initform nil)
   (rig-name :initarg :rig-name :initform nil)
   (parent   :initarg :parent   :initform nil))
  "Data container for an individual polecat row.")

;;; ============================================================
;;; Context Detection
;;; ============================================================

(defun gastown-status-current-section ()
  "Return the section object at point in a Gas Town status buffer.

Returns an EIEIO instance of one of the `gastown-*-section' classes
when point is on a line that has context metadata attached, or nil
when not in a status buffer or no context is at point.

Used by `gastown-agent-at-point' in gastown-context.el for
context-aware transient command auto-fill."
  (get-text-property (point) 'gastown-status-section))

(defun gastown-status--propertize-section (str section)
  "Return STR with SECTION stored as the `gastown-status-section' text property."
  (propertize str 'gastown-status-section section))

;;; ============================================================
;;; Mode
;;; ============================================================

(defvar-keymap gastown-status-mode-map
  :parent vui-mode-map
  "g"   #'gastown-status-refresh
  "q"   #'quit-window
  "w"   #'gastown-status-toggle-watch)

(define-derived-mode gastown-status-mode vui-mode "GT-Status"
  "Major mode for the Gas Town status buffer (vui.el based).

Displays an interactive overview of the Gas Town workspace with
async loading, collapsible rig sections, and clickable elements.

Key bindings:
\\{gastown-status-mode-map}"
  :group 'gastown-status-buffer
  (setq truncate-lines t)
  (add-hook 'kill-buffer-hook #'gastown-status--cancel-watch nil t))

;;; ============================================================
;;; Buffer-Local State
;;; ============================================================

(defvar-local gastown-status--data nil
  "Current status data as a `gastown-gt-status' object.")

(defvar-local gastown-status--watch-timer nil
  "Auto-refresh timer, or nil when watch mode is off.")

(defvar-local gastown-status--watch-interval 10
  "Seconds between auto-refreshes in watch mode.")

;;; ============================================================
;;; Rendering Helpers (pure functions)
;;; ============================================================

(defun gastown-status--role-icon (role)
  "Return the display icon for ROLE string."
  (or (cdr (assoc role gastown-status--role-icons)) "?"))

(defun gastown-status--running-indicator (running)
  "Return a propertized ●/○ indicator for RUNNING boolean."
  (if running
      (propertize "●" 'face 'gastown-status-running)
    (propertize "○" 'face 'gastown-status-stopped)))

(defun gastown-status--abbreviate-path (path)
  "Replace home directory prefix in PATH with ~."
  (if (and path (stringp path))
      (let ((home (expand-file-name "~")))
        (if (string-prefix-p home path)
            (concat "~" (substring path (length home)))
          path))
    (or path "")))

;;; ============================================================
;;; Async Data Fetch
;;; ============================================================

(defun gastown-status--async-fetch (resolve reject)
  "Start async `gt status --json' fetch.
RESOLVE is called with a `gastown-gt-status' object on success.
REJECT is called with an error message string on failure."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-status-fetch"
     :command (list exe "status" "--json")
     :filter (lambda (_proc chunk)
               (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (if (string-prefix-p "finished" event)
                     (condition-case err
                         (let ((json-array-type 'list)
                               (json-object-type 'alist))
                           (funcall resolve
                                    (gastown-gt-status-from-json
                                     (json-read-from-string output))))
                       (error (funcall reject (error-message-string err))))
                   (funcall reject (format "Process ended: %s" (string-trim event)))))
     :connection-type 'pipe)))

;;; ============================================================
;;; vnode Builders (stateless — return vui vnodes)
;;; ============================================================

(defun gastown-status--overseer-vnode (overseer)
  "Build overseer line vnode from OVERSEER (`gastown-overseer')."
  (when overseer
    (let* ((o-name   (or (oref overseer name) ""))
           (o-email  (or (oref overseer email) ""))
           (o-unread (or (oref overseer unread-mail) 0)))
      (vui-hstack :spacing 0
        (vui-text (format "👤 Overseer: %s" o-name))
        (unless (string-empty-p o-email)
          (vui-text (format " <%s>" o-email)))
        (when (> o-unread 0)
          (vui-button
           (propertize (format " 📬%d" o-unread)
                       'face 'gastown-status-mail-indicator)
           :no-decoration t
           :help-echo "Open mail inbox"
           :on-click (lambda ()
                       (when (fboundp 'gastown-mail-inbox)
                         (call-interactively #'gastown-mail-inbox)))))))))

(defun gastown-status--services-vnode (daemon dolt tmux)
  "Build the services line vnode from DAEMON, DOLT, and TMUX objects."
  (let* ((d-pid      (and daemon (oref daemon pid)))
         (dolt-pid   (and dolt (oref dolt pid)))
         (dolt-port  (and dolt (oref dolt port)))
         (dolt-dir   (gastown-status--abbreviate-path
                      (and dolt (oref dolt data-dir))))
         (dolt-dir-abs (and dolt (oref dolt data-dir)))
         (tmux-socket  (and tmux (oref tmux socket)))
         (tmux-pid     (and tmux (oref tmux pid)))
         (tmux-count   (and tmux (oref tmux session-count)))
         (tmux-path    (and tmux (oref tmux socket-path))))
    (apply #'vui-hstack :spacing 0
           (delq nil
                 (list
                  (vui-text "Services:")
                  (when daemon
                    (vui-text (format "  daemon%s"
                                      (if d-pid (format " (PID %d)" d-pid) ""))))
                  (when dolt
                    (list
                     (vui-text (format "  dolt (PID %d, :%d, "
                                       (or dolt-pid 0)
                                       (or dolt-port 0)))
                     (if (and dolt-dir-abs (not (string-empty-p dolt-dir-abs)))
                         (vui-button dolt-dir
                           :no-decoration t
                           :face 'gastown-status-link
                           :help-echo (format "Open Dired: %s" dolt-dir-abs)
                           :on-click (let ((p dolt-dir-abs))
                                       (lambda () (dired p))))
                       (vui-text (or dolt-dir "")))
                     (vui-text ")")))
                  (when tmux
                    (vui-text (format "  tmux (-L %s, PID %d, %d session%s, %s)"
                                      (or tmux-socket "")
                                      (or tmux-pid 0)
                                      (or tmux-count 0)
                                      (if (eql tmux-count 1) "" "s")
                                      (or tmux-path "")))))))))

(defun gastown-status--agent-line-vnode (agent &optional rig-section)
  "Build a single AGENT (`gastown-agent') row vnode.
Optionally RIG-SECTION is the parent `gastown-rig-section' for context."
  (let* ((name      (or (oref agent name) ""))
         (role      (or (oref agent role) ""))
         (running   (oref agent running))
         (session   (oref agent session))
         (info      (or (oref agent agent-info) ""))
         (unread    (or (oref agent unread-mail) 0))
         (subject   (oref agent first-subject))
         (icon      (gastown-status--role-icon role))
         (indicator (gastown-status--running-indicator running))
         (section   (gastown-agent-section :agent agent :parent rig-section))
         (label     (gastown-status--propertize-section
                     (concat
                      icon " "
                      (format "%-12s" name)
                      " " indicator
                      (unless (string-empty-p info) (format " [%s]" info))
                      (when (and subject (not (string-empty-p subject)))
                        (let* ((sc (replace-regexp-in-string "^🤝 HANDOFF: " "" subject))
                               (ss (if (> (length sc) 30)
                                       (concat (substring sc 0 29) "…")
                                     sc)))
                          (format " → %s" ss)))
                      (when (> unread 0)
                        (propertize (format " 📬%d" unread)
                                    'face 'gastown-status-mail-indicator)))
                     section)))
    (if (and session running)
        (vui-button label
          :no-decoration t
          :help-echo (format "Switch to tmux session: gt:%s" session)
          :on-click (let ((s session))
                      (lambda ()
                        (shell-command (format "tmux select-window -t gt:%s" s)))))
      (vui-text label))))

(defun gastown-status--polecat-line-vnode (agent rig-name &optional rig-section)
  "Build a crew/polecat AGENT (`gastown-agent') row vnode.
RIG-NAME is the rig's name string.  RIG-SECTION is the parent section."
  (let* ((name      (or (oref agent name) ""))
         (running   (oref agent running))
         (session   (oref agent session))
         (info      (or (oref agent agent-info) ""))
         (unread    (or (oref agent unread-mail) 0))
         (indicator (gastown-status--running-indicator running))
         (section   (gastown-polecat-section :polecat agent
                                             :rig-name rig-name
                                             :parent rig-section))
         (label     (gastown-status--propertize-section
                     (concat
                      "   "
                      (format "%-12s" name)
                      " " indicator
                      (unless (string-empty-p info) (format " [%s]" info))
                      (when (> unread 0)
                        (propertize (format " 📬%d" unread)
                                    'face 'gastown-status-mail-indicator)))
                     section)))
    (if (and session running)
        (vui-button label
          :no-decoration t
          :help-echo (format "Open polecat detail: %s/%s" rig-name name)
          :on-click (let ((a agent) (r rig-name))
                      (lambda ()
                        (if (fboundp 'gastown-polecat-detail-show)
                            (gastown-polecat-detail-show a r)
                          (shell-command
                           (format "tmux select-window -t gt:%s" session))))))
      (vui-text label))))

;;; ============================================================
;;; Rig Component (collapsible, local state)
;;; ============================================================

(vui-defcomponent gastown-status-rig-widget (rig)
  "Collapsible rig section component."
  :state ((collapsed nil))
  :render
  (let* ((rig-name    (or (oref rig name) "unknown"))
         (agents-list (oref rig agents))
         (witnesses   (seq-filter (lambda (a) (equal (oref a role) "witness"))
                                  agents-list))
         (refineries  (seq-filter (lambda (a) (equal (oref a role) "refinery"))
                                  agents-list))
         (polecats    (seq-filter (lambda (a) (equal (oref a role) "polecat"))
                                  agents-list))
         (crews       (seq-filter (lambda (a) (equal (oref a role) "crew"))
                                  agents-list))
         (rig-sec     (gastown-rig-section :rig rig))
         (header-label (gastown-status--propertize-section
                        (format "─── %s/ ──────────────────" rig-name)
                        rig-sec)))
    (vui-vstack
     ;; Rig separator header — click to toggle collapse
     (vui-button header-label
       :no-decoration t
       :face 'gastown-status-rig-separator
       :help-echo (if collapsed "Expand rig section" "Collapse rig section")
       :on-click (lambda () (vui-set-state 'collapsed (not collapsed))))
     ;; Body — only shown when not collapsed
     (unless collapsed
       (vui-vstack
        ;; Witness + refinery agents
        (mapcar (lambda (a) (gastown-status--agent-line-vnode a rig-sec))
                witnesses)
        (mapcar (lambda (a) (gastown-status--agent-line-vnode a rig-sec))
                refineries)
        ;; Crew block
        (when crews
          (vui-vstack
           (vui-text (format "👷 Crew (%d)" (length crews)))
           (mapcar (lambda (a)
                     (gastown-status--polecat-line-vnode a rig-name rig-sec))
                   crews)))
        ;; Polecats block
        (when polecats
          (vui-vstack
           (vui-text (format "😺 Polecats (%d)" (length polecats)))
           (mapcar (lambda (a)
                     (gastown-status--polecat-line-vnode a rig-name rig-sec))
                   polecats))))))))

;;; ============================================================
;;; Full Content vnode (synchronous, called from both components)
;;; ============================================================

(defun gastown-status--full-content-vnode (data)
  "Build the complete status view vnode tree from DATA (`gastown-gt-status')."
  (let* ((name     (or (oref data name) "unknown"))
         (location (or (oref data location) ""))
         (overseer (oref data overseer))
         (daemon   (oref data daemon))
         (dolt     (oref data dolt))
         (tmux     (oref data tmux))
         (agents   (oref data agents))
         (rigs     (oref data rigs)))
    (vui-vstack
     ;; Town name and location
     (vui-text (format "Town: %s" name))
     (vui-text location)
     (vui-newline)
     ;; Overseer
     (gastown-status--overseer-vnode overseer)
     (vui-newline)
     ;; Services line
     (gastown-status--services-vnode daemon dolt tmux)
     (vui-newline)
     ;; Global agents (mayor, deacon, etc.)
     (mapcar #'gastown-status--agent-line-vnode agents)
     ;; Rig sections
     (when rigs
       (mapcar (lambda (rig)
                 (vui-component 'gastown-status-rig-widget
                   :rig rig
                   :key (oref rig name)))
               rigs)))))

;;; ============================================================
;;; Synchronous App Component (for gastown-status--render / tests)
;;; ============================================================

(vui-defcomponent gastown-status-sync-app (data)
  "Static status render component — no async loading.
Used by `gastown-status--render' for synchronous rendering in tests."
  :render
  (gastown-status--full-content-vnode data))

;;; ============================================================
;;; Async App Component (for interactive use)
;;; ============================================================

(vui-defcomponent gastown-status-app ()
  "Root async component for the Gas Town status buffer.
Fetches `gt status --json' asynchronously and renders on arrival."
  :state ((refresh-tick 0))
  :render
  (let* ((result
          (vui-use-async (list 'status refresh-tick)
            (lambda (resolve reject)
              (gastown-status--async-fetch resolve reject))))
         (status (plist-get result :status))
         (data   (plist-get result :data))
         (err    (plist-get result :error)))
    (pcase status
      ('pending
       (vui-text (propertize "⏳ Loading Gas Town status…"
                             'face 'gastown-status-stopped)))
      ('error
       (vui-vstack
        (vui-text (propertize "Error loading status:" 'face 'error))
        (vui-text (propertize (or err "unknown error") 'face 'error))
        (vui-newline)
        (vui-button "[Retry]"
          :on-click (lambda ()
                      (vui-set-state 'refresh-tick (1+ refresh-tick))))))
      ('ready
       (gastown-status--full-content-vnode data)))))

;;; ============================================================
;;; Main Render (synchronous, for testing)
;;; ============================================================

(defun gastown-status--render (data)
  "Render status DATA into the current buffer synchronously.

DATA must be a `gastown-gt-status' object.  The buffer is erased
and re-rendered.  This function is used by tests and by the
`gastown-status-mode' direct refresh path.

For the interactive async entry point, see `gastown-status-show-buffer'."
  (setq gastown-status--data data)
  (vui-mount
   (vui-component 'gastown-status-sync-app :data data)
   (buffer-name)))

;;; ============================================================
;;; Interactive Commands
;;; ============================================================

;;;###autoload
(defun gastown-status-refresh ()
  "Refresh the *gastown-status* buffer with current status."
  (interactive)
  (gastown-status-show-buffer))

(defun gastown-status--revert (_ignore-auto _noconfirm)
  "Revert function for `revert-buffer-function'."
  (gastown-status-refresh))

(defun gastown-status--cancel-watch ()
  "Cancel the watch timer if active."
  (when gastown-status--watch-timer
    (cancel-timer gastown-status--watch-timer)
    (setq gastown-status--watch-timer nil)))

;;;###autoload
(defun gastown-status-toggle-watch ()
  "Toggle auto-refresh watch mode for the status buffer."
  (interactive)
  (if gastown-status--watch-timer
      (progn
        (gastown-status--cancel-watch)
        (message "Watch mode disabled"))
    (let ((buf (current-buffer)))
      (setq gastown-status--watch-timer
            (run-with-timer
             gastown-status--watch-interval
             gastown-status--watch-interval
             (lambda ()
               (when (buffer-live-p buf)
                 (with-current-buffer buf
                   (gastown-status-show-buffer)))))))
    (message "Watch mode enabled (refresh every %ds)"
             gastown-status--watch-interval)))

;;; ============================================================
;;; Buffer Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-status-show-buffer ()
  "Show the *gastown-status* buffer with Gas Town status (async)."
  (interactive)
  (let ((buf (get-buffer-create gastown-status-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-status-mode)
        (gastown-status-mode)))
    (vui-mount
     (vui-component 'gastown-status-app)
     gastown-status-buffer-name)
    (pop-to-buffer gastown-status-buffer-name)))

;;; ============================================================
;;; Method Override
;;; ============================================================

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-status))
  "Show Gas Town status in the dedicated *gastown-status* buffer."
  (gastown-status-show-buffer))

(provide 'gastown-status-buffer)
;;; gastown-status-buffer.el ends here
