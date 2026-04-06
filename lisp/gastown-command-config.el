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
(require 'gastown-reader)

(require 'transient)

(defvar gastown-executable)

;;; Account Command

(gastown-defcommand gastown-command-account (gastown-command-global-options)
  ()
  :documentation "Represents gt account command.
Manage Gas Town account settings.")


;;; Account Subcommands

(gastown-defcommand gastown-command-account-add (gastown-command-global-options)
  ((handle
    :initarg :handle
    :type (or null string)
    :initform nil
    :documentation "Account handle to add."
    :positional 1
    :option-type :string
    :key "h"
    :transient-description "Handle (required)"
    :class transient-option
    :prompt "Handle: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt account add command.
Add a new Claude Code account."
  :cli-command "account add")


(gastown-defcommand gastown-command-account-default (gastown-command-global-options)
  ((handle
    :initarg :handle
    :type (or null string)
    :initform nil
    :documentation "Account handle to set as default."
    :positional 1
    :option-type :string
    :key "h"
    :transient-description "Handle (required)"
    :class transient-option
    :prompt "Handle: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt account default command.
Set the default Claude Code account."
  :cli-command "account default")


(gastown-defcommand gastown-command-account-list (gastown-command-global-options)
  ()
  :documentation "Represents gt account list command.
List all registered Claude Code accounts."
  :cli-command "account list")


(gastown-defcommand gastown-command-account-status (gastown-command-global-options)
  ()
  :documentation "Represents gt account status command.
Show current account info."
  :cli-command "account status")


(gastown-defcommand gastown-command-account-switch (gastown-command-global-options)
  ((handle
    :initarg :handle
    :type (or null string)
    :initform nil
    :documentation "Account handle to switch to."
    :positional 1
    :option-type :string
    :key "h"
    :transient-description "Handle (required)"
    :class transient-option
    :prompt "Handle: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt account switch command.
Switch to a different account."
  :cli-command "account switch")


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


;;; Config Subcommands

(gastown-defcommand gastown-command-config-agent (gastown-command-global-options)
  ((subcommand
    :initarg :subcommand
    :type (or null string)
    :initform nil
    :documentation "Agent subcommand (list, get, set, remove)."
    :positional 1
    :option-type :string
    :key "s"
    :transient-description "Subcommand (optional)"
    :class transient-option
    :prompt "Subcommand: "
    :transient-choices ("list" "get" "set" "remove")
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt config agent command.
Manage agent configuration."
  :cli-command "config agent")


(gastown-defcommand gastown-command-config-agent-email-domain (gastown-command-global-options)
  ((domain
    :initarg :domain
    :type (or null string)
    :initform nil
    :documentation "Email domain to set (optional, omit to get current)."
    :positional 1
    :option-type :string
    :key "d"
    :transient-description "Domain (optional)"
    :class transient-option
    :prompt "Domain (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt config agent-email-domain command.
Get or set agent email domain."
  :cli-command "config agent-email-domain")


(gastown-defcommand gastown-command-config-cost-tier (gastown-command-global-options)
  ((tier
    :initarg :tier
    :type (or null string)
    :initform nil
    :documentation "Cost tier to set (optional, omit to get current)."
    :positional 1
    :option-type :string
    :key "t"
    :transient-description "Tier (optional)"
    :class transient-option
    :prompt "Tier (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt config cost-tier command.
Get or set cost optimization tier."
  :cli-command "config cost-tier")


(gastown-defcommand gastown-command-config-default-agent (gastown-command-global-options)
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Agent name to set as default (optional, omit to get current)."
    :positional 1
    :option-type :string
    :key "n"
    :transient-description "Agent name (optional)"
    :class transient-option
    :prompt "Agent name (optional): "
    :transient-group "Arguments"
    :level 2
    :order 1))
  :documentation "Represents gt config default-agent command.
Get or set the default agent."
  :cli-command "config default-agent")


(gastown-defcommand gastown-command-config-get (gastown-command-global-options)
  ((key
    :initarg :key
    :type (or null string)
    :initform nil
    :documentation "Configuration key to get (dot-notation)."
    :positional 1
    :option-type :string
    :key "k"
    :transient-description "Key (required)"
    :class transient-option
    :prompt "Key: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt config get command.
Get a town configuration value."
  :cli-command "config get")


(gastown-defcommand gastown-command-config-set (gastown-command-global-options)
  ((key
    :initarg :key
    :type (or null string)
    :initform nil
    :documentation "Configuration key to set (dot-notation)."
    :positional 1
    :option-type :string
    :key "k"
    :transient-description "Key (required)"
    :class transient-option
    :prompt "Key: "
    :transient-group "Arguments"
    :level 1
    :order 1)
   (value
    :initarg :value
    :type (or null string)
    :initform nil
    :documentation "Value to set."
    :positional 2
    :option-type :string
    :key "v"
    :transient-description "Value (required)"
    :class transient-option
    :prompt "Value: "
    :transient-group "Arguments"
    :level 1
    :order 2))
  :documentation "Represents gt config set command.
Set a town configuration value."
  :cli-command "config set")


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
    :transient-description "Role name (required)"
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
    :transient-description "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
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
    :transient-description "Role name (required)"
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
    :transient-description "Rig name"
    :class transient-option
    :argument "--rig="
    :prompt "Rig: "
    :transient-reader gastown-reader-rig-name
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
    :transient-description "Edit town-level directive"
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


;;; Hooks Subcommands

(gastown-defcommand gastown-command-hooks-base (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks base command.
Edit the shared base hook config."
  :cli-command "hooks base")


(gastown-defcommand gastown-command-hooks-diff (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks diff command.
Show what sync would change."
  :cli-command "hooks diff")


(gastown-defcommand gastown-command-hooks-init (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks init command.
Initialize hooks configuration."
  :cli-command "hooks init")


(gastown-defcommand gastown-command-hooks-install (gastown-command-global-options)
  ((hook-name
    :initarg :hook-name
    :type (or null string)
    :initform nil
    :documentation "Hook name to install from the registry."
    :positional 1
    :option-type :string
    :key "h"
    :transient-description "Hook name (required)"
    :class transient-option
    :prompt "Hook name: "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt hooks install command.
Install a hook from the registry."
  :cli-command "hooks install")


(gastown-defcommand gastown-command-hooks-list (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks list command.
Show all managed settings.json locations."
  :cli-command "hooks list")


(gastown-defcommand gastown-command-hooks-override (gastown-command-global-options)
  ((target
    :initarg :target
    :type (or null string)
    :initform nil
    :documentation "Role or rig to edit overrides for."
    :positional 1
    :option-type :string
    :key "t"
    :transient-description "Target (required)"
    :class transient-option
    :prompt "Target (role or rig): "
    :transient-group "Arguments"
    :level 1
    :order 1))
  :documentation "Represents gt hooks override command.
Edit overrides for a role or rig."
  :cli-command "hooks override")


(gastown-defcommand gastown-command-hooks-registry (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks registry command.
List hooks from the registry."
  :cli-command "hooks registry")


(gastown-defcommand gastown-command-hooks-scan (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks scan command.
Scan workspace for existing hooks."
  :cli-command "hooks scan")


(gastown-defcommand gastown-command-hooks-sync (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks sync command.
Regenerate all .claude/settings.json files."
  :cli-command "hooks sync")


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

;;;###autoload (autoload 'gastown-account-add "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account-add "gastown-account-add"
  "Add a new account.")

;;;###autoload (autoload 'gastown-account-default "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account-default "gastown-account-default"
  "Set default account.")

;;;###autoload (autoload 'gastown-account-list "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account-list "gastown-account-list"
  "List registered accounts.")

;;;###autoload (autoload 'gastown-account-status "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account-status "gastown-account-status"
  "Show account status.")

;;;###autoload (autoload 'gastown-account-switch "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-account-switch "gastown-account-switch"
  "Switch to a different account.")

;;; Account Dispatch Transient

;;;###autoload (autoload 'gastown-account-menu "gastown-command-config" nil t)
(transient-define-prefix gastown-account-menu ()
  "Manage Claude Code accounts."
  ["Account Info"
   ("l" "List accounts" gastown-account-list)
   ("s" "Account status" gastown-account-status)]
  ["Account Actions"
   ("a" "Add account" gastown-account-add)
   ("d" "Set default" gastown-account-default)
   ("w" "Switch account" gastown-account-switch)])

;;;###autoload (autoload 'gastown-completion "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-completion "gastown-completion"
  "Generate shell completion scripts.")

;;;###autoload (autoload 'gastown-config "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config "gastown-config"
  "Show or edit Gas Town configuration.")

;;;###autoload (autoload 'gastown-config-agent "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-agent "gastown-config-agent"
  "Manage agent configuration.")

;;;###autoload (autoload 'gastown-config-agent-email-domain "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-agent-email-domain "gastown-config-agent-email-domain"
  "Get or set agent email domain.")

;;;###autoload (autoload 'gastown-config-cost-tier "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-cost-tier "gastown-config-cost-tier"
  "Get or set cost tier.")

;;;###autoload (autoload 'gastown-config-default-agent "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-default-agent "gastown-config-default-agent"
  "Get or set default agent.")

;;;###autoload (autoload 'gastown-config-get "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-get "gastown-config-get"
  "Get a configuration value.")

;;;###autoload (autoload 'gastown-config-set "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-config-set "gastown-config-set"
  "Set a configuration value.")

;;; Config Values Dispatch Transient

;;;###autoload (autoload 'gastown-config-values-menu "gastown-command-config" nil t)
(transient-define-prefix gastown-config-values-menu ()
  "Manage Gas Town configuration values."
  ["Values"
   ("g" "Get value" gastown-config-get)
   ("s" "Set value" gastown-config-set)]
  ["Agent Config"
   ("a" "Agent settings" gastown-config-agent)
   ("e" "Email domain" gastown-config-agent-email-domain)
   ("d" "Default agent" gastown-config-default-agent)
   ("c" "Cost tier" gastown-config-cost-tier)])

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

;;;###autoload (autoload 'gastown-hooks-base "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-base "gastown-hooks-base"
  "Edit base hook config.")

;;;###autoload (autoload 'gastown-hooks-diff "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-diff "gastown-hooks-diff"
  "Show hooks diff.")

;;;###autoload (autoload 'gastown-hooks-init "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-init "gastown-hooks-init"
  "Initialize hooks config.")

;;;###autoload (autoload 'gastown-hooks-install "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-install "gastown-hooks-install"
  "Install hook from registry.")

;;;###autoload (autoload 'gastown-hooks-list "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-list "gastown-hooks-list"
  "List managed hook locations.")

;;;###autoload (autoload 'gastown-hooks-override "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-override "gastown-hooks-override"
  "Edit role/rig hook overrides.")

;;;###autoload (autoload 'gastown-hooks-registry "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-registry "gastown-hooks-registry"
  "List hooks registry.")

;;;###autoload (autoload 'gastown-hooks-scan "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-scan "gastown-hooks-scan"
  "Scan for existing hooks.")

;;;###autoload (autoload 'gastown-hooks-sync "gastown-command-config" nil t)
(beads-meta-define-transient gastown-command-hooks-sync "gastown-hooks-sync"
  "Sync all settings.json files.")

;;; Hooks Dispatch Transient

;;;###autoload (autoload 'gastown-hooks-menu "gastown-command-config" nil t)
(transient-define-prefix gastown-hooks-menu ()
  "Manage Gas Town hooks."
  ["View"
   ("l" "List locations" gastown-hooks-list)
   ("d" "Diff" gastown-hooks-diff)
   ("r" "Registry" gastown-hooks-registry)
   ("s" "Scan" gastown-hooks-scan)]
  ["Edit"
   ("b" "Edit base" gastown-hooks-base)
   ("o" "Edit override" gastown-hooks-override)]
  ["Actions"
   ("S" "Sync" gastown-hooks-sync)
   ("i" "Init" gastown-hooks-init)
   ("I" "Install from registry" gastown-hooks-install)])

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
   ("c" "Config values..." gastown-config-values-menu)
   ("a" "Account..." gastown-account-menu)
   ("t" "Theme" gastown-theme)
   ("s" "Shell" gastown-shell)
   ("C" "Completion" gastown-completion)]
  ["Plugins & Hooks"
   ("p" "Plugin" gastown-plugin)
   ("h" "Hooks..." gastown-hooks-menu)
   ("e" "Enable" gastown-enable)
   ("d" "Disable" gastown-disable)]
  ["Directives"
   ("D" "Directive..." gastown-directive)]
  ["Lifecycle"
   ("i" "Issue" gastown-issue)
   ("u" "Uninstall" gastown-uninstall)])

(provide 'gastown-command-config)
;;; gastown-command-config.el ends here
