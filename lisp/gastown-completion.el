;;; gastown-completion.el --- Completion support for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module provides rich completion with TTL caching for Gas Town
;; entities: rigs, polecats, and convoys.
;;
;; Key features:
;; - EIEIO classes for rig, polecat, and convoy summaries
;; - TTL-based caching for each entity type (5 second default)
;; - Annotation functions showing entity status
;; - Completion tables with text properties for rich UIs
;; - Public read-* functions for interactive selection
;; - Optional marginalia integration
;;
;; Usage:
;;
;;   (gastown-completion-read-rig "Rig: " nil t)
;;   (gastown-completion-read-polecat "Polecat: " nil t)
;;   (gastown-completion-read-mail-address "To: " nil nil)

;;; Code:

(require 'eieio)
(require 'seq)
(require 'gastown-command)

;; Forward declarations for command modules
(declare-function gastown-command-rig-list "gastown-command-rig")
(declare-function gastown-command-polecat-list "gastown-command-polecat")
(declare-function gastown-command-convoy-list "gastown-command-convoy")

;;; ============================================================
;;; EIEIO Classes
;;; ============================================================

(defclass gastown-completion-rig ()
  ((name
    :initarg :name
    :type string
    :documentation "Rig name.")
   (beads-prefix
    :initarg :beads-prefix
    :type (or null string)
    :initform nil
    :documentation "Beads issue prefix for this rig.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Rig status (operational, degraded, docked, parked).")
   (witness
    :initarg :witness
    :type (or null string)
    :initform nil
    :documentation "Witness service status.")
   (refinery
    :initarg :refinery
    :type (or null string)
    :initform nil
    :documentation "Refinery service status.")
   (polecats
    :initarg :polecats
    :type (or null integer)
    :initform nil
    :documentation "Number of polecats in this rig.")
   (crew
    :initarg :crew
    :type (or null integer)
    :initform nil
    :documentation "Number of crew members."))
  :documentation "A Gas Town rig summary.")

(defclass gastown-completion-polecat ()
  ((name
    :initarg :name
    :type string
    :documentation "Polecat name.")
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig this polecat belongs to.")
   (state
    :initarg :state
    :type (or null string)
    :initform nil
    :documentation "Polecat state (working, idle, etc.).")
   (issue
    :initarg :issue
    :type (or null string)
    :initform nil
    :documentation "Current issue the polecat is working on.")
   (session-running
    :initarg :session-running
    :type boolean
    :initform nil
    :documentation "Whether the polecat session is running."))
  :documentation "A Gas Town polecat summary.")

(defclass gastown-completion-convoy ()
  ((id
    :initarg :id
    :type string
    :documentation "Convoy ID.")
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Convoy title.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Convoy status (open, completed, cancelled).")
   (completed
    :initarg :completed
    :type (or null integer)
    :initform nil
    :documentation "Number of completed tasks.")
   (total
    :initarg :total
    :type (or null integer)
    :initform nil
    :documentation "Total number of tasks."))
  :documentation "A Gas Town convoy summary.")

;;; ============================================================
;;; Parse Functions
;;; ============================================================

(defun gastown-completion--parse-rig (alist)
  "Parse a rig ALIST into a `gastown-completion-rig' object."
  (gastown-completion-rig
   :name (or (cdr (assq 'name alist)) "")
   :beads-prefix (cdr (assq 'beads_prefix alist))
   :status (cdr (assq 'status alist))
   :witness (cdr (assq 'witness alist))
   :refinery (cdr (assq 'refinery alist))
   :polecats (cdr (assq 'polecats alist))
   :crew (cdr (assq 'crew alist))))

(defun gastown-completion--parse-polecat (alist)
  "Parse a polecat ALIST into a `gastown-completion-polecat' object."
  (let ((session-raw (cdr (assq 'session_running alist))))
    (gastown-completion-polecat
     :name (or (cdr (assq 'name alist)) "")
     :rig (cdr (assq 'rig alist))
     :state (cdr (assq 'state alist))
     :issue (cdr (assq 'issue alist))
     :session-running (and session-raw
                           (not (eq session-raw :json-false))
                           t))))

(defun gastown-completion--parse-convoy (alist)
  "Parse a convoy ALIST into a `gastown-completion-convoy' object."
  (gastown-completion-convoy
   :id (or (cdr (assq 'id alist)) "")
   :title (cdr (assq 'title alist))
   :status (cdr (assq 'status alist))
   :completed (cdr (assq 'completed alist))
   :total (cdr (assq 'total alist))))

;;; ============================================================
;;; Data Fetching
;;; ============================================================

(defun gastown-completion--fetch-rigs ()
  "Fetch rig list via gt rig list --json.
Returns list of `gastown-completion-rig' objects."
  (require 'gastown-command-rig)
  (let* ((cmd (gastown-command-rig-list :json t))
         (execution (gastown-command-execute cmd))
         (data (oref execution result)))
    (mapcar #'gastown-completion--parse-rig
            (if (vectorp data) (append data nil) data))))

(defun gastown-completion--fetch-polecats ()
  "Fetch polecat list via gt polecat list --all --json.
Returns list of `gastown-completion-polecat' objects."
  (require 'gastown-command-polecat)
  (let* ((cmd (gastown-command-polecat-list :json t))
         (execution (gastown-command-execute cmd))
         (data (oref execution result)))
    (mapcar #'gastown-completion--parse-polecat
            (if (vectorp data) (append data nil) data))))

(defun gastown-completion--fetch-convoys ()
  "Fetch convoy list via gt convoy list --json.
Returns list of `gastown-completion-convoy' objects."
  (require 'gastown-command-convoy)
  (let* ((cmd (gastown-command-convoy-list :json t))
         (execution (gastown-command-execute cmd))
         (data (oref execution result)))
    (mapcar #'gastown-completion--parse-convoy
            (if (vectorp data) (append data nil) data))))

;;; ============================================================
;;; TTL Caching
;;; ============================================================

(defvar gastown-completion--rig-cache nil
  "Cache for rig list.  Format: (TIMESTAMP . RIGS-LIST).")

(defvar gastown-completion--rig-cache-ttl 5
  "TTL for rig completion cache in seconds.")

(defvar gastown-completion--polecat-cache nil
  "Cache for polecat list.  Format: (TIMESTAMP . POLECATS-LIST).")

(defvar gastown-completion--polecat-cache-ttl 5
  "TTL for polecat completion cache in seconds.")

(defvar gastown-completion--convoy-cache nil
  "Cache for convoy list.  Format: (TIMESTAMP . CONVOYS-LIST).")

(defvar gastown-completion--convoy-cache-ttl 5
  "TTL for convoy completion cache in seconds.")

(defun gastown-completion--get-cached-rigs ()
  "Get cached rig list, refreshing if stale.
On fetch failure, returns previous cached data (if any) with a warning."
  (let ((now (float-time)))
    (when (or (null gastown-completion--rig-cache)
              (> (- now (car gastown-completion--rig-cache))
                 gastown-completion--rig-cache-ttl))
      (condition-case err
          (setq gastown-completion--rig-cache
                (cons now (gastown-completion--fetch-rigs)))
        (error
         (when gastown-completion--rig-cache
           (message "Warning: Failed to refresh rigs: %s (using cached data)"
                    (error-message-string err))))))
    (cdr gastown-completion--rig-cache)))

(defun gastown-completion--get-cached-polecats ()
  "Get cached polecat list, refreshing if stale.
On fetch failure, returns previous cached data (if any) with a warning."
  (let ((now (float-time)))
    (when (or (null gastown-completion--polecat-cache)
              (> (- now (car gastown-completion--polecat-cache))
                 gastown-completion--polecat-cache-ttl))
      (condition-case err
          (setq gastown-completion--polecat-cache
                (cons now (gastown-completion--fetch-polecats)))
        (error
         (when gastown-completion--polecat-cache
           (message
            "Warning: Failed to refresh polecats: %s (using cached data)"
            (error-message-string err))))))
    (cdr gastown-completion--polecat-cache)))

(defun gastown-completion--get-cached-convoys ()
  "Get cached convoy list, refreshing if stale.
On fetch failure, returns previous cached data (if any) with a warning."
  (let ((now (float-time)))
    (when (or (null gastown-completion--convoy-cache)
              (> (- now (car gastown-completion--convoy-cache))
                 gastown-completion--convoy-cache-ttl))
      (condition-case err
          (setq gastown-completion--convoy-cache
                (cons now (gastown-completion--fetch-convoys)))
        (error
         (when gastown-completion--convoy-cache
           (message
            "Warning: Failed to refresh convoys: %s (using cached data)"
            (error-message-string err))))))
    (cdr gastown-completion--convoy-cache)))

(defun gastown-completion-invalidate-rig-cache ()
  "Invalidate the rig completion cache."
  (setq gastown-completion--rig-cache nil))

(defun gastown-completion-invalidate-polecat-cache ()
  "Invalidate the polecat completion cache."
  (setq gastown-completion--polecat-cache nil))

(defun gastown-completion-invalidate-convoy-cache ()
  "Invalidate the convoy completion cache."
  (setq gastown-completion--convoy-cache nil))

;;; ============================================================
;;; Annotation Functions
;;; ============================================================

(defun gastown-completion--rig-annotate (candidate)
  "Annotate rig CANDIDATE with status and polecat/crew counts."
  (condition-case nil
      (let ((rig (get-text-property 0 'gastown-rig candidate)))
        (when rig
          (let ((status (oref rig status))
                (polecats (oref rig polecats))
                (crew (oref rig crew)))
            (format " %s %s"
                    (propertize (or status "unknown")
                                'face (pcase status
                                        ("operational" 'success)
                                        ("degraded" 'warning)
                                        ("docked" 'shadow)
                                        ("parked" 'shadow)
                                        (_ 'default)))
                    (format "[%s polecats, %s crew]"
                            (or polecats "?")
                            (or crew "?"))))))
    (error "")))

(defun gastown-completion--polecat-annotate (candidate)
  "Annotate polecat CANDIDATE with state and current issue."
  (condition-case nil
      (let ((polecat (get-text-property 0 'gastown-polecat candidate)))
        (when polecat
          (let ((state (oref polecat state))
                (issue (oref polecat issue))
                (running (oref polecat session-running)))
            (format " %s%s"
                    (propertize (or state "unknown")
                                'face (pcase state
                                        ("working" 'warning)
                                        ("idle" 'success)
                                        (_ 'default)))
                    (if issue
                        (format " [%s]%s"
                                issue
                                (if running " (running)" ""))
                      "")))))
    (error "")))

(defun gastown-completion--convoy-annotate (candidate)
  "Annotate convoy CANDIDATE with status and progress."
  (condition-case nil
      (let ((convoy (get-text-property 0 'gastown-convoy candidate)))
        (when convoy
          (let ((status (oref convoy status))
                (completed (oref convoy completed))
                (total (oref convoy total))
                (title (oref convoy title)))
            (format " %s%s%s"
                    (propertize (or status "unknown")
                                'face (pcase status
                                        ("open" 'warning)
                                        ("completed" 'success)
                                        ("cancelled" 'shadow)
                                        (_ 'default)))
                    (if (and completed total (> total 0))
                        (format " [%d/%d]" completed total)
                      "")
                    (if title (format " - %s" title) "")))))
    (error "")))

;;; ============================================================
;;; Completion Tables
;;; ============================================================

(defun gastown-completion-rig-table ()
  "Return completion table for rig names with status annotations."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-rig)
          (annotation-function . gastown-completion--rig-annotate))
      (let ((rigs (gastown-completion--get-cached-rigs)))
        (complete-with-action
         action
         (mapcar (lambda (r)
                   (propertize (oref r name) 'gastown-rig r))
                 rigs)
         string pred)))))

(defun gastown-completion-polecat-table (&optional rig-filter)
  "Return completion table for polecat addresses (rig/name format).
When RIG-FILTER is non-nil, filter to polecats in that rig."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-polecat)
          (annotation-function . gastown-completion--polecat-annotate))
      (let* ((polecats (gastown-completion--get-cached-polecats))
             (filtered (if rig-filter
                           (seq-filter (lambda (p)
                                         (equal rig-filter (oref p rig)))
                                       polecats)
                         polecats)))
        (complete-with-action
         action
         (mapcar (lambda (p)
                   (let ((address (if (oref p rig)
                                      (format "%s/%s" (oref p rig) (oref p name))
                                    (oref p name))))
                     (propertize address 'gastown-polecat p)))
                 filtered)
         string pred)))))

(defun gastown-completion-convoy-table ()
  "Return completion table for convoy IDs with title annotations."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-convoy)
          (annotation-function . gastown-completion--convoy-annotate))
      (let ((convoys (gastown-completion--get-cached-convoys)))
        (complete-with-action
         action
         (mapcar (lambda (c)
                   (propertize (oref c id) 'gastown-convoy c))
                 convoys)
         string pred)))))

;;; ============================================================
;;; Mail Address Completion
;;; ============================================================

(defconst gastown-completion--standard-roles
  '("witness" "refinery" "mayor" "overseer")
  "Standard Gas Town agent roles for mail address completion.")

(defun gastown-completion-mail-address-table ()
  "Return completion table for mail addresses in rig/role format.
Builds candidates from known rigs and standard roles."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-mail-address))
      (let* ((rigs (gastown-completion--get-cached-rigs))
             (rig-names (mapcar (lambda (r) (oref r name)) rigs))
             (candidates
              (append
               ;; Standard global roles
               gastown-completion--standard-roles
               ;; rig/role combinations
               (apply #'append
                      (mapcar (lambda (rig-name)
                                (mapcar (lambda (role)
                                          (format "%s/%s" rig-name role))
                                        gastown-completion--standard-roles))
                              rig-names))
               ;; rig/polecats/* style addresses from known polecats
               (mapcar (lambda (p)
                         (if (oref p rig)
                             (format "%s/polecats/%s"
                                     (oref p rig) (oref p name))
                           (oref p name)))
                       (gastown-completion--get-cached-polecats)))))
        (complete-with-action action candidates string pred)))))

;;; ============================================================
;;; Public Read Functions
;;; ============================================================

(defun gastown-completion-read-rig (prompt &optional predicate
                                           require-match initial-input
                                           history default)
  "Read a rig name with rich completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (completing-read prompt (gastown-completion-rig-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-polecat (prompt &optional predicate
                                               require-match initial-input
                                               history default)
  "Read a polecat address (rig/name) with rich completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (completing-read prompt (gastown-completion-polecat-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-mail-address (prompt &optional predicate
                                                    require-match
                                                    initial-input history
                                                    default)
  "Read a mail address in rig/role format with completion.
Builds candidate list from known rigs and standard roles.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (completing-read prompt (gastown-completion-mail-address-table)
                   predicate require-match initial-input history default))

;;; ============================================================
;;; Marginalia Integration (optional)
;;; ============================================================

(eval-when-compile (require 'marginalia nil t))

(defvar marginalia-annotators-heavy)

(defun gastown-completion-setup-marginalia ()
  "Register Gas Town completion categories with marginalia.
Call this after loading marginalia to enable richer annotations
in Gas Town completion interfaces.  For example:

  (with-eval-after-load \\='marginalia
    (gastown-completion-setup-marginalia))"
  (add-to-list 'marginalia-annotators-heavy
               '(gastown-rig . gastown-completion--rig-annotate))
  (add-to-list 'marginalia-annotators-heavy
               '(gastown-polecat . gastown-completion--polecat-annotate))
  (add-to-list 'marginalia-annotators-heavy
               '(gastown-convoy . gastown-completion--convoy-annotate)))

(provide 'gastown-completion)
;;; gastown-completion.el ends here
