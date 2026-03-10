;;; gastown-polecat-detail.el --- Polecat detail view using vui.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides a rich, interactive detail view for individual polecats,
;; rendered using vui.el declarative components.
;;
;; The view shows:
;;   - Polecat header: name, rig, running status
;;   - Hook: current work assignment (has work / no work)
;;   - Session: tmux session name, clickable to jump to it
;;   - Mail: unread count with link to mail inbox
;;   - Work history: recent beads assigned to this polecat
;;
;; Entry point: `gastown-polecat-detail-show' — opens the detail
;; buffer for a polecat given its agent alist and rig name.
;;
;; The work history is loaded asynchronously using `vui-use-async',
;; matching the React-like pattern: the loader runs inline and vui
;; re-renders when results arrive.
;;
;; Usage:
;;   (gastown-polecat-detail-show polecat-alist "gastown_el")

;;; Code:

(require 'vui)
(require 'json)
(require 'gastown-types)

;; Forward declarations for optional beads integration
(defvar beads-executable)
(declare-function gastown-mail-inbox-show-buffer "gastown-tabulated")

;;; ============================================================
;;; Faces
;;; ============================================================

(defgroup gastown-polecat-detail nil
  "Faces and settings for the Gas Town polecat detail buffer."
  :group 'gastown
  :prefix "gastown-polecat-detail-")

(defface gastown-polecat-detail-running
  '((t :inherit success :weight bold))
  "Face for running status indicator."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-stopped
  '((t :inherit shadow))
  "Face for stopped status indicator."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-heading
  '((t :inherit magit-section-heading))
  "Face for the polecat name heading."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-label
  '((t :inherit font-lock-comment-face))
  "Face for field labels."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-mail
  '((t :inherit warning))
  "Face for unread mail count."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-work-id
  '((t :inherit font-lock-constant-face))
  "Face for bead IDs in work history."
  :group 'gastown-polecat-detail)

(defface gastown-polecat-detail-section
  '((t :weight bold))
  "Face for sub-section headings."
  :group 'gastown-polecat-detail)

;;; ============================================================
;;; Data Fetching
;;; ============================================================

(defun gastown-polecat-detail--bd-executable ()
  "Return the bd executable name, falling back to \"bd\"."
  (if (boundp 'beads-executable) beads-executable "bd"))

(defun gastown-polecat-detail--fetch-work-history (rig-name polecat-name)
  "Fetch recent beads assigned to POLECAT-NAME in RIG-NAME.

Calls `bd list --json --assignee=rig/polecats/name' and parses the result.
Returns a list of `gastown-work-item' objects, or nil on error."
  (condition-case _err
      (with-temp-buffer
        (let* ((assignee (format "%s/polecats/%s" rig-name polecat-name))
               (bd (gastown-polecat-detail--bd-executable))
               (exit-code (call-process bd nil t nil
                                        "list" "--json"
                                        (format "--assignee=%s" assignee))))
          (when (zerop exit-code)
            (let ((output (buffer-string)))
              (when (and output (not (string-empty-p (string-trim output))))
                (let ((json-array-type 'list)
                      (json-object-type 'alist))
                  (when-let ((raw (ignore-errors (json-read-from-string output))))
                    (mapcar #'gastown-work-item-from-json raw))))))))
    (error nil)))

;;; ============================================================
;;; Stateless Render Helpers (return vnodes)
;;; ============================================================

(defun gastown-polecat-detail--running-indicator (running)
  "Return a propertized running indicator string for RUNNING boolean."
  (if running
      (propertize "●" 'face 'gastown-polecat-detail-running)
    (propertize "○" 'face 'gastown-polecat-detail-stopped)))

(defun gastown-polecat-detail--field-label (text)
  "Return a propertized label string for TEXT."
  (vui-text (format "%-12s" text) :face 'gastown-polecat-detail-label))

(defun gastown-polecat-detail--header (polecat rig-name)
  "Render header row for POLECAT (`gastown-agent') in RIG-NAME."
  (let* ((name    (or (oref polecat name) ""))
         (running (oref polecat running))
         (info    (or (oref polecat agent-info) "")))
    (vui-vstack
     (vui-text
      (concat
       (gastown-polecat-detail--running-indicator running)
       " "
       (propertize (format "%s/%s" rig-name name)
                   'face 'gastown-polecat-detail-heading)
       (unless (string-empty-p info)
         (propertize (format "  [%s]" info)
                     'face 'gastown-polecat-detail-label)))))))

(defun gastown-polecat-detail--hook-row (polecat)
  "Render the hook/work assignment row for POLECAT (`gastown-agent')."
  (let ((has-work (oref polecat has-work)))
    (vui-hstack
     (gastown-polecat-detail--field-label "Hook")
     (if has-work
         (vui-text (propertize "has work" 'face 'success))
       (vui-text (propertize "no work" 'face 'gastown-polecat-detail-stopped))))))

(defun gastown-polecat-detail--session-row (polecat)
  "Render the tmux session row for POLECAT (`gastown-agent')."
  (let* ((session (oref polecat session))
         (running (oref polecat running)))
    (vui-hstack
     (gastown-polecat-detail--field-label "Session")
     (if (and session running)
         (vui-button session
           :no-decoration t
           :on-click (lambda ()
                       (shell-command
                        (format "tmux select-window -t gt:%s" session))))
       (vui-text (propertize (or session "none")
                             'face 'gastown-polecat-detail-stopped))))))

(defun gastown-polecat-detail--mail-row (polecat)
  "Render the mail row for POLECAT (`gastown-agent')."
  (let ((unread (or (oref polecat unread-mail) 0)))
    (vui-hstack
     (gastown-polecat-detail--field-label "Mail")
     (if (> unread 0)
         (vui-button
          (propertize (format "📬 %d unread" unread)
                      'face 'gastown-polecat-detail-mail)
          :no-decoration t
          :on-click (lambda ()
                      (if (fboundp 'gastown-mail-inbox-show-buffer)
                          (gastown-mail-inbox-show-buffer)
                        (message "Mail inbox: %d unread" unread))))
       (vui-text (propertize "no unread mail"
                             'face 'gastown-polecat-detail-stopped))))))

(defun gastown-polecat-detail--work-item (bead)
  "Render a single BEAD (`gastown-work-item') as a work history row."
  (let* ((id     (or (oref bead id) ""))
         (title  (or (oref bead title) ""))
         (status (or (oref bead status) "")))
    (vui-hstack
     (vui-text (format "%-12s" id) :face 'gastown-polecat-detail-work-id)
     (vui-text (format "%-12s" status) :face 'gastown-polecat-detail-label)
     (vui-text title))))

(defun gastown-polecat-detail--work-history-section (status data error-msg)
  "Render work history based on async STATUS, DATA list, and ERROR-MSG."
  (vui-vstack
   (vui-text "Work History" :face 'gastown-polecat-detail-section)
   (pcase status
     ('pending (vui-text (propertize "  Loading…"
                                     'face 'gastown-polecat-detail-stopped)))
     ('error   (vui-text (propertize (format "  Error: %s" error-msg)
                                     'face 'error)))
     ('ready   (if (null data)
                   (vui-text (propertize "  No recent work."
                                         'face 'gastown-polecat-detail-stopped))
                 (apply #'vui-vstack
                        (mapcar #'gastown-polecat-detail--work-item data)))))))

;;; ============================================================
;;; Root Component
;;; ============================================================

(vui-defcomponent gastown-polecat-detail-app
    (polecat rig-name polecat-name)
  "Root component for the polecat detail view."
  :render
  (let* ((history-result
          (vui-use-async (list 'work-history rig-name polecat-name)
            (lambda (resolve reject)
              (condition-case err
                  (funcall resolve
                           (gastown-polecat-detail--fetch-work-history
                            rig-name polecat-name))
                (error (funcall reject (error-message-string err)))))))
         (history-status (plist-get history-result :status))
         (history-data   (plist-get history-result :data))
         (history-error  (plist-get history-result :error)))
    (vui-vstack
     (gastown-polecat-detail--header polecat rig-name)
     (vui-newline)
     (gastown-polecat-detail--hook-row polecat)
     (gastown-polecat-detail--session-row polecat)
     (gastown-polecat-detail--mail-row polecat)
     (vui-newline)
     (gastown-polecat-detail--work-history-section
      history-status history-data history-error))))

;;; ============================================================
;;; Entry Point
;;; ============================================================

;;;###autoload
(defun gastown-polecat-detail-show (polecat rig-name)
  "Show the detail view for POLECAT (`gastown-agent') in rig RIG-NAME.

Opens a dedicated vui.el buffer showing polecat status, hook,
session, mail, and recent work history."
  (let* ((polecat-name (or (oref polecat name) ""))
         (buf-name (format "*gastown-polecat: %s/%s*" rig-name polecat-name)))
    (vui-mount
     (vui-component 'gastown-polecat-detail-app
       :polecat polecat
       :rig-name rig-name
       :polecat-name polecat-name)
     buf-name)
    (with-current-buffer buf-name
      (setq-local header-line-format
                  (format " Gas Town — %s/%s  (g=refresh  q=quit)"
                          rig-name polecat-name))
      (local-set-key
       (kbd "g")
       (lambda ()
         (interactive)
         (gastown-polecat-detail-show polecat rig-name)))
      (local-set-key (kbd "q") #'quit-window))))

(provide 'gastown-polecat-detail)
;;; gastown-polecat-detail.el ends here
