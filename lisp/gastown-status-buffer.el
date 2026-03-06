;;; gastown-status-buffer.el --- Rich interactive status buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the default terminal passthrough
;; with a custom `gastown-status-mode' buffer that:
;;
;;   - Fetches `gt status --json' and renders a structured dashboard
;;   - Displays sections: Town, Services (Daemon/Dolt/Tmux), Agents, Rigs
;;   - Provides clickable elements: polecat/crew names → Dired,
;;     agent sessions → tmux window, unread mail → inbox,
;;     rig names → Dired, Dolt data_dir → Dired
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

(defface gastown-status-section-heading
  '((t :inherit bold))
  "Face for section headings in the status buffer."
  :group 'gastown-status-buffer)

(defface gastown-status-running
  '((t :inherit success))
  "Face for running/active status indicators."
  :group 'gastown-status-buffer)

(defface gastown-status-stopped
  '((t :inherit error))
  "Face for stopped/inactive status indicators."
  :group 'gastown-status-buffer)

(defface gastown-status-count
  '((t :inherit font-lock-constant-face))
  "Face for numeric count values."
  :group 'gastown-status-buffer)

(defface gastown-status-role
  '((t :inherit font-lock-type-face))
  "Face for agent role labels."
  :group 'gastown-status-buffer)

(defface gastown-status-has-work
  '((t :inherit warning))
  "Face for the has-work indicator."
  :group 'gastown-status-buffer)

;;; ============================================================
;;; Constants
;;; ============================================================

(defconst gastown-status-buffer-name "*gastown-status*"
  "Name of the Gas Town status buffer.")

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

(defun gastown-status--running-str (running)
  "Return a propertized status string for RUNNING."
  (if running
      (propertize "running" 'face 'gastown-status-running)
    (propertize "stopped" 'face 'gastown-status-stopped)))

(defun gastown-status--section (title)
  "Insert a section heading line with TITLE."
  (insert (propertize title 'face 'gastown-status-section-heading) "\n"))

(defun gastown-status--separator ()
  "Insert a thin horizontal separator line."
  (insert (propertize (make-string 60 ?─) 'face 'shadow) "\n"))

;;; ============================================================
;;; Section Renderers
;;; ============================================================

(defun gastown-status--insert-town (data)
  "Insert the Town overview section from DATA."
  (let* ((name (alist-get 'name data))
         (location (alist-get 'location data))
         (overseer (alist-get 'overseer data))
         (o-name (alist-get 'name overseer))
         (o-username (alist-get 'username overseer))
         (o-mail (alist-get 'unread_mail overseer)))
    (gastown-status--section (format "Town: %s" (or name "unknown")))
    (insert (format "  Location:  %s\n" (or location "unknown")))
    (when overseer
      (insert (format "  Overseer:  %s (%s)"
                      (or o-name "?")
                      (or o-username "?")))
      (when (and o-mail (> o-mail 0))
        (insert "  ")
        (insert-text-button
         (format "%d unread" o-mail)
         'action (lambda (_btn) (gastown-mail-inbox))
         'follow-link t
         'help-echo "Open mail inbox"))
      (insert "\n"))))

(defun gastown-status--insert-services (data)
  "Insert the Services section (Daemon, Dolt, Tmux) from DATA."
  (let* ((daemon (alist-get 'daemon data))
         (dolt (alist-get 'dolt data))
         (tmux (alist-get 'tmux data))
         (d-running (alist-get 'running daemon))
         (dolt-running (alist-get 'running dolt))
         (dolt-port (alist-get 'port dolt))
         (dolt-data-dir (alist-get 'data_dir dolt))
         (tmux-running (alist-get 'running tmux))
         (tmux-sessions (alist-get 'session_count tmux)))
    (gastown-status--section "Services")
    ;; Daemon
    (insert (format "  Daemon  %s\n" (gastown-status--running-str d-running)))
    ;; Dolt
    (insert (format "  Dolt    %s" (gastown-status--running-str dolt-running)))
    (when dolt-port
      (insert (format "  port:%s"
                      (propertize (number-to-string dolt-port)
                                  'face 'gastown-status-count))))
    (when dolt-data-dir
      (insert "  ")
      (insert-text-button
       dolt-data-dir
       'action (let ((dir dolt-data-dir))
                 (lambda (_btn) (dired dir)))
       'follow-link t
       'help-echo (format "Open Dired: %s" dolt-data-dir)))
    (insert "\n")
    ;; Tmux
    (insert (format "  Tmux    %s" (gastown-status--running-str tmux-running)))
    (when tmux-sessions
      (insert "  "
              (propertize (format "%d sessions" tmux-sessions)
                          'face 'gastown-status-count)))
    (insert "\n")))

(defun gastown-status--insert-agents (agents)
  "Insert the Agents section from AGENTS vector."
  (gastown-status--section "Agents")
  (if (or (null agents) (zerop (length agents)))
      (insert "  (no agents)\n")
    (seq-do
     (lambda (agent)
       (let* ((name (alist-get 'name agent))
              (session (alist-get 'session agent))
              (role (alist-get 'role agent))
              (running (alist-get 'running agent))
              (has-work (alist-get 'has_work agent))
              (unread (alist-get 'unread_mail agent)))
         (insert "  ")
         ;; Agent name: clickable → attach tmux window if session exists
         (if (and session running)
             (insert-text-button
              (format "%-14s" (or name "?"))
              'action (let ((s session))
                        (lambda (_btn)
                          (shell-command
                           (format "tmux select-window -t gt:%s" s))))
              'follow-link t
              'help-echo (format "Attach to tmux session: %s" session))
           (insert (format "%-14s" (or name "?"))))
         ;; Running status
         (insert "  " (gastown-status--running-str running))
         ;; Role
         (when role
           (insert "  " (propertize role 'face 'gastown-status-role)))
         ;; Has work indicator
         (when (eq has-work t)
           (insert "  " (propertize "has-work" 'face 'gastown-status-has-work)))
         ;; Unread mail
         (when (and unread (> unread 0))
           (insert "  ")
           (insert-text-button
            (format "%d unread" unread)
            'action (lambda (_btn)
                      (when (fboundp 'gastown-mail-inbox)
                        (call-interactively #'gastown-mail-inbox)))
            'follow-link t
            'help-echo "Open mail inbox"))
         (insert "\n")))
     agents)))

(defun gastown-status--insert-rigs (rigs location)
  "Insert the Rigs section from RIGS vector, using LOCATION for paths."
  (gastown-status--section "Rigs")
  (if (or (null rigs) (zerop (length rigs)))
      (insert "  (no rigs)\n")
    (seq-do
     (lambda (rig)
       (let* ((rig-name (alist-get 'name rig))
              (polecats (alist-get 'polecats rig))
              (crews (alist-get 'crews rig))
              (polecat-count (alist-get 'polecat_count rig))
              (crew-count (alist-get 'crew_count rig))
              (has-witness (alist-get 'has_witness rig))
              (has-refinery (alist-get 'has_refinery rig))
              (rig-path (when (and location rig-name)
                          (expand-file-name rig-name location))))
         ;; Rig name: clickable → Dired to rig root
         (insert "  ")
         (if rig-path
             (insert-text-button
              (or rig-name "?")
              'action (let ((p rig-path))
                        (lambda (_btn) (dired p)))
              'follow-link t
              'help-echo (format "Open Dired: %s" rig-path))
           (insert (or rig-name "?")))
         ;; Counts
         (insert "  "
                 (propertize (format "%d" (or polecat-count 0))
                             'face 'gastown-status-count)
                 " polecats")
         (insert "  "
                 (propertize (format "%d" (or crew-count 0))
                             'face 'gastown-status-count)
                 " crew")
         ;; Witness / refinery indicators
         (when (eq has-witness t)
           (insert "  witness"))
         (when (eq has-refinery t)
           (insert "  refinery"))
         (insert "\n")
         ;; Polecat names
         (when (and polecats (> (length polecats) 0))
           (insert "    polecats: ")
           (seq-do
            (lambda (pc)
              (let ((pc-path (when (and location rig-name)
                               (expand-file-name
                                (format "%s/polecats/%s/%s/" rig-name pc rig-name)
                                location))))
                (insert-text-button
                 pc
                 'action (let ((p pc-path))
                           (lambda (_btn) (when p (dired p))))
                 'follow-link t
                 'help-echo (or pc-path pc))
                (insert "  ")))
            polecats)
           (insert "\n"))
         ;; Crew names
         (when (and crews (> (length crews) 0))
           (insert "    crew:     ")
           (seq-do
            (lambda (cr)
              (let ((cr-path (when (and location rig-name)
                               (expand-file-name
                                (format "%s/crew/%s/%s/" rig-name cr rig-name)
                                location))))
                (insert-text-button
                 cr
                 'action (let ((p cr-path))
                           (lambda (_btn) (when p (dired p))))
                 'follow-link t
                 'help-echo (or cr-path cr))
                (insert "  ")))
            crews)
           (insert "\n"))))
     rigs)))

;;; ============================================================
;;; Main Render
;;; ============================================================

(defun gastown-status--render (data)
  "Render status DATA into the current buffer."
  (let ((inhibit-read-only t)
        (location (alist-get 'location data)))
    (erase-buffer)
    (gastown-status--insert-town data)
    (insert "\n")
    (gastown-status--insert-services data)
    (insert "\n")
    (gastown-status--insert-agents (alist-get 'agents data))
    (insert "\n")
    (gastown-status--insert-rigs (alist-get 'rigs data) location)
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
  (let* ((buf (get-buffer-create gastown-status-buffer-name))
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
