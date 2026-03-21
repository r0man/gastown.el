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

(provide 'gastown-error)
;;; gastown-error.el ends here
