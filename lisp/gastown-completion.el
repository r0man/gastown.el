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
(require 'gastown-types)

;; Forward declarations for command modules
(declare-function gastown-command-rig-list "gastown-command-rig")
(declare-function gastown-command-polecat-list "gastown-command-polecat")
(declare-function gastown-command-convoy-list "gastown-command-convoy")

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

(defun gastown-completion--parse-formula (alist)
  "Parse a formula ALIST into a `gastown-completion-formula' object."
  (gastown-completion-formula
   :name (or (cdr (assq 'name alist)) "")
   :type (cdr (assq 'type alist))
   :description (cdr (assq 'description alist))
   :vars (cdr (assq 'vars alist))))

(defun gastown-completion--parse-crew (alist)
  "Parse a crew ALIST into a `gastown-completion-crew' object."
  (let ((session-raw (cdr (assq 'has_session alist))))
    (gastown-completion-crew
     :name (or (cdr (assq 'name alist)) "")
     :rig (cdr (assq 'rig alist))
     :branch (cdr (assq 'branch alist))
     :has-session (and session-raw
                       (not (eq session-raw :json-false))
                       t))))

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
Returns list of `gastown-completion-polecat' objects, or nil on error."
  (require 'gastown-command-polecat)
  (condition-case nil
      (let* ((cmd (gastown-command-polecat-list :all t :json t))
             (execution (gastown-command-execute cmd))
             (data (oref execution result)))
        (mapcar #'gastown-completion--parse-polecat
                (if (vectorp data) (append data nil) data)))
    (error nil)))

(defun gastown-completion--fetch-convoys ()
  "Fetch convoy list via gt convoy list --json.
Returns list of `gastown-completion-convoy' objects."
  (require 'gastown-command-convoy)
  (let* ((cmd (gastown-command-convoy-list :json t))
         (execution (gastown-command-execute cmd))
         (data (oref execution result)))
    (mapcar #'gastown-completion--parse-convoy
            (if (vectorp data) (append data nil) data))))

(defun gastown-completion--fetch-formulas ()
  "Fetch formula list via gt formula list --json.
Returns list of `gastown-completion-formula' objects."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output (with-output-to-string
                   (call-process exe nil standard-output nil "formula" "list" "--json")))
         (json-array-type 'list)
         (json-object-type 'alist)
         (data (condition-case nil
                   (json-read-from-string output)
                 (error nil))))
    (when data
      (mapcar #'gastown-completion--parse-formula
              (if (vectorp data) (append data nil) data)))))

(defun gastown-completion--fetch-crew ()
  "Fetch crew list via gt crew list --json.
Returns list of `gastown-completion-crew' objects."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output (with-output-to-string
                   (call-process exe nil standard-output nil "crew" "list" "--json")))
         (json-array-type 'list)
         (json-object-type 'alist)
         (data (condition-case nil
                   (json-read-from-string output)
                 (error nil))))
    (when data
      (mapcar #'gastown-completion--parse-crew
              (if (vectorp data) (append data nil) data)))))

;;; ============================================================
;;; Async Prefetch (non-blocking cache warming)
;;; ============================================================

(defun gastown-completion--async-warm-rigs ()
  "Start async `gt rig list --json' fetch to warm the rig cache.
Returns the process object.  The cache is updated in the process sentinel."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-completion-fetch-rigs"
     :command (list exe "rig" "list" "--json")
     :filter (lambda (_proc chunk) (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (when (string-prefix-p "finished" event)
                   (condition-case nil
                       (let ((json-array-type 'list)
                             (json-object-type 'alist))
                         (setq gastown-completion--rig-cache
                               (cons (float-time)
                                     (mapcar #'gastown-completion--parse-rig
                                             (let ((d (json-read-from-string output)))
                                               (if (vectorp d) (append d nil) d))))))
                     (error nil))))
     :connection-type 'pipe)))

(defun gastown-completion--async-warm-polecats ()
  "Start async `gt polecat list --json' fetch to warm the polecat cache.
Returns the process object.  The cache is updated in the process sentinel."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-completion-fetch-polecats"
     :command (list exe "polecat" "list" "--json")
     :filter (lambda (_proc chunk) (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (when (string-prefix-p "finished" event)
                   (condition-case nil
                       (let ((json-array-type 'list)
                             (json-object-type 'alist))
                         (setq gastown-completion--polecat-cache
                               (cons (float-time)
                                     (mapcar #'gastown-completion--parse-polecat
                                             (let ((d (json-read-from-string output)))
                                               (if (vectorp d) (append d nil) d))))))
                     (error nil))))
     :connection-type 'pipe)))

(defun gastown-completion--async-warm-convoys ()
  "Start async `gt convoy list --json' fetch to warm the convoy cache.
Returns the process object.  The cache is updated in the process sentinel."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-completion-fetch-convoys"
     :command (list exe "convoy" "list" "--json")
     :filter (lambda (_proc chunk) (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (when (string-prefix-p "finished" event)
                   (condition-case nil
                       (let ((json-array-type 'list)
                             (json-object-type 'alist))
                         (setq gastown-completion--convoy-cache
                               (cons (float-time)
                                     (mapcar #'gastown-completion--parse-convoy
                                             (let ((d (json-read-from-string output)))
                                               (if (vectorp d) (append d nil) d))))))
                     (error nil))))
     :connection-type 'pipe)))

(defun gastown-completion--async-warm-formulas ()
  "Start async `gt formula list --json' fetch to warm the formula cache.
Returns the process object.  The cache is updated in the process sentinel."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-completion-fetch-formulas"
     :command (list exe "formula" "list" "--json")
     :filter (lambda (_proc chunk) (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (when (string-prefix-p "finished" event)
                   (condition-case nil
                       (let ((json-array-type 'list)
                             (json-object-type 'alist))
                         (setq gastown-completion--formula-cache
                               (cons (float-time)
                                     (mapcar #'gastown-completion--parse-formula
                                             (let ((d (json-read-from-string output)))
                                               (if (vectorp d) (append d nil) d))))))
                     (error nil))))
     :connection-type 'pipe)))

(defun gastown-completion--async-warm-crew ()
  "Start async `gt crew list --json' fetch to warm the crew cache.
Returns the process object.  The cache is updated in the process sentinel."
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output ""))
    (make-process
     :name "gastown-completion-fetch-crew"
     :command (list exe "crew" "list" "--json")
     :filter (lambda (_proc chunk) (setq output (concat output chunk)))
     :sentinel (lambda (_proc event)
                 (when (string-prefix-p "finished" event)
                   (condition-case nil
                       (let ((json-array-type 'list)
                             (json-object-type 'alist))
                         (setq gastown-completion--crew-cache
                               (cons (float-time)
                                     (mapcar #'gastown-completion--parse-crew
                                             (let ((d (json-read-from-string output)))
                                               (if (vectorp d) (append d nil) d))))))
                     (error nil))))
     :connection-type 'pipe)))

(defun gastown-completion--warm-if-stale (cache-var ttl warm-fn timeout)
  "Warm CACHE-VAR asynchronously if stale, waiting up to TIMEOUT seconds.
TTL is the cache time-to-live in seconds.  When the cache is stale or nil,
calls WARM-FN to start an async process, then waits up to TIMEOUT seconds
for it to complete via `accept-process-output'.
Returns non-nil when a warm was attempted."
  (let* ((cache (symbol-value cache-var))
         (now (float-time))
         (stale (or (null cache)
                    (> (- now (car cache)) ttl))))
    (when stale
      (let ((proc (funcall warm-fn)))
        (when (processp proc)
          (accept-process-output proc timeout)))
      t)))

(defun gastown-completion-prefetch ()
  "Start async cache warming for all completion data types.

Kicks off async `gt rig list --json', `gt polecat list --json',
`gt convoy list --json', `gt formula list --json', and
`gt crew list --json' processes in parallel.  Safe to call multiple
times — skips fetch for caches that are still within their TTL.

Callers invoke this before `completing-read' to avoid blocking the Emacs
main thread during minibuffer completion."
  (let ((now (float-time)))
    (when (or (null gastown-completion--rig-cache)
              (> (- now (car gastown-completion--rig-cache))
                 gastown-completion--rig-cache-ttl))
      (gastown-completion--async-warm-rigs))
    (when (or (null gastown-completion--polecat-cache)
              (> (- now (car gastown-completion--polecat-cache))
                 gastown-completion--polecat-cache-ttl))
      (gastown-completion--async-warm-polecats))
    (when (or (null gastown-completion--convoy-cache)
              (> (- now (car gastown-completion--convoy-cache))
                 gastown-completion--convoy-cache-ttl))
      (gastown-completion--async-warm-convoys))
    (when (or (null gastown-completion--formula-cache)
              (> (- now (car gastown-completion--formula-cache))
                 gastown-completion--formula-cache-ttl))
      (gastown-completion--async-warm-formulas))
    (when (or (null gastown-completion--crew-cache)
              (> (- now (car gastown-completion--crew-cache))
                 gastown-completion--crew-cache-ttl))
      (gastown-completion--async-warm-crew))))

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

(defvar gastown-completion--formula-cache nil
  "Cache for formula list.  Format: (TIMESTAMP . FORMULAS-LIST).")

(defvar gastown-completion--formula-cache-ttl 30
  "TTL for formula completion cache in seconds.
Formulas change infrequently so we use a longer TTL.")

(defvar gastown-completion--crew-cache nil
  "Cache for crew list.  Format: (TIMESTAMP . CREW-LIST).")

(defvar gastown-completion--crew-cache-ttl 10
  "TTL for crew completion cache in seconds.")

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

(defun gastown-completion--get-cached-formulas ()
  "Get cached formula list, refreshing if stale.
On fetch failure, returns previous cached data (if any) with a warning."
  (let ((now (float-time)))
    (when (or (null gastown-completion--formula-cache)
              (> (- now (car gastown-completion--formula-cache))
                 gastown-completion--formula-cache-ttl))
      (condition-case err
          (setq gastown-completion--formula-cache
                (cons now (gastown-completion--fetch-formulas)))
        (error
         (when gastown-completion--formula-cache
           (message
            "Warning: Failed to refresh formulas: %s (using cached data)"
            (error-message-string err))))))
    (cdr gastown-completion--formula-cache)))

(defun gastown-completion--get-cached-crew ()
  "Get cached crew list, refreshing if stale.
On fetch failure, returns previous cached data (if any) with a warning."
  (let ((now (float-time)))
    (when (or (null gastown-completion--crew-cache)
              (> (- now (car gastown-completion--crew-cache))
                 gastown-completion--crew-cache-ttl))
      (condition-case err
          (setq gastown-completion--crew-cache
                (cons now (gastown-completion--fetch-crew)))
        (error
         (when gastown-completion--crew-cache
           (message
            "Warning: Failed to refresh crew: %s (using cached data)"
            (error-message-string err))))))
    (cdr gastown-completion--crew-cache)))

(defun gastown-completion-invalidate-formula-cache ()
  "Invalidate the formula completion cache."
  (setq gastown-completion--formula-cache nil))

(defun gastown-completion-invalidate-crew-cache ()
  "Invalidate the crew completion cache."
  (setq gastown-completion--crew-cache nil))

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

(defun gastown-completion--formula-annotate (candidate)
  "Annotate formula CANDIDATE with type and description."
  (condition-case nil
      (let ((formula (get-text-property 0 'gastown-formula candidate)))
        (if formula
            (let ((type (oref formula type))
                  (description (oref formula description))
                  (vars (oref formula vars)))
              (format " %s%s%s"
                      (propertize (or type "")
                                  'face 'shadow)
                      (if (and vars (> vars 0))
                          (format " [%d vars]" vars)
                        "")
                      (if description
                          (format " - %s"
                                  (truncate-string-to-width description 50 nil nil "…"))
                        "")))
          ""))
    (error "")))

(defun gastown-completion--crew-annotate (candidate)
  "Annotate crew CANDIDATE with rig and session status."
  (condition-case nil
      (let ((crew (get-text-property 0 'gastown-crew candidate)))
        (if crew
            (let ((rig (oref crew rig))
                  (branch (oref crew branch))
                  (has-session (oref crew has-session)))
              (format " %s%s%s"
                      (if rig (propertize rig 'face 'shadow) "")
                      (if branch (format " [%s]" branch) "")
                      (if has-session
                          (propertize " (active)" 'face 'success)
                        "")))
          ""))
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

(defun gastown-completion-formula-table ()
  "Return completion table for formula names with description annotations."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-formula)
          (annotation-function . gastown-completion--formula-annotate))
      (let ((formulas (gastown-completion--get-cached-formulas)))
        (complete-with-action
         action
         (mapcar (lambda (f)
                   (propertize (oref f name) 'gastown-formula f))
                 formulas)
         string pred)))))

(defun gastown-completion-crew-table ()
  "Return completion table for crew worker names with status annotations."
  (lambda (string pred action)
    (if (eq action 'metadata)
        '(metadata
          (category . gastown-crew)
          (annotation-function . gastown-completion--crew-annotate))
      (let ((crew (gastown-completion--get-cached-crew)))
        (complete-with-action
         action
         (mapcar (lambda (c)
                   (propertize (oref c name) 'gastown-crew c))
                 crew)
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

(defconst gastown-completion--prefetch-timeout 5.0
  "Seconds to wait for async prefetch before falling back to synchronous fetch.")

(defun gastown-completion-read-rig (prompt &optional predicate
                                           require-match initial-input
                                           history default)
  "Read a rig name with rich completion.
Pre-warms the rig cache asynchronously before opening the minibuffer
to avoid blocking the Emacs main thread during completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--rig-cache
   gastown-completion--rig-cache-ttl
   #'gastown-completion--async-warm-rigs
   gastown-completion--prefetch-timeout)
  (completing-read prompt (gastown-completion-rig-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-polecat (prompt &optional predicate
                                               require-match initial-input
                                               history default)
  "Read a polecat address (rig/name) with rich completion.
Pre-warms the polecat cache asynchronously before opening the minibuffer
to avoid blocking the Emacs main thread during completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--polecat-cache
   gastown-completion--polecat-cache-ttl
   #'gastown-completion--async-warm-polecats
   gastown-completion--prefetch-timeout)
  (completing-read prompt (gastown-completion-polecat-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-convoy (prompt &optional predicate
                                             require-match initial-input
                                             history default)
  "Read a convoy ID with rich completion.
Pre-warms the convoy cache asynchronously before opening the minibuffer
to avoid blocking the Emacs main thread during completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--convoy-cache
   gastown-completion--convoy-cache-ttl
   #'gastown-completion--async-warm-convoys
   gastown-completion--prefetch-timeout)
  (completing-read prompt (gastown-completion-convoy-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-formula (prompt &optional predicate
                                              require-match initial-input
                                              history default)
  "Read a formula name with rich completion.
Pre-warms the formula cache asynchronously before opening the minibuffer
to avoid blocking the Emacs main thread during completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--formula-cache
   gastown-completion--formula-cache-ttl
   #'gastown-completion--async-warm-formulas
   gastown-completion--prefetch-timeout)
  (completing-read prompt (gastown-completion-formula-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-crew (prompt &optional predicate
                                           require-match initial-input
                                           history default)
  "Read a crew worker name with rich completion.
Pre-warms the crew cache asynchronously before opening the minibuffer
to avoid blocking the Emacs main thread during completion.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--crew-cache
   gastown-completion--crew-cache-ttl
   #'gastown-completion--async-warm-crew
   gastown-completion--prefetch-timeout)
  (completing-read prompt (gastown-completion-crew-table)
                   predicate require-match initial-input history default))

(defun gastown-completion-read-mail-address (prompt &optional predicate
                                                    require-match
                                                    initial-input history
                                                    default)
  "Read a mail address in rig/role format with completion.
Pre-warms rig and polecat caches asynchronously before opening the
minibuffer to avoid blocking the Emacs main thread during completion.
Builds candidate list from known rigs and standard roles.
PROMPT, PREDICATE, REQUIRE-MATCH, INITIAL-INPUT, HISTORY, and DEFAULT
are passed to `completing-read'."
  (gastown-completion--warm-if-stale
   'gastown-completion--rig-cache
   gastown-completion--rig-cache-ttl
   #'gastown-completion--async-warm-rigs
   gastown-completion--prefetch-timeout)
  (gastown-completion--warm-if-stale
   'gastown-completion--polecat-cache
   gastown-completion--polecat-cache-ttl
   #'gastown-completion--async-warm-polecats
   gastown-completion--prefetch-timeout)
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
               '(gastown-convoy . gastown-completion--convoy-annotate))
  (add-to-list 'marginalia-annotators-heavy
               '(gastown-formula . gastown-completion--formula-annotate))
  (add-to-list 'marginalia-annotators-heavy
               '(gastown-crew . gastown-completion--crew-annotate)))

;;; ============================================================
;;; Formula Vars Cache
;;; ============================================================

(defvar gastown-completion--formula-vars-cache (make-hash-table :test 'equal)
  "Cache for formula variable lists.
Hash table: formula-name (string) -> (TIMESTAMP . VARS-LIST).
VARS-LIST is a list of `gastown-formula-var' objects.")

(defvar gastown-completion--formula-vars-cache-ttl 60
  "TTL for formula vars cache in seconds.
Formula vars change rarely, so we use a longer TTL than the formula list.")

(defun gastown-completion--parse-formula-vars (vars-alist)
  "Parse VARS-ALIST into a list of `gastown-formula-var' objects.
VARS-ALIST is from `gt formula show --json': an alist where each entry
is (VARNAME-SYMBOL . PROPERTY-ALIST) representing one formula variable."
  (when vars-alist
    (mapcar (lambda (entry)
              (gastown-formula-var-from-json
               (symbol-name (car entry))
               (cdr entry)))
            vars-alist)))

(defun gastown-completion--fetch-formula-vars (formula-name)
  "Fetch variables for FORMULA-NAME via `gt formula show --json'.
Returns a list of `gastown-formula-var' objects, or nil on error."
  (require 'gastown-types)
  (let* ((exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (output (with-output-to-string
                   (call-process exe nil standard-output nil
                                 "formula" "show" formula-name "--json")))
         (json-array-type 'list)
         (json-object-type 'alist)
         (data (condition-case nil
                   (json-read-from-string output)
                 (error nil))))
    (when data
      (gastown-completion--parse-formula-vars (alist-get 'vars data)))))

(defun gastown-completion--get-cached-formula-vars (formula-name)
  "Get cached vars for FORMULA-NAME, refreshing if stale.
Returns a list of `gastown-formula-var' objects."
  (let* ((entry (gethash formula-name gastown-completion--formula-vars-cache))
         (now (float-time))
         (stale (or (null entry)
                    (> (- now (car entry))
                       gastown-completion--formula-vars-cache-ttl))))
    (when stale
      (condition-case err
          (let ((vars (gastown-completion--fetch-formula-vars formula-name)))
            (puthash formula-name (cons now vars)
                     gastown-completion--formula-vars-cache))
        (error
         (when entry
           (message "Warning: Failed to refresh formula vars for %s: %s (using cached)"
                    formula-name (error-message-string err))))))
    (cdr (gethash formula-name gastown-completion--formula-vars-cache))))

(defun gastown-completion-invalidate-formula-vars-cache (&optional formula-name)
  "Invalidate the formula vars cache.
If FORMULA-NAME is given, only invalidate that formula's entry.
Otherwise clears the entire cache."
  (if formula-name
      (remhash formula-name gastown-completion--formula-vars-cache)
    (clrhash gastown-completion--formula-vars-cache)))

(provide 'gastown-completion)
;;; gastown-completion.el ends here
