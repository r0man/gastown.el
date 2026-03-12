;;; gastown-whats-new.el --- What's New buffer for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; Provides `gastown-whats-new', a vui-based buffer that shows the
;; output of `gt info --whats-new' immediately without a transient
;; Execute/Preview step.
;;
;; The buffer renders the CLI output faithfully with lightweight
;; syntax highlighting: bold title, coloured version headers, and
;; per-category bullet colours (NEW/CHANGED/FIX).
;;
;; The `gastown-command-info' execute-interactive method is overridden
;; so that pressing the "Info" key in the diagnostics transient opens
;; this buffer directly.

;;; Code:

(require 'vui)
(require 'gastown-command-diagnostics)

(defvar gastown-executable)

;;; Buffer name

(defconst gastown-whats-new-buffer-name "*gastown-whats-new*"
  "Name of the What's New buffer.")

;;; Major mode

(defvar-keymap gastown-whats-new-mode-map
  :parent vui-mode-map
  "g" #'gastown-whats-new
  "n" #'next-line
  "p" #'previous-line
  "N" #'scroll-up-command
  "P" #'scroll-down-command
  "q" #'quit-window)

(define-derived-mode gastown-whats-new-mode vui-mode "GT-WhatsNew"
  "Major mode for the Gas Town What's New buffer.

Key bindings:
\\{gastown-whats-new-mode-map}"
  (setq-local header-line-format
              " Gas Town — What's New  (g=refresh  n/p=nav  q=quit)"))

;;; Faces

(defface gastown-whats-new-title
  '((t :inherit bold))
  "Face for the What's New title line.")

(defface gastown-whats-new-version
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for version header lines (## vX.Y.Z).")

(defface gastown-whats-new-separator
  '((t :inherit shadow))
  "Face for separator lines (====).")

(defface gastown-whats-new-new
  '((t :inherit font-lock-string-face :weight bold))
  "Face for NEW: bullet category tag.")

(defface gastown-whats-new-changed
  '((t :inherit font-lock-type-face :weight bold))
  "Face for CHANGED: bullet category tag.")

(defface gastown-whats-new-fix
  '((t :inherit font-lock-warning-face :weight bold))
  "Face for FIX: bullet category tag.")

;;; Line rendering

(defun gastown-whats-new--propertize-bullet (line)
  "Return LINE with colour applied to NEW:/CHANGED:/FIX: tag."
  (cond
   ((string-match "\\(NEW:\\)" line)
    (put-text-property (match-beginning 1) (match-end 1)
                       'face 'gastown-whats-new-new line))
   ((string-match "\\(CHANGED:\\)" line)
    (put-text-property (match-beginning 1) (match-end 1)
                       'face 'gastown-whats-new-changed line))
   ((string-match "\\(FIX:\\)" line)
    (put-text-property (match-beginning 1) (match-end 1)
                       'face 'gastown-whats-new-fix line)))
  line)

(defun gastown-whats-new--line-vnode (line)
  "Return a vui vnode for a single LINE of `gt info --whats-new' output."
  (let ((content
         (cond
          ;; Title: "What's New in Gas Town..."
          ((string-match-p "\\`What's New" line)
           (propertize line 'face 'gastown-whats-new-title))
          ;; Separator: ====...
          ((string-match-p "\\`=\\{4,\\}" line)
           (propertize line 'face 'gastown-whats-new-separator))
          ;; Version header: ## vX.Y.Z ...
          ((string-match-p "\\`## " line)
           (propertize line 'face 'gastown-whats-new-version))
          ;; Bullet with category tag
          ((string-match-p "\\*.*:\\(NEW\\|CHANGED\\|FIX\\):" line)
           (gastown-whats-new--propertize-bullet (copy-sequence line)))
          ((string-match-p "\\* \\(NEW\\|CHANGED\\|FIX\\):" line)
           (gastown-whats-new--propertize-bullet (copy-sequence line)))
          ;; Plain line (indent, blank, normal text)
          (t line))))
    (vui-text content)))

;;; Async fetch

(defun gastown-whats-new--async-fetch (resolve reject)
  "Fetch `gt info --whats-new' output asynchronously.
RESOLVE is called with the raw text string on success.
REJECT is called with an error message string on failure."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-whats-new-fetch"
     :command (list exe "info" "--whats-new")
     :filter (lambda (_proc chunk)
               (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (if (string-prefix-p "finished" event)
                     (funcall resolve output)
                   (funcall reject (format "Process ended: %s"
                                           (string-trim event)))))
     :connection-type 'pipe)))

;;; vui component

(vui-defcomponent gastown-whats-new-app ()
  "Root async component for the Gas Town What's New buffer.

Fetches `gt info --whats-new' output asynchronously, shows a
spinner while loading, then renders the result line-by-line."
  :state ((refresh-tick 0))
  :render
  (let* ((result (vui-use-async (list 'whats-new refresh-tick)
                   #'gastown-whats-new--async-fetch))
         (status (plist-get result :status))
         (text   (plist-get result :data))
         (err    (plist-get result :error)))
    (cond
     ((eq status 'pending)
      (vui-text (propertize "⏳ Loading…" 'face 'shadow)))
     (err
      (vui-vstack
       (vui-text (propertize "Error:" 'face 'error))
       (vui-text (propertize (or err "unknown error") 'face 'error))
       (vui-newline)
       (vui-button "[Retry]"
         :on-click (let ((tick refresh-tick))
                     (lambda ()
                       (vui-set-state :refresh-tick (1+ tick)))))))
     (text
      (apply #'vui-vstack
             (mapcar #'gastown-whats-new--line-vnode
                     (split-string text "\n")))))))

;;; Entry point

;;;###autoload
(defun gastown-whats-new ()
  "Show Gas Town What's New in a dedicated vui buffer."
  (interactive)
  (let ((buf (get-buffer-create gastown-whats-new-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'gastown-whats-new-mode)
        (gastown-whats-new-mode)))
    (vui-mount
     (vui-component 'gastown-whats-new-app)
     gastown-whats-new-buffer-name)
    (pop-to-buffer gastown-whats-new-buffer-name)))

;;; execute-interactive override

(cl-defmethod gastown-command-execute-interactive
    ((_command gastown-command-info))
  "Open the What's New buffer directly instead of a transient terminal."
  (gastown-whats-new))

(provide 'gastown-whats-new)
;;; gastown-whats-new.el ends here
