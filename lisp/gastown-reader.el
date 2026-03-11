;;; gastown-reader.el --- Transient reader functions for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides reader functions following the transient reader
;; protocol for Gas Town entities (rigs, polecats, mail addresses).
;;
;; Reader functions follow the transient reader signature:
;;   (PROMPT &optional INITIAL-INPUT HISTORY)
;;
;; Wire them to command slots via :transient-reader:
;;
;;   (rig-name
;;    :initarg :rig-name
;;    ...
;;    :transient-reader gastown-reader-rig-name)

;;; Code:

(require 'gastown-completion)

;;; History variables

(defvar gastown--rig-name-history nil
  "History list for rig name completion.")

(defvar gastown--polecat-address-history nil
  "History list for polecat address completion.")

(defvar gastown--mail-address-history nil
  "History list for mail address completion.")

;;; ============================================================
;;; Transient Reader Functions
;;; ============================================================

(defun gastown-reader-rig-name (prompt &optional _initial-input _history)
  "Read a rig name with rich completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--rig-name-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-rig-name'."
  (gastown-completion-read-rig prompt nil t nil
                               'gastown--rig-name-history))

(defun gastown-reader-polecat-address (prompt &optional _initial-input
                                              _history)
  "Read a polecat address (rig/name) with rich completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--polecat-address-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-polecat-address'."
  (gastown-completion-read-polecat prompt nil t nil
                                   'gastown--polecat-address-history))

(defun gastown-reader-mail-address (prompt &optional _initial-input _history)
  "Read a mail address in rig/role format with completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--mail-address-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-mail-address'."
  (gastown-completion-read-mail-address prompt nil nil nil
                                        'gastown--mail-address-history))

(provide 'gastown-reader)
;;; gastown-reader.el ends here
