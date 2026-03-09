;;; gastown-command-coverage-test.el --- CLI coverage tests for gastown.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests verifying that all gt CLI subcommands have corresponding
;; gastown.el transient entries.

;;; Code:

(require 'ert)
(require 'gastown-command)
(require 'gastown-command-convoy)
(require 'gastown-command-formula)
(require 'gastown-command-mail)
(require 'gastown-command-polecat)
(require 'gastown-command-rig)
(require 'gastown-command-services)
(require 'gastown-command-work)

;;; Rig command coverage

(ert-deftest gastown-coverage-rig-list-class-exists ()
  "gastown-command-rig-list class should exist."
  (should (find-class 'gastown-command-rig-list)))

(ert-deftest gastown-coverage-rig-dock-class-exists ()
  "gastown-command-rig-dock class should exist."
  (should (find-class 'gastown-command-rig-dock)))

(ert-deftest gastown-coverage-rig-undock-class-exists ()
  "gastown-command-rig-undock class should exist."
  (should (find-class 'gastown-command-rig-undock)))

(ert-deftest gastown-coverage-rig-park-class-exists ()
  "gastown-command-rig-park class should exist."
  (should (find-class 'gastown-command-rig-park)))

(ert-deftest gastown-coverage-rig-unpark-class-exists ()
  "gastown-command-rig-unpark class should exist."
  (should (find-class 'gastown-command-rig-unpark)))

(ert-deftest gastown-coverage-rig-start-class-exists ()
  "gastown-command-rig-start class should exist."
  (should (find-class 'gastown-command-rig-start)))

(ert-deftest gastown-coverage-rig-stop-class-exists ()
  "gastown-command-rig-stop class should exist."
  (should (find-class 'gastown-command-rig-stop)))

(ert-deftest gastown-coverage-rig-restart-class-exists ()
  "gastown-command-rig-restart class should exist."
  (should (find-class 'gastown-command-rig-restart)))

(ert-deftest gastown-coverage-rig-reboot-class-exists ()
  "gastown-command-rig-reboot class should exist."
  (should (find-class 'gastown-command-rig-reboot)))

(ert-deftest gastown-coverage-rig-status-class-exists ()
  "gastown-command-rig-status class should exist."
  (should (find-class 'gastown-command-rig-status)))

(ert-deftest gastown-coverage-rig-start-cli-command ()
  "gastown-command-rig-start should include 'start' in command line."
  (let ((cmd (make-instance 'gastown-command-rig-start)))
    (should (member "start" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-rig-stop-cli-command ()
  "gastown-command-rig-stop should include 'stop' in command line."
  (let ((cmd (make-instance 'gastown-command-rig-stop)))
    (should (member "stop" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-rig-restart-cli-command ()
  "gastown-command-rig-restart should include 'restart' in command line."
  (let ((cmd (make-instance 'gastown-command-rig-restart)))
    (should (member "restart" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-rig-reboot-cli-command ()
  "gastown-command-rig-reboot should include 'reboot' in command line."
  (let ((cmd (make-instance 'gastown-command-rig-reboot)))
    (should (member "reboot" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-rig-transient-functions-exist ()
  "All rig transient functions should be defined."
  (should (fboundp 'gastown-rig-start))
  (should (fboundp 'gastown-rig-stop))
  (should (fboundp 'gastown-rig-restart))
  (should (fboundp 'gastown-rig-reboot))
  (should (fboundp 'gastown-rig-status)))

(ert-deftest gastown-coverage-rig-menu-exists ()
  "gastown-rig dispatch transient should exist."
  (should (fboundp 'gastown-rig)))

;;; Polecat command coverage

(ert-deftest gastown-coverage-polecat-list-class-exists ()
  "gastown-command-polecat-list class should exist."
  (should (find-class 'gastown-command-polecat-list)))

(ert-deftest gastown-coverage-polecat-nuke-class-exists ()
  "gastown-command-polecat-nuke class should exist."
  (should (find-class 'gastown-command-polecat-nuke)))

(ert-deftest gastown-coverage-polecat-status-class-exists ()
  "gastown-command-polecat-status class should exist."
  (should (find-class 'gastown-command-polecat-status)))

(ert-deftest gastown-coverage-polecat-status-transient-exists ()
  "gastown-polecat-status transient function should exist."
  (should (fboundp 'gastown-polecat-status)))

(ert-deftest gastown-coverage-polecat-menu-exists ()
  "gastown-polecat dispatch transient should exist."
  (should (fboundp 'gastown-polecat)))

;;; Convoy command coverage

(ert-deftest gastown-coverage-convoy-list-class-exists ()
  "gastown-command-convoy-list class should exist."
  (should (find-class 'gastown-command-convoy-list)))

(ert-deftest gastown-coverage-convoy-status-class-exists ()
  "gastown-command-convoy-status class should exist."
  (should (find-class 'gastown-command-convoy-status)))

(ert-deftest gastown-coverage-convoy-create-class-exists ()
  "gastown-command-convoy-create class should exist."
  (should (find-class 'gastown-command-convoy-create)))

(ert-deftest gastown-coverage-convoy-create-transient-exists ()
  "gastown-convoy-create transient function should exist."
  (should (fboundp 'gastown-convoy-create)))

(ert-deftest gastown-coverage-convoy-menu-exists ()
  "gastown-convoy dispatch transient should exist."
  (should (fboundp 'gastown-convoy)))

;;; Mail command coverage

(ert-deftest gastown-coverage-mail-inbox-class-exists ()
  "gastown-command-mail-inbox class should exist."
  (should (find-class 'gastown-command-mail-inbox)))

(ert-deftest gastown-coverage-mail-read-class-exists ()
  "gastown-command-mail-read class should exist."
  (should (find-class 'gastown-command-mail-read)))

(ert-deftest gastown-coverage-mail-send-class-exists ()
  "gastown-command-mail-send class should exist."
  (should (find-class 'gastown-command-mail-send)))

(ert-deftest gastown-coverage-mail-mark-read-class-exists ()
  "gastown-command-mail-mark-read class should exist."
  (should (find-class 'gastown-command-mail-mark-read)))

(ert-deftest gastown-coverage-mail-mark-read-transient-exists ()
  "gastown-mail-mark-read transient function should exist."
  (should (fboundp 'gastown-mail-mark-read)))

(ert-deftest gastown-coverage-mail-menu-exists ()
  "gastown-mail dispatch transient should exist."
  (should (fboundp 'gastown-mail)))

;;; Formula command coverage

(ert-deftest gastown-coverage-formula-list-class-exists ()
  "gastown-command-formula-list class should exist."
  (should (find-class 'gastown-command-formula-list)))

(ert-deftest gastown-coverage-formula-show-class-exists ()
  "gastown-command-formula-show class should exist."
  (should (find-class 'gastown-command-formula-show)))

(ert-deftest gastown-coverage-formula-run-class-exists ()
  "gastown-command-formula-run class should exist."
  (should (find-class 'gastown-command-formula-run)))

(ert-deftest gastown-coverage-formula-create-class-exists ()
  "gastown-command-formula-create class should exist."
  (should (find-class 'gastown-command-formula-create)))

(ert-deftest gastown-coverage-formula-transient-functions-exist ()
  "All formula transient functions should be defined."
  (should (fboundp 'gastown-formula-list))
  (should (fboundp 'gastown-formula-show))
  (should (fboundp 'gastown-formula-run))
  (should (fboundp 'gastown-formula-create)))

(ert-deftest gastown-coverage-formula-menu-exists ()
  "gastown-formula-menu dispatch transient should exist."
  (should (fboundp 'gastown-formula-menu)))

;;; Dolt command coverage

(ert-deftest gastown-coverage-dolt-status-class-exists ()
  "gastown-command-dolt-status class should exist."
  (should (find-class 'gastown-command-dolt-status)))

(ert-deftest gastown-coverage-dolt-start-class-exists ()
  "gastown-command-dolt-start class should exist."
  (should (find-class 'gastown-command-dolt-start)))

(ert-deftest gastown-coverage-dolt-stop-class-exists ()
  "gastown-command-dolt-stop class should exist."
  (should (find-class 'gastown-command-dolt-stop)))

(ert-deftest gastown-coverage-dolt-cleanup-class-exists ()
  "gastown-command-dolt-cleanup class should exist."
  (should (find-class 'gastown-command-dolt-cleanup)))

(ert-deftest gastown-coverage-dolt-transient-functions-exist ()
  "All dolt transient functions should be defined."
  (should (fboundp 'gastown-dolt-status))
  (should (fboundp 'gastown-dolt-start))
  (should (fboundp 'gastown-dolt-stop))
  (should (fboundp 'gastown-dolt-cleanup)))

(ert-deftest gastown-coverage-dolt-menu-exists ()
  "gastown-dolt-menu dispatch transient should exist."
  (should (fboundp 'gastown-dolt-menu)))

;;; Core work commands coverage

(ert-deftest gastown-coverage-work-done-exists ()
  "gastown-done transient should exist."
  (should (fboundp 'gastown-done)))

(ert-deftest gastown-coverage-work-hook-exists ()
  "gastown-hook transient should exist."
  (should (fboundp 'gastown-hook)))

(ert-deftest gastown-coverage-work-escalate-exists ()
  "gastown-escalate transient should exist."
  (should (fboundp 'gastown-escalate)))

(ert-deftest gastown-coverage-work-compact-exists ()
  "gastown-compact transient should exist."
  (should (fboundp 'gastown-compact)))

(ert-deftest gastown-coverage-work-handoff-exists ()
  "gastown-handoff transient should exist."
  (should (fboundp 'gastown-handoff)))

;;; Services coverage

(ert-deftest gastown-coverage-up-exists ()
  "gastown-up transient should exist."
  (should (fboundp 'gastown-up)))

(ert-deftest gastown-coverage-down-exists ()
  "gastown-down transient should exist."
  (should (fboundp 'gastown-down)))

;;; Diagnostics coverage

(ert-deftest gastown-coverage-vitals-exists ()
  "gastown-vitals transient should exist."
  (require 'gastown-command-diagnostics)
  (should (fboundp 'gastown-vitals)))

(ert-deftest gastown-coverage-whoami-exists ()
  "gastown-whoami transient should exist."
  (require 'gastown-command-diagnostics)
  (should (fboundp 'gastown-whoami)))

(ert-deftest gastown-coverage-info-exists ()
  "gastown-info transient should exist."
  (require 'gastown-command-diagnostics)
  (should (fboundp 'gastown-info)))

(ert-deftest gastown-coverage-prime-exists ()
  "gastown-prime transient should exist."
  (require 'gastown-command-diagnostics)
  (should (fboundp 'gastown-prime)))

;;; Nudge and sling coverage

(ert-deftest gastown-coverage-nudge-exists ()
  "gastown-nudge transient should exist."
  (require 'gastown-command-nudge)
  (should (fboundp 'gastown-nudge)))

(ert-deftest gastown-coverage-sling-exists ()
  "gastown-sling transient should exist."
  (require 'gastown-command-sling)
  (should (fboundp 'gastown-sling)))

(provide 'gastown-command-coverage-test)
;;; gastown-command-coverage-test.el ends here
