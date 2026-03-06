;;; gastown-status-buffer.el --- Rich interactive status buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the default terminal passthrough
;; with a custom `gastown-status-mode' buffer rendered with vui.el.
;;
;; Entry point: `gastown-status-show-buffer' or via M-x gastown-status.

;;; Code:

(require 'vui)
(require 'gastown-command-status)

;; Forward declarations for optional interactive features
(declare-function gastown-mail-inbox "gastown-command-mail")
(declare-function vui-update "vui")

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

(define-derived-mode gastown-status-mode vui-mode "GT-Status"
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

(defvar-local gastown-status--root-instance nil
  "Root vui instance for the mounted component, or nil.")

(defvar-local gastown-status--watch-timer nil
  "Auto-refresh timer, or nil when watch mode is off.")

(defvar-local gastown-status--watch-interval 10
  "Seconds between auto-refreshes in watch mode.")

;;; ============================================================
;;; Helpers
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
;;; vui Rendering Helpers
;;; ============================================================

(defun gastown-status--vui-mail-button (unread)
  "Return a vui button vnode for UNREAD mail count."
  (vui-button (format "📬%d" unread)
    :no-decoration t
    :face 'gastown-status-mail-indicator
    :on-click (lambda ()
                (when (fboundp 'gastown-mail-inbox)
                  (call-interactively #'gastown-mail-inbox)))
    :help-echo "Open mail inbox"))

(defun gastown-status--vui-agent-line (agent)
  "Return a vui hstack vnode for a single AGENT line."
  (let* ((name    (or (alist-get 'name agent) ""))
         (role    (or (alist-get 'role agent) ""))
         (running (alist-get 'running agent))
         (session (alist-get 'session agent))
         (info    (or (alist-get 'agent_info agent) ""))
         (unread  (alist-get 'unread_mail agent))
         (subject (alist-get 'first_subject agent))
         (icon    (gastown-status--role-icon role)))
    (vui-hstack :spacing 0
      (vui-text (format "%s " icon))
      (if (and session running)
          (vui-button (format "%-12s" name)
            :no-decoration t
            :face 'gastown-status-link
            :on-click (let ((s session))
                        (lambda ()
                          (shell-command
                           (format "tmux select-window -t gt:%s" s))))
            :help-echo (format "Switch to tmux session: gt:%s" session))
        (vui-text (format "%-12s" name)))
      (vui-text " ")
      (vui-text (if running "●" "○")
                :face (if running 'gastown-status-running 'gastown-status-stopped))
      (unless (string-empty-p info)
        (vui-text (format " [%s]" info)))
      (when (and subject (not (string-empty-p subject)))
        (let* ((clean (replace-regexp-in-string "^🤝 HANDOFF: " "" subject))
               (short (if (> (length clean) 30)
                          (concat (substring clean 0 29) "…")
                        clean)))
          (vui-text (format " → %s" short))))
      (when (and unread (> unread 0))
        (list (vui-text " ")
              (gastown-status--vui-mail-button unread))))))

(defun gastown-status--vui-worktree-line (name running info path &optional unread)
  "Return a vui hstack for a polecat or crew line.
NAME, RUNNING, INFO describe the agent.  PATH is the Dired target or nil.
Optional UNREAD is the unread mail count."
  (vui-hstack :spacing 0
    (vui-text "   ")
    (if path
        (vui-button (format "%-12s" name)
          :no-decoration t
          :face 'gastown-status-link
          :on-click (let ((p path)) (lambda () (dired p)))
          :help-echo (format "Open Dired: %s" path))
      (vui-text (format "%-12s" name)))
    (vui-text " ")
    (vui-text (if running "●" "○")
              :face (if running 'gastown-status-running 'gastown-status-stopped))
    (unless (string-empty-p info)
      (vui-text (format " [%s]" info)))
    (when (and unread (> unread 0))
      (list (vui-text " ")
            (gastown-status--vui-mail-button unread)))))

;;; ============================================================
;;; vui Section Renderers
;;; ============================================================

(defun gastown-status--vui-overseer (data)
  "Return a vui hstack vnode for the overseer line from DATA, or nil."
  (let ((overseer (alist-get 'overseer data)))
    (when overseer
      (let* ((o-name  (or (alist-get 'name overseer) ""))
             (o-email (or (alist-get 'email overseer) ""))
             (o-unread (alist-get 'unread_mail overseer)))
        (vui-hstack :spacing 0
          (vui-text (format "👤 Overseer: %s%s"
                            o-name
                            (if (string-empty-p o-email) ""
                              (format " <%s>" o-email))))
          (when (and o-unread (> o-unread 0))
            (list (vui-text " ")
                  (gastown-status--vui-mail-button o-unread))))))))

(defun gastown-status--vui-services (data)
  "Return a vui hstack vnode for the compact services line from DATA."
  (let* ((daemon (alist-get 'daemon data))
         (dolt   (alist-get 'dolt data))
         (tmux   (alist-get 'tmux data))
         (d-pid       (alist-get 'pid daemon))
         (dolt-pid    (alist-get 'pid dolt))
         (dolt-port   (alist-get 'port dolt))
         (dolt-dir    (gastown-status--abbreviate-path (alist-get 'data_dir dolt)))
         (dolt-dir-abs (alist-get 'data_dir dolt))
         (tmux-socket (alist-get 'socket tmux))
         (tmux-pid    (alist-get 'pid tmux))
         (tmux-count  (alist-get 'session_count tmux))
         (tmux-path   (alist-get 'socket_path tmux)))
    (vui-hstack :spacing 0
      (vui-text "Services:")
      (when daemon
        (vui-text (format "  daemon%s"
                          (if d-pid (format " (PID %d)" d-pid) ""))))
      (when dolt
        (list
         (vui-text (format "  dolt (PID %d, :%d, "
                           (or dolt-pid 0) (or dolt-port 0)))
         (if (and dolt-dir-abs (not (string-empty-p dolt-dir-abs)))
             (vui-button dolt-dir
               :no-decoration t
               :face 'gastown-status-link
               :on-click (let ((p dolt-dir-abs)) (lambda () (dired p)))
               :help-echo (format "Open Dired: %s" dolt-dir-abs))
           (vui-text (or dolt-dir "")))
         (vui-text ")")))
      (when tmux
        (vui-text (format "  tmux (-L %s, PID %d, %d session%s, %s)"
                          (or tmux-socket "")
                          (or tmux-pid 0)
                          (or tmux-count 0)
                          (if (eql tmux-count 1) "" "s")
                          (or tmux-path "")))))))

(defun gastown-status--vui-rig (rig town-location)
  "Return a vui vstack vnode for a complete rig section.
RIG is the rig data alist; TOWN-LOCATION is the town's root path."
  (let* ((rig-name   (or (alist-get 'name rig) "unknown"))
         (agents     (seq-into (or (alist-get 'agents rig) []) 'list))
         (witnesses  (seq-filter (lambda (a) (equal (alist-get 'role a) "witness")) agents))
         (refineries (seq-filter (lambda (a) (equal (alist-get 'role a) "refinery")) agents))
         (polecats   (seq-filter (lambda (a) (equal (alist-get 'role a) "polecat")) agents))
         (crews      (seq-filter (lambda (a) (equal (alist-get 'role a) "crew")) agents))
         (sep-label  (format " %s/ " rig-name))
         (sep-left   "─── ")
         (sep-right  (make-string (max 0 (- 55 (length sep-label) (length sep-left))) ?─)))
    (apply #'vui-vstack
           (delq nil
                 (list
                  (vui-newline)
                  (vui-text (concat sep-left sep-label sep-right)
                            :face 'gastown-status-rig-separator)
                  (vui-newline)
                  (when witnesses
                    (apply #'vui-vstack
                           (mapcar #'gastown-status--vui-agent-line witnesses)))
                  (when refineries
                    (apply #'vui-vstack
                           (mapcar #'gastown-status--vui-agent-line refineries)))
                  (when crews
                    (apply #'vui-vstack
                           (cons
                            (vui-text (format "👷 Crew (%d)" (length crews)))
                            (mapcar (lambda (a)
                                      (let* ((n (or (alist-get 'name a) ""))
                                             (r (alist-get 'running a))
                                             (i (or (alist-get 'agent_info a) ""))
                                             (p (when (and town-location rig-name)
                                                  (expand-file-name
                                                   (format "%s/crew/%s/%s/" rig-name n rig-name)
                                                   town-location))))
                                        (gastown-status--vui-worktree-line n r i p)))
                                    crews))))
                  (when polecats
                    (apply #'vui-vstack
                           (cons
                            (vui-text (format "😺 Polecats (%d)" (length polecats)))
                            (mapcar (lambda (a)
                                      (let* ((n (or (alist-get 'name a) ""))
                                             (r (alist-get 'running a))
                                             (i (or (alist-get 'agent_info a) ""))
                                             (u (alist-get 'unread_mail a))
                                             (p (when (and town-location rig-name)
                                                  (expand-file-name
                                                   (format "%s/polecats/%s/%s/" rig-name n rig-name)
                                                   town-location))))
                                        (gastown-status--vui-worktree-line n r i p u)))
                                    polecats)))))))))

(defun gastown-status--vui-content (data)
  "Return a vui vstack vnode tree for the full status view of DATA."
  (let* ((name   (or (alist-get 'name data) "unknown"))
         (location (or (alist-get 'location data) ""))
         (agents (seq-into (or (alist-get 'agents data) []) 'list))
         (rigs   (seq-into (or (alist-get 'rigs data) []) 'list)))
    (apply #'vui-vstack
           (delq nil
                 (append
                  (list
                   (vui-text (format "Town: %s" name))
                   (vui-text location)
                   (gastown-status--vui-overseer data)
                   (gastown-status--vui-services data)
                   (when agents (vui-newline))
                   (when agents
                     (apply #'vui-vstack
                            (mapcar #'gastown-status--vui-agent-line agents))))
                  (mapcar (lambda (r)
                            (gastown-status--vui-rig r location))
                          rigs))))))

;;; ============================================================
;;; Component (interactive use with auto-refresh)
;;; ============================================================

(vui-defcomponent gastown-status-root (watch refresh-key)
  "Root component for the Gas Town status buffer."
  :state ((data nil))
  :render
  (progn
    ;; Fetch data on mount or explicit refresh
    (vui-use-effect (refresh-key)
      (let ((new-data (gastown-command-status! :json t)))
        (vui-set-state :data new-data)))
    ;; Auto-refresh timer — set up when watch is enabled
    (vui-use-effect (watch)
      (when watch
        (let* ((interval gastown-status--watch-interval)
               (refresh-cb
                (vui-with-async-context
                  (let ((new-data (gastown-command-status! :json t)))
                    (vui-set-state :data new-data)))))
          (setq gastown-status--watch-timer
                (run-with-timer interval interval refresh-cb))
          (lambda ()
            (cancel-timer gastown-status--watch-timer)
            (setq gastown-status--watch-timer nil)))))
    ;; Render content or loading placeholder
    (if data
        (gastown-status--vui-content data)
      (vui-text "Loading..."))))

;;; ============================================================
;;; Main Render (used by tests and manual calls)
;;; ============================================================

(defun gastown-status--render (data)
  "Render status DATA into the current buffer."
  (setq gastown-status--data data)
  (vui-render (gastown-status--vui-content data)))

;;; ============================================================
;;; Interactive Commands
;;; ============================================================

;;;###autoload
(defun gastown-status-refresh ()
  "Refresh the *gastown-status* buffer with current status."
  (interactive)
  (if gastown-status--root-instance
      (let* ((props (vui-instance-props gastown-status--root-instance))
             (key   (or (plist-get props :refresh-key) 0)))
        (vui-update gastown-status--root-instance
                    (list :watch (plist-get props :watch)
                          :refresh-key (1+ key)))
        (message "Status refreshed"))
    ;; Fallback for buffers rendered without component (e.g., tests)
    (when gastown-status--data
      (gastown-status--render gastown-status--data)
      (message "Status refreshed"))))

(defun gastown-status--cancel-watch ()
  "Cancel the watch timer if active."
  (when gastown-status--watch-timer
    (cancel-timer gastown-status--watch-timer)
    (setq gastown-status--watch-timer nil)))

;;;###autoload
(defun gastown-status-toggle-watch ()
  "Toggle auto-refresh watch mode for the status buffer."
  (interactive)
  (if gastown-status--root-instance
      (let* ((props   (vui-instance-props gastown-status--root-instance))
             (current (plist-get props :watch)))
        (vui-update gastown-status--root-instance
                    (list :watch (not current)
                          :refresh-key (plist-get props :refresh-key)))
        (message "Watch mode %s" (if (not current) "enabled" "disabled")))
    ;; Fallback: manual timer management (e.g., when used outside component)
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
                     (gastown-status-refresh))))))
        (message "Watch mode enabled (refresh every %ds)"
                 gastown-status--watch-interval)))))

;;; ============================================================
;;; Buffer Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-status-show-buffer ()
  "Show the *gastown-status* buffer with current Gas Town status."
  (interactive)
  (let ((buf (get-buffer-create gastown-status-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-status-mode)
        (gastown-status-mode))
      (unless gastown-status--root-instance
        (setq gastown-status--root-instance
              (vui-mount
               (vui-component 'gastown-status-root
                              :watch nil
                              :refresh-key 0)
               gastown-status-buffer-name))))
    (pop-to-buffer buf)))

;;; ============================================================
;;; Method Override
;;; ============================================================

(cl-defmethod gastown-command-execute-interactive ((_command gastown-command-status))
  "Show Gas Town status in the dedicated *gastown-status* buffer."
  (gastown-status-show-buffer))

(provide 'gastown-status-buffer)
;;; gastown-status-buffer.el ends here
