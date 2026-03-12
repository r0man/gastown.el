;;; gastown-status-buffer.el --- Rich interactive status buffer using vui.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the magit-section-mode implementation
;; with a vui.el declarative component that:
;;
;;   - Immediately shows fast status (gt status --fast --json) on invocation
;;   - Fetches full `gt status --json' async right after fast render
;;   - Auto-refreshes every `gastown-status-refresh-interval' seconds while
;;     the buffer is visible in a window
;;   - Cancels the timer when the buffer is killed
;;   - Provides context-aware actions: agent → tmux session, polecat → detail
;;   - Rig sections are collapsible (click header or press RET on header)
;;   - g → manual refresh, q → quit, w → watch mode toggle
;;   - `gastown-status-current-section' returns context at point for transient readers
;;
;; Entry point: `gastown-status-show-buffer' or via M-x gastown-status.
;;
;; `gastown-status--render DATA' renders synchronously into the current
;; buffer — used for testing.

;;; Code:

(require 'vui)
(require 'gastown-command)
(require 'gastown-command-status)
(require 'gastown-types)

;; Forward declarations for optional interactive features
(declare-function gastown-mail-inbox "gastown-command-mail")
(declare-function gastown-polecat-detail-show "gastown-polecat-detail")

;;; ============================================================
;;; Customization
;;; ============================================================

(defgroup gastown-status-buffer nil
  "Faces and settings for the Gas Town status buffer."
  :group 'gastown
  :prefix "gastown-status-")

(defcustom gastown-status-refresh-interval 30
  "Seconds between auto-refreshes while the status buffer is visible.
Set to nil to disable auto-refresh."
  :type '(choice (integer :tag "Seconds")
                 (const :tag "Disabled" nil))
  :group 'gastown-status-buffer)

;;; ============================================================
;;; Faces
;;; ============================================================

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

(defface gastown-status-timestamp
  '((t :inherit shadow))
  "Face for the last-refreshed timestamp."
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

(defun gastown-status--activate-button ()
  "Activate the vui button at point via `widget-apply-action'.

Uses `widget-apply-action' rather than `widget-button-press' to
avoid the read-only error that occurs when `widget-button-press'
attempts to modify button text for visual feedback."
  (interactive)
  (let ((widget (widget-at (point))))
    (when widget
      (widget-apply-action widget))))

(defvar-keymap gastown-status-mode-map
  :parent vui-mode-map
  "RET" #'gastown-status--activate-button
  "g"   #'gastown-status-refresh
  "q"   #'quit-window
  "w"   #'gastown-status-toggle-watch)

(define-derived-mode gastown-status-mode vui-mode "GT-Status"
  "Major mode for the Gas Town status buffer (vui.el based).

Displays an interactive overview of the Gas Town workspace with
progressive async loading, collapsible rig sections, and clickable elements.

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

(defvar-local gastown-status--watch-interval nil
  "Effective refresh interval (seconds) for this buffer's watch timer.
Defaults to `gastown-status-refresh-interval' when nil.")

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

(defun gastown-status--rig-separator (rig-name)
  "Build a separator string for RIG-NAME, filling to 60 columns."
  (let* ((prefix (format "─── %s/ " rig-name))
         (fill (max 4 (- 60 (string-width prefix)))))
    (concat prefix (make-string fill ?─))))

;;; ============================================================
;;; Tmux Helpers
;;; ============================================================

(defun gastown-status--tmux-command (session &optional socket)
  "Build a tmux `select-window' command string for SESSION.
SOCKET is the tmux -L argument.  When SOCKET is nil or \"default\",
no -L flag is used (the default server is addressed directly)."
  (if (and socket (not (string= socket "default")))
      (format "tmux -L %s select-window -t %s" socket session)
    (format "tmux select-window -t %s" session)))

(defun gastown-status--show-agent-tmux (session socket)
  "Open an Emacs terminal buffer showing the agent's tmux SESSION.
SOCKET is the tmux -L socket name; nil or \"default\" uses the default server.
Uses `gastown-command--run-in-terminal' so the buffer respects
`gastown-terminal-backend'."
  (let* ((tmux-cmd (if (and socket (not (string= socket "default")))
                       (format "tmux -L %s attach-session -t %s" socket session)
                     (format "tmux attach-session -t %s" session)))
         ;; Unset TMUX so nested attach works when Emacs is inside tmux.
         (cmd (format "env -u TMUX %s" tmux-cmd))
         (buf-name (format "*gt-agent-%s*" session)))
    (gastown-command--run-in-terminal cmd buf-name default-directory)))

;;; ============================================================
;;; Async Data Fetch
;;; ============================================================

(defun gastown-status--async-fetch (resolve reject &optional fast)
  "Start async `gt status --json' fetch.
If FAST is non-nil, passes --fast flag (skips mail lookups).
RESOLVE is called with a `gastown-gt-status' object on success.
REJECT is called with an error message string on failure."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (args (if fast
                   (list exe "status" "--fast" "--json")
                 (list exe "status" "--json")))
         (output ""))
    (make-process
     :name (if fast "gastown-status-fetch-fast" "gastown-status-fetch")
     :command args
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

(defun gastown-status--dnd-vnode (dnd)
  "Build DND status vnode from DND (`gastown-dnd-status')."
  (when dnd
    (let* ((enabled (oref dnd enabled))
           (level   (or (oref dnd level) ""))
           (agent   (or (oref dnd agent) ""))
           (status  (if enabled "on" "off")))
      (vui-vstack
       (vui-hstack :spacing 0
         (vui-text (format "🔔 DND: %s" status))
         (unless (string-empty-p agent)
           (vui-text (format " (%s)" agent))))
       (unless (string-empty-p level)
         (vui-text (format "   notifications %s" level)))))))

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
           (append
            (list (vui-text "Services:"))
            (when daemon
              (list (vui-text (format " daemon%s"
                                      (if d-pid (format " (PID %d)" d-pid) "")))))
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
              (list (vui-text (format "  tmux (-L %s, PID %d, %d session%s, %s)"
                                      (or tmux-socket "")
                                      (or tmux-pid 0)
                                      (or tmux-count 0)
                                      (if (eql tmux-count 1) "" "s")
                                      (or tmux-path "")))))))))

(defun gastown-status--agent-line-vnode (agent &optional rig-section tmux-socket)
  "Build a single AGENT (`gastown-agent') row vnode.
Optionally RIG-SECTION is the parent `gastown-rig-section' for context.
TMUX-SOCKET is the tmux -L socket name used for the switch-to-session action."
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
          :help-echo (format "Show agent in tmux: %s" session)
          :on-click (let ((s session) (sock tmux-socket))
                      (lambda ()
                        (gastown-status--show-agent-tmux s sock))))
      (vui-text label))))

(defun gastown-status--polecat-line-vnode (agent rig-name &optional rig-section tmux-socket)
  "Build a crew/polecat AGENT (`gastown-agent') row vnode.
RIG-NAME is the rig's name string.  RIG-SECTION is the parent section.
TMUX-SOCKET is the tmux -L socket name for the fallback switch-to-session action."
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
          :on-click (let ((a agent) (r rig-name) (sess session) (sock tmux-socket))
                      (lambda ()
                        (if (fboundp 'gastown-polecat-detail-show)
                            (gastown-polecat-detail-show a r)
                          (gastown-status--show-agent-tmux sess sock)))))
      (vui-text label))))

;;; ============================================================
;;; Rig Component (collapsible, local state)
;;; ============================================================

(vui-defcomponent gastown-status-rig-widget (rig tmux-socket)
  "Collapsible rig section component.
RIG is a `gastown-rig-data' object.  TMUX-SOCKET is the tmux -L socket name
passed through to agent row actions."
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
                        (gastown-status--rig-separator rig-name)
                        rig-sec)))
    (vui-vstack
     ;; Blank line before each rig header (between sections)
     (vui-newline)
     ;; Rig separator header — click to toggle collapse
     (vui-button header-label
       :no-decoration t
       :face 'gastown-status-rig-separator
       :help-echo (if collapsed "Expand rig section" "Collapse rig section")
       :on-click (lambda () (vui-set-state :collapsed (not collapsed))))
     ;; Body — only shown when not collapsed
     (unless collapsed
       (vui-vstack
        ;; Witness + refinery agents
        (mapcar (lambda (a) (gastown-status--agent-line-vnode a rig-sec tmux-socket))
                witnesses)
        (mapcar (lambda (a) (gastown-status--agent-line-vnode a rig-sec tmux-socket))
                refineries)
        ;; Crew block
        (when crews
          (vui-vstack
           (vui-text (format "👷 Crew (%d)" (length crews)))
           (mapcar (lambda (a)
                     (gastown-status--polecat-line-vnode a rig-name rig-sec tmux-socket))
                   crews)))
        ;; Polecats block
        (when polecats
          (vui-vstack
           (vui-text (format "😺 Polecats (%d)" (length polecats)))
           (mapcar (lambda (a)
                     (gastown-status--polecat-line-vnode a rig-name rig-sec tmux-socket))
                   polecats))))))))

;;; ============================================================
;;; Full Content vnode (synchronous, called from both components)
;;; ============================================================

(defun gastown-status--full-content-vnode (data &optional timestamp)
  "Build the complete status view vnode tree from DATA (`gastown-gt-status').
TIMESTAMP is an optional `format-time-string' compatible time value for the
last-refreshed line."
  (let* ((name        (or (oref data name) "unknown"))
         (location    (or (oref data location) ""))
         (overseer    (oref data overseer))
         (dnd         (oref data dnd))
         (daemon      (oref data daemon))
         (dolt        (oref data dolt))
         (tmux        (oref data tmux))
         (tmux-socket (and tmux (oref tmux socket)))
         (agents      (oref data agents))
         (rigs        (oref data rigs)))
    (vui-vstack
     ;; Town name and location
     (vui-text (format "Town: %s" name))
     (vui-text location)
     (when timestamp
       (vui-text (propertize
                  (format "Last updated: %s"
                          (format-time-string "%H:%M:%S" timestamp))
                  'face 'gastown-status-timestamp)))
     (vui-newline)
     ;; Overseer
     (gastown-status--overseer-vnode overseer)
     (vui-newline)
     ;; DND
     (gastown-status--dnd-vnode dnd)
     (when dnd (vui-newline))
     ;; Services line
     (gastown-status--services-vnode daemon dolt tmux)
     (vui-newline)
     ;; Global agents (mayor, deacon, etc.)
     (mapcar (lambda (a) (gastown-status--agent-line-vnode a nil tmux-socket)) agents)
     ;; Rig sections (each rig widget prepends its own blank line)
     (when rigs
       (mapcar (lambda (rig)
                 (vui-component 'gastown-status-rig-widget
                   :rig rig
                   :tmux-socket tmux-socket
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
;;; Async App Component (progressive loading)
;;; ============================================================

(vui-defcomponent gastown-status-app ()
  "Root async component for the Gas Town status buffer.

Phase 1 (INSTANT): Fetches `gt status --fast --json' — renders immediately.
Phase 2 (FULL): Fetches `gt status --json' in parallel — replaces fast data
when it arrives.
Phase 3 (AUTO-REFRESH): Timer-driven refresh via `gastown-status-do-refresh'
while buffer is visible (see `gastown-status-refresh-interval').

On refresh, previously-loaded data is shown immediately while new data loads,
eliminating the blank loading flash."
  :state ((refresh-tick 0))
  :render
  ;; Refs persist across re-renders without triggering extra renders.
  ;; last-data-ref holds the most recent full fetch result so we can
  ;; show it while a subsequent refresh is loading.
  (let* ((last-data-ref (vui-use-ref nil))
         (last-ts-ref   (vui-use-ref nil))
         (fast-result
          (vui-use-async (list 'fast refresh-tick)
            (lambda (resolve reject)
              (gastown-status--async-fetch resolve reject t))))
         (full-result
          (vui-use-async (list 'full refresh-tick)
            (lambda (resolve reject)
              (gastown-status--async-fetch resolve reject nil))))
         (fast-status (plist-get fast-result :status))
         (full-status (plist-get full-result :status))
         ;; Prefer full data when ready; fall back to fast data
         (data (or (and (eq full-status 'ready) (plist-get full-result :data))
                   (and (eq fast-status 'ready) (plist-get fast-result :data))))
         (err  (and (not data)
                    (or (plist-get full-result :error)
                        (plist-get fast-result :error)))))
    ;; When full data arrives, save it to refs for use during next refresh.
    ;; Using refs (not state) avoids an extra re-render on update.
    (vui-use-effect ((plist-get full-result :data))
      (let ((d (plist-get full-result :data)))
        (when d
          (setcar last-data-ref d)
          (setcar last-ts-ref (current-time)))))
    (cond
     ;; Both fetches still pending — show stale data if available (no flicker)
     ((and (eq fast-status 'pending) (eq full-status 'pending))
      (if (car last-data-ref)
          (gastown-status--full-content-vnode (car last-data-ref) (car last-ts-ref))
        (vui-text (propertize "⏳ Loading Gas Town status…"
                              'face 'gastown-status-stopped))))
     ;; Error with no data
     (err
      (vui-vstack
       (vui-text (propertize "Error loading status:" 'face 'error))
       (vui-text (propertize (or err "unknown error") 'face 'error))
       (vui-newline)
       (vui-button "[Retry]"
         :on-click (lambda ()
                     (vui-set-state :refresh-tick (1+ refresh-tick))))))
     ;; Data available (fast or full)
     (data
      (gastown-status--full-content-vnode
       data
       ;; Show timestamp only when full data has arrived
       (when (eq full-status 'ready) (current-time)))))))

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

(defun gastown-status-do-refresh (buf)
  "Refresh the status component in BUF without a full remount.

Increments `:refresh-tick' state on the existing `gastown-status-app'
root instance, which triggers new async fetches while keeping the
previous render visible until new data arrives (no flicker).

Returns t when an existing instance was refreshed, nil when BUF has
no live vui root instance (caller should fall back to `vui-mount')."
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (when vui--root-instance
        (let* ((inst  vui--root-instance)
               (state (vui-instance-state inst))
               (tick  (or (plist-get state :refresh-tick) 0)))
          (setf (vui-instance-state inst)
                (plist-put state :refresh-tick (1+ tick))))
        (vui-flush-sync)
        t))))

(defun gastown-status--cancel-watch ()
  "Cancel the watch timer if active."
  (when gastown-status--watch-timer
    (cancel-timer gastown-status--watch-timer)
    (setq gastown-status--watch-timer nil)))

(defun gastown-status--start-watch (buf interval)
  "Start auto-refresh timer for BUF with INTERVAL seconds.
The timer only triggers a refresh when BUF is visible in a window."
  (gastown-status--cancel-watch)
  (with-current-buffer buf
    (setq gastown-status--watch-timer
          (run-with-timer
           interval interval
           (lambda ()
             (when (and (buffer-live-p buf)
                        (get-buffer-window buf))
               (gastown-status-do-refresh buf)))))))

;;;###autoload
(defun gastown-status-toggle-watch ()
  "Toggle auto-refresh watch mode for the status buffer."
  (interactive)
  (if gastown-status--watch-timer
      (progn
        (gastown-status--cancel-watch)
        (message "Watch mode disabled"))
    (let* ((buf (current-buffer))
           (interval (or gastown-status--watch-interval
                         gastown-status-refresh-interval
                         30)))
      (gastown-status--start-watch buf interval)
      (message "Watch mode enabled (refresh every %ds)" interval))))

;;; ============================================================
;;; Buffer Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-status-show-buffer ()
  "Show the *gastown-status* buffer with Gas Town status (async).

On first open, mounts a progressive-loading component:
  Phase 1 — fast data (gt status --fast --json) renders immediately.
  Phase 2 — full data (gt status --json) replaces it on arrival.

On subsequent calls (refresh), the existing component instance is updated
in-place: previous data remains visible while new data loads, eliminating
the blank loading flash.

An auto-refresh timer fires every `gastown-status-refresh-interval' seconds
while the buffer is visible."
  (interactive)
  (let ((buf (get-buffer-create gastown-status-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-status-mode)
        (gastown-status-mode))
      ;; Start auto-refresh timer if enabled and not already running
      (when (and gastown-status-refresh-interval
                 (not gastown-status--watch-timer))
        (gastown-status--start-watch buf gastown-status-refresh-interval)))
    ;; Refresh in-place when a live instance exists; full remount otherwise.
    (unless (gastown-status-do-refresh buf)
      (vui-mount
       (vui-component 'gastown-status-app)
       gastown-status-buffer-name))
    (pop-to-buffer gastown-status-buffer-name)))

;;; ============================================================
;;; Method Override
;;; ============================================================

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-status))
  "Show Gas Town status in the dedicated *gastown-status* buffer."
  (gastown-status-show-buffer))

(provide 'gastown-status-buffer)
;;; gastown-status-buffer.el ends here
