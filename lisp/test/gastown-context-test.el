;;; gastown-context-test.el --- Tests for gastown-context -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for gastown-context.el — context-aware command helpers.
;;
;; Tests cover:
;;   - Function existence
;;   - gastown--beads-issue-at-point safe wrapper
;;   - gastown-agent-at-point for polecat and agent sections
;;   - Reader functions: gastown-reader-bead-id, gastown-reader-agent-target
;;   - gastown--read-bead-or-prompt and gastown--read-agent-or-prompt

;;; Code:

(require 'ert)
(require 'gastown-context)

;;; ============================================================
;;; Module structure tests
;;; ============================================================

(ert-deftest gastown-context-test-read-bead-or-prompt-defined ()
  "Test that gastown--read-bead-or-prompt is defined."
  (should (fboundp 'gastown--read-bead-or-prompt)))

(ert-deftest gastown-context-test-read-agent-or-prompt-defined ()
  "Test that gastown--read-agent-or-prompt is defined."
  (should (fboundp 'gastown--read-agent-or-prompt)))

(ert-deftest gastown-context-test-beads-issue-at-point-defined ()
  "Test that gastown--beads-issue-at-point is defined."
  (should (fboundp 'gastown--beads-issue-at-point)))

(ert-deftest gastown-context-test-agent-at-point-defined ()
  "Test that gastown-agent-at-point is defined."
  (should (fboundp 'gastown-agent-at-point)))

(ert-deftest gastown-context-test-reader-bead-id-defined ()
  "Test that gastown-reader-bead-id is defined."
  (should (fboundp 'gastown-reader-bead-id)))

(ert-deftest gastown-context-test-reader-agent-target-defined ()
  "Test that gastown-reader-agent-target is defined."
  (should (fboundp 'gastown-reader-agent-target)))

;;; ============================================================
;;; gastown--beads-issue-at-point tests
;;; ============================================================

(ert-deftest gastown-context-test-beads-issue-at-point-nil-when-unavailable ()
  "Test that gastown--beads-issue-at-point returns nil when beads-issue-at-point unavailable."
  ;; Temporarily unbind beads-issue-at-point to simulate unavailability.
  ;; cl-letf cannot be used here because it keeps the symbol fbound, so we
  ;; manually save, unbind, test, and restore.
  (let* ((was-bound (fboundp 'beads-issue-at-point))
         (saved-fn  (when was-bound (symbol-function 'beads-issue-at-point))))
    (when was-bound (fmakunbound 'beads-issue-at-point))
    (unwind-protect
        (should (null (gastown--beads-issue-at-point)))
      (when (and was-bound saved-fn)
        (fset 'beads-issue-at-point saved-fn)))))

(ert-deftest gastown-context-test-beads-issue-at-point-returns-string-or-nil ()
  "Test that gastown--beads-issue-at-point returns a string or nil."
  (let ((result (gastown--beads-issue-at-point)))
    (should (or (null result) (stringp result)))))

;;; ============================================================
;;; gastown-agent-at-point tests
;;; ============================================================

(ert-deftest gastown-context-test-agent-at-point-nil-outside-gastown-buffer ()
  "Test that gastown-agent-at-point returns nil in a non-gastown buffer."
  (with-temp-buffer
    (should (null (gastown-agent-at-point)))))

(ert-deftest gastown-context-test-agent-at-point-nil-when-no-section ()
  "Test that gastown-agent-at-point returns nil when magit-current-section is nil."
  (cl-letf (((symbol-function 'magit-current-section)
             (lambda () nil)))
    (should (null (gastown-agent-at-point)))))

(ert-deftest gastown-context-test-agent-at-point-polecat-section ()
  "Test gastown-agent-at-point on a gastown-polecat-section."
  (require 'gastown-status-buffer)
  (let* ((agent '((name . "nux") (role . "polecat") (running . t)))
         (section (make-instance 'gastown-polecat-section
                                 :polecat agent
                                 :rig-name "gastown_el")))
    (cl-letf (((symbol-function 'magit-current-section)
               (lambda () section)))
      (let ((result (gastown-agent-at-point)))
        (should (stringp result))
        (should (string= result "gastown_el/nux"))))))

(ert-deftest gastown-context-test-agent-at-point-polecat-section-missing-rig ()
  "Test gastown-agent-at-point on polecat section with nil rig-name returns nil."
  (require 'gastown-status-buffer)
  (let* ((agent '((name . "nux") (role . "polecat") (running . t)))
         (section (make-instance 'gastown-polecat-section
                                 :polecat agent
                                 :rig-name nil)))
    (cl-letf (((symbol-function 'magit-current-section)
               (lambda () section)))
      (should (null (gastown-agent-at-point))))))

(ert-deftest gastown-context-test-agent-at-point-agent-section-global ()
  "Test gastown-agent-at-point on a global gastown-agent-section (no parent rig)."
  (require 'gastown-status-buffer)
  (let* ((agent '((name . "mayor") (role . "coordinator") (running . t)))
         (section (make-instance 'gastown-agent-section
                                 :agent agent)))
    (cl-letf (((symbol-function 'magit-current-section)
               (lambda () section)))
      (let ((result (gastown-agent-at-point)))
        (should (stringp result))
        (should (string= result "mayor"))))))

(ert-deftest gastown-context-test-agent-at-point-agent-section-with-rig ()
  "Test gastown-agent-at-point on a rig-scoped gastown-agent-section."
  (require 'gastown-status-buffer)
  (let* ((rig '((name . "gastown_el")))
         (parent-section (make-instance 'gastown-rig-section :rig rig))
         (agent '((name . "witness") (role . "witness") (running . t)))
         ;; magit-section inherits `parent' but without :initarg, so use oset
         (section (make-instance 'gastown-agent-section :agent agent)))
    (oset section parent parent-section)
    (cl-letf (((symbol-function 'magit-current-section)
               (lambda () section)))
      (let ((result (gastown-agent-at-point)))
        (should (stringp result))
        (should (string= result "gastown_el/witness"))))))

;;; ============================================================
;;; gastown--read-bead-or-prompt tests
;;; ============================================================

(ert-deftest gastown-context-test-read-bead-uses-context-when-available ()
  "Test gastown--read-bead-or-prompt uses bead at point when available."
  (cl-letf (((symbol-function 'gastown--beads-issue-at-point)
             (lambda () "ge-123")))
    (should (string= (gastown--read-bead-or-prompt "ID: ") "ge-123"))))

(ert-deftest gastown-context-test-read-bead-prompts-when-no-context ()
  "Test gastown--read-bead-or-prompt prompts when no bead at point."
  (cl-letf (((symbol-function 'gastown--beads-issue-at-point)
             (lambda () nil))
            ((symbol-function 'read-string)
             (lambda (prompt &rest _) (concat "user-input-" prompt))))
    (let ((result (gastown--read-bead-or-prompt "Bead ID: ")))
      (should (string-match-p "user-input" result)))))

;;; ============================================================
;;; gastown--read-agent-or-prompt tests
;;; ============================================================

(ert-deftest gastown-context-test-read-agent-uses-context-when-available ()
  "Test gastown--read-agent-or-prompt uses agent at point when available."
  (cl-letf (((symbol-function 'gastown-agent-at-point)
             (lambda () "gastown_el/nux")))
    (should (string= (gastown--read-agent-or-prompt "Target: ") "gastown_el/nux"))))

(ert-deftest gastown-context-test-read-agent-prompts-when-no-context ()
  "Test gastown--read-agent-or-prompt prompts when no agent at point."
  (cl-letf (((symbol-function 'gastown-agent-at-point)
             (lambda () nil))
            ((symbol-function 'read-string)
             (lambda (prompt &rest _) (concat "agent-" prompt))))
    (let ((result (gastown--read-agent-or-prompt "Target: ")))
      (should (string-match-p "agent-" result)))))

;;; ============================================================
;;; Reader function tests (transient protocol)
;;; ============================================================

(ert-deftest gastown-context-test-reader-bead-id-uses-context ()
  "Test gastown-reader-bead-id returns context bead id when available."
  (cl-letf (((symbol-function 'gastown--beads-issue-at-point)
             (lambda () "ge-abc")))
    (let ((result (gastown-reader-bead-id "Bead ID: " nil nil)))
      (should (string= result "ge-abc")))))

(ert-deftest gastown-context-test-reader-bead-id-prompts-without-context ()
  "Test gastown-reader-bead-id prompts when no context."
  (cl-letf (((symbol-function 'gastown--beads-issue-at-point)
             (lambda () nil))
            ((symbol-function 'read-string)
             (lambda (_prompt &rest _) "typed-id")))
    (let ((result (gastown-reader-bead-id "Bead ID: " nil nil)))
      (should (string= result "typed-id")))))

(ert-deftest gastown-context-test-reader-agent-target-uses-context ()
  "Test gastown-reader-agent-target returns context agent when available."
  (cl-letf (((symbol-function 'gastown-agent-at-point)
             (lambda () "beads_el/nux")))
    (let ((result (gastown-reader-agent-target "Target: " nil nil)))
      (should (string= result "beads_el/nux")))))

(ert-deftest gastown-context-test-reader-agent-target-prompts-without-context ()
  "Test gastown-reader-agent-target prompts when no context."
  (cl-letf (((symbol-function 'gastown-agent-at-point)
             (lambda () nil))
            ((symbol-function 'read-string)
             (lambda (_prompt &rest _) "entered-target")))
    (let ((result (gastown-reader-agent-target "Target: " nil nil)))
      (should (string= result "entered-target")))))

(provide 'gastown-context-test)
;;; gastown-context-test.el ends here
