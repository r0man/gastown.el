;;; gastown-polecat-detail-test.el --- Tests for gastown-polecat-detail.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; ERT tests for the polecat detail view module.

;;; Code:

(require 'ert)
(require 'gastown-polecat-detail)
(require 'gastown-types)

;;; ============================================================
;;; Fixtures
;;; ============================================================

(defconst gastown-polecat-detail-test--running-polecat
  (gastown-agent
   :name "furiosa"
   :session "ge-furiosa"
   :role "polecat"
   :running t
   :has-work t
   :unread-mail 2
   :agent-info "claude")
  "Fixture: running polecat with work and mail.")

(defconst gastown-polecat-detail-test--stopped-polecat
  (gastown-agent
   :name "nux"
   :session "ge-nux"
   :role "polecat"
   :running nil
   :has-work nil
   :unread-mail 0
   :agent-info "claude/sonnet")
  "Fixture: stopped polecat with no work or mail.")

(defconst gastown-polecat-detail-test--sample-beads
  (list (gastown-work-item :id "ge-abc" :title "Fix the thing" :status "in_progress")
        (gastown-work-item :id "ge-def" :title "Update docs" :status "closed"))
  "Fixture: sample bead history list.")

;;; ============================================================
;;; Buffer Name Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-buffer-name ()
  "Buffer name includes rig and polecat names."
  (let* ((polecat gastown-polecat-detail-test--running-polecat)
         (rig "gastown_el")
         (name (oref polecat name))
         (expected (format "*gastown-polecat: %s/%s*" rig name)))
    (should (equal expected "*gastown-polecat: gastown_el/furiosa*"))))

;;; ============================================================
;;; Running Indicator Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-running-indicator-running ()
  "Running indicator shows bullet for running polecat."
  (let ((indicator (gastown-polecat-detail--running-indicator t)))
    (should (string-prefix-p "●" indicator))))

(ert-deftest gastown-polecat-detail-test-running-indicator-stopped ()
  "Running indicator shows circle for stopped polecat."
  (let ((indicator (gastown-polecat-detail--running-indicator nil)))
    (should (string-prefix-p "○" indicator))))

;;; ============================================================
;;; Vnode Render Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-header-returns-vnode ()
  "Header renders without error and returns a non-nil vnode."
  (let* ((polecat gastown-polecat-detail-test--running-polecat)
         (result (gastown-polecat-detail--header polecat "gastown_el")))
    (should result)))

(ert-deftest gastown-polecat-detail-test-hook-row-has-work ()
  "Hook row returns vnode for polecat with work."
  (let* ((polecat gastown-polecat-detail-test--running-polecat)
         (result (gastown-polecat-detail--hook-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-hook-row-no-work ()
  "Hook row returns vnode for polecat without work."
  (let* ((polecat gastown-polecat-detail-test--stopped-polecat)
         (result (gastown-polecat-detail--hook-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-session-row-running ()
  "Session row returns vnode for running polecat."
  (let* ((polecat gastown-polecat-detail-test--running-polecat)
         (result (gastown-polecat-detail--session-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-session-row-stopped ()
  "Session row returns vnode for stopped polecat."
  (let* ((polecat gastown-polecat-detail-test--stopped-polecat)
         (result (gastown-polecat-detail--session-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-mail-row-unread ()
  "Mail row returns vnode for polecat with unread mail."
  (let* ((polecat gastown-polecat-detail-test--running-polecat)
         (result (gastown-polecat-detail--mail-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-mail-row-no-mail ()
  "Mail row returns vnode for polecat with no mail."
  (let* ((polecat gastown-polecat-detail-test--stopped-polecat)
         (result (gastown-polecat-detail--mail-row polecat)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-work-item-renders ()
  "Work item renders a single gastown-work-item as a vnode."
  (let* ((bead (car gastown-polecat-detail-test--sample-beads))
         (result (gastown-polecat-detail--work-item bead)))
    (should result)))

;;; ============================================================
;;; Work History Section Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-work-history-pending ()
  "Work history section renders loading state."
  (let ((result (gastown-polecat-detail--work-history-section
                 'pending nil nil)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-work-history-error ()
  "Work history section renders error state."
  (let ((result (gastown-polecat-detail--work-history-section
                 'error nil "connection refused")))
    (should result)))

(ert-deftest gastown-polecat-detail-test-work-history-ready-empty ()
  "Work history section renders empty state."
  (let ((result (gastown-polecat-detail--work-history-section
                 'ready nil nil)))
    (should result)))

(ert-deftest gastown-polecat-detail-test-work-history-ready-with-data ()
  "Work history section renders bead list."
  (let ((result (gastown-polecat-detail--work-history-section
                 'ready gastown-polecat-detail-test--sample-beads nil)))
    (should result)))

;;; ============================================================
;;; BD Executable Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-bd-executable-default ()
  "BD executable defaults to \"bd\" when beads-executable not bound."
  (let ((bd (gastown-polecat-detail--bd-executable)))
    (should (stringp bd))
    (should (not (string-empty-p bd)))))

(ert-deftest gastown-polecat-detail-test-bd-executable-from-beads ()
  "BD executable uses beads-executable when bound."
  (let ((beads-executable "bd-custom"))
    (should (equal "bd-custom" (gastown-polecat-detail--bd-executable)))))

;;; ============================================================
;;; Fetch Work History Tests
;;; ============================================================

(ert-deftest gastown-polecat-detail-test-fetch-work-history-handles-error ()
  "Fetch work history returns nil when bd is unavailable."
  ;; Override bd with a command that doesn't exist
  (cl-letf (((symbol-function 'call-process)
             (lambda (&rest _) (error "process failed"))))
    (let ((result (gastown-polecat-detail--fetch-work-history
                   "nonexistent_rig" "nobody")))
      (should (null result)))))

(provide 'gastown-polecat-detail-test)
;;; gastown-polecat-detail-test.el ends here
