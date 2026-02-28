;;; gastown-error.el --- Error definitions for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines all error conditions used throughout gastown.el.
;;
;; Error Hierarchy:
;;
;; error
;;   └─ gastown-error (base error for all gastown operations)
;;       ├─ gastown-command-error (command execution failed)
;;       ├─ gastown-json-parse-error (JSON parsing failed)
;;       └─ gastown-validation-error (command validation failed)

;;; Code:

;;; Error Definitions

(define-error 'gastown-error
  "Gas Town error"
  'error)

(define-error 'gastown-command-error
  "Gas Town command execution error"
  'gastown-error)

(define-error 'gastown-json-parse-error
  "Gas Town JSON parse error"
  'gastown-error)

(define-error 'gastown-validation-error
  "Gas Town command validation error"
  'gastown-error)

;;; Error Extraction Utilities

(defun gastown-error-extract-message (err)
  "Extract user-friendly message from gastown error ERR.
ERR is the error data from `condition-case'.

For `gastown-command-error', this extracts the stderr message which
typically contains the actual error text from the gt CLI.
If stderr is empty, falls back to stdout, then to the generic message.

Returns a string suitable for display to the user."
  (let* ((err-data (cdr err))
         (message (car err-data))
         (plist (cdr err-data))
         (stderr (plist-get plist :stderr))
         (stdout (plist-get plist :stdout)))
    (cond
     ;; Prefer stderr if non-empty (typical for CLI errors)
     ((and stderr (not (string-empty-p (string-trim stderr))))
      (string-trim stderr))
     ;; Fall back to stdout if stderr is empty
     ((and stdout (not (string-empty-p (string-trim stdout))))
      (string-trim stdout))
     ;; Use the error message if nothing else
     (t (or message (error-message-string err))))))

(provide 'gastown-error)
;;; gastown-error.el ends here
