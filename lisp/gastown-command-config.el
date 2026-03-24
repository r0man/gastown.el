;;; gastown-command-config.el --- Configuration commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for configuration commands:
;; gt account, gt completion, gt config, gt directive, gt disable, gt enable,
;; gt hooks, gt issue, gt plugin, gt shell, gt theme, gt uninstall.

;;; Code:

(require 'gastown-command)
(require 'beads-meta)

(require 'transient)

(defvar gastown-executable)

;;; Account Command

(gastown-defcommand gastown-command-account (gastown-command-global-options)
  ()
  :documentation "Represents gt account command.
Manage Gas Town account settings.")


;;; Completion Command

(gastown-defcommand gastown-command-completion (gastown-command-global-options)
  ()
  :documentation "Represents gt completion command.
Generate shell completion scripts.")


;;; Config Command

(gastown-defcommand gastown-command-config (gastown-command-global-options)
  ()
  :documentation "Represents gt config command.
Show or edit Gas Town configuration.")


;;; Directive Commands

(gastown-defcommand gastown-command-directive-show (gastown-command-global-options)
  ((role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Role name to show directive for."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Role name (required)"
    :class transient-option
    :prompt "Role: "
    :transient-group "Required"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (default: auto-detect from cwd)."
    :long-option "rig"
    :option-type :string
    :key "R"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 2
    :order 2))
  :documentation "Represents gt directive show command.
Display the resolved directive content for a role with source annotation."
  :cli-command "directive show")


(gastown-defcommand gastown-command-directive-edit (gastown-command-global-options)
  ((role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Role name to edit directive for."
    :positional 1
    :option-type :string
    :key "r"
    :transient "Role name (required)"
    :class transient-option
    :prompt "Role: "
    :transient-group "Required"
    :level 1
    :order 1)
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name (default: auto-detect from cwd)."
    :long-option "rig"
    :option-type :string
    :key "R"
    :transient "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-group "Options"
    :level 2
    :order 2)
   (town
    :initarg :town
    :type boolean
    :initform nil
    :documentation "Edit town-level directive instead of rig-level."
    :long-option "town"
    :option-type :boolean
    :key "t"
    :transient "Edit town-level directive"
    :class transient-switch
    :argument "--town"
    :transient-group "Options"
    :level 2
    :order 3))
  :documentation "Represents gt directive edit command.
Open the directive file for a role in $EDITOR."
  :cli-command "directive edit")


(gastown-defcommand gastown-command-directive-list (gastown-command-global-options)
  ()
  :documentation "Represents gt directive list command.
List all directive files across town and rig levels."
  :cli-command "directive list")


;;; Disable Command

(gastown-defcommand gastown-command-disable (gastown-command-global-options)
  ()
  :documentation "Represents gt disable command.
Disable a feature or plugin.")


;;; Enable Command

(gastown-defcommand gastown-command-enable (gastown-command-global-options)
  ()
  :documentation "Represents gt enable command.
Enable a feature or plugin.")


;;; Hooks Command

(gastown-defcommand gastown-command-hooks (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks command.
Manage Gas Town hooks.")


;;; Issue Command

(gastown-defcommand gastown-command-issue (gastown-command-global-options)
  ()
  :documentation "Represents gt issue command.
Manage issues and configuration.")


;;; Plugin Command

(gastown-defcommand gastown-command-plugin (gastown-command-global-options)
  ()
  :documentation "Represents gt plugin command.
Manage Gas Town plugins.")


;;; Shell Command

(gastown-defcommand gastown-command-shell (gastown-command-global-options)
  ()
  :documentation "Represents gt shell command.
Configure shell integration.")


;;; Theme Command

(gastown-defcommand gastown-command-theme (gastown-command-global-options)
  ()
  :documentation "Represents gt theme command.
Manage Gas Town UI themes.")


;;; Uninstall Command

(gastown-defcommand gastown-command-uninstall (gastown-command-global-options)
  ()
  :documentation "Represents gt uninstall command.
Uninstall Gas Town components.")


;;; Transient Menus

;;;###autoload (autoload 'gastown-account "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account "gastown-account"
  "Manage Gas Town account settings.")

;;;###autoload (autoload 'gastown-completion "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-completion "gastown-completion"
  "Generate shell completion scripts.")

;;;###autoload (autoload 'gastown-config "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config "gastown-config"
  "Show or edit Gas Town configuration.")

;;;###autoload (autoload 'gastown-directive-show "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-directive-show "gastown-directive-show"
  "Show active directive for a role.")

;;;###autoload (autoload 'gastown-directive-edit "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-directive-edit "gastown-directive-edit"
  "Edit directive for a role.")

;;;###autoload (autoload 'gastown-directive-list "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-directive-list "gastown-directive-list"
  "List all directive files.")

;;; Directive Dispatch Transient

;;;###autoload (autoload 'gastown-directive "gastown-command-config" nil t)
(transient-define-prefix gastown-directive ()
  "Manage operator-provided role directives."
  ["Directive Commands"
   ("s" "Show directive" gastown-directive-show)
   ("e" "Edit directive" gastown-directive-edit)
   ("l" "List directives" gastown-directive-list)])

;;;###autoload (autoload 'gastown-disable "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-disable "gastown-disable"
  "Disable a feature or plugin.")

;;;###autoload (autoload 'gastown-enable "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-enable "gastown-enable"
  "Enable a feature or plugin.")

;;;###autoload (autoload 'gastown-hooks "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks "gastown-hooks"
  "Manage Gas Town hooks.")

;;;###autoload (autoload 'gastown-issue "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-issue "gastown-issue"
  "Manage issues and configuration.")

;;;###autoload (autoload 'gastown-plugin "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-plugin "gastown-plugin"
  "Manage Gas Town plugins.")

;;;###autoload (autoload 'gastown-shell "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-shell "gastown-shell"
  "Configure shell integration.")

;;;###autoload (autoload 'gastown-theme "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-theme "gastown-theme"
  "Manage Gas Town UI themes.")

;;;###autoload (autoload 'gastown-uninstall "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-uninstall "gastown-uninstall"
  "Uninstall Gas Town components.")

;;; Config Dispatch Transient

;;;###autoload (autoload 'gastown-config-menu "gastown-command-config" nil t)
(transient-define-prefix gastown-config-menu ()
  "Gas Town configuration commands."
  ["Configuration"
   ("c" "Config" gastown-config)
   ("a" "Account" gastown-account)
   ("t" "Theme" gastown-theme)
   ("s" "Shell" gastown-shell)
   ("C" "Completion" gastown-completion)]
  ["Plugins & Hooks"
   ("p" "Plugin" gastown-plugin)
   ("h" "Hooks" gastown-hooks)
   ("e" "Enable" gastown-enable)
   ("d" "Disable" gastown-disable)]
  ["Directives"
   ("D" "Directive..." gastown-directive)]
  ["Lifecycle"
   ("i" "Issue" gastown-issue)
   ("u" "Uninstall" gastown-uninstall)])

(provide 'gastown-command-config)
;;; gastown-command-config.el ends here
