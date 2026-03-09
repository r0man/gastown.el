;;; gastown-tabulated.el --- Paginated tabulated-list views for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Paginated tabulated-list-mode buffers for Gas Town list views:
;; rig list, session list, convoy list, and mail inbox.
;;
;; Pagination behaviour:
;;   - Page size = rows fitting in the current window (window-body-height - 2)
;;   - ] / [ navigate to next/previous page
;;   - G prompts for a page number to jump to
;;   - Mode line shows "Name [page/total]"
;;   - Page size recomputes automatically on window resize
;;
;; Entry points (also wired as gastown-command-execute-interactive overrides):
;;   M-x gastown-rig-list-show-buffer
;;   M-x gastown-session-list-show-buffer
;;   M-x gastown-convoy-list-show-buffer
;;   M-x gastown-mail-inbox-show-buffer

;;; Code:

(require 'gastown-command-rig)
(require 'gastown-command-agents)
(require 'gastown-command-convoy)
(require 'gastown-command-mail)
(require 'gastown-spec)

;;; ============================================================
;;; Pagination Mixin — Buffer-Local State
;;; ============================================================

(defvar-local gastown-paged--all-entries nil
  "Complete list of tabulated-list entries before pagination.")

(defvar-local gastown-paged--current-page 1
  "Current page number (1-indexed).")

(defvar-local gastown-paged--page-size nil
  "Entries per page.  Nil means compute from window height on demand.")

(defvar-local gastown-paged--base-name ""
  "Base string used in the mode-line page indicator.")

;;; ============================================================
;;; Pagination Mixin — Core Functions
;;; ============================================================

(defun gastown-paged--compute-page-size ()
  "Return how many entries fit in the current window.
Subtracts 2 lines for the tabulated-list column header and mode line."
  (max 1 (- (window-body-height) 2)))

(defun gastown-paged--effective-page-size ()
  "Return the active page size, computing it from the window if not set."
  (or gastown-paged--page-size
      (gastown-paged--compute-page-size)))

(defun gastown-paged--total-pages ()
  "Return the total number of pages given current entries and page size."
  (let ((total (length gastown-paged--all-entries))
        (size  (gastown-paged--effective-page-size)))
    (max 1 (ceiling (/ (float total) size)))))

(defun gastown-paged--page-slice ()
  "Return the sublist of entries for `gastown-paged--current-page'."
  (let* ((size  (gastown-paged--effective-page-size))
         (start (* (1- gastown-paged--current-page) size))
         (end   (min (length gastown-paged--all-entries) (+ start size))))
    (seq-subseq gastown-paged--all-entries start end)))

(defun gastown-paged--update-mode-name ()
  "Set `mode-name' to include the current page / total indicator."
  (setq mode-name
        (format "%s [%d/%d]"
                gastown-paged--base-name
                gastown-paged--current-page
                (gastown-paged--total-pages)))
  (force-mode-line-update))

(defun gastown-paged--refresh-display ()
  "Slice `gastown-paged--all-entries' to the current page and redraw."
  (setq tabulated-list-entries (gastown-paged--page-slice))
  (tabulated-list-print t)
  (gastown-paged--update-mode-name))

;;; ============================================================
;;; Pagination Mixin — Interactive Commands
;;; ============================================================

(defun gastown-paged-next-page ()
  "Advance to the next page."
  (interactive)
  (let ((total (gastown-paged--total-pages)))
    (if (>= gastown-paged--current-page total)
        (message "Already on last page (%d/%d)"
                 gastown-paged--current-page total)
      (setq gastown-paged--current-page (1+ gastown-paged--current-page))
      (gastown-paged--refresh-display))))

(defun gastown-paged-prev-page ()
  "Go back to the previous page."
  (interactive)
  (if (<= gastown-paged--current-page 1)
      (message "Already on first page")
    (setq gastown-paged--current-page (1- gastown-paged--current-page))
    (gastown-paged--refresh-display)))

(defun gastown-paged-goto-page (n)
  "Jump to page N (1-indexed).  Prompt when called interactively."
  (interactive
   (list (read-number (format "Go to page (1-%d): "
                              (gastown-paged--total-pages)))))
  (let ((total (gastown-paged--total-pages)))
    (if (or (< n 1) (> n total))
        (user-error "Page %d out of range (1-%d)" n total)
      (setq gastown-paged--current-page n)
      (gastown-paged--refresh-display))))

;;; ============================================================
;;; Pagination Mixin — Window Resize Hook
;;; ============================================================

(defun gastown-paged--frame-resize (frame)
  "Recompute page size for all paged buffers visible in FRAME."
  (dolist (win (window-list frame))
    (let ((buf (window-buffer win)))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (when (local-variable-p 'gastown-paged--all-entries)
            (let ((new-size (with-selected-window win
                              (gastown-paged--compute-page-size))))
              (unless (eql new-size gastown-paged--page-size)
                (setq gastown-paged--page-size new-size)
                (let ((total (gastown-paged--total-pages)))
                  (when (> gastown-paged--current-page total)
                    (setq gastown-paged--current-page total)))
                (gastown-paged--refresh-display)))))))))

(add-hook 'window-size-change-functions #'gastown-paged--frame-resize)

;;; ============================================================
;;; Shared Helpers
;;; ============================================================

(defun gastown-tabulated--format-timestamp (ts)
  "Shorten ISO-8601 timestamp TS to its date portion (YYYY-MM-DD)."
  (if (or (not ts) (string-empty-p ts))
      ""
    (substring ts 0 (min 10 (length ts)))))

(defun gastown-tabulated--init-paged (base-name all-entries)
  "Initialise pagination state for the current buffer.
BASE-NAME is the label shown in the mode line.
ALL-ENTRIES is the complete list of tabulated-list entries."
  (setq gastown-paged--all-entries all-entries
        gastown-paged--current-page 1
        gastown-paged--page-size    (gastown-paged--compute-page-size)
        gastown-paged--base-name    base-name)
  (gastown-paged--refresh-display))

;;; ============================================================
;;; Shared Keymap (pagination bindings)
;;; ============================================================

(defvar gastown-tabulated-paged-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "]") #'gastown-paged-next-page)
    (define-key map (kbd "[") #'gastown-paged-prev-page)
    (define-key map (kbd "G") #'gastown-paged-goto-page)
    map)
  "Keymap providing pagination bindings for tabulated-list views.")

;;; ============================================================
;;; Effective Spec Helpers
;;; ============================================================

(defun gastown-tabulated--effective-rig-spec ()
  "Return the effective rig spec for the current buffer.
Returns `gastown-current-rig-spec' when set, else `gastown-default-rig-spec'."
  (or gastown-current-rig-spec gastown-default-rig-spec))

(defun gastown-tabulated--effective-agent-spec ()
  "Return the effective agent spec for the current buffer.
Returns `gastown-current-agent-spec' when set, else `gastown-default-agent-spec'."
  (or gastown-current-agent-spec gastown-default-agent-spec))

(defun gastown-tabulated--effective-convoy-spec ()
  "Return the effective convoy spec for the current buffer.
Returns `gastown-current-convoy-spec' when set, else `gastown-default-convoy-spec'."
  (or gastown-current-convoy-spec gastown-default-convoy-spec))

(defun gastown-tabulated--effective-mail-spec ()
  "Return the effective mail spec for the current buffer.
Returns `gastown-current-mail-spec' when set, else `gastown-default-mail-spec'."
  (or gastown-current-mail-spec gastown-default-mail-spec))

;;; ============================================================
;;; Rig List
;;; ============================================================

(defconst gastown-rig-list-buffer-name "*gastown-rig-list*"
  "Buffer name for the Gas Town rig list.")

(defface gastown-rig-list-operational
  '((t :inherit success))
  "Face for operational rig status."
  :group 'gastown)

(defface gastown-rig-list-degraded
  '((t :inherit warning))
  "Face for degraded rig status."
  :group 'gastown)

(defun gastown-rig-list--status-face (status)
  "Return the face for rig STATUS string."
  (if (equal status "operational")
      'gastown-rig-list-operational
    'gastown-rig-list-degraded))

(defun gastown-rig-list--entry (rig)
  "Convert RIG alist (from gt rig list --json) to a tabulated-list entry."
  (let* ((name     (or (alist-get 'name rig) ""))
         (status   (or (alist-get 'status rig) ""))
         (witness  (or (alist-get 'witness rig) ""))
         (refinery (or (alist-get 'refinery rig) ""))
         (polecats (or (alist-get 'polecats rig) 0))
         (crew     (or (alist-get 'crew rig) 0)))
    (list name
          (vector name
                  (propertize status 'face (gastown-rig-list--status-face status))
                  witness
                  refinery
                  (number-to-string polecats)
                  (number-to-string crew)))))

(defun gastown-rig-list-filter ()
  "Invoke the rig list filter menu."
  (interactive)
  (message "Rig list filter: set `gastown-current-rig-spec' or use the filter menu (ge-f8m)."))

(defvar gastown-rig-list-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "g")   #'gastown-rig-list-refresh)
    (define-key map (kbd "RET") #'gastown-rig-list-show-rig)
    (define-key map (kbd "/")   #'gastown-rig-list-filter)
    (define-key map (kbd "]")   #'gastown-paged-next-page)
    (define-key map (kbd "[")   #'gastown-paged-prev-page)
    (define-key map (kbd "G")   #'gastown-paged-goto-page)
    map)
  "Keymap for `gastown-rig-list-mode'.")

(define-derived-mode gastown-rig-list-mode tabulated-list-mode "GT-Rigs"
  "Major mode for the Gas Town rig list buffer.

Key bindings:
\\{gastown-rig-list-mode-map}"
  :group 'gastown
  (setq tabulated-list-format
        [("Name"     20 t)
         ("Status"   12 t)
         ("Witness"  10 t)
         ("Refinery" 10 t)
         ("Polecats"  9 t)
         ("Crew"      6 t)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key (cons "Name" nil))
  (tabulated-list-init-header))

(defun gastown-rig-list--populate (data)
  "Populate the rig list buffer from DATA (JSON array of rig alists)."
  (let ((entries (mapcar #'gastown-rig-list--entry
                         (if (vectorp data) (append data nil) data))))
    (gastown-tabulated--init-paged "GT-Rigs" entries)))

;;;###autoload
(defun gastown-rig-list-refresh ()
  "Refresh the *gastown-rig-list* buffer.
Applies the current buffer-local `gastown-current-rig-spec' filter."
  (interactive)
  (let* ((spec (gastown-tabulated--effective-rig-spec))
         (data (gastown-command-rig-list! :json t
                                          :extra-args (gastown-spec--to-args spec))))
    (gastown-rig-list--populate data)
    (message "Rig list refreshed")))

(defun gastown-rig-list-show-rig ()
  "Show details for the rig at point."
  (interactive)
  (let ((name (tabulated-list-get-id)))
    (if name
        (message "Rig: %s" name)
      (user-error "No rig at point"))))

;;;###autoload
(defun gastown-rig-list-show-buffer ()
  "Open (or switch to) the *gastown-rig-list* paginated buffer."
  (interactive)
  (let* ((buf  (get-buffer-create gastown-rig-list-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-rig-list-mode)
        (gastown-rig-list-mode))
      (gastown-rig-list-refresh))
    (pop-to-buffer buf)))

(cl-defmethod gastown-command-execute-interactive ((_cmd gastown-command-rig-list))
  "Show rig list in a paginated tabulated-list buffer."
  (gastown-rig-list-show-buffer))

;;; ============================================================
;;; Session List
;;; ============================================================

(defconst gastown-session-list-buffer-name "*gastown-session-list*"
  "Buffer name for the Gas Town session list.")

(defface gastown-session-list-running
  '((t :inherit success :weight bold))
  "Face for running session indicator."
  :group 'gastown)

(defface gastown-session-list-stopped
  '((t :inherit shadow))
  "Face for stopped session indicator."
  :group 'gastown)

(defun gastown-session-list--entry (session)
  "Convert SESSION alist (from gt session list --json) to a tabulated-list entry."
  (let* ((rig        (or (alist-get 'rig session) ""))
         (polecat    (or (alist-get 'polecat session) ""))
         (session-id (or (alist-get 'session_id session) ""))
         (running    (let ((v (alist-get 'running session)))
                       (and v (not (eq v :json-false)))))
         (indicator  (if running
                         (propertize "●" 'face 'gastown-session-list-running)
                       (propertize "○" 'face 'gastown-session-list-stopped))))
    (list session-id
          (vector rig polecat session-id indicator))))

(defun gastown-session-list-filter ()
  "Invoke the session list filter menu."
  (interactive)
  (message "Session list filter: set `gastown-current-agent-spec' or use the filter menu (ge-f8m)."))

(defvar gastown-session-list-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "g")   #'gastown-session-list-refresh)
    (define-key map (kbd "RET") #'gastown-session-list-jump)
    (define-key map (kbd "/")   #'gastown-session-list-filter)
    (define-key map (kbd "]")   #'gastown-paged-next-page)
    (define-key map (kbd "[")   #'gastown-paged-prev-page)
    (define-key map (kbd "G")   #'gastown-paged-goto-page)
    map)
  "Keymap for `gastown-session-list-mode'.")

(define-derived-mode gastown-session-list-mode tabulated-list-mode "GT-Sessions"
  "Major mode for the Gas Town session list buffer.

Key bindings:
\\{gastown-session-list-mode-map}"
  :group 'gastown
  (setq tabulated-list-format
        [("Rig"        15 t)
         ("Polecat"    15 t)
         ("Session ID" 22 t)
         ("Running"     7 nil)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key (cons "Rig" nil))
  (tabulated-list-init-header))

(defun gastown-session-list--populate (data)
  "Populate the session list buffer from DATA (JSON array of session alists)."
  (let ((entries (mapcar #'gastown-session-list--entry
                         (if (vectorp data) (append data nil) data))))
    (gastown-tabulated--init-paged "GT-Sessions" entries)))

;;;###autoload
(defun gastown-session-list-refresh ()
  "Refresh the *gastown-session-list* buffer.
Applies the current buffer-local `gastown-current-agent-spec' filter."
  (interactive)
  (let* ((spec (gastown-tabulated--effective-agent-spec))
         (data (gastown-command-session-list! :json t
                                              :extra-args (gastown-spec--to-args spec))))
    (gastown-session-list--populate data)
    (message "Session list refreshed")))

(defun gastown-session-list-jump ()
  "Switch to the tmux window for the session at point."
  (interactive)
  (let ((id (tabulated-list-get-id)))
    (if id
        (shell-command (format "tmux select-window -t gt:%s" id))
      (user-error "No session at point"))))

;;;###autoload
(defun gastown-session-list-show-buffer ()
  "Open (or switch to) the *gastown-session-list* paginated buffer."
  (interactive)
  (let* ((buf (get-buffer-create gastown-session-list-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-session-list-mode)
        (gastown-session-list-mode))
      (gastown-session-list-refresh))
    (pop-to-buffer buf)))

(cl-defmethod gastown-command-execute-interactive ((_cmd gastown-command-session-list))
  "Show session list in a paginated tabulated-list buffer."
  (gastown-session-list-show-buffer))

;;; ============================================================
;;; Convoy List
;;; ============================================================

(defconst gastown-convoy-list-buffer-name "*gastown-convoy-list*"
  "Buffer name for the Gas Town convoy list.")

(defun gastown-convoy-list--entry (convoy)
  "Convert CONVOY alist (from gt convoy list --json) to a tabulated-list entry."
  (let* ((id        (or (alist-get 'id convoy) ""))
         (title     (or (alist-get 'title convoy) ""))
         (status    (or (alist-get 'status convoy) ""))
         (created   (gastown-tabulated--format-timestamp
                     (alist-get 'created_at convoy)))
         (completed (or (alist-get 'completed convoy) 0))
         (total     (or (alist-get 'total convoy) 0))
         (progress  (format "%d/%d" completed total)))
    (list id
          (vector id title status created progress))))

(defun gastown-convoy-list-filter ()
  "Invoke the convoy list filter menu."
  (interactive)
  (message "Convoy list filter: set `gastown-current-convoy-spec' or use the filter menu (ge-f8m)."))

(defvar gastown-convoy-list-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "g")   #'gastown-convoy-list-refresh)
    (define-key map (kbd "RET") #'gastown-convoy-list-show-status)
    (define-key map (kbd "/")   #'gastown-convoy-list-filter)
    (define-key map (kbd "]")   #'gastown-paged-next-page)
    (define-key map (kbd "[")   #'gastown-paged-prev-page)
    (define-key map (kbd "G")   #'gastown-paged-goto-page)
    map)
  "Keymap for `gastown-convoy-list-mode'.")

(define-derived-mode gastown-convoy-list-mode tabulated-list-mode "GT-Convoys"
  "Major mode for the Gas Town convoy list buffer.

Key bindings:
\\{gastown-convoy-list-mode-map}"
  :group 'gastown
  (setq tabulated-list-format
        [("ID"       16 t)
         ("Title"    42 t)
         ("Status"   12 t)
         ("Created"  10 t)
         ("Progress"  9 t)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key (cons "Created" nil))
  (tabulated-list-init-header))

(defun gastown-convoy-list--populate (data)
  "Populate the convoy list buffer from DATA (JSON array of convoy alists)."
  (let ((entries (mapcar #'gastown-convoy-list--entry
                         (if (vectorp data) (append data nil) data))))
    (gastown-tabulated--init-paged "GT-Convoys" entries)))

;;;###autoload
(defun gastown-convoy-list-refresh ()
  "Refresh the *gastown-convoy-list* buffer.
Applies the current buffer-local `gastown-current-convoy-spec' filter."
  (interactive)
  (let* ((spec (gastown-tabulated--effective-convoy-spec))
         (data (gastown-command-convoy-list! :json t
                                             :extra-args (gastown-spec--to-args spec))))
    (gastown-convoy-list--populate data)
    (message "Convoy list refreshed")))

(defun gastown-convoy-list-show-status ()
  "Show convoy status details for the convoy at point."
  (interactive)
  (let ((id (tabulated-list-get-id)))
    (if id
        (gastown-command-convoy-status! :convoy-id id)
      (user-error "No convoy at point"))))

;;;###autoload
(defun gastown-convoy-list-show-buffer ()
  "Open (or switch to) the *gastown-convoy-list* paginated buffer."
  (interactive)
  (let* ((buf (get-buffer-create gastown-convoy-list-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-convoy-list-mode)
        (gastown-convoy-list-mode))
      (gastown-convoy-list-refresh))
    (pop-to-buffer buf)))

(cl-defmethod gastown-command-execute-interactive ((_cmd gastown-command-convoy-list))
  "Show convoy list in a paginated tabulated-list buffer."
  (gastown-convoy-list-show-buffer))

;;; ============================================================
;;; Mail Inbox
;;; ============================================================

(defconst gastown-mail-inbox-buffer-name "*gastown-mail-inbox*"
  "Buffer name for the Gas Town mail inbox.")

(defface gastown-mail-inbox-unread
  '((t :inherit bold))
  "Face for unread mail indicator."
  :group 'gastown)

(defface gastown-mail-inbox-priority-high
  '((t :inherit warning))
  "Face for high-priority mail."
  :group 'gastown)

(defun gastown-mail-inbox--entry (mail)
  "Convert MAIL alist (from gt mail inbox --json) to a tabulated-list entry."
  (let* ((id        (or (alist-get 'id mail) ""))
         (from      (or (alist-get 'from mail) ""))
         (subject   (or (alist-get 'subject mail) ""))
         (timestamp (gastown-tabulated--format-timestamp
                     (alist-get 'timestamp mail)))
         (read      (let ((v (alist-get 'read mail)))
                       (and v (not (eq v :json-false)))))
         (priority  (or (alist-get 'priority mail) "normal"))
         (unread    (if (not read)
                        (propertize "●" 'face 'gastown-mail-inbox-unread)
                      ""))
         (subj-str  (if (equal priority "high")
                        (propertize subject 'face 'gastown-mail-inbox-priority-high)
                      subject)))
    (list id
          (vector id from subj-str timestamp unread))))

(defun gastown-mail-inbox-filter ()
  "Invoke the mail inbox filter menu."
  (interactive)
  (message "Mail inbox filter: set `gastown-current-mail-spec' or use the filter menu (ge-f8m)."))

(defvar gastown-mail-inbox-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map tabulated-list-mode-map)
    (define-key map (kbd "g")   #'gastown-mail-inbox-refresh)
    (define-key map (kbd "RET") #'gastown-mail-inbox-read)
    (define-key map (kbd "/")   #'gastown-mail-inbox-filter)
    (define-key map (kbd "]")   #'gastown-paged-next-page)
    (define-key map (kbd "[")   #'gastown-paged-prev-page)
    (define-key map (kbd "G")   #'gastown-paged-goto-page)
    map)
  "Keymap for `gastown-mail-inbox-mode'.")

(define-derived-mode gastown-mail-inbox-mode tabulated-list-mode "GT-Mail"
  "Major mode for the Gas Town mail inbox buffer.

Key bindings:
\\{gastown-mail-inbox-mode-map}"
  :group 'gastown
  (setq tabulated-list-format
        [("ID"      15 t)
         ("From"    22 t)
         ("Subject" 46 t)
         ("Date"    10 t)
         ("New"      3 nil)])
  (setq tabulated-list-padding 1)
  (setq tabulated-list-sort-key nil)
  (tabulated-list-init-header))

(defun gastown-mail-inbox--populate (data)
  "Populate the mail inbox buffer from DATA (JSON array of mail alists)."
  (let ((entries (mapcar #'gastown-mail-inbox--entry
                         (if (vectorp data) (append data nil) data))))
    (gastown-tabulated--init-paged "GT-Mail" entries)))

;;;###autoload
(defun gastown-mail-inbox-refresh ()
  "Refresh the *gastown-mail-inbox* buffer.
Applies the current buffer-local `gastown-current-mail-spec' filter."
  (interactive)
  (let* ((spec (gastown-tabulated--effective-mail-spec))
         (data (gastown-command-mail-inbox! :json t
                                            :extra-args (gastown-spec--to-args spec))))
    (gastown-mail-inbox--populate data)
    (message "Mail inbox refreshed")))

(defun gastown-mail-inbox-read ()
  "Read the mail message at point."
  (interactive)
  (let ((id (tabulated-list-get-id)))
    (if id
        (gastown-command-mail-read! :mail-id id)
      (user-error "No message at point"))))

;;;###autoload
(defun gastown-mail-inbox-show-buffer ()
  "Open (or switch to) the *gastown-mail-inbox* paginated buffer."
  (interactive)
  (let* ((buf (get-buffer-create gastown-mail-inbox-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-mail-inbox-mode)
        (gastown-mail-inbox-mode))
      (gastown-mail-inbox-refresh))
    (pop-to-buffer buf)))

(cl-defmethod gastown-command-execute-interactive ((_cmd gastown-command-mail-inbox))
  "Show mail inbox in a paginated tabulated-list buffer."
  (gastown-mail-inbox-show-buffer))

(provide 'gastown-tabulated)
;;; gastown-tabulated.el ends here
