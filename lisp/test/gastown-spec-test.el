;;; gastown-spec-test.el --- Tests for gastown-spec -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for gastown-spec.el: filter spec objects for list views.

;;; Code:

(require 'ert)
(require 'gastown-spec)

;;; ============================================================
;;; gastown-agent-spec
;;; ============================================================

(ert-deftest gastown-spec-test-agent-spec-default-slots ()
  "Default agent spec has nil rig, role, running, and name order."
  (let ((spec (gastown-agent-spec)))
    (should (null (oref spec rig)))
    (should (null (oref spec role)))
    (should (null (oref spec running)))
    (should (eq 'name (oref spec order)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-empty ()
  "Empty agent spec produces empty args list."
  (let ((spec (gastown-agent-spec)))
    (should (equal '() (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-rig ()
  "Agent spec with rig produces --rig= arg."
  (let ((spec (gastown-agent-spec :rig "beads_el")))
    (should (member "--rig=beads_el" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-role ()
  "Agent spec with role produces --role= arg."
  (let ((spec (gastown-agent-spec :role "polecat")))
    (should (member "--role=polecat" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-running-true ()
  "Agent spec with running t produces --running arg."
  (let ((spec (gastown-agent-spec :running t)))
    (should (member "--running" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-running-nil ()
  "Agent spec with running nil produces no running arg."
  (let ((spec (gastown-agent-spec :running nil)))
    (should (not (member "--running" (gastown-spec--to-args spec))))))

(ert-deftest gastown-spec-test-agent-spec-to-args-order-non-default ()
  "Agent spec with non-default order produces --order= arg."
  (let ((spec (gastown-agent-spec :order 'rig)))
    (should (member "--order=rig" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-agent-spec-to-args-order-default-omitted ()
  "Agent spec with default 'name order does not produce --order arg."
  (let ((spec (gastown-agent-spec :order 'name)))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--order" a))
                             (gastown-spec--to-args spec))))))

(ert-deftest gastown-spec-test-agent-spec-to-args-combined ()
  "Agent spec with multiple fields produces all corresponding args."
  (let* ((spec (gastown-agent-spec :rig "gastown_el" :role "witness" :running t))
         (args (gastown-spec--to-args spec)))
    (should (member "--rig=gastown_el" args))
    (should (member "--role=witness" args))
    (should (member "--running" args))))

;;; ============================================================
;;; gastown-rig-spec
;;; ============================================================

(ert-deftest gastown-spec-test-rig-spec-default-slots ()
  "Default rig spec has nil status and name order."
  (let ((spec (gastown-rig-spec)))
    (should (null (oref spec status)))
    (should (eq 'name (oref spec order)))))

(ert-deftest gastown-spec-test-rig-spec-to-args-empty ()
  "Empty rig spec produces empty args list."
  (let ((spec (gastown-rig-spec)))
    (should (equal '() (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-rig-spec-to-args-status ()
  "Rig spec with status produces --status= arg."
  (let ((spec (gastown-rig-spec :status "operational")))
    (should (member "--status=operational" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-rig-spec-to-args-order-non-default ()
  "Rig spec with non-default order produces --order= arg."
  (let ((spec (gastown-rig-spec :order 'status)))
    (should (member "--order=status" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-rig-spec-to-args-order-default-omitted ()
  "Rig spec with default 'name order does not produce --order arg."
  (let ((spec (gastown-rig-spec :order 'name)))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--order" a))
                             (gastown-spec--to-args spec))))))

;;; ============================================================
;;; gastown-convoy-spec
;;; ============================================================

(ert-deftest gastown-spec-test-convoy-spec-default-slots ()
  "Default convoy spec has nil status."
  (let ((spec (gastown-convoy-spec)))
    (should (null (oref spec status)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-empty ()
  "Empty convoy spec produces empty args list."
  (let* ((spec (gastown-convoy-spec))
         (args (gastown-spec--to-args spec)))
    (should (equal '() args))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-status ()
  "Convoy spec with status produces --status= arg."
  (let ((spec (gastown-convoy-spec :status "open")))
    (should (member "--status=open" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-status-closed ()
  "Convoy spec with closed status produces --status=closed arg."
  (let ((spec (gastown-convoy-spec :status "closed")))
    (should (member "--status=closed" (gastown-spec--to-args spec)))))

;;; ============================================================
;;; gastown-mail-spec
;;; ============================================================

(ert-deftest gastown-spec-test-mail-spec-default-slots ()
  "Default mail spec has nil unread-only."
  (let ((spec (gastown-mail-spec)))
    (should (null (oref spec unread-only)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-empty ()
  "Empty mail spec produces empty args list."
  (let* ((spec (gastown-mail-spec))
         (args (gastown-spec--to-args spec)))
    (should (equal '() args))
    (should (not (member "--unread" args)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-unread-only ()
  "Mail spec with unread-only t produces --unread arg."
  (let ((spec (gastown-mail-spec :unread-only t)))
    (should (member "--unread" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-unread-nil ()
  "Mail spec with unread-only nil produces no --unread arg."
  (let ((spec (gastown-mail-spec :unread-only nil)))
    (should (not (member "--unread" (gastown-spec--to-args spec))))))

(ert-deftest gastown-spec-test-mail-spec-to-args-all ()
  "Mail spec with all t produces --all arg."
  (let ((spec (gastown-mail-spec :all t)))
    (should (member "--all" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-all-nil ()
  "Mail spec with all nil produces no --all arg."
  (let ((spec (gastown-mail-spec :all nil)))
    (should (not (member "--all" (gastown-spec--to-args spec))))))

;;; ============================================================
;;; defcustom defaults
;;; ============================================================

(ert-deftest gastown-spec-test-default-agent-spec-is-spec ()
  "gastown-default-agent-spec is a gastown-agent-spec."
  (should (gastown-agent-spec-p gastown-default-agent-spec)))

(ert-deftest gastown-spec-test-default-rig-spec-is-spec ()
  "gastown-default-rig-spec is a gastown-rig-spec."
  (should (gastown-rig-spec-p gastown-default-rig-spec)))

(ert-deftest gastown-spec-test-default-convoy-spec-is-spec ()
  "gastown-default-convoy-spec is a gastown-convoy-spec."
  (should (gastown-convoy-spec-p gastown-default-convoy-spec)))

(ert-deftest gastown-spec-test-default-mail-spec-is-spec ()
  "gastown-default-mail-spec is a gastown-mail-spec."
  (should (gastown-mail-spec-p gastown-default-mail-spec)))

;;; ============================================================
;;; Buffer-local spec variables
;;; ============================================================

(ert-deftest gastown-spec-test-buffer-local-agent-spec ()
  "gastown-current-agent-spec is automatically buffer-local and defaults to nil."
  (with-temp-buffer
    (should (local-variable-if-set-p 'gastown-current-agent-spec))
    (should (null gastown-current-agent-spec))))

(ert-deftest gastown-spec-test-buffer-local-rig-spec ()
  "gastown-current-rig-spec is automatically buffer-local and defaults to nil."
  (with-temp-buffer
    (should (local-variable-if-set-p 'gastown-current-rig-spec))
    (should (null gastown-current-rig-spec))))

(ert-deftest gastown-spec-test-buffer-local-convoy-spec ()
  "gastown-current-convoy-spec is automatically buffer-local and defaults to nil."
  (with-temp-buffer
    (should (local-variable-if-set-p 'gastown-current-convoy-spec))
    (should (null gastown-current-convoy-spec))))

(ert-deftest gastown-spec-test-buffer-local-mail-spec ()
  "gastown-current-mail-spec is automatically buffer-local and defaults to nil."
  (with-temp-buffer
    (should (local-variable-if-set-p 'gastown-current-mail-spec))
    (should (null gastown-current-mail-spec))))

;;; ============================================================
;;; Effective Spec Accessor Tests (ge-3y8 regression)
;;; ============================================================

(ert-deftest gastown-spec-test-effective-agent-spec-returns-spec ()
  "gastown-effective-agent-spec returns a gastown-agent-spec."
  (with-temp-buffer
    (should (gastown-agent-spec-p (gastown-effective-agent-spec)))))

(ert-deftest gastown-spec-test-effective-rig-spec-returns-spec ()
  "gastown-effective-rig-spec returns a gastown-rig-spec."
  (with-temp-buffer
    (should (gastown-rig-spec-p (gastown-effective-rig-spec)))))

(ert-deftest gastown-spec-test-effective-convoy-spec-returns-spec ()
  "gastown-effective-convoy-spec returns a gastown-convoy-spec."
  (with-temp-buffer
    (should (gastown-convoy-spec-p (gastown-effective-convoy-spec)))))

(ert-deftest gastown-spec-test-effective-mail-spec-returns-spec ()
  "gastown-effective-mail-spec returns a gastown-mail-spec."
  (with-temp-buffer
    (should (gastown-mail-spec-p (gastown-effective-mail-spec)))))

(ert-deftest gastown-spec-test-effective-agent-spec-returns-buffer-local ()
  "gastown-effective-agent-spec returns buffer-local spec when set."
  (with-temp-buffer
    (let ((local-spec (gastown-agent-spec :rig "my-rig")))
      (setq gastown-current-agent-spec local-spec)
      (should (eq local-spec (gastown-effective-agent-spec))))))

(ert-deftest gastown-spec-test-effective-rig-spec-returns-buffer-local ()
  "gastown-effective-rig-spec returns buffer-local spec when set."
  (with-temp-buffer
    (let ((local-spec (gastown-rig-spec :status "operational")))
      (setq gastown-current-rig-spec local-spec)
      (should (eq local-spec (gastown-effective-rig-spec))))))

(ert-deftest gastown-spec-test-effective-agent-spec-clones-default ()
  "gastown-effective-agent-spec returns a fresh clone when no buffer-local spec.
Regression for ge-3y8: direct access to gastown-default-agent-spec exposed
the shared mutable object, so oset mutations would be permanent and global."
  (with-temp-buffer
    (let ((a (gastown-effective-agent-spec))
          (b (gastown-effective-agent-spec)))
      ;; Two calls return different objects (not the same shared instance)
      (should (not (eq a b)))
      ;; Mutating one does not affect the other
      (oset a :rig "mutated")
      (should (not (equal (oref a :rig) (oref b :rig))))
      ;; The global default is unchanged
      (should (not (equal "mutated" (oref gastown-default-agent-spec :rig)))))))

(ert-deftest gastown-spec-test-effective-rig-spec-clones-default ()
  "gastown-effective-rig-spec returns a fresh clone when no buffer-local spec."
  (with-temp-buffer
    (let ((a (gastown-effective-rig-spec))
          (b (gastown-effective-rig-spec)))
      (should (not (eq a b))))))

(ert-deftest gastown-spec-test-effective-convoy-spec-clones-default ()
  "gastown-effective-convoy-spec returns a fresh clone when no buffer-local spec."
  (with-temp-buffer
    (let ((a (gastown-effective-convoy-spec))
          (b (gastown-effective-convoy-spec)))
      (should (not (eq a b))))))

(ert-deftest gastown-spec-test-effective-mail-spec-clones-default ()
  "gastown-effective-mail-spec returns a fresh clone when no buffer-local spec."
  (with-temp-buffer
    (let ((a (gastown-effective-mail-spec))
          (b (gastown-effective-mail-spec)))
      (should (not (eq a b))))))

(provide 'gastown-spec-test)
;;; gastown-spec-test.el ends here
