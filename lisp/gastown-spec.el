;;; gastown-spec.el --- Filter spec objects for Gas Town list views -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; EIEIO filter spec classes for Gas Town tabulated-list views.
;;
;; Each spec class captures the filtering and ordering parameters for a
;; particular list view, and provides a `gastown-spec--to-args' generic
;; method that converts the spec to a list of CLI flag strings suitable
;; for passing to the corresponding `gt' subcommand.
;;
;; Pattern follows beads-issue-spec and Forge's forge--topics-spec:
;;   - EIEIO class with typed slots
;;   - Generic `gastown-spec--to-args' method per class
;;   - `defcustom' for user-configurable global defaults
;;   - `defvar-local' buffer-local variable per list type
;;
;; Spec classes:
;;   gastown-agent-spec   — agent/session list (rig, role, running, order)
;;   gastown-rig-spec     — rig list (status, order)
;;   gastown-convoy-spec  — convoy list (status)
;;   gastown-mail-spec    — mail inbox (unread-only, all)

;;; Code:

(require 'eieio)
(require 'cl-lib)
(require 'gastown-types)

;;; ============================================================
;;; Generic Method
;;; ============================================================

(cl-defgeneric gastown-spec--to-args (spec)
  "Return a list of CLI flag strings for SPEC.
The returned list is suitable for appending to a `gt' subcommand invocation.")

;;; ============================================================
;;; gastown-agent-spec
;;; ============================================================

(cl-defmethod gastown-spec--to-args ((spec gastown-agent-spec))
  "Return CLI args for SPEC as a flat list of strings."
  (let (args)
    (when (oref spec rig)
      (push (format "--rig=%s" (oref spec rig)) args))
    (when (oref spec role)
      (push (format "--role=%s" (oref spec role)) args))
    (when (oref spec running)
      (push "--running" args))
    (unless (eq (oref spec order) 'name)
      (push (format "--order=%s" (oref spec order)) args))
    (nreverse args)))

;;; ============================================================
;;; gastown-rig-spec
;;; ============================================================

(cl-defmethod gastown-spec--to-args ((spec gastown-rig-spec))
  "Return CLI args for SPEC as a flat list of strings."
  (let (args)
    (when (oref spec status)
      (push (format "--status=%s" (oref spec status)) args))
    (unless (eq (oref spec order) 'name)
      (push (format "--order=%s" (oref spec order)) args))
    (nreverse args)))

;;; ============================================================
;;; gastown-convoy-spec
;;; ============================================================

(cl-defmethod gastown-spec--to-args ((spec gastown-convoy-spec))
  "Return CLI args for SPEC as a flat list of strings."
  (let (args)
    (when (oref spec status)
      (push (format "--status=%s" (oref spec status)) args))
    (nreverse args)))

;;; ============================================================
;;; gastown-mail-spec
;;; ============================================================

(cl-defmethod gastown-spec--to-args ((spec gastown-mail-spec))
  "Return CLI args for SPEC as a flat list of strings.
--unread and --all are mutually exclusive; --all takes precedence."
  (let (args)
    (cond
     ((oref spec all)        (push "--all" args))
     ((oref spec unread-only) (push "--unread" args)))
    (nreverse args)))

;;; ============================================================
;;; Default Spec Customization Variables
;;; ============================================================

(defcustom gastown-default-agent-spec (gastown-agent-spec)
  "Default filter spec for the Gas Town agent/session list view.
This spec is used when no buffer-local spec has been set."
  :type '(restricted-sexp :match-alternatives (gastown-agent-spec-p))
  :group 'gastown)

(defcustom gastown-default-rig-spec (gastown-rig-spec)
  "Default filter spec for the Gas Town rig list view.
This spec is used when no buffer-local spec has been set."
  :type '(restricted-sexp :match-alternatives (gastown-rig-spec-p))
  :group 'gastown)

(defcustom gastown-default-convoy-spec (gastown-convoy-spec)
  "Default filter spec for the Gas Town convoy list view.
This spec is used when no buffer-local spec has been set."
  :type '(restricted-sexp :match-alternatives (gastown-convoy-spec-p))
  :group 'gastown)

(defcustom gastown-default-mail-spec (gastown-mail-spec)
  "Default filter spec for the Gas Town mail inbox view.
This spec is used when no buffer-local spec has been set."
  :type '(restricted-sexp :match-alternatives (gastown-mail-spec-p))
  :group 'gastown)

;;; ============================================================
;;; Buffer-Local Spec Variables
;;; ============================================================

(defvar-local gastown-current-agent-spec nil
  "Buffer-local filter spec for the agent/session list.
When nil, `gastown-default-agent-spec' is used instead.")

(defvar-local gastown-current-rig-spec nil
  "Buffer-local filter spec for the rig list.
When nil, `gastown-default-rig-spec' is used instead.")

(defvar-local gastown-current-convoy-spec nil
  "Buffer-local filter spec for the convoy list.
When nil, `gastown-default-convoy-spec' is used instead.")

(defvar-local gastown-current-mail-spec nil
  "Buffer-local filter spec for the mail inbox.
When nil, `gastown-default-mail-spec' is used instead.")

;;; ============================================================
;;; Effective Spec Accessors
;;; ============================================================
;;
;; `gastown-default-*-spec' defcustom variables hold shared EIEIO
;; objects created at load time.  Direct callers must never `oset'
;; on them, as the mutation would be permanent and global.  These
;; accessor functions return the buffer-local spec when set, or a
;; fresh clone of the global default otherwise, so callers are
;; always working on an independent copy.

(defun gastown-effective-agent-spec ()
  "Return the effective agent spec for the current buffer.
Returns `gastown-current-agent-spec' if set, otherwise a fresh
clone of `gastown-default-agent-spec'."
  (or gastown-current-agent-spec
      (clone gastown-default-agent-spec)))

(defun gastown-effective-rig-spec ()
  "Return the effective rig spec for the current buffer.
Returns `gastown-current-rig-spec' if set, otherwise a fresh
clone of `gastown-default-rig-spec'."
  (or gastown-current-rig-spec
      (clone gastown-default-rig-spec)))

(defun gastown-effective-convoy-spec ()
  "Return the effective convoy spec for the current buffer.
Returns `gastown-current-convoy-spec' if set, otherwise a fresh
clone of `gastown-default-convoy-spec'."
  (or gastown-current-convoy-spec
      (clone gastown-default-convoy-spec)))

(defun gastown-effective-mail-spec ()
  "Return the effective mail spec for the current buffer.
Returns `gastown-current-mail-spec' if set, otherwise a fresh
clone of `gastown-default-mail-spec'."
  (or gastown-current-mail-spec
      (clone gastown-default-mail-spec)))

(provide 'gastown-spec)
;;; gastown-spec.el ends here
