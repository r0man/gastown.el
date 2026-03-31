;;; gastown-command-sling.el --- Sling command for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines the `gastown-command-sling' EIEIO class for the
;; `gt sling' command — the unified work dispatch command.

;;; Code:

(require 'gastown-command)
(require 'gastown-context)
(require 'gastown-reader)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Sling Command

(gastown-defcommand gastown-command-sling (gastown-command-global-options)
  ((bead-id
    :initarg :bead-id
    :type (or null string)
    :initform nil
    :documentation "Bead ID or formula to assign."
    :positional 1
    :option-type :string
    :key "b"
    :transient "Bead ID (required)"
    :class transient-option
    :prompt "Bead ID: "
    :transient-reader gastown-reader-bead-id
    :transient-group "Required"
    :level 1
    :order 1)
   (target
    :initarg :target
    :type (or null string)
    :initform nil
    :documentation "Target agent or rig (e.g. crew, gastown_el, mayor, gastown_el/Toast)."
    :positional 2
    :option-type :string
    :key "t"
    :transient "Target agent/rig"
    :class transient-option
    :prompt "Target (rig or agent): "
    :transient-reader gastown-reader-agent-target
    :transient-group "Required"
    :level 1
    :order 2)
   ;;; Spawning options
   (force
    :initarg :force
    :type boolean
    :initform nil
    :documentation "Force spawn even if polecat has unread mail."
    :long-option "force"
    :option-type :boolean
    :key "f"
    :transient "--force"
    :class transient-switch
    :argument "--force"
    :transient-group "Spawning"
    :level 1
    :order 10)
   (create
    :initarg :create
    :type boolean
    :initform nil
    :documentation "Create polecat if it does not exist."
    :long-option "create"
    :option-type :boolean
    :key "c"
    :transient "--create"
    :class transient-switch
    :argument "--create"
    :transient-group "Spawning"
    :level 1
    :order 11)
   (account
    :initarg :account
    :type (or null string)
    :initform nil
    :documentation "Claude Code account handle to use."
    :long-option "account"
    :option-type :string
    :key "A"
    :transient "--account"
    :class transient-option
    :argument "--account="
    :prompt "Account handle: "
    :transient-group "Spawning"
    :level 1
    :order 12)
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Override agent/runtime for this sling (e.g. claude, gemini, codex)."
    :long-option "agent"
    :option-type :string
    :key "G"
    :transient "--agent"
    :class transient-option
    :argument "--agent="
    :prompt "Agent runtime: "
    :transient-group "Spawning"
    :level 1
    :order 13)
   (crew
    :initarg :crew
    :type (or null string)
    :initform nil
    :documentation "Target a crew member in the specified rig."
    :long-option "crew"
    :option-type :string
    :key "C"
    :transient "--crew"
    :class transient-option
    :argument "--crew="
    :prompt "Crew member: "
    :transient-reader gastown-reader-crew-name
    :transient-group "Spawning"
    :level 1
    :order 14)
   ;;; Work content options
   (formula
    :initarg :formula
    :type (or null string)
    :initform nil
    :documentation "Formula to apply (default: mol-polecat-work for polecat targets)."
    :long-option "formula"
    :option-type :string
    :key "F"
    :transient "--formula"
    :class transient-option
    :argument "--formula="
    :prompt "Formula: "
    :transient-reader gastown-reader-formula-name
    :transient-group "Work"
    :level 1
    :order 20)
   (on
    :initarg :on
    :type (or null string)
    :initform nil
    :documentation "Apply formula to existing bead (implies wisp scaffolding)."
    :long-option "on"
    :option-type :string
    :key "o"
    :transient "--on"
    :class transient-option
    :argument "--on="
    :prompt "Apply formula to bead: "
    :transient-reader gastown-reader-bead-id
    :transient-group "Work"
    :level 1
    :order 21)
   (args
    :initarg :args
    :type (or null string)
    :initform nil
    :documentation "Natural language instructions for the executor."
    :long-option "args"
    :option-type :string
    :key "a"
    :transient "--args"
    :class transient-option
    :argument "--args="
    :prompt "Args (natural language instructions): "
    :transient-group "Work"
    :level 1
    :order 22)
   (message
    :initarg :message
    :type (or null string)
    :initform nil
    :documentation "Context message for the work."
    :long-option "message"
    :option-type :string
    :key "m"
    :transient "--message"
    :class transient-option
    :argument "--message="
    :prompt "Message: "
    :transient-group "Work"
    :level 1
    :order 23)
   (subject
    :initarg :subject
    :type (or null string)
    :initform nil
    :documentation "Context subject for the work."
    :long-option "subject"
    :option-type :string
    :key "s"
    :transient "--subject"
    :class transient-option
    :argument "--subject="
    :prompt "Subject: "
    :transient-group "Work"
    :level 1
    :order 24)
   (var
    :initarg :var
    :type list
    :initform nil
    :documentation "Formula variable substitutions (key=value), can be repeated."
    :long-option "var"
    :option-type :list
    :key "v"
    :transient "--var"
    :class transient-option
    :argument "--var="
    :prompt "Variable (key=value): "
    :transient-group "Work"
    :level 1
    :order 25)
   (stdin
    :initarg :stdin
    :type boolean
    :initform nil
    :documentation "Read --message and/or --args from stdin."
    :long-option "stdin"
    :option-type :boolean
    :key "S"
    :transient "--stdin"
    :class transient-switch
    :argument "--stdin"
    :transient-group "Work"
    :level 2
    :order 26)
   ;;; Merge strategy options
   (merge
    :initarg :merge
    :type (or null string)
    :initform nil
    :documentation "Merge strategy: direct (push to main), mr (merge queue), local (keep on branch)."
    :long-option "merge"
    :option-type :string
    :key "M"
    :transient "--merge"
    :class transient-option
    :argument "--merge="
    :prompt "Merge strategy: "
    :transient-choices ("direct" "mr" "local")
    :transient-group "Merge"
    :level 1
    :order 30)
   (no-merge
    :initarg :no-merge
    :type boolean
    :initform nil
    :documentation "Skip merge queue on completion (keep work on feature branch)."
    :long-option "no-merge"
    :option-type :boolean
    :key "N"
    :transient "--no-merge"
    :class transient-switch
    :argument "--no-merge"
    :transient-group "Merge"
    :level 1
    :order 31)
   (no-convoy
    :initarg :no-convoy
    :type boolean
    :initform nil
    :documentation "Skip auto-convoy creation for single-issue sling."
    :long-option "no-convoy"
    :option-type :boolean
    :key "n"
    :transient "--no-convoy"
    :class transient-switch
    :argument "--no-convoy"
    :transient-group "Merge"
    :level 1
    :order 32)
   (base-branch
    :initarg :base-branch
    :type (or null string)
    :initform nil
    :documentation "Override base branch for polecat worktree."
    :long-option "base-branch"
    :option-type :string
    :key "B"
    :transient "--base-branch"
    :class transient-option
    :argument "--base-branch="
    :prompt "Base branch: "
    :transient-group "Merge"
    :level 1
    :order 33)
   ;;; Advanced options
   (ralph
    :initarg :ralph
    :type boolean
    :initform nil
    :documentation "Enable Ralph Wiggum loop mode (fresh context per step)."
    :long-option "ralph"
    :option-type :boolean
    :key "r"
    :transient "--ralph"
    :class transient-switch
    :argument "--ralph"
    :transient-group "Advanced"
    :level 2
    :order 40)
   (hook-raw-bead
    :initarg :hook-raw-bead
    :type boolean
    :initform nil
    :documentation "Hook raw bead without default formula (expert mode)."
    :long-option "hook-raw-bead"
    :option-type :boolean
    :key "R"
    :transient "--hook-raw-bead"
    :class transient-switch
    :argument "--hook-raw-bead"
    :transient-group "Advanced"
    :level 2
    :order 41)
   (owned
    :initarg :owned
    :type boolean
    :initform nil
    :documentation "Mark auto-convoy as caller-managed lifecycle."
    :long-option "owned"
    :option-type :boolean
    :key "O"
    :transient "--owned"
    :class transient-switch
    :argument "--owned"
    :transient-group "Advanced"
    :level 2
    :order 42)
   (no-boot
    :initarg :no-boot
    :type boolean
    :initform nil
    :documentation "Skip rig boot after polecat spawn."
    :long-option "no-boot"
    :option-type :boolean
    :key "x"
    :transient "--no-boot"
    :class transient-switch
    :argument "--no-boot"
    :transient-group "Advanced"
    :level 2
    :order 43)
   (dry-run
    :initarg :dry-run
    :type boolean
    :initform nil
    :documentation "Show what would be done without executing."
    :long-option "dry-run"
    :option-type :boolean
    :key "d"
    :transient "--dry-run"
    :class transient-switch
    :argument "--dry-run"
    :transient-group "Advanced"
    :level 2
    :order 44)
   (max-concurrent
    :initarg :max-concurrent
    :type (or null integer)
    :initform nil
    :documentation "Limit concurrent polecat spawns in batch mode (0 = no limit)."
    :long-option "max-concurrent"
    :option-type :integer
    :key "X"
    :transient "--max-concurrent"
    :class transient-option
    :argument "--max-concurrent="
    :prompt "Max concurrent spawns: "
    :transient-group "Advanced"
    :level 2
    :order 45)
   (review-only
    :initarg :review-only
    :type boolean
    :initform nil
    :documentation "Mark work as review-only: assignee evaluates and reports back without merging."
    :long-option "review-only"
    :option-type :boolean
    :key "e"
    :transient "--review-only"
    :class transient-switch
    :argument "--review-only"
    :transient-group "Advanced"
    :level 2
    :order 46))
  :documentation "Represents gt sling command.
Assigns work to an agent — the unified work dispatch command.")


;;; Transient Menu

;;;###autoload (autoload 'gastown-sling "gastown-command-sling" nil t)
(beads-meta-define-transient gastown-command-sling "gastown-sling"
  "Assign work to an agent (dispatch).")


;;; ============================================================
;;; Formula Dispatch (gastown-sling-formula)
;;; ============================================================

;; Forward declarations for formula command infrastructure
(declare-function gastown-formula-var-transient "gastown-command-formula")
(declare-function gastown-formula-output-buffer "gastown-command-formula")
(declare-function gastown-formula--record-convoy "gastown-command-formula")
(declare-function gastown-completion-read-formula "gastown-completion")
(declare-function gastown-completion-read-rig "gastown-completion")

(defun gastown-sling--run-formula-dispatch (formula-name rig var-alist &optional bead-id)
  "Dispatch formula FORMULA-NAME to RIG with VAR-ALIST and optional BEAD-ID.
Runs `gt sling <rig> --formula <name> --var k=v ...' and shows output.
When BEAD-ID is non-nil, passes `--on BEAD-ID' to sling."
  (require 'gastown-command-formula)
  (let* ((buf (gastown-formula-output-buffer formula-name rig))
         (exe (if (boundp 'gastown-executable) gastown-executable "gt"))
         (var-args (mapcan (lambda (kv)
                             (list "--var"
                                   (format "%s=%s" (car kv) (cdr kv))))
                           var-alist))
         (on-args (when bead-id (list "--on" bead-id)))
         (cmd-args (append (list rig "--formula" formula-name)
                           on-args
                           var-args)))
    (pop-to-buffer buf)
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (goto-char (point-max))
        (when bead-id
          (insert (format "Issue:   %s\n" bead-id)))
        (insert (format "\n$ %s sling %s\n\n"
                        exe (mapconcat #'identity cmd-args " ")))
        ;; Run sling; capture output (convoy ID etc.)
        (let ((output-start (point)))
          (apply #'call-process exe nil buf t "sling" cmd-args)
          ;; Try to extract convoy ID from output for gastown-formula-status
          (let ((output (buffer-substring-no-properties output-start (point-max))))
            (when (string-match "convoy[:\s]+\\([a-z0-9-]+\\)" output)
              (gastown-formula--record-convoy (match-string 1 output)))))))))

;;;###autoload
(defun gastown-sling-formula ()
  "Interactively pick a formula and rig, fill vars, and dispatch via `gt sling'.
Flow: formula picker → rig picker → var transient → sling action.
Shows sling output in a `gastown-formula-output-buffer'."
  (interactive)
  (require 'gastown-command-formula)
  (require 'gastown-completion)
  (let* ((formula-name (gastown-completion-read-formula "Formula: " nil t))
         (rig (gastown-completion-read-rig "Rig: " nil t)))
    (gastown-formula-var-transient
     formula-name
     (lambda (var-alist)
       (gastown-sling--run-formula-dispatch formula-name rig var-alist)))))

;;;###autoload
(defun gastown-sling-formula-on-issue (bead-id)
  "Dispatch a formula on BEAD-ID: pick formula, fill vars, sling with --on BEAD-ID.
Like `gastown-sling-formula' but pre-fills `--on BEAD-ID' in the dispatch.
Intended for beads.el integration (issue buffer, dispatch transient)."
  (interactive
   (list (read-string "Bead ID: "
                      ;; Try to get current issue from beads context
                      (or (and (boundp 'beads-show--issue-id) beads-show--issue-id)
                          (and (fboundp 'beads-list--current-issue-id)
                               (beads-list--current-issue-id))))))
  (require 'gastown-command-formula)
  (require 'gastown-completion)
  (let* ((formula-name (gastown-completion-read-formula "Formula: " nil t))
         (rig (gastown-completion-read-rig "Rig: " nil t)))
    (gastown-formula-var-transient
     formula-name
     (lambda (var-alist)
       (gastown-sling--run-formula-dispatch formula-name rig var-alist bead-id)))))

(provide 'gastown-command-sling)
;;; gastown-command-sling.el ends here
