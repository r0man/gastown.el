;;; gastown-status-buffer.el --- Rich interactive status buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides a rich, interactive Emacs-native status buffer for
;; the `gt status' command.  It replaces the default terminal passthrough
;; with a custom `gastown-status-mode' buffer (derived from magit-section-mode)
;; that:
;;
;;   - Fetches `gt status --json' and renders output as collapsible sections
;;   - Global agents (mayor, deacon) appear at the top
;;   - Each rig gets a collapsible section with witness/refinery first,
;;     then crew block, then polecats block
;;   - Provides context-aware RET: rig → rig list, agent → peek, polecat → detail view
;;   - Clickable elements: polecat/crew names -> Dired,
;;     agent sessions -> tmux window, unread mail -> inbox,
;;     Dolt data_dir -> Dired
;;   - Supports auto-refresh (w to toggle watch mode)
;;   - Extensions add sections via gastown-status-sections-hook
;;
;; Entry point: `gastown-status-show-buffer' or via M-x gastown-status.

;;; Code:

(require 'magit-section)
(require 'gastown-command-status)

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
  '((t :inherit magit-section-heading))
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
;;; Section Types (EIEIO classes)
;;; ============================================================

(defclass gastown-services-section (magit-section)
  ((keymap :initform 'gastown-services-section-map))
  "Section for the services overview (daemon, dolt, tmux).")

(defclass gastown-service-section (magit-section)
  ((keymap  :initform 'gastown-service-section-map)
   (service :initarg :service :initform nil))
  "Section for an individual service.")

(defclass gastown-agents-section (magit-section)
  ((keymap :initform 'gastown-agents-section-map))
  "Section for the global agents block (mayor, deacon, etc.).")

(defclass gastown-agent-section (magit-section)
  ((keymap :initform 'gastown-agent-section-map)
   (agent  :initarg :agent :initform nil))
  "Section for an individual agent.")

(defclass gastown-rig-section (magit-section)
  ((keymap :initform 'gastown-rig-section-map)
   (rig    :initarg :rig :initform nil))
  "Collapsible section for a rig.")

(defclass gastown-polecat-section (magit-section)
  ((keymap   :initform 'gastown-polecat-section-map)
   (polecat  :initarg :polecat :initform nil)
   (rig-name :initarg :rig-name :initform nil))
  "Section for an individual polecat within a rig.")

;;; ============================================================
;;; Section Keymaps (minimal — inherit from magit-section)
;;; ============================================================

(defvar-keymap gastown-services-section-map
  :parent magit-section-mode-map)
(defvar-keymap gastown-service-section-map
  :parent magit-section-mode-map)
(defvar-keymap gastown-agents-section-map
  :parent magit-section-mode-map)
(defvar-keymap gastown-agent-section-map
  :parent magit-section-mode-map)
(defvar-keymap gastown-rig-section-map
  :parent magit-section-mode-map)
(defvar-keymap gastown-polecat-section-map
  :parent magit-section-mode-map)

;;; ============================================================
;;; Sections Hook
;;; ============================================================

(defcustom gastown-status-sections-hook
  (list #'gastown-insert-services
        #'gastown-insert-global-agents
        #'gastown-insert-rigs)
  "Hook run to insert sections into the gastown status buffer.

Each function is called with no arguments and should insert one or
more sections into the current buffer using `magit-insert-section'.

Extensions add to this hook via `magit-add-section-hook':
  (magit-add-section-hook \\='gastown-status-sections-hook
                          #\\='my-insert-fn nil t)"
  :group 'gastown-status-buffer
  :type 'hook)

;;; ============================================================
;;; Mode
;;; ============================================================

(defvar-keymap gastown-status-mode-map
  :parent magit-section-mode-map
  "RET" #'gastown-status-visit-section
  "g"   #'gastown-status-refresh
  "q"   #'quit-window
  "w"   #'gastown-status-toggle-watch)

(define-derived-mode gastown-status-mode magit-section-mode "GT-Status"
  "Major mode for the Gas Town status buffer.

Displays a rich, interactive overview of the Gas Town workspace,
including service health, agents, and rig topology as collapsible
magit-section sections.

Key bindings:
\\{gastown-status-mode-map}"
  :group 'gastown-status-buffer
  (setq truncate-lines t)
  (setq-local revert-buffer-function #'gastown-status--revert)
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

(defun gastown-status--insert-mail-button (unread)
  "Insert a clickable mail badge for UNREAD count."
  (insert-text-button
   (propertize (format "📬%d" unread) 'face 'gastown-status-mail-indicator)
   'action (lambda (_btn)
             (when (fboundp 'gastown-mail-inbox)
               (call-interactively #'gastown-mail-inbox)))
   'follow-link t
   'help-echo "Open mail inbox"))

;;; ============================================================
;;; Insert Functions (called via gastown-status-sections-hook)
;;; ============================================================

(defun gastown-insert-services ()
  "Insert services section into the status buffer."
  (when-let ((data gastown-status--data))
    (let* ((daemon      (alist-get 'daemon data))
           (dolt        (alist-get 'dolt data))
           (tmux        (alist-get 'tmux data))
           (d-pid       (alist-get 'pid daemon))
           (dolt-pid    (alist-get 'pid dolt))
           (dolt-port   (alist-get 'port dolt))
           (dolt-dir    (gastown-status--abbreviate-path (alist-get 'data_dir dolt)))
           (dolt-dir-abs (alist-get 'data_dir dolt))
           (tmux-socket (alist-get 'socket tmux))
           (tmux-pid    (alist-get 'pid tmux))
           (tmux-count  (alist-get 'session_count tmux))
           (tmux-path   (alist-get 'socket_path tmux)))
      (magit-insert-section (gastown-services-section)
        (magit-insert-heading "Services:")
        (when daemon
          (insert (format "  daemon%s\n"
                          (if d-pid (format " (PID %d)" d-pid) ""))))
        (when dolt
          (insert (format "  dolt (PID %d, :%d, "
                          (or dolt-pid 0)
                          (or dolt-port 0)))
          (if (and dolt-dir-abs (not (string-empty-p dolt-dir-abs)))
              (gastown-status--insert-dired-link dolt-dir dolt-dir-abs)
            (insert (or dolt-dir "")))
          (insert ")\n"))
        (when tmux
          (insert (format "  tmux (-L %s, PID %d, %d session%s, %s)\n"
                          (or tmux-socket "")
                          (or tmux-pid 0)
                          (or tmux-count 0)
                          (if (eql tmux-count 1) "" "s")
                          (or tmux-path ""))))))))

(defun gastown-insert-global-agents ()
  "Insert global agents section into the status buffer."
  (when-let ((data gastown-status--data))
    (let ((agents (alist-get 'agents data)))
      (when (and agents (> (length agents) 0))
        (magit-insert-section (gastown-agents-section)
          (magit-insert-heading "Agents:")
          (seq-do #'gastown-status--insert-agent-section-line
                  (if (vectorp agents) (append agents nil) agents)))))))

(defun gastown-insert-rigs ()
  "Insert rig sections into the status buffer."
  (when-let ((data gastown-status--data))
    (let* ((location (or (alist-get 'location data) ""))
           (rigs     (alist-get 'rigs data)))
      (when (and rigs (> (length rigs) 0))
        (seq-do (lambda (rig)
                  (gastown-status--insert-rig-section rig location))
                (if (vectorp rigs) (append rigs nil) rigs))))))

;;; ============================================================
;;; Section Renderers
;;; ============================================================

(defun gastown-status--insert-town-header (data)
  "Insert town name and location header from DATA (outside sections)."
  (let* ((name     (or (alist-get 'name data) "unknown"))
         (location (or (alist-get 'location data) ""))
         (overseer  (alist-get 'overseer data))
         (o-name    (or (alist-get 'name overseer) ""))
         (o-email   (or (alist-get 'email overseer) ""))
         (o-unread  (alist-get 'unread_mail overseer)))
    (insert "Town: " name "\n")
    (insert location "\n")
    (when overseer
      (insert "\n👤 Overseer: " o-name
              (if (string-empty-p o-email) "" (format " <%s>" o-email)))
      (when (and o-unread (> o-unread 0))
        (insert " ")
        (gastown-status--insert-mail-button o-unread))
      (insert "\n"))
    (insert "\n")))

(defun gastown-status--insert-agent-section-line (agent)
  "Insert a single AGENT as a magit section line."
  (let* ((name      (or (alist-get 'name agent) ""))
         (role      (or (alist-get 'role agent) ""))
         (running   (alist-get 'running agent))
         (session   (alist-get 'session agent))
         (info      (or (alist-get 'agent_info agent) ""))
         (unread    (alist-get 'unread_mail agent))
         (subject   (alist-get 'first_subject agent))
         (icon      (gastown-status--role-icon role))
         (indicator (gastown-status--running-indicator running)))
    (magit-insert-section (gastown-agent-section :agent agent)
      (magit-insert-heading
        (concat
         icon " "
         (if (and session running)
             (progn
               ;; Build button text inline
               (format "%-12s" name))
           (format "%-12s" name))
         " " indicator
         (unless (string-empty-p info) (format " [%s]" info))
         (when (and subject (not (string-empty-p subject)))
           (let* ((subject-clean (replace-regexp-in-string "^🤝 HANDOFF: " "" subject))
                  (subject-short (if (> (length subject-clean) 30)
                                     (concat (substring subject-clean 0 29) "…")
                                   subject-clean)))
             (format " → %s" subject-short)))
         (when (and unread (> unread 0))
           (format " 📬%d" unread)))))))

(defun gastown-status--insert-rig-section (rig town-location)
  "Insert a collapsible section for RIG using TOWN-LOCATION."
  (let* ((rig-name  (or (alist-get 'name rig) "unknown"))
         (agents    (or (alist-get 'agents rig) []))
         (agents-list (if (vectorp agents) (append agents nil) agents))
         ;; Partition agents by role
         (witnesses  (seq-filter (lambda (a) (equal (alist-get 'role a) "witness")) agents-list))
         (refineries (seq-filter (lambda (a) (equal (alist-get 'role a) "refinery")) agents-list))
         (polecats   (seq-filter (lambda (a) (equal (alist-get 'role a) "polecat")) agents-list))
         (crews      (seq-filter (lambda (a) (equal (alist-get 'role a) "crew")) agents-list)))
    (magit-insert-section (gastown-rig-section :rig rig)
      (magit-insert-heading
        (propertize (format "── %s/ ──" rig-name)
                    'face 'gastown-status-rig-separator))
      ;; Witness and refinery
      (seq-do (lambda (a) (gastown-status--insert-agent-in-rig a town-location rig-name))
              witnesses)
      (seq-do (lambda (a) (gastown-status--insert-agent-in-rig a town-location rig-name))
              refineries)
      ;; Crew block
      (when crews
        (magit-insert-section (crew)
          (magit-insert-heading (format "👷 Crew (%d)" (length crews)))
          (seq-do (lambda (a)
                    (gastown-status--insert-crew-or-polecat-line
                     a town-location rig-name "crew"))
                  crews)))
      ;; Polecats block
      (when polecats
        (magit-insert-section (polecats)
          (magit-insert-heading (format "😺 Polecats (%d)" (length polecats)))
          (seq-do (lambda (a)
                    (gastown-status--insert-crew-or-polecat-line
                     a town-location rig-name "polecat"))
                  polecats))))))

(defun gastown-status--insert-agent-in-rig (agent _town-location _rig-name)
  "Insert AGENT line (witness/refinery) within a rig section."
  (let* ((name      (or (alist-get 'name agent) ""))
         (role      (or (alist-get 'role agent) ""))
         (running   (alist-get 'running agent))
         (info      (or (alist-get 'agent_info agent) ""))
         (unread    (alist-get 'unread_mail agent))
         (subject   (alist-get 'first_subject agent))
         (icon      (gastown-status--role-icon role))
         (indicator (gastown-status--running-indicator running)))
    (magit-insert-section (gastown-agent-section :agent agent)
      (magit-insert-heading
        (concat
         icon " "
         (format "%-12s" name)
         " " indicator
         (unless (string-empty-p info) (format " [%s]" info))
         (when (and subject (not (string-empty-p subject)))
           (let* ((subject-clean (replace-regexp-in-string "^🤝 HANDOFF: " "" subject))
                  (subject-short (if (> (length subject-clean) 30)
                                     (concat (substring subject-clean 0 29) "…")
                                   subject-clean)))
             (format " → %s" subject-short)))
         (when (and unread (> unread 0))
           (format " 📬%d" unread)))))))


(defun gastown-status--insert-crew-or-polecat-line (agent _town-location rig-name _role)
  "Insert a crew or polecat AGENT line within a rig section.
RIG-NAME is used to build the polecat section metadata."
  (let* ((name      (or (alist-get 'name agent) ""))
         (running   (alist-get 'running agent))
         (info      (or (alist-get 'agent_info agent) ""))
         (unread    (alist-get 'unread_mail agent))
         (indicator (gastown-status--running-indicator running)))
    (magit-insert-section (gastown-polecat-section :polecat agent :rig-name rig-name)
      (magit-insert-heading
        (concat
         "   "
         (format "%-12s" name)
         " " indicator
         (unless (string-empty-p info) (format " [%s]" info))
         (when (and unread (> unread 0))
           (format " 📬%d" unread)))))))

;;; ============================================================
;;; Main Render
;;; ============================================================

(defun gastown-status--render (data)
  "Render status DATA into the current buffer."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (setq gastown-status--data data)
    (magit-insert-section (status)
      ;; Town header (outside sections hook — always present)
      (gastown-status--insert-town-header data)
      ;; Run sections hook
      (run-hooks 'gastown-status-sections-hook))
    (goto-char (point-min))))

;;; ============================================================
;;; Context-Aware Visit
;;; ============================================================

;;;###autoload
(defun gastown-status-visit-section ()
  "Visit the thing at point based on section type."
  (interactive)
  (if-let ((section (magit-current-section)))
      (cond
       ((object-of-class-p section 'gastown-rig-section)
        (message "Rig: %s"
                 (alist-get 'name (oref section rig))))
       ((object-of-class-p section 'gastown-agent-section)
        (let* ((agent (oref section agent))
               (session (alist-get 'session agent))
               (running (alist-get 'running agent)))
          (if (and session running)
              (shell-command (format "tmux select-window -t gt:%s" session))
            (message "Agent %s is not running" (alist-get 'name agent)))))
       ((object-of-class-p section 'gastown-polecat-section)
        (let* ((polecat  (oref section polecat))
               (rig-name (oref section rig-name)))
          (if (fboundp 'gastown-polecat-detail-show)
              (gastown-polecat-detail-show polecat rig-name)
            (let ((session (alist-get 'session polecat))
                  (running (alist-get 'running polecat)))
              (if (and session running)
                  (shell-command (format "tmux select-window -t gt:%s" session))
                (message "Polecat %s is not running"
                         (alist-get 'name polecat)))))))
       (t
        (magit-section-toggle section)))
    (user-error "No section at point")))

;;; ============================================================
;;; Interactive Commands
;;; ============================================================

;;;###autoload
(defun gastown-status-refresh ()
  "Refresh the *gastown-status* buffer with current status."
  (interactive)
  (let ((data (gastown-command-status! :json t)))
    (gastown-status--render data)
    (message "Status refreshed")))

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
