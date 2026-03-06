;;; gastown-command-config.el --- Configuration commands for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for configuration commands:
;; gt account, gt completion, gt config, gt disable, gt enable,
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

(cl-defmethod gastown-command-subcommand ((_command gastown-command-account))
  "Return \"account\" as the CLI subcommand name."
  "account")

;;; Completion Command

(gastown-defcommand gastown-command-completion (gastown-command-global-options)
  ()
  :documentation "Represents gt completion command.
Generate shell completion scripts.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-completion))
  "Return \"completion\" as the CLI subcommand name."
  "completion")

;;; Config Command

(gastown-defcommand gastown-command-config (gastown-command-global-options)
  ()
  :documentation "Represents gt config command.
Show or edit Gas Town configuration.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-config))
  "Return \"config\" as the CLI subcommand name."
  "config")

;;; Disable Command

(gastown-defcommand gastown-command-disable (gastown-command-global-options)
  ()
  :documentation "Represents gt disable command.
Disable a feature or plugin.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-disable))
  "Return \"disable\" as the CLI subcommand name."
  "disable")

;;; Enable Command

(gastown-defcommand gastown-command-enable (gastown-command-global-options)
  ()
  :documentation "Represents gt enable command.
Enable a feature or plugin.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-enable))
  "Return \"enable\" as the CLI subcommand name."
  "enable")

;;; Hooks Command

(gastown-defcommand gastown-command-hooks (gastown-command-global-options)
  ()
  :documentation "Represents gt hooks command.
Manage Gas Town hooks.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-hooks))
  "Return \"hooks\" as the CLI subcommand name."
  "hooks")

;;; Issue Command

(gastown-defcommand gastown-command-issue (gastown-command-global-options)
  ()
  :documentation "Represents gt issue command.
Manage issues and configuration.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-issue))
  "Return \"issue\" as the CLI subcommand name."
  "issue")

;;; Plugin Command

(gastown-defcommand gastown-command-plugin (gastown-command-global-options)
  ()
  :documentation "Represents gt plugin command.
Manage Gas Town plugins.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-plugin))
  "Return \"plugin\" as the CLI subcommand name."
  "plugin")

;;; Shell Command

(gastown-defcommand gastown-command-shell (gastown-command-global-options)
  ()
  :documentation "Represents gt shell command.
Configure shell integration.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-shell))
  "Return \"shell\" as the CLI subcommand name."
  "shell")

;;; Theme Command

(gastown-defcommand gastown-command-theme (gastown-command-global-options)
  ()
  :documentation "Represents gt theme command.
Manage Gas Town UI themes.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-theme))
  "Return \"theme\" as the CLI subcommand name."
  "theme")

;;; Uninstall Command

(gastown-defcommand gastown-command-uninstall (gastown-command-global-options)
  ()
  :documentation "Represents gt uninstall command.
Uninstall Gas Town components.")

(cl-defmethod gastown-command-subcommand ((_command gastown-command-uninstall))
  "Return \"uninstall\" as the CLI subcommand name."
  "uninstall")

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
  ["Lifecycle"
   ("i" "Issue" gastown-issue)
   ("u" "Uninstall" gastown-uninstall)])

(provide 'gastown-command-config)
;;; gastown-command-config.el ends here
