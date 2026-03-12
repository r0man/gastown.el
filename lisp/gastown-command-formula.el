;;; gastown-command-formula.el --- Formula commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for `gt formula' subcommands.
;; Provides formula listing, showing, running, and creation.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

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
    :transient-group "Required"
    :level 1
    :order 1))
  :documentation "Represents gt formula show command.
Display formula details (steps, variables, composition)."
  :cli-command "formula show")


;;; Formula Run Command

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
    :order 2)
   (merge
    :initarg :merge
    :type boolean
    :initform nil
    :documentation "Merge branches when work completes"
    :long-option "merge"
    :option-type :boolean
    :key "m"
    :transient "Merge branches when work completes"
    :class transient-switch
    :argument "--merge"
    :transient-group "Options"
    :level 2
    :order 3))
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


;;; Transient Menus

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

;;; Formula Dispatch Transient

;;;###autoload (autoload 'gastown-formula-menu "gastown-command-formula" nil t)
(transient-define-prefix gastown-formula-menu ()
  "Manage Gas Town workflow formulas."
  ["Formula Commands"
   ("l" "List formulas" gastown-formula-list)
   ("s" "Show formula" gastown-formula-show)
   ("r" "Run formula" gastown-formula-run)
   ("c" "Create formula" gastown-formula-create)])

(provide 'gastown-command-formula)
;;; gastown-command-formula.el ends here
