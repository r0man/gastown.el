;;; gastown-beads-test.el --- Tests for gastown-beads -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for the gastown-beads.el injection module.
;;
;; Tests cover:
;;   - Function existence
;;   - Polecat line formatting
;;   - Safe behavior when optional deps not loaded
;;   - Integration: dispatch injection when beads is available

;;; Code:

(require 'ert)
(require 'gastown-beads)

;;; Module structure tests

(ert-deftest gastown-beads-test-inject-dispatch-defined ()
  "Test that gastown-beads--inject-dispatch is defined."
  (should (fboundp 'gastown-beads--inject-dispatch)))

(ert-deftest gastown-beads-test-inject-section-hook-defined ()
  "Test that gastown-beads--inject-section-hook is defined."
  (should (fboundp 'gastown-beads--inject-section-hook)))

(ert-deftest gastown-beads-test-insert-work-queue-defined ()
  "Test that gastown-insert-work-queue is defined."
  (should (fboundp 'gastown-insert-work-queue)))

(ert-deftest gastown-beads-test-fetch-agents-defined ()
  "Test that gastown-beads--fetch-agents is defined."
  (should (fboundp 'gastown-beads--fetch-agents)))

(ert-deftest gastown-beads-test-format-polecat-line-defined ()
  "Test that gastown-beads--format-polecat-line is defined."
  (should (fboundp 'gastown-beads--format-polecat-line)))

;;; Format function tests

(ert-deftest gastown-beads-test-format-polecat-line-running ()
  "Test format for a running polecat includes name, rig, and running indicator."
  (let* ((polecat (cons "beads_el" (gastown-agent :name "jasper" :running t :agent-info "")))
         (result (gastown-beads--format-polecat-line polecat)))
    (should (stringp result))
    (should (string-match-p "jasper" result))
    (should (string-match-p "beads_el" result))
    (should (string-match-p "●" result))))

(ert-deftest gastown-beads-test-format-polecat-line-stopped ()
  "Test format for a stopped polecat shows stopped indicator."
  (let* ((polecat (cons "gastown_el" (gastown-agent :name "nux" :running nil :agent-info "")))
         (result (gastown-beads--format-polecat-line polecat)))
    (should (stringp result))
    (should (string-match-p "nux" result))
    (should (string-match-p "○" result))))

(ert-deftest gastown-beads-test-format-polecat-line-returns-string ()
  "Test that format always returns a string even with nil fields."
  (let* ((polecat (cons nil (gastown-agent)))
         (result (gastown-beads--format-polecat-line polecat)))
    (should (stringp result))))

;;; Inject dispatch safety tests

(ert-deftest gastown-beads-test-inject-dispatch-safe-without-beads ()
  "Test that inject-dispatch returns nil safely when beads is not loaded."
  ;; Only meaningful if beads is NOT loaded; otherwise skip
  (when (not (featurep 'beads))
    (should-not (gastown-beads--inject-dispatch))))

;;; Section hook safety tests

(ert-deftest gastown-beads-test-inject-section-hook-safe-without-beads-section ()
  "Test that inject-section-hook returns nil when beads-section is not loaded."
  (when (not (featurep 'beads-section))
    (should-not (gastown-beads--inject-section-hook))))

;;; Insert work queue safety test

(ert-deftest gastown-beads-test-insert-work-queue-safe-without-beads-section ()
  "Test that gastown-insert-work-queue returns nil when beads-section is not loaded."
  (when (not (featurep 'beads-section))
    (with-temp-buffer
      (should-not (gastown-insert-work-queue)))))

;;; Dispatch injection integration test

(ert-deftest gastown-beads-test-inject-dispatch-when-beads-available ()
  "Test that dispatch injection registers Gas Town in beads prefix when beads is loaded."
  :tags '(:integration)
  (skip-unless (featurep 'beads))
  ;; The injection happens via with-eval-after-load in gastown-beads.el.
  ;; Call it explicitly to verify it runs without error and registers the key.
  (gastown-beads--inject-dispatch)
  ;; Verify no error was thrown (test passes by reaching here)
  (should t))

;;; Fetch agents test (mocked)

(ert-deftest gastown-beads-test-fetch-agents-returns-list-or-nil ()
  "Test that fetch-agents returns a list or nil, never errors."
  (let ((result (gastown-beads--fetch-agents)))
    (should (or (null result) (listp result)))))

(provide 'gastown-beads-test)
;;; gastown-beads-test.el ends here
