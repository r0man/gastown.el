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

(defvar gastown--convoy-id-history nil
  "History list for convoy ID completion.")

(defvar gastown--formula-name-history nil
  "History list for formula name completion.")

(defvar gastown--crew-name-history nil
  "History list for crew worker name completion.")

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

(defun gastown-reader-convoy-id (prompt &optional _initial-input _history)
  "Read a convoy ID with rich completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--convoy-id-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-convoy-id'."
  (gastown-completion-read-convoy prompt nil nil nil
                                  'gastown--convoy-id-history))

(defun gastown-reader-formula-name (prompt &optional _initial-input _history)
  "Read a formula name with rich completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--formula-name-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-formula-name'."
  (gastown-completion-read-formula prompt nil nil nil
                                   'gastown--formula-name-history))

(defun gastown-reader-crew-name (prompt &optional _initial-input _history)
  "Read a crew worker name with rich completion.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are accepted
but ignored in favour of `gastown--crew-name-history'.

Wire this to a command slot via
`:transient-reader gastown-reader-crew-name'."
  (gastown-completion-read-crew prompt nil nil nil
                                'gastown--crew-name-history))

(defun gastown-reader-merge-strategy (prompt &optional _initial-input _history)
  "Read a merge strategy from a fixed list of choices.
PROMPT is shown to the user.  INITIAL-INPUT and HISTORY are ignored.

Valid strategies: direct (push to main), mr (merge queue),
local (keep on branch).

Wire this to a command slot via
`:transient-reader gastown-reader-merge-strategy'."
  (completing-read prompt '("mr" "direct" "local") nil t))

(provide 'gastown-reader)
;;; gastown-reader.el ends here
