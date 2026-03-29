;;; gastown-command-formula.el --- Formula commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt formula' subcommands.
;; Provides formula listing, showing, running, creation, and the
;; formula lifecycle integration: interactive var filling, output
;; buffers, and local/agent dispatch.
;;
;; New interactive commands:
;;   `gastown-formula-run-interactive'  — pick formula, fill vars, run locally
;;   `gastown-formula-status'           — poll convoy status for dispatched runs
;;
;; New infrastructure:
;;   `gastown-formula-output-buffer'    — get/create a read-only output buffer
;;   `gastown-formula-output-append'    — append text to an output buffer
;;   `gastown-formula-output-show'      — pop to an output buffer
;;   `gastown-formula-var-transient'    — dynamic var-filling transient (≤10 vars)

;;; Code:

(require 'gastown-command)
(require 'gastown-completion)
(require 'gastown-reader)
(require 'gastown-types)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; ============================================================
;;; Formula EIEIO Command Classes
;;; ============================================================

;;; Formula List Command

(gastown-defcommand gastown-command-formula-list (gastown-command-global-options)
  ()
  :documentation "Represents gt formula list command.
List available formulas from all search paths."
  :cli-command "formula list")


;;; Formula Show Command

(gastown-defcommand gastown-command-formula-show (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to show."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt formula show command.
Display formula details (steps, variables, composition)."
  :cli-command "formula show")


;;; Formula Run Command (kept for backwards compatibility and coverage)

(gastown-defcommand gastown-command-formula-run (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to run."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Required"
    :level 1
    :order 1)
   (args
    :initarg :args
    :type (or null string)
    :initform nil
    :documentation "Formula arguments"
    :long-option "args"
    :option-type :string
    :key "a"
    :transient "Formula arguments"
    :class transient-option
    :argument "--args="
    :prompt "Args (key=value,...): "
    :transient-group "Options"
    :level 1
    :order 2))
  :documentation "Represents gt formula run command.
Execute a formula (pour and dispatch)."
  :cli-command "formula run")


;;; Formula Create Command

(gastown-defcommand gastown-command-formula-create (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to create."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt formula create command.
Create a new formula template."
  :cli-command "formula create")


;;; Formula Overlay Command

(gastown-defcommand gastown-command-formula-overlay (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to overlay."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt formula overlay command.
Create a user overlay for an existing formula."
  :cli-command "formula overlay")


;;; Formula Overlay Subcommands

(gastown-defcommand gastown-command-formula-overlay-show (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to show overlay for."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Required"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, shows rig-level overlay)."
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt formula overlay show command.
Display the active overlay for a formula."
  :cli-command "formula overlay show")


(gastown-defcommand gastown-command-formula-overlay-edit (gastown-command-global-options)
  ((formula-name
    :initarg :formula-name
    :type (or null string)
    :initform nil
    :documentation "Formula name to edit overlay for."
    :positional 1
    :option-type :string
    :key "f"
    :transient "Formula name (required)"
    :class transient-option
    :prompt "Formula name: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Required"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (optional, creates rig-level overlay)."
    :long-option "rig"
    :option-type :string
    :key "r"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt formula overlay edit command.
Open an overlay in $EDITOR (creates if needed)."
  :cli-command "formula overlay edit")


(gastown-defcommand gastown-command-formula-overlay-list (gastown-command-global-options)
  ()
  :documentation "Represents gt formula overlay list command.
List all overlay files."
  :cli-command "formula overlay list")


;;; ============================================================
;;; Transient Menus for EIEIO Commands
;;; ============================================================

;;;###autoload (autoload 'gastown-formula-list "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-list "gastown-formula-list"
  "List available formulas.")

;;;###autoload (autoload 'gastown-formula-show "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-show "gastown-formula-show"
  "Show formula details.")

;;;###autoload (autoload 'gastown-formula-run "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-run "gastown-formula-run"
  "Execute a formula.")

;;;###autoload (autoload 'gastown-formula-create "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-create "gastown-formula-create"
  "Create a new formula template.")

;;;###autoload (autoload 'gastown-formula-overlay "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-overlay "gastown-formula-overlay"
  "Create a formula overlay.")

;;;###autoload (autoload 'gastown-formula-overlay-show "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-overlay-show "gastown-formula-overlay-show"
  "Show active formula overlay.")

;;;###autoload (autoload 'gastown-formula-overlay-edit "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-overlay-edit "gastown-formula-overlay-edit"
  "Edit formula overlay.")

;;;###autoload (autoload 'gastown-formula-overlay-list "gastown-command-formula" nil t)
(beads-meta-define-transient gastown-command-formula-overlay-list "gastown-formula-overlay-list"
  "List formula overlays.")

;;; Formula Overlay Dispatch Transient

;;;###autoload (autoload 'gastown-formula-overlay-menu "gastown-command-formula" nil t)
(transient-define-prefix gastown-formula-overlay-menu ()
  "Manage formula overlays."
  ["Formula Overlays"
   ("l" "List overlays" gastown-formula-overlay-list)
   ("s" "Show overlay" gastown-formula-overlay-show)
   ("e" "Edit overlay" gastown-formula-overlay-edit)])


;;; ============================================================
;;; Formula Output Buffer
;;; ============================================================

(defun gastown-formula--output-buffer-name (formula-name)
  "Return buffer name for formula FORMULA-NAME output."
  (format "*gastown-formula: %s*" formula-name))

;;;###autoload
(defun gastown-formula-output-buffer (formula-name &optional target)
  "Get or create the output buffer for formula FORMULA-NAME.
Initializes the buffer with a header showing formula name, optional TARGET
\(rig/agent), and start time.  Buffer uses `special-mode' and is read-only
\(append via `gastown-formula-output-append').
Returns the buffer object."
  (let* ((buf-name (gastown-formula--output-buffer-name formula-name))
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'special-mode)
        (special-mode))
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (propertize (format "Formula: %s\n" formula-name) 'face 'bold))
        (when target
          (insert (format "Target:  %s\n" target)))
        (insert (format "Started: %s\n" (format-time-string "%Y-%m-%d %H:%M")))
        (insert "\n--- Output ---\n")))
    buf))

;;;###autoload
(defun gastown-formula-output-append (formula-name text)
  "Append TEXT to the output buffer for FORMULA-NAME.
No-op if the buffer does not exist."
  (let* ((buf-name (gastown-formula--output-buffer-name formula-name))
         (buf (get-buffer buf-name)))
    (when buf
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (goto-char (point-max))
          (insert text))))))

;;;###autoload
(defun gastown-formula-output-show (formula-name)
  "Pop to the output buffer for FORMULA-NAME.
Signals an error if the buffer does not exist."
  (interactive
   (list (completing-read "Formula output buffer: "
                          (mapcar (lambda (b)
                                    (let ((name (buffer-name b)))
                                      (when (string-prefix-p "*gastown-formula: " name)
                                        (substring name
                                                   (length "*gastown-formula: ")
                                                   (1- (length name))))))
                                  (buffer-list))
                          nil t)))
  (let* ((buf-name (gastown-formula--output-buffer-name formula-name))
         (buf (get-buffer buf-name)))
    (if buf
        (pop-to-buffer buf)
      (user-error "No output buffer for formula: %s" formula-name))))


;;; ============================================================
;;; Dynamic Variable Transient
;;; ============================================================

(defvar gastown-formula--pending-action nil
  "Pending action function to invoke when the var transient executes.
Set by `gastown-formula-var-transient' before building the transient,
cleared in `gastown-formula--var-transient-run'.")

(defvar gastown-formula--pending-formula-name nil
  "Formula name associated with the currently active var transient.
Set by `gastown-formula-var-transient', cleared on execution.")

(defvar gastown-formula--vars-history (make-hash-table :test 'equal)
  "Per-formula history of last-used var values.
Hash table: formula-name (string) -> ((varname . value) ...) alist.")

(defun gastown-formula--var-transient-run ()
  "Read args from transient and call the pending formula action.
This command is bound as the execute suffix in the dynamic var transient."
  (interactive)
  (when-let* ((formula-name gastown-formula--pending-formula-name)
              (action gastown-formula--pending-action))
    (let* ((args (transient-args transient-current-command))
           (var-alist (delq nil
                            (mapcar (lambda (arg)
                                      (when (string-match
                                             "^--\\([^=]+\\)=\\(.*\\)\\'" arg)
                                        (cons (match-string 1 arg)
                                              (match-string 2 arg))))
                                    args))))
      ;; Store in per-formula history
      (puthash formula-name var-alist gastown-formula--vars-history)
      ;; Clear pending state before calling action (action may invoke another transient)
      (setq gastown-formula--pending-action nil
            gastown-formula--pending-formula-name nil)
      (funcall action var-alist))))

(defun gastown-formula--pick-key (var-name used-keys)
  "Pick a unique single-char key for VAR-NAME not already in USED-KEYS.
Returns a string."
  (or (cl-find-if (lambda (c)
                    (not (member (string c) used-keys)))
                  var-name)
      (cl-find-if (lambda (c)
                    (not (member (string c) used-keys)))
                  "1234567890abcdefghijklmnopqrstuvwxyz")
      "?"))

(defun gastown-formula--build-var-groups (vars history)
  "Build transient group spec forms for VARS with HISTORY pre-fill hints.
VARS is a list of `gastown-formula-var' objects.
HISTORY is an alist of prior values ((varname . value) ...).
Returns group spec forms suitable for `transient-define-prefix'."
  (let ((required-specs nil)
        (optional-specs nil)
        (used-keys (list "C-c C-c" "q")))
    (dolist (var vars)
      (let* ((name (oref var name))
             (desc (or (oref var description) name))
             (var-default (oref var default))
             (hist-val (cdr (assoc name history)))
             (is-required (oref var required))
             ;; Show history value or default in description for UX
             (hint (or hist-val
                       (and var-default (not (string= var-default "")) var-default)))
             (full-desc (format "%s%s%s"
                                (if is-required
                                    (concat desc " [required]")
                                  desc)
                                (if hint (format " (was: %s)" hint) "")
                                ""))
             (key-char (gastown-formula--pick-key name used-keys))
             (key-str (if (characterp key-char) (string key-char) key-char))
             (arg (format "--%s=" name))
             ;; Inline option spec (transient infers transient-option from "=" in arg)
             (spec (list key-str
                         (truncate-string-to-width full-desc 60 nil nil "…")
                         arg)))
        (push key-str used-keys)
        (if is-required
            (push spec required-specs)
          (push spec optional-specs))))
    (let ((groups nil))
      (when optional-specs
        (push (cons "Optional" (nreverse optional-specs)) groups))
      (when required-specs
        (push (cons "Required" (nreverse required-specs)) groups))
      ;; Build transient group forms (list with heading and specs)
      (mapcar (lambda (g)
                (cons (car g) (cdr g)))
              groups))))

(defun gastown-formula--invoke-var-transient (formula-name vars)
  "Build and invoke a dynamic transient for filling FORMULA-NAME vars.
VARS is a list of `gastown-formula-var' objects."
  (let* ((safe-name (replace-regexp-in-string "[^a-zA-Z0-9]" "-" formula-name))
         (sym (intern (format "gastown--var-transient-%s" safe-name)))
         (history (gethash formula-name gastown-formula--vars-history))
         (raw-groups (gastown-formula--build-var-groups vars history))
         ;; Convert list groups to vector-headed group forms for transient
         (group-forms (mapcar (lambda (g)
                                (apply #'list (car g) (cdr g)))
                              raw-groups)))
    (eval `(transient-define-prefix ,sym ()
             ,(format "Fill variables for formula: %s\nPress C-c C-c to run, q to cancel."
                      formula-name)
             ,@group-forms
             ["Actions"
              ("C-c C-c" "Run" gastown-formula--var-transient-run)
              ("q" "Cancel" transient-quit-one)]))
    (funcall sym)))

(defun gastown-formula--prompt-vars-sequentially (vars formula-name)
  "Prompt for each var in VARS with `read-string', returning an alist.
Used as fallback when there are more than 10 vars.
FORMULA-NAME is used to look up prior history for pre-filling."
  (let ((history (gethash formula-name gastown-formula--vars-history)))
    (mapcar (lambda (var)
              (let* ((name (oref var name))
                     (desc (or (oref var description) name))
                     (var-default (oref var default))
                     (hist-val (cdr (assoc name history)))
                     (initial (or hist-val
                                  (and var-default
                                       (not (string= var-default ""))
                                       var-default)))
                     (prompt (format "%s%s: "
                                     desc
                                     (if (oref var required) " (required)" "")))
                     (value (read-string prompt initial)))
              (cons name value)))
          vars)))

;;;###autoload
(defun gastown-formula-var-transient (formula-name action)
  "Show a var-filling UI for FORMULA-NAME, then call ACTION with vars alist.
ACTION is called with an alist of ((varname . value) ...) pairs.

When there are 0 vars, ACTION is called immediately with nil.
When there are 1-10 vars, a dynamic transient is shown for interactive filling.
When there are >10 vars, sequential `read-string' prompts are used instead.

ACTION will be called after the user confirms (C-c C-c in the transient)."
  (let* ((vars (gastown-completion--get-cached-formula-vars formula-name))
         (var-count (length vars)))
    (cond
     ((= var-count 0)
      ;; No vars: call action immediately
      (funcall action nil))
     ((> var-count 10)
      ;; Too many for transient: sequential prompts
      (let ((result (gastown-formula--prompt-vars-sequentially vars formula-name)))
        (puthash formula-name result gastown-formula--vars-history)
        (funcall action result)))
     (t
      ;; Dynamic transient (≤10 vars)
      (setq gastown-formula--pending-action action
            gastown-formula--pending-formula-name formula-name)
      (gastown-formula--invoke-var-transient formula-name vars)))))


;;; ============================================================
;;; Enhanced Formula Run (interactive)
;;; ============================================================

(defun gastown-formula--run-with-vars (formula-name var-alist)
  "Run formula FORMULA-NAME with VAR-ALIST ((varname . value) ...).
Shows output in a `gastown-formula-output-buffer'."
  (let* ((buf (gastown-formula-output-buffer formula-name))
         (exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         ;; Add var-count hint to buffer
         (var-args (mapcan (lambda (kv)
                             (list "--var"
                                   (format "%s=%s" (car kv) (cdr kv))))
                           var-alist))
         (cmd-args (append (list "formula" "run" formula-name) var-args)))
    (pop-to-buffer buf)
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        ;; Show the command being run
        (goto-char (point-max))
        (insert (format "\n$ %s %s\n\n" exe (mapconcat #'identity cmd-args " ")))
        ;; Run synchronously, appending output to buffer
        (apply #'call-process exe nil buf t cmd-args)))))

;;;###autoload
(defun gastown-formula-run-interactive ()
  "Interactively pick a formula, fill vars, and run it locally.
Shows formula output in a dedicated read-only buffer."
  (interactive)
  (let ((formula-name (gastown-completion-read-formula "Formula: " nil t)))
    (gastown-formula-var-transient
     formula-name
     (lambda (var-alist)
       (gastown-formula--run-with-vars formula-name var-alist)))))


;;; ============================================================
;;; Formula Status Command
;;; ============================================================

(defvar gastown-formula--recent-convoy-ids nil
  "List of recent convoy IDs from formula dispatch, for completion.")

(defun gastown-formula--record-convoy (convoy-id)
  "Record CONVOY-ID in recent convoy list for later completion."
  (push convoy-id gastown-formula--recent-convoy-ids)
  (setq gastown-formula--recent-convoy-ids
        (seq-take (delete-dups gastown-formula--recent-convoy-ids) 20)))

;;;###autoload
(defun gastown-formula-status ()
  "Show convoy status for a dispatched formula run.
Prompts for a convoy ID (with completion from recently dispatched convoys)
and displays the status in the formula output buffer."
  (interactive)
  (let* ((convoy-id
          (completing-read "Convoy ID: "
                           gastown-formula--recent-convoy-ids
                           nil nil nil nil
                           (car gastown-formula--recent-convoy-ids)))
         (buf (get-buffer-create (format "*gastown-formula-status: %s*" convoy-id)))
         (exe (if (boundp 'gastown-executable) gastown-executable "gt")))
    (with-current-buffer buf
      (unless (derived-mode-p 'special-mode)
        (special-mode))
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (propertize (format "Convoy Status: %s\n" convoy-id) 'face 'bold))
        (insert (format "Checked: %s\n\n" (format-time-string "%Y-%m-%d %H:%M")))
        (insert "--- Status ---\n")
        (call-process exe nil buf t "convoy" "status" convoy-id "--json")))
    (pop-to-buffer buf)))


;;; ============================================================
;;; Formula Dispatch Menu
;;; ============================================================

;;;###autoload (autoload 'gastown-formula-menu "gastown-command-formula" nil t)
(transient-define-prefix gastown-formula-menu ()
  "Manage Gas Town workflow formulas."
  ["Formula Commands"
   ("l" "List formulas" gastown-formula-list)
   ("s" "Show formula details" gastown-formula-show)
   ("r" "Run formula locally" gastown-formula-run-interactive)
   ("d" "Dispatch formula to agent" gastown-sling-formula)
   ("S" "Status of dispatched run" gastown-formula-status)
   ("c" "Create formula" gastown-formula-create)
   ("o" "Overlay..." gastown-formula-overlay-menu)])

(provide 'gastown-command-formula)
;;; gastown-command-formula.el ends here
