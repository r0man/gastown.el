;;; gastown-status-buffer.el --- Rich interactive status buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the default terminal passthrough
;; with a custom `gastown-status-mode' buffer that:
;;
;;   - Fetches `gt status --json' and renders output matching the CLI
;;   - Global agents (mayor, deacon) appear at the top
;;   - Each rig gets a separator section with witness/refinery first,
;;     then crew block, then polecats block
;;   - Provides clickable elements: polecat/crew names -> Dired,
;;     agent sessions -> tmux window, unread mail -> inbox,
;;     Dolt data_dir -> Dired
;;   - Supports auto-refresh (w to toggle watch mode)
;;
;; Entry point: `gastown-status-show-buffer' or via M-x gastown-status.

;;; Code:

(require 'gastown-command-status)

;; Forward declarations for optional interactive features
(declare-function gastown-mail-inbox "gastown-command-mail")

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
  '((t :inherit font-lock-comment-face))
  "Face for rig separator lines."
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
;;; Mode
;;; ============================================================

(defvar gastown-status-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "g" #'gastown-status-refresh)
    (define-key map "q" #'quit-window)
    (define-key map "w" #'gastown-status-toggle-watch)
    map)
  "Keymap for `gastown-status-mode'.")

(define-derived-mode gastown-status-mode special-mode "GT-Status"
  "Major mode for the Gas Town status buffer.

Displays a rich, interactive overview of the Gas Town workspace,
including service health, agents, and rig topology.

Key bindings:
\\{gastown-status-mode-map}"
  :group 'gastown-status-buffer
  (setq truncate-lines t)
  (add-hook 'kill-buffer-hook #'gastown-status--cancel-watch nil t))

;;; ============================================================
;;; Buffer-Local State
;;; ============================================================

(defvar-local gastown-status--data nil
  "Current status data as a parsed JSON alist.")

(defvar-local gastown-status--watch-timer nil
  "Auto-refresh timer, or nil when watch mode is off.")

(defvar-local gastown-status--watch-interval 10
  "Seconds between auto-refreshes in watch mode.")

;;; ============================================================
;;; Rendering Helpers
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

(defun gastown-status--insert-dired-link (text path)
  "Insert TEXT as a clickable link that opens PATH in Dired."
  (insert-text-button
   text
   'action (let ((p path))
             (lambda (_btn) (dired p)))
   'follow-link t
   'face 'gastown-status-link
   'help-echo (format "Open Dired: %s" path)))

(defun gastown-status--insert-tmux-link (text session)
  "Insert TEXT as a clickable link to switch to tmux SESSION."
  (insert-text-button
   text
   'action (let ((s session))
             (lambda (_btn)
               (shell-command (format "tmux select-window -t gt:%s" s))))
   'follow-link t
   'face 'gastown-status-link
   'help-echo (format "Switch to tmux session: gt:%s" session)))

;;; ============================================================
;;; Section Renderers
;;; ============================================================

(defun gastown-status--insert-town (data)
  "Insert town name and location from DATA."
  (let* ((name     (or (alist-get 'name data) "unknown"))
         (location (or (alist-get 'location data) "")))
    (insert "Town: " name "\n")
    (insert location "\n")))

(defun gastown-status--insert-overseer (data)
  "Insert the overseer line from DATA."
  (let* ((overseer  (alist-get 'overseer data))
         (o-name    (or (alist-get 'name overseer) ""))
         (o-email   (or (alist-get 'email overseer) ""))
         (o-unread  (alist-get 'unread_mail overseer)))
    (when overseer
      (insert "\n👤 Overseer: " o-name
              (if (string-empty-p o-email) "" (format " <%s>" o-email)))
      (when (and o-unread (> o-unread 0))
        (insert " ")
        (insert-text-button
         (propertize (format "📬%d" o-unread) 'face 'gastown-status-mail-indicator)
         'action (lambda (_btn)
                   (when (fboundp 'gastown-mail-inbox)
                     (call-interactively #'gastown-mail-inbox)))
         'follow-link t
         'help-echo "Open mail inbox"))
      (insert "\n"))))

(defun gastown-status--insert-services (data)
  "Insert the compact services line from DATA."
  (let* ((daemon       (alist-get 'daemon data))
         (dolt         (alist-get 'dolt data))
         (tmux         (alist-get 'tmux data))
         (d-pid        (alist-get 'pid daemon))
         (dolt-pid     (alist-get 'pid dolt))
         (dolt-port    (alist-get 'port dolt))
         (dolt-dir     (gastown-status--abbreviate-path (alist-get 'data_dir dolt)))
         (dolt-dir-abs (alist-get 'data_dir dolt))
         (tmux-socket  (alist-get 'socket tmux))
         (tmux-pid     (alist-get 'pid tmux))
         (tmux-count   (alist-get 'session_count tmux))
         (tmux-path    (alist-get 'socket_path tmux)))
    (insert "\nServices:")
    ;; Daemon
    (when daemon
      (insert (format "  daemon%s"
                      (if d-pid (format " (PID %d)" d-pid) ""))))
    ;; Dolt
    (when dolt
      (insert (format "  dolt (PID %d, :%d, "
                      (or dolt-pid 0)
                      (or dolt-port 0)))
      (if (and dolt-dir-abs (not (string-empty-p dolt-dir-abs)))
          (gastown-status--insert-dired-link dolt-dir dolt-dir-abs)
        (insert (or dolt-dir "")))
      (insert ")"))
    ;; Tmux
    (when tmux
      (insert (format "  tmux (-L %s, PID %d, %d session%s, %s)"
                      (or tmux-socket "")
                      (or tmux-pid 0)
                      (or tmux-count 0)
                      (if (eql tmux-count 1) "" "s")
                      (or tmux-path ""))))
    (insert "\n")))

(defun gastown-status--insert-agent-line (agent)
  "Insert a single AGENT line."
  (let* ((name      (or (alist-get 'name agent) ""))
         (role      (or (alist-get 'role agent) ""))
         (running   (alist-get 'running agent))
         (session   (alist-get 'session agent))
         (info      (or (alist-get 'agent_info agent) ""))
         (unread    (alist-get 'unread_mail agent))
         (subject   (alist-get 'first_subject agent))
         (icon      (gastown-status--role-icon role))
         (indicator (gastown-status--running-indicator running)))
    (insert icon " ")
    ;; Agent name: clickable -> tmux session if running
    (if (and session running)
        (gastown-status--insert-tmux-link (format "%-12s" name) session)
      (insert (format "%-12s" name)))
    (insert " " indicator)
    ;; Agent info in brackets
    (unless (string-empty-p info)
      (insert (format " [%s]" info)))
    ;; Mail subject preview (e.g., "→ witness Handoff")
    (when (and subject (not (string-empty-p subject)))
      (let* ((subject-clean (replace-regexp-in-string "^🤝 HANDOFF: " "" subject))
             (subject-short (if (> (length subject-clean) 30)
                                (concat (substring subject-clean 0 29) "…")
                              subject-clean)))
        (insert " → " subject-short)))
    ;; Unread mail indicator
    (when (and unread (> unread 0))
      (insert " ")
      (insert-text-button
       (propertize (format "📬%d" unread) 'face 'gastown-status-mail-indicator)
       'action (lambda (_btn)
                 (when (fboundp 'gastown-mail-inbox)
                   (call-interactively #'gastown-mail-inbox)))
       'follow-link t
       'help-echo "Open mail inbox"))
    (insert "\n")))

(defun gastown-status--insert-rig-section (rig town-location)
  "Insert a complete rig section for RIG using TOWN-LOCATION."
  (let* ((rig-name  (or (alist-get 'name rig) "unknown"))
         (agents    (or (alist-get 'agents rig) []))
         ;; Partition agents by role
         (witnesses  (seq-filter (lambda (a) (equal (alist-get 'role a) "witness")) agents))
         (refineries (seq-filter (lambda (a) (equal (alist-get 'role a) "refinery")) agents))
         (polecats   (seq-filter (lambda (a) (equal (alist-get 'role a) "polecat")) agents))
         (crews      (seq-filter (lambda (a) (equal (alist-get 'role a) "crew")) agents)))
    ;; Rig separator: ─── rigname/ ──────...
    (let* ((sep-label (format " %s/ " rig-name))
           (sep-left  "─── ")
           (sep-right (make-string (max 0 (- 55 (length sep-label) (length sep-left))) ?─)))
      (insert "\n"
              (propertize (concat sep-left sep-label sep-right)
                          'face 'gastown-status-rig-separator)
              "\n\n"))
    ;; Witness and refinery individually
    (seq-do #'gastown-status--insert-agent-line witnesses)
    (seq-do #'gastown-status--insert-agent-line refineries)
    ;; Crew block
    (when crews
      (let ((crew-count (length crews)))
        (insert (format "👷 Crew (%d)\n" crew-count))
        (seq-do
         (lambda (a)
           (let* ((name    (or (alist-get 'name a) ""))
                  (running (alist-get 'running a))
                  (info    (or (alist-get 'agent_info a) ""))
                  (indicator (gastown-status--running-indicator running))
                  (crew-path (when (and town-location rig-name)
                               (expand-file-name
                                (format "%s/crew/%s/%s/" rig-name name rig-name)
                                town-location))))
             (insert "   ")
             (if crew-path
                 (gastown-status--insert-dired-link (format "%-12s" name) crew-path)
               (insert (format "%-12s" name)))
             (insert " " indicator)
             (unless (string-empty-p info) (insert (format " [%s]" info)))
             (insert "\n")))
         crews)))
    ;; Polecats block
    (when polecats
      (let ((pc-count (length polecats)))
        (insert (format "😺 Polecats (%d)\n" pc-count))
        (seq-do
         (lambda (a)
           (let* ((name    (or (alist-get 'name a) ""))
                  (running (alist-get 'running a))
                  (info    (or (alist-get 'agent_info a) ""))
                  (indicator (gastown-status--running-indicator running))
                  (pc-path (when (and town-location rig-name)
                             (expand-file-name
                              (format "%s/polecats/%s/%s/" rig-name name rig-name)
                              town-location))))
             (insert "   ")
             (if pc-path
                 (gastown-status--insert-dired-link (format "%-12s" name) pc-path)
               (insert (format "%-12s" name)))
             (insert " " indicator)
             (unless (string-empty-p info) (insert (format " [%s]" info)))
             ;; Unread mail on polecat line
             (let ((unread (alist-get 'unread_mail a)))
               (when (and unread (> unread 0))
                 (insert " ")
                 (insert-text-button
                  (propertize (format "📬%d" unread) 'face 'gastown-status-mail-indicator)
                  'action (lambda (_btn)
                            (when (fboundp 'gastown-mail-inbox)
                              (call-interactively #'gastown-mail-inbox)))
                  'follow-link t
                  'help-echo "Open mail inbox")))
             (insert "\n")))
         polecats)))))

;;; ============================================================
;;; Main Render
;;; ============================================================

(defun gastown-status--render (data)
  "Render status DATA into the current buffer."
  (let* ((inhibit-read-only t)
         (location (or (alist-get 'location data) ""))
         (agents   (or (alist-get 'agents data) []))
         (rigs     (or (alist-get 'rigs data) [])))
    (erase-buffer)
    ;; Town: name + location
    (gastown-status--insert-town data)
    ;; Overseer line
    (gastown-status--insert-overseer data)
    ;; Services line
    (gastown-status--insert-services data)
    ;; Global agents (mayor, deacon, etc.)
    (when (> (length agents) 0)
      (insert "\n")
      (seq-do #'gastown-status--insert-agent-line agents))
    ;; Rig sections
    (seq-do (lambda (r) (gastown-status--insert-rig-section r location)) rigs)
    (goto-char (point-min))))

;;; ============================================================
;;; Interactive Commands
;;; ============================================================

;;;###autoload
(defun gastown-status-refresh ()
  "Refresh the *gastown-status* buffer with current status."
  (interactive)
  (let ((data (gastown-command-status! :json t)))
    (setq gastown-status--data data)
    (gastown-status--render data)
    (message "Status refreshed")))

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
                   (gastown-status-refresh)))))))
    (message "Watch mode enabled (refresh every %ds)"
             gastown-status--watch-interval)))

;;; ============================================================
;;; Buffer Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-status-show-buffer ()
  "Show the *gastown-status* buffer with current Gas Town status."
  (interactive)
  (let* ((buf  (get-buffer-create gastown-status-buffer-name))
         (data (gastown-command-status! :json t)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-status-mode)
        (gastown-status-mode))
      (setq gastown-status--data data)
      (gastown-status--render data))
    (pop-to-buffer buf)))

;;; ============================================================
;;; Method Override
;;; ============================================================

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-status))
  "Show Gas Town status in the dedicated *gastown-status* buffer."
  (gastown-status-show-buffer))

(provide 'gastown-status-buffer)
;;; gastown-status-buffer.el ends here
