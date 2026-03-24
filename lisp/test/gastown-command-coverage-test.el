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

(provide 'gastown-command-coverage-test)
;;; gastown-command-coverage-test.el ends here
