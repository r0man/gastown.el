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

(ert-deftest gastown-coverage-estop-class-exists ()
  "gastown-command-estop class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-estop)))

(ert-deftest gastown-coverage-estop-transient-exists ()
  "gastown-estop transient should exist."
  (require 'gastown-command-services)
  (should (fboundp 'gastown-estop)))

(ert-deftest gastown-coverage-thaw-class-exists ()
  "gastown-command-thaw class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-thaw)))

(ert-deftest gastown-coverage-thaw-transient-exists ()
  "gastown-thaw transient should exist."
  (require 'gastown-command-services)
  (should (fboundp 'gastown-thaw)))

(ert-deftest gastown-coverage-estop-cli-command ()
  "gastown-command-estop should include 'estop' in command line."
  (require 'gastown-command-services)
  (let ((cmd (make-instance 'gastown-command-estop)))
    (should (member "estop" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-thaw-cli-command ()
  "gastown-command-thaw should include 'thaw' in command line."
  (require 'gastown-command-services)
  (let ((cmd (make-instance 'gastown-command-thaw)))
    (should (member "thaw" (gastown-command-line cmd)))))

;;; Assign, changelog, mountain coverage

(ert-deftest gastown-coverage-assign-class-exists ()
  "gastown-command-assign class should exist."
  (should (find-class 'gastown-command-assign)))

(ert-deftest gastown-coverage-assign-transient-exists ()
  "gastown-assign transient should exist."
  (should (fboundp 'gastown-assign)))

(ert-deftest gastown-coverage-changelog-class-exists ()
  "gastown-command-changelog class should exist."
  (should (find-class 'gastown-command-changelog)))

(ert-deftest gastown-coverage-changelog-transient-exists ()
  "gastown-changelog transient should exist."
  (should (fboundp 'gastown-changelog)))

(ert-deftest gastown-coverage-mountain-class-exists ()
  "gastown-command-mountain class should exist."
  (should (find-class 'gastown-command-mountain)))

(ert-deftest gastown-coverage-mountain-transient-exists ()
  "gastown-mountain transient should exist."
  (should (fboundp 'gastown-mountain)))

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

;;; Context-aware reader wiring

(ert-deftest gastown-coverage-sling-bead-id-reader-wired ()
  "gastown-command-sling bead-id slot should use gastown-reader-bead-id."
  (require 'gastown-command-sling)
  (should (eq (beads-meta-slot-property 'gastown-command-sling 'bead-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-done-issue-slot-exists ()
  "gastown-command-done should have an issue slot."
  (should (slot-exists-p (make-instance 'gastown-command-done) 'issue)))

(ert-deftest gastown-coverage-done-issue-reader-wired ()
  "gastown-command-done issue slot should use gastown-reader-bead-id."
  (should (eq (beads-meta-slot-property 'gastown-command-done 'issue
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-hook-bead-id-slot-exists ()
  "gastown-command-hook should have a bead-id slot."
  (should (slot-exists-p (make-instance 'gastown-command-hook) 'bead-id)))

(ert-deftest gastown-coverage-hook-bead-id-reader-wired ()
  "gastown-command-hook bead-id slot should use gastown-reader-bead-id."
  (should (eq (beads-meta-slot-property 'gastown-command-hook 'bead-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-peek-target-reader-wired ()
  "gastown-command-peek target slot should use gastown-reader-agent-target."
  (require 'gastown-command-peek)
  (should (eq (beads-meta-slot-property 'gastown-command-peek 'target
                                        :transient-reader)
              'gastown-reader-agent-target)))

(ert-deftest gastown-coverage-nudge-target-reader-wired ()
  "gastown-command-nudge target slot should use gastown-reader-agent-target."
  (require 'gastown-command-nudge)
  (should (eq (beads-meta-slot-property 'gastown-command-nudge 'target
                                        :transient-reader)
              'gastown-reader-agent-target)))

;;; Sling command full option coverage

(ert-deftest gastown-coverage-sling-target-slot-exists ()
  "gastown-command-sling should have a positional target slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'target)))

(ert-deftest gastown-coverage-sling-target-reader-wired ()
  "gastown-command-sling target slot should use gastown-reader-agent-target."
  (require 'gastown-command-sling)
  (should (eq (beads-meta-slot-property 'gastown-command-sling 'target
                                        :transient-reader)
              'gastown-reader-agent-target)))

(ert-deftest gastown-coverage-sling-force-slot-exists ()
  "gastown-command-sling should have a force slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'force)))

(ert-deftest gastown-coverage-sling-create-slot-exists ()
  "gastown-command-sling should have a create slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'create)))

(ert-deftest gastown-coverage-sling-account-slot-exists ()
  "gastown-command-sling should have an account slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'account)))

(ert-deftest gastown-coverage-sling-agent-slot-exists ()
  "gastown-command-sling should have an agent slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'agent)))

(ert-deftest gastown-coverage-sling-crew-slot-exists ()
  "gastown-command-sling should have a crew slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'crew)))

(ert-deftest gastown-coverage-sling-formula-slot-exists ()
  "gastown-command-sling should have a formula slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'formula)))

(ert-deftest gastown-coverage-sling-on-slot-exists ()
  "gastown-command-sling should have an on slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'on)))

(ert-deftest gastown-coverage-sling-args-slot-exists ()
  "gastown-command-sling should have an args slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'args)))

(ert-deftest gastown-coverage-sling-message-slot-exists ()
  "gastown-command-sling should have a message slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'message)))

(ert-deftest gastown-coverage-sling-subject-slot-exists ()
  "gastown-command-sling should have a subject slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'subject)))

(ert-deftest gastown-coverage-sling-var-slot-exists ()
  "gastown-command-sling should have a var slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'var)))

(ert-deftest gastown-coverage-sling-stdin-slot-exists ()
  "gastown-command-sling should have a stdin slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'stdin)))

(ert-deftest gastown-coverage-sling-merge-slot-exists ()
  "gastown-command-sling should have a merge slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'merge)))

(ert-deftest gastown-coverage-sling-no-merge-slot-exists ()
  "gastown-command-sling should have a no-merge slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'no-merge)))

(ert-deftest gastown-coverage-sling-no-convoy-slot-exists ()
  "gastown-command-sling should have a no-convoy slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'no-convoy)))

(ert-deftest gastown-coverage-sling-base-branch-slot-exists ()
  "gastown-command-sling should have a base-branch slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'base-branch)))

(ert-deftest gastown-coverage-sling-ralph-slot-exists ()
  "gastown-command-sling should have a ralph slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'ralph)))

(ert-deftest gastown-coverage-sling-hook-raw-bead-slot-exists ()
  "gastown-command-sling should have a hook-raw-bead slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'hook-raw-bead)))

(ert-deftest gastown-coverage-sling-owned-slot-exists ()
  "gastown-command-sling should have an owned slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'owned)))

(ert-deftest gastown-coverage-sling-no-boot-slot-exists ()
  "gastown-command-sling should have a no-boot slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'no-boot)))

(ert-deftest gastown-coverage-sling-dry-run-slot-exists ()
  "gastown-command-sling should have a dry-run slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'dry-run)))

(ert-deftest gastown-coverage-sling-review-only-slot-exists ()
  "gastown-command-sling should have a review-only slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'review-only)))

(ert-deftest gastown-coverage-sling-max-concurrent-slot-exists ()
  "gastown-command-sling should have a max-concurrent slot."
  (require 'gastown-command-sling)
  (should (slot-exists-p (make-instance 'gastown-command-sling) 'max-concurrent)))

(ert-deftest gastown-coverage-sling-command-line-bead-target ()
  "gastown-command-sling command line should include bead-id and target positionally."
  (require 'gastown-command-sling)
  (let ((cmd (gastown-command-sling :bead-id "gt-abc" :target "gastown_el")))
    (let ((line (gastown-command-line cmd)))
      (should (member "gt-abc" line))
      (should (member "gastown_el" line)))))

(ert-deftest gastown-coverage-sling-command-line-flags ()
  "gastown-command-sling command line should include boolean flags when set."
  (require 'gastown-command-sling)
  (let ((cmd (gastown-command-sling :force t :dry-run t :no-convoy t)))
    (let ((line (gastown-command-line cmd)))
      (should (member "--force" line))
      (should (member "--dry-run" line))
      (should (member "--no-convoy" line)))))

(ert-deftest gastown-coverage-sling-command-line-options ()
  "gastown-command-sling command line should include string options when set."
  (require 'gastown-command-sling)
  (let ((cmd (gastown-command-sling :merge "direct" :base-branch "develop"
                                    :formula "shiny" :args "patch release")))
    (let ((line (gastown-command-line cmd)))
      (should (member "--merge" line))
      (should (member "direct" line))
      (should (member "--base-branch" line))
      (should (member "develop" line))
      (should (member "--formula" line))
      (should (member "shiny" line))
      (should (member "--args" line))
      (should (member "patch release" line)))))

;;; New reader wiring tests

(ert-deftest gastown-coverage-convoy-status-convoy-id-reader-wired ()
  "gastown-command-convoy-status convoy-id slot should use gastown-reader-convoy-id."
  (require 'gastown-command-convoy)
  (should (eq (beads-meta-slot-property 'gastown-command-convoy-status 'convoy-id
                                        :transient-reader)
              'gastown-reader-convoy-id)))

(ert-deftest gastown-coverage-convoy-list-rig-reader-wired ()
  "gastown-command-convoy-list rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-convoy)
  (should (eq (beads-meta-slot-property 'gastown-command-convoy-list 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-formula-show-reader-wired ()
  "gastown-command-formula-show formula-name slot should use gastown-reader-formula-name."
  (require 'gastown-command-formula)
  (should (eq (beads-meta-slot-property 'gastown-command-formula-show 'formula-name
                                        :transient-reader)
              'gastown-reader-formula-name)))

(ert-deftest gastown-coverage-formula-run-reader-wired ()
  "gastown-command-formula-run formula-name slot should use gastown-reader-formula-name."
  (require 'gastown-command-formula)
  (should (eq (beads-meta-slot-property 'gastown-command-formula-run 'formula-name
                                        :transient-reader)
              'gastown-reader-formula-name)))

(ert-deftest gastown-coverage-mq-list-rig-reader-wired ()
  "gastown-command-mq-list rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-list 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; MQ post-merge command coverage

(ert-deftest gastown-coverage-mq-post-merge-class-exists ()
  "gastown-command-mq-post-merge class should exist."
  (require 'gastown-command-work)
  (should (find-class 'gastown-command-mq-post-merge)))

(ert-deftest gastown-coverage-mq-post-merge-cli-command ()
  "gastown-command-mq-post-merge should include 'post-merge' in command line."
  (require 'gastown-command-work)
  (let ((cmd (make-instance 'gastown-command-mq-post-merge)))
    (should (member "post-merge" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-mq-post-merge-cli-command-includes-mq ()
  "gastown-command-mq-post-merge should include 'mq' in command line."
  (require 'gastown-command-work)
  (let ((cmd (make-instance 'gastown-command-mq-post-merge)))
    (should (member "mq" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-mq-post-merge-rig-reader-wired ()
  "gastown-command-mq-post-merge rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-post-merge 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-mq-post-merge-mr-id-reader-wired ()
  "gastown-command-mq-post-merge mr-id slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-post-merge 'mr-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-mq-post-merge-skip-branch-delete-flag ()
  "gastown-command-mq-post-merge with skip-branch-delete should include flag."
  (require 'gastown-command-work)
  (let ((cmd (make-instance 'gastown-command-mq-post-merge
                            :skip-branch-delete t
                            :rig "gastown"
                            :mr-id "ge-mr-abc")))
    (should (member "--skip-branch-delete" (gastown-command-line cmd)))))

;;; New reader function tests

(ert-deftest gastown-coverage-reader-convoy-id-defined ()
  "gastown-reader-convoy-id should be defined."
  (require 'gastown-reader)
  (should (fboundp 'gastown-reader-convoy-id)))

(ert-deftest gastown-coverage-reader-formula-name-defined ()
  "gastown-reader-formula-name should be defined."
  (require 'gastown-reader)
  (should (fboundp 'gastown-reader-formula-name)))

(ert-deftest gastown-coverage-reader-crew-name-defined ()
  "gastown-reader-crew-name should be defined."
  (require 'gastown-reader)
  (should (fboundp 'gastown-reader-crew-name)))

(ert-deftest gastown-coverage-reader-merge-strategy-defined ()
  "gastown-reader-merge-strategy should be defined."
  (require 'gastown-reader)
  (should (fboundp 'gastown-reader-merge-strategy)))

(ert-deftest gastown-coverage-reader-merge-strategy-uses-completing-read ()
  "gastown-reader-merge-strategy should use completing-read with valid choices."
  (require 'gastown-reader)
  (cl-letf (((symbol-function 'completing-read)
             (lambda (_prompt choices &rest _) (car choices))))
    (let ((result (gastown-reader-merge-strategy "Merge strategy: " nil nil)))
      (should (member result '("mr" "direct" "local"))))))

;;; Directive command coverage

(ert-deftest gastown-coverage-directive-show-class-exists ()
  "gastown-command-directive-show class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-directive-show)))

(ert-deftest gastown-coverage-directive-edit-class-exists ()
  "gastown-command-directive-edit class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-directive-edit)))

(ert-deftest gastown-coverage-directive-list-class-exists ()
  "gastown-command-directive-list class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-directive-list)))

(ert-deftest gastown-coverage-directive-transient-functions-exist ()
  "All directive transient functions should be defined."
  (require 'gastown-command-config)
  (should (fboundp 'gastown-directive-show))
  (should (fboundp 'gastown-directive-edit))
  (should (fboundp 'gastown-directive-list)))

(ert-deftest gastown-coverage-directive-menu-exists ()
  "gastown-directive dispatch transient should exist."
  (require 'gastown-command-config)
  (should (fboundp 'gastown-directive)))

(ert-deftest gastown-coverage-directive-show-cli-command ()
  "gastown-command-directive-show should produce 'directive show' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-directive-show)))
    (should (member "directive" (gastown-command-line cmd)))
    (should (member "show" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-directive-edit-cli-command ()
  "gastown-command-directive-edit should produce 'directive edit' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-directive-edit)))
    (should (member "directive" (gastown-command-line cmd)))
    (should (member "edit" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-directive-list-cli-command ()
  "gastown-command-directive-list should produce 'directive list' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-directive-list)))
    (should (member "directive" (gastown-command-line cmd)))
    (should (member "list" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-directive-edit-town-flag ()
  "gastown-command-directive-edit should include --town flag when set."
  (require 'gastown-command-config)
  (let ((cmd (gastown-command-directive-edit :town t)))
    (should (member "--town" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-directive-show-rig-option ()
  "gastown-command-directive-show should include --rig option when set."
  (require 'gastown-command-config)
  (let ((cmd (gastown-command-directive-show :rig "sky")))
    (let ((line (gastown-command-line cmd)))
      (should (member "--rig" line))
      (should (member "sky" line)))))

;;; Mol command coverage

(ert-deftest gastown-coverage-mol-attach-class-exists ()
  "gastown-command-mol-attach class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-attach)))

(ert-deftest gastown-coverage-mol-attach-from-mail-class-exists ()
  "gastown-command-mol-attach-from-mail class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-attach-from-mail)))

(ert-deftest gastown-coverage-mol-attachment-class-exists ()
  "gastown-command-mol-attachment class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-attachment)))

(ert-deftest gastown-coverage-mol-await-signal-class-exists ()
  "gastown-command-mol-await-signal class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-await-signal)))

(ert-deftest gastown-coverage-mol-burn-class-exists ()
  "gastown-command-mol-burn class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-burn)))

(ert-deftest gastown-coverage-mol-current-class-exists ()
  "gastown-command-mol-current class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-current)))

(ert-deftest gastown-coverage-mol-dag-class-exists ()
  "gastown-command-mol-dag class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-dag)))

(ert-deftest gastown-coverage-mol-detach-class-exists ()
  "gastown-command-mol-detach class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-detach)))

(ert-deftest gastown-coverage-mol-progress-class-exists ()
  "gastown-command-mol-progress class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-progress)))

(ert-deftest gastown-coverage-mol-squash-class-exists ()
  "gastown-command-mol-squash class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-squash)))

(ert-deftest gastown-coverage-mol-status-class-exists ()
  "gastown-command-mol-status class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-status)))

(ert-deftest gastown-coverage-mol-step-done-class-exists ()
  "gastown-command-mol-step-done class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-step-done)))

(ert-deftest gastown-coverage-mol-step-await-signal-class-exists ()
  "gastown-command-mol-step-await-signal class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-step-await-signal)))

(ert-deftest gastown-coverage-mol-step-await-event-class-exists ()
  "gastown-command-mol-step-await-event class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-step-await-event)))

(ert-deftest gastown-coverage-mol-step-emit-event-class-exists ()
  "gastown-command-mol-step-emit-event class should exist."
  (require 'gastown-command-mol)
  (should (find-class 'gastown-command-mol-step-emit-event)))

(ert-deftest gastown-coverage-mol-transient-functions-exist ()
  "Key mol transient functions should exist."
  (require 'gastown-command-mol)
  (should (fboundp 'gastown-mol-attach))
  (should (fboundp 'gastown-mol-current))
  (should (fboundp 'gastown-mol-status))
  (should (fboundp 'gastown-mol-step-done)))

(ert-deftest gastown-coverage-mol-menu-exists ()
  "gastown-mol transient menu should exist."
  (require 'gastown-command-mol)
  (should (fboundp 'gastown-mol)))

(ert-deftest gastown-coverage-mol-step-menu-exists ()
  "gastown-mol-step transient menu should exist."
  (require 'gastown-command-mol)
  (should (fboundp 'gastown-mol-step)))

(ert-deftest gastown-coverage-mol-attach-cli-command ()
  "gastown-command-mol-attach should produce 'mol attach' command line."
  (require 'gastown-command-mol)
  (let ((cmd (make-instance 'gastown-command-mol-attach)))
    (should (member "mol" (gastown-command-line cmd)))
    (should (member "attach" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-mol-step-done-cli-command ()
  "gastown-command-mol-step-done should produce 'mol step done' command line."
  (require 'gastown-command-mol)
  (let ((cmd (make-instance 'gastown-command-mol-step-done)))
    (should (member "mol" (gastown-command-line cmd)))
    (should (member "step" (gastown-command-line cmd)))
    (should (member "done" (gastown-command-line cmd)))))

;;; WL command coverage

(ert-deftest gastown-coverage-wl-browse-class-exists ()
  "gastown-command-wl-browse class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-browse)))

(ert-deftest gastown-coverage-wl-charsheet-class-exists ()
  "gastown-command-wl-charsheet class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-charsheet)))

(ert-deftest gastown-coverage-wl-claim-class-exists ()
  "gastown-command-wl-claim class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-claim)))

(ert-deftest gastown-coverage-wl-done-class-exists ()
  "gastown-command-wl-done class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-done)))

(ert-deftest gastown-coverage-wl-join-class-exists ()
  "gastown-command-wl-join class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-join)))

(ert-deftest gastown-coverage-wl-post-class-exists ()
  "gastown-command-wl-post class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-post)))

(ert-deftest gastown-coverage-wl-scorekeeper-class-exists ()
  "gastown-command-wl-scorekeeper class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-scorekeeper)))

(ert-deftest gastown-coverage-wl-show-class-exists ()
  "gastown-command-wl-show class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-show)))

(ert-deftest gastown-coverage-wl-stamp-class-exists ()
  "gastown-command-wl-stamp class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-stamp)))

(ert-deftest gastown-coverage-wl-stamps-class-exists ()
  "gastown-command-wl-stamps class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-stamps)))

(ert-deftest gastown-coverage-wl-sync-class-exists ()
  "gastown-command-wl-sync class should exist."
  (require 'gastown-command-wl)
  (should (find-class 'gastown-command-wl-sync)))

(ert-deftest gastown-coverage-wl-transient-functions-exist ()
  "Key wl transient functions should exist."
  (require 'gastown-command-wl)
  (should (fboundp 'gastown-wl-browse))
  (should (fboundp 'gastown-wl-claim))
  (should (fboundp 'gastown-wl-show))
  (should (fboundp 'gastown-wl-sync)))

(ert-deftest gastown-coverage-wl-menu-exists ()
  "gastown-wl transient menu should exist."
  (require 'gastown-command-wl)
  (should (fboundp 'gastown-wl)))

(ert-deftest gastown-coverage-wl-claim-cli-command ()
  "gastown-command-wl-claim should produce 'wl claim' command line."
  (require 'gastown-command-wl)
  (let ((cmd (make-instance 'gastown-command-wl-claim)))
    (should (member "wl" (gastown-command-line cmd)))
    (should (member "claim" (gastown-command-line cmd)))))

;;; Crew subcommand coverage

(ert-deftest gastown-coverage-crew-add-class-exists ()
  "gastown-command-crew-add class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-add)))

(ert-deftest gastown-coverage-crew-at-class-exists ()
  "gastown-command-crew-at class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-at)))

(ert-deftest gastown-coverage-crew-list-class-exists ()
  "gastown-command-crew-list class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-list)))

(ert-deftest gastown-coverage-crew-pristine-class-exists ()
  "gastown-command-crew-pristine class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-pristine)))

(ert-deftest gastown-coverage-crew-refresh-class-exists ()
  "gastown-command-crew-refresh class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-refresh)))

(ert-deftest gastown-coverage-crew-remove-class-exists ()
  "gastown-command-crew-remove class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-remove)))

(ert-deftest gastown-coverage-crew-rename-class-exists ()
  "gastown-command-crew-rename class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-rename)))

(ert-deftest gastown-coverage-crew-restart-class-exists ()
  "gastown-command-crew-restart class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-restart)))

(ert-deftest gastown-coverage-crew-start-class-exists ()
  "gastown-command-crew-start class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-start)))

(ert-deftest gastown-coverage-crew-status-class-exists ()
  "gastown-command-crew-status class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-status)))

(ert-deftest gastown-coverage-crew-stop-class-exists ()
  "gastown-command-crew-stop class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-crew-stop)))

(ert-deftest gastown-coverage-crew-transient-functions-exist ()
  "Key crew transient functions should exist."
  (require 'gastown-command-workspace)
  (should (fboundp 'gastown-crew-add))
  (should (fboundp 'gastown-crew-list))
  (should (fboundp 'gastown-crew-start))
  (should (fboundp 'gastown-crew-stop)))

(ert-deftest gastown-coverage-crew-menu-exists ()
  "gastown-crew-menu transient should exist."
  (require 'gastown-command-workspace)
  (should (fboundp 'gastown-crew-menu)))

(ert-deftest gastown-coverage-crew-start-cli-command ()
  "gastown-command-crew-start should produce 'crew start' command line."
  (require 'gastown-command-workspace)
  (let ((cmd (make-instance 'gastown-command-crew-start)))
    (should (member "crew" (gastown-command-line cmd)))
    (should (member "start" (gastown-command-line cmd)))))

;;; Namepool subcommand coverage

(ert-deftest gastown-coverage-namepool-add-class-exists ()
  "gastown-command-namepool-add class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-add)))

(ert-deftest gastown-coverage-namepool-create-class-exists ()
  "gastown-command-namepool-create class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-create)))

(ert-deftest gastown-coverage-namepool-delete-class-exists ()
  "gastown-command-namepool-delete class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-delete)))

(ert-deftest gastown-coverage-namepool-reset-class-exists ()
  "gastown-command-namepool-reset class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-reset)))

(ert-deftest gastown-coverage-namepool-set-class-exists ()
  "gastown-command-namepool-set class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-set)))

(ert-deftest gastown-coverage-namepool-themes-class-exists ()
  "gastown-command-namepool-themes class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-namepool-themes)))

(ert-deftest gastown-coverage-namepool-menu-exists ()
  "gastown-namepool-menu transient should exist."
  (require 'gastown-command-workspace)
  (should (fboundp 'gastown-namepool-menu)))

;;; Worktree subcommand coverage

(ert-deftest gastown-coverage-worktree-list-class-exists ()
  "gastown-command-worktree-list class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-worktree-list)))

(ert-deftest gastown-coverage-worktree-remove-class-exists ()
  "gastown-command-worktree-remove class should exist."
  (require 'gastown-command-workspace)
  (should (find-class 'gastown-command-worktree-remove)))

(ert-deftest gastown-coverage-worktree-menu-exists ()
  "gastown-worktree-menu transient should exist."
  (require 'gastown-command-workspace)
  (should (fboundp 'gastown-worktree-menu)))

;;; Account subcommand coverage

(ert-deftest gastown-coverage-account-add-class-exists ()
  "gastown-command-account-add class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-account-add)))

(ert-deftest gastown-coverage-account-default-class-exists ()
  "gastown-command-account-default class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-account-default)))

(ert-deftest gastown-coverage-account-list-class-exists ()
  "gastown-command-account-list class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-account-list)))

(ert-deftest gastown-coverage-account-status-class-exists ()
  "gastown-command-account-status class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-account-status)))

(ert-deftest gastown-coverage-account-switch-class-exists ()
  "gastown-command-account-switch class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-account-switch)))

(ert-deftest gastown-coverage-account-menu-exists ()
  "gastown-account-menu transient should exist."
  (require 'gastown-command-config)
  (should (fboundp 'gastown-account-menu)))

(ert-deftest gastown-coverage-account-list-cli-command ()
  "gastown-command-account-list should produce 'account list' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-account-list)))
    (should (member "account" (gastown-command-line cmd)))
    (should (member "list" (gastown-command-line cmd)))))

;;; Config subcommand coverage

(ert-deftest gastown-coverage-config-agent-class-exists ()
  "gastown-command-config-agent class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-agent)))

(ert-deftest gastown-coverage-config-agent-email-domain-class-exists ()
  "gastown-command-config-agent-email-domain class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-agent-email-domain)))

(ert-deftest gastown-coverage-config-cost-tier-class-exists ()
  "gastown-command-config-cost-tier class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-cost-tier)))

(ert-deftest gastown-coverage-config-default-agent-class-exists ()
  "gastown-command-config-default-agent class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-default-agent)))

(ert-deftest gastown-coverage-config-get-class-exists ()
  "gastown-command-config-get class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-get)))

(ert-deftest gastown-coverage-config-set-class-exists ()
  "gastown-command-config-set class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-config-set)))

(ert-deftest gastown-coverage-config-values-menu-exists ()
  "gastown-config-values-menu transient should exist."
  (require 'gastown-command-config)
  (should (fboundp 'gastown-config-values-menu)))

(ert-deftest gastown-coverage-config-get-cli-command ()
  "gastown-command-config-get should produce 'config get' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-config-get)))
    (should (member "config" (gastown-command-line cmd)))
    (should (member "get" (gastown-command-line cmd)))))

;;; Hooks subcommand coverage

(ert-deftest gastown-coverage-hooks-base-class-exists ()
  "gastown-command-hooks-base class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-base)))

(ert-deftest gastown-coverage-hooks-diff-class-exists ()
  "gastown-command-hooks-diff class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-diff)))

(ert-deftest gastown-coverage-hooks-init-class-exists ()
  "gastown-command-hooks-init class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-init)))

(ert-deftest gastown-coverage-hooks-install-class-exists ()
  "gastown-command-hooks-install class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-install)))

(ert-deftest gastown-coverage-hooks-list-class-exists ()
  "gastown-command-hooks-list class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-list)))

(ert-deftest gastown-coverage-hooks-override-class-exists ()
  "gastown-command-hooks-override class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-override)))

(ert-deftest gastown-coverage-hooks-registry-class-exists ()
  "gastown-command-hooks-registry class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-registry)))

(ert-deftest gastown-coverage-hooks-scan-class-exists ()
  "gastown-command-hooks-scan class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-scan)))

(ert-deftest gastown-coverage-hooks-sync-class-exists ()
  "gastown-command-hooks-sync class should exist."
  (require 'gastown-command-config)
  (should (find-class 'gastown-command-hooks-sync)))

(ert-deftest gastown-coverage-hooks-menu-exists ()
  "gastown-hooks-menu transient should exist."
  (require 'gastown-command-config)
  (should (fboundp 'gastown-hooks-menu)))

(ert-deftest gastown-coverage-hooks-sync-cli-command ()
  "gastown-command-hooks-sync should produce 'hooks sync' command line."
  (require 'gastown-command-config)
  (let ((cmd (make-instance 'gastown-command-hooks-sync)))
    (should (member "hooks" (gastown-command-line cmd)))
    (should (member "sync" (gastown-command-line cmd)))))

;;; Dolt extended subcommand coverage

(ert-deftest gastown-coverage-dolt-dump-class-exists ()
  "gastown-command-dolt-dump class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-dump)))

(ert-deftest gastown-coverage-dolt-fix-metadata-class-exists ()
  "gastown-command-dolt-fix-metadata class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-fix-metadata)))

(ert-deftest gastown-coverage-dolt-flatten-class-exists ()
  "gastown-command-dolt-flatten class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-flatten)))

(ert-deftest gastown-coverage-dolt-init-class-exists ()
  "gastown-command-dolt-init class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-init)))

(ert-deftest gastown-coverage-dolt-init-rig-class-exists ()
  "gastown-command-dolt-init-rig class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-init-rig)))

(ert-deftest gastown-coverage-dolt-kill-imposters-class-exists ()
  "gastown-command-dolt-kill-imposters class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-kill-imposters)))

(ert-deftest gastown-coverage-dolt-list-class-exists ()
  "gastown-command-dolt-list class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-list)))

(ert-deftest gastown-coverage-dolt-logs-class-exists ()
  "gastown-command-dolt-logs class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-logs)))

(ert-deftest gastown-coverage-dolt-migrate-class-exists ()
  "gastown-command-dolt-migrate class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-migrate)))

(ert-deftest gastown-coverage-dolt-migrate-wisps-class-exists ()
  "gastown-command-dolt-migrate-wisps class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-migrate-wisps)))

(ert-deftest gastown-coverage-dolt-rebase-class-exists ()
  "gastown-command-dolt-rebase class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-rebase)))

(ert-deftest gastown-coverage-dolt-recover-class-exists ()
  "gastown-command-dolt-recover class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-recover)))

(ert-deftest gastown-coverage-dolt-restart-class-exists ()
  "gastown-command-dolt-restart class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-restart)))

(ert-deftest gastown-coverage-dolt-rollback-class-exists ()
  "gastown-command-dolt-rollback class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-rollback)))

(ert-deftest gastown-coverage-dolt-sql-class-exists ()
  "gastown-command-dolt-sql class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-sql)))

(ert-deftest gastown-coverage-dolt-sync-class-exists ()
  "gastown-command-dolt-sync class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-dolt-sync)))

(ert-deftest gastown-coverage-dolt-extended-transients-exist ()
  "Key extended dolt transient functions should exist."
  (require 'gastown-command-services)
  (should (fboundp 'gastown-dolt-dump))
  (should (fboundp 'gastown-dolt-logs))
  (should (fboundp 'gastown-dolt-restart))
  (should (fboundp 'gastown-dolt-sql)))

;;; Quota subcommand coverage

(ert-deftest gastown-coverage-quota-clear-class-exists ()
  "gastown-command-quota-clear class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-quota-clear)))

(ert-deftest gastown-coverage-quota-rotate-class-exists ()
  "gastown-command-quota-rotate class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-quota-rotate)))

(ert-deftest gastown-coverage-quota-scan-class-exists ()
  "gastown-command-quota-scan class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-quota-scan)))

(ert-deftest gastown-coverage-quota-status-class-exists ()
  "gastown-command-quota-status class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-quota-status)))

(ert-deftest gastown-coverage-quota-watch-class-exists ()
  "gastown-command-quota-watch class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-quota-watch)))

(ert-deftest gastown-coverage-quota-menu-exists ()
  "gastown-quota-menu transient should exist."
  (require 'gastown-command-services)
  (should (fboundp 'gastown-quota-menu)))

(ert-deftest gastown-coverage-quota-status-cli-command ()
  "gastown-command-quota-status should produce 'quota status' command line."
  (require 'gastown-command-services)
  (let ((cmd (make-instance 'gastown-command-quota-status)))
    (should (member "quota" (gastown-command-line cmd)))
    (should (member "status" (gastown-command-line cmd)))))

;;; Scheduler subcommand coverage

(ert-deftest gastown-coverage-scheduler-clear-class-exists ()
  "gastown-command-scheduler-clear class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-clear)))

(ert-deftest gastown-coverage-scheduler-list-class-exists ()
  "gastown-command-scheduler-list class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-list)))

(ert-deftest gastown-coverage-scheduler-pause-class-exists ()
  "gastown-command-scheduler-pause class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-pause)))

(ert-deftest gastown-coverage-scheduler-resume-class-exists ()
  "gastown-command-scheduler-resume class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-resume)))

(ert-deftest gastown-coverage-scheduler-run-class-exists ()
  "gastown-command-scheduler-run class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-run)))

(ert-deftest gastown-coverage-scheduler-status-class-exists ()
  "gastown-command-scheduler-status class should exist."
  (require 'gastown-command-services)
  (should (find-class 'gastown-command-scheduler-status)))

(ert-deftest gastown-coverage-scheduler-menu-exists ()
  "gastown-scheduler-menu transient should exist."
  (require 'gastown-command-services)
  (should (fboundp 'gastown-scheduler-menu)))

(ert-deftest gastown-coverage-scheduler-status-cli-command ()
  "gastown-command-scheduler-status should produce 'scheduler status' command line."
  (require 'gastown-command-services)
  (let ((cmd (make-instance 'gastown-command-scheduler-status)))
    (should (member "scheduler" (gastown-command-line cmd)))
    (should (member "status" (gastown-command-line cmd)))))

;;; Checkpoint subcommand coverage

(ert-deftest gastown-coverage-checkpoint-clear-class-exists ()
  "gastown-command-checkpoint-clear class should exist."
  (require 'gastown-command-diagnostics)
  (should (find-class 'gastown-command-checkpoint-clear)))

(ert-deftest gastown-coverage-checkpoint-read-class-exists ()
  "gastown-command-checkpoint-read class should exist."
  (require 'gastown-command-diagnostics)
  (should (find-class 'gastown-command-checkpoint-read)))

(ert-deftest gastown-coverage-checkpoint-write-class-exists ()
  "gastown-command-checkpoint-write class should exist."
  (require 'gastown-command-diagnostics)
  (should (find-class 'gastown-command-checkpoint-write)))

(ert-deftest gastown-coverage-checkpoint-menu-exists ()
  "gastown-checkpoint-menu transient should exist."
  (require 'gastown-command-diagnostics)
  (should (fboundp 'gastown-checkpoint-menu)))

(ert-deftest gastown-coverage-checkpoint-read-cli-command ()
  "gastown-command-checkpoint-read should produce 'checkpoint read' command line."
  (require 'gastown-command-diagnostics)
  (let ((cmd (make-instance 'gastown-command-checkpoint-read)))
    (should (member "checkpoint" (gastown-command-line cmd)))
    (should (member "read" (gastown-command-line cmd)))))

;;; Cycle subcommand coverage

(ert-deftest gastown-coverage-cycle-next-class-exists ()
  "gastown-command-cycle-next class should exist."
  (require 'gastown-command-diagnostics)
  (should (find-class 'gastown-command-cycle-next)))

(ert-deftest gastown-coverage-cycle-prev-class-exists ()
  "gastown-command-cycle-prev class should exist."
  (require 'gastown-command-diagnostics)
  (should (find-class 'gastown-command-cycle-prev)))

(ert-deftest gastown-coverage-cycle-next-cli-command ()
  "gastown-command-cycle-next should produce 'cycle next' command line."
  (require 'gastown-command-diagnostics)
  (let ((cmd (make-instance 'gastown-command-cycle-next)))
    (should (member "cycle" (gastown-command-line cmd)))
    (should (member "next" (gastown-command-line cmd)))))

;;; Formula overlay coverage

(ert-deftest gastown-coverage-formula-overlay-class-exists ()
  "gastown-command-formula-overlay class should exist."
  (require 'gastown-command-formula)
  (should (find-class 'gastown-command-formula-overlay)))

(ert-deftest gastown-coverage-formula-overlay-transient-exists ()
  "gastown-formula-overlay transient should exist."
  (require 'gastown-command-formula)
  (should (fboundp 'gastown-formula-overlay)))

(ert-deftest gastown-coverage-formula-overlay-cli-command ()
  "gastown-command-formula-overlay should produce 'formula overlay' command line."
  (require 'gastown-command-formula)
  (let ((cmd (make-instance 'gastown-command-formula-overlay)))
    (should (member "formula" (gastown-command-line cmd)))
    (should (member "overlay" (gastown-command-line cmd)))))

(ert-deftest gastown-coverage-formula-overlay-show-class-exists ()
  "gastown-command-formula-overlay-show class should exist."
  (require 'gastown-command-formula)
  (should (find-class 'gastown-command-formula-overlay-show)))

(ert-deftest gastown-coverage-formula-overlay-edit-class-exists ()
  "gastown-command-formula-overlay-edit class should exist."
  (require 'gastown-command-formula)
  (should (find-class 'gastown-command-formula-overlay-edit)))

(ert-deftest gastown-coverage-formula-overlay-list-class-exists ()
  "gastown-command-formula-overlay-list class should exist."
  (require 'gastown-command-formula)
  (should (find-class 'gastown-command-formula-overlay-list)))

(ert-deftest gastown-coverage-formula-overlay-menu-exists ()
  "gastown-formula-overlay-menu transient should exist."
  (require 'gastown-command-formula)
  (should (fboundp 'gastown-formula-overlay-menu)))

(ert-deftest gastown-coverage-formula-overlay-show-cli-command ()
  "gastown-command-formula-overlay-show should produce 'formula overlay show' command line."
  (require 'gastown-command-formula)
  (let ((cmd (make-instance 'gastown-command-formula-overlay-show)))
    (should (member "formula" (gastown-command-line cmd)))
    (should (member "overlay" (gastown-command-line cmd)))
    (should (member "show" (gastown-command-line cmd)))))

;;; Agents reader wiring tests

(ert-deftest gastown-coverage-agents-rig-reader-wired ()
  "gastown-command-agents rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-agents 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-witness-status-rig-reader-wired ()
  "gastown-command-witness-status rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-witness-status 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-refinery-status-rig-reader-wired ()
  "gastown-command-refinery-status rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-refinery-status 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-session-list-rig-reader-wired ()
  "gastown-command-session-list rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-list 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-witness-attach-rig-reader-wired ()
  "gastown-command-witness-attach rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-witness-attach 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-witness-start-rig-reader-wired ()
  "gastown-command-witness-start rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-witness-start 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-witness-stop-rig-reader-wired ()
  "gastown-command-witness-stop rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-witness-stop 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-refinery-attach-rig-reader-wired ()
  "gastown-command-refinery-attach rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-refinery-attach 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-refinery-start-rig-reader-wired ()
  "gastown-command-refinery-start rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-refinery-start 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-refinery-stop-rig-reader-wired ()
  "gastown-command-refinery-stop rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-refinery-stop 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-refinery-unclaimed-rig-reader-wired ()
  "gastown-command-refinery-unclaimed rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-refinery-unclaimed 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-session-check-rig-reader-wired ()
  "gastown-command-session-check rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-check 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-session-at-polecat-reader-wired ()
  "gastown-command-session-at polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-at 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-capture-polecat-reader-wired ()
  "gastown-command-session-capture polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-capture 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-inject-polecat-reader-wired ()
  "gastown-command-session-inject polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-inject 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-restart-polecat-reader-wired ()
  "gastown-command-session-restart polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-restart 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-start-polecat-reader-wired ()
  "gastown-command-session-start polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-start 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-status-polecat-reader-wired ()
  "gastown-command-session-status polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-status 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

(ert-deftest gastown-coverage-session-stop-polecat-reader-wired ()
  "gastown-command-session-stop polecat-address slot should use gastown-reader-polecat-address."
  (require 'gastown-command-agents)
  (should (eq (beads-meta-slot-property 'gastown-command-session-stop 'polecat-address
                                        :transient-reader)
              'gastown-reader-polecat-address)))

;;; Mail reader wiring tests

(ert-deftest gastown-coverage-mail-send-recipient-reader-wired ()
  "gastown-command-mail-send recipient slot should use gastown-reader-mail-address."
  (require 'gastown-command-mail)
  (should (eq (beads-meta-slot-property 'gastown-command-mail-send 'recipient
                                        :transient-reader)
              'gastown-reader-mail-address)))

(ert-deftest gastown-coverage-mail-clear-target-reader-wired ()
  "gastown-command-mail-clear target slot should use gastown-reader-mail-address."
  (require 'gastown-command-mail)
  (should (eq (beads-meta-slot-property 'gastown-command-mail-clear 'target
                                        :transient-reader)
              'gastown-reader-mail-address)))

(ert-deftest gastown-coverage-mail-search-from-reader-wired ()
  "gastown-command-mail-search from slot should use gastown-reader-mail-address."
  (require 'gastown-command-mail)
  (should (eq (beads-meta-slot-property 'gastown-command-mail-search 'from
                                        :transient-reader)
              'gastown-reader-mail-address)))

;;; Sling formula/crew reader wiring tests

(ert-deftest gastown-coverage-sling-formula-reader-wired ()
  "gastown-command-sling formula slot should use gastown-reader-formula-name."
  (require 'gastown-command-sling)
  (should (eq (beads-meta-slot-property 'gastown-command-sling 'formula
                                        :transient-reader)
              'gastown-reader-formula-name)))

(ert-deftest gastown-coverage-sling-crew-reader-wired ()
  "gastown-command-sling crew slot should use gastown-reader-crew-name."
  (require 'gastown-command-sling)
  (should (eq (beads-meta-slot-property 'gastown-command-sling 'crew
                                        :transient-reader)
              'gastown-reader-crew-name)))

;;; Rig lifecycle reader wiring tests (edge cases — start/stop/restart/reboot/status)

(ert-deftest gastown-coverage-rig-start-rig-name-reader-wired ()
  "gastown-command-rig-start rig-name slot should use gastown-reader-rig-name."
  (require 'gastown-command-rig)
  (should (eq (beads-meta-slot-property 'gastown-command-rig-start 'rig-name
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-rig-stop-rig-name-reader-wired ()
  "gastown-command-rig-stop rig-name slot should use gastown-reader-rig-name."
  (require 'gastown-command-rig)
  (should (eq (beads-meta-slot-property 'gastown-command-rig-stop 'rig-name
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-rig-restart-rig-name-reader-wired ()
  "gastown-command-rig-restart rig-name slot should use gastown-reader-rig-name."
  (require 'gastown-command-rig)
  (should (eq (beads-meta-slot-property 'gastown-command-rig-restart 'rig-name
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-rig-reboot-rig-name-reader-wired ()
  "gastown-command-rig-reboot rig-name slot should use gastown-reader-rig-name."
  (require 'gastown-command-rig)
  (should (eq (beads-meta-slot-property 'gastown-command-rig-reboot 'rig-name
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-rig-status-rig-name-reader-wired ()
  "gastown-command-rig-status rig-name slot should use gastown-reader-rig-name."
  (require 'gastown-command-rig)
  (should (eq (beads-meta-slot-property 'gastown-command-rig-status 'rig-name
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Diagnostics reader wiring tests

(ert-deftest gastown-coverage-log-rig-reader-wired ()
  "gastown-command-log rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-diagnostics)
  (should (eq (beads-meta-slot-property 'gastown-command-log 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-activity-rig-reader-wired ()
  "gastown-command-activity rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-diagnostics)
  (should (eq (beads-meta-slot-property 'gastown-command-activity 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-costs-rig-reader-wired ()
  "gastown-command-costs rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-diagnostics)
  (should (eq (beads-meta-slot-property 'gastown-command-costs 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-trail-rig-reader-wired ()
  "gastown-command-trail rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-diagnostics)
  (should (eq (beads-meta-slot-property 'gastown-command-trail 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Services reader wiring tests

(ert-deftest gastown-coverage-estop-rig-reader-wired ()
  "gastown-command-estop rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-services)
  (should (eq (beads-meta-slot-property 'gastown-command-estop 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-thaw-rig-reader-wired ()
  "gastown-command-thaw rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-services)
  (should (eq (beads-meta-slot-property 'gastown-command-thaw 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-dolt-init-rig-rig-reader-wired ()
  "gastown-command-dolt-init-rig rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-services)
  (should (eq (beads-meta-slot-property 'gastown-command-dolt-init-rig 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Workspace reader wiring tests

(ert-deftest gastown-coverage-crew-add-rig-reader-wired ()
  "gastown-command-crew-add rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-workspace)
  (should (eq (beads-meta-slot-property 'gastown-command-crew-add 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-crew-list-rig-reader-wired ()
  "gastown-command-crew-list rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-workspace)
  (should (eq (beads-meta-slot-property 'gastown-command-crew-list 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-worktree-remove-rig-reader-wired ()
  "gastown-command-worktree-remove rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-workspace)
  (should (eq (beads-meta-slot-property 'gastown-command-worktree-remove 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Polecat rig slot reader wiring tests

(ert-deftest gastown-coverage-polecat-list-rig-reader-wired ()
  "gastown-command-polecat-list rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-polecat)
  (should (eq (beads-meta-slot-property 'gastown-command-polecat-list 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-polecat-nuke-rig-reader-wired ()
  "gastown-command-polecat-nuke rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-polecat)
  (should (eq (beads-meta-slot-property 'gastown-command-polecat-nuke 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-polecat-status-rig-reader-wired ()
  "gastown-command-polecat-status rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-polecat)
  (should (eq (beads-meta-slot-property 'gastown-command-polecat-status 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Formula overlay rig reader wiring tests

(ert-deftest gastown-coverage-formula-overlay-show-rig-reader-wired ()
  "gastown-command-formula-overlay-show rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-formula)
  (should (eq (beads-meta-slot-property 'gastown-command-formula-overlay-show 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-formula-overlay-edit-rig-reader-wired ()
  "gastown-command-formula-overlay-edit rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-formula)
  (should (eq (beads-meta-slot-property 'gastown-command-formula-overlay-edit 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Config directive rig reader wiring tests

(ert-deftest gastown-coverage-directive-show-rig-reader-wired ()
  "gastown-command-directive-show rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-config)
  (should (eq (beads-meta-slot-property 'gastown-command-directive-show 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-directive-edit-rig-reader-wired ()
  "gastown-command-directive-edit rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-config)
  (should (eq (beads-meta-slot-property 'gastown-command-directive-edit 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Unsling agent-target reader wiring test

(ert-deftest gastown-coverage-unsling-target-reader-wired ()
  "gastown-command-unsling target slot should use gastown-reader-agent-target."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-unsling 'target
                                        :transient-reader)
              'gastown-reader-agent-target)))

;;; WL rig reader wiring tests

(ert-deftest gastown-coverage-wl-charsheet-rig-reader-wired ()
  "gastown-command-wl-charsheet rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-wl)
  (should (eq (beads-meta-slot-property 'gastown-command-wl-charsheet 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-wl-join-rig-reader-wired ()
  "gastown-command-wl-join rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-wl)
  (should (eq (beads-meta-slot-property 'gastown-command-wl-join 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

;;; Sling 'on' slot reader wiring test

(ert-deftest gastown-coverage-sling-on-reader-wired ()
  "gastown-command-sling on slot should use gastown-reader-bead-id."
  (require 'gastown-command-sling)
  (should (eq (beads-meta-slot-property 'gastown-command-sling 'on
                                        :transient-reader)
              'gastown-reader-bead-id)))

;;; MQ next/reject/retry/status/submit reader wiring tests

(ert-deftest gastown-coverage-mq-next-rig-reader-wired ()
  "gastown-command-mq-next rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-next 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-mq-reject-rig-reader-wired ()
  "gastown-command-mq-reject rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-reject 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-mq-reject-mr-id-reader-wired ()
  "gastown-command-mq-reject mr-id slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-reject 'mr-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-mq-retry-rig-reader-wired ()
  "gastown-command-mq-retry rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-retry 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-mq-retry-mr-id-reader-wired ()
  "gastown-command-mq-retry mr-id slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-retry 'mr-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-mq-status-mr-id-reader-wired ()
  "gastown-command-mq-status mr-id slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-status 'mr-id
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-mq-submit-issue-reader-wired ()
  "gastown-command-mq-submit issue slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-submit 'issue
                                        :transient-reader)
              'gastown-reader-bead-id)))

(ert-deftest gastown-coverage-mq-submit-epic-reader-wired ()
  "gastown-command-mq-submit epic slot should use gastown-reader-bead-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-mq-submit 'epic
                                        :transient-reader)
              'gastown-reader-bead-id)))

;;; Synthesis command reader wiring tests

(ert-deftest gastown-coverage-synthesis-start-convoy-id-reader-wired ()
  "gastown-command-synthesis-start convoy-id slot should use gastown-reader-convoy-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-synthesis-start 'convoy-id
                                        :transient-reader)
              'gastown-reader-convoy-id)))

(ert-deftest gastown-coverage-synthesis-start-rig-reader-wired ()
  "gastown-command-synthesis-start rig slot should use gastown-reader-rig-name."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-synthesis-start 'rig
                                        :transient-reader)
              'gastown-reader-rig-name)))

(ert-deftest gastown-coverage-synthesis-status-convoy-id-reader-wired ()
  "gastown-command-synthesis-status convoy-id slot should use gastown-reader-convoy-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-synthesis-status 'convoy-id
                                        :transient-reader)
              'gastown-reader-convoy-id)))

(ert-deftest gastown-coverage-synthesis-close-convoy-id-reader-wired ()
  "gastown-command-synthesis-close convoy-id slot should use gastown-reader-convoy-id."
  (require 'gastown-command-work)
  (should (eq (beads-meta-slot-property 'gastown-command-synthesis-close 'convoy-id
                                        :transient-reader)
              'gastown-reader-convoy-id)))

(provide 'gastown-command-coverage-test)
;;; gastown-command-coverage-test.el ends here
