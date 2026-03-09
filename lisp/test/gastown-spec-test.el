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
  "Default convoy spec has nil status, newest order, and 50 limit."
  (let ((spec (gastown-convoy-spec)))
    (should (null (oref spec status)))
    (should (eq 'newest (oref spec order)))
    (should (= 50 (oref spec limit)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-empty ()
  "Convoy spec with all defaults produces only the --limit arg."
  (let* ((spec (gastown-convoy-spec))
         (args (gastown-spec--to-args spec)))
    (should (member "--limit=50" args))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--status" a)) args)))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--order" a)) args)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-status ()
  "Convoy spec with status produces --status= arg."
  (let ((spec (gastown-convoy-spec :status "open")))
    (should (member "--status=open" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-order-oldest ()
  "Convoy spec with oldest order produces --order=oldest arg."
  (let ((spec (gastown-convoy-spec :order 'oldest)))
    (should (member "--order=oldest" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-convoy-spec-to-args-limit ()
  "Convoy spec with custom limit produces --limit= arg."
  (let ((spec (gastown-convoy-spec :limit 10)))
    (should (member "--limit=10" (gastown-spec--to-args spec)))))

;;; ============================================================
;;; gastown-mail-spec
;;; ============================================================

(ert-deftest gastown-spec-test-mail-spec-default-slots ()
  "Default mail spec has nil unread-only, from, priority, newest order, 100 limit."
  (let ((spec (gastown-mail-spec)))
    (should (null (oref spec unread-only)))
    (should (null (oref spec from)))
    (should (null (oref spec priority)))
    (should (eq 'newest (oref spec order)))
    (should (= 100 (oref spec limit)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-empty ()
  "Mail spec with all defaults produces only the --limit arg."
  (let* ((spec (gastown-mail-spec))
         (args (gastown-spec--to-args spec)))
    (should (member "--limit=100" args))
    (should (not (member "--unread" args)))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--from" a)) args)))
    (should (not (seq-filter (lambda (a) (string-prefix-p "--priority" a)) args)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-unread-only ()
  "Mail spec with unread-only t produces --unread arg."
  (let ((spec (gastown-mail-spec :unread-only t)))
    (should (member "--unread" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-from ()
  "Mail spec with from produces --from= arg."
  (let ((spec (gastown-mail-spec :from "gastown_el/witness")))
    (should (member "--from=gastown_el/witness" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-priority ()
  "Mail spec with priority produces --priority= arg."
  (let ((spec (gastown-mail-spec :priority "high")))
    (should (member "--priority=high" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-order-oldest ()
  "Mail spec with oldest order produces --order=oldest arg."
  (let ((spec (gastown-mail-spec :order 'oldest)))
    (should (member "--order=oldest" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-limit ()
  "Mail spec with custom limit produces --limit= arg."
  (let ((spec (gastown-mail-spec :limit 25)))
    (should (member "--limit=25" (gastown-spec--to-args spec)))))

(ert-deftest gastown-spec-test-mail-spec-to-args-combined ()
  "Mail spec with multiple fields produces all corresponding args."
  (let* ((spec (gastown-mail-spec :unread-only t :from "mayor/" :priority "high" :limit 20))
         (args (gastown-spec--to-args spec)))
    (should (member "--unread" args))
    (should (member "--from=mayor/" args))
    (should (member "--priority=high" args))
    (should (member "--limit=20" args))))

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

(provide 'gastown-spec-test)
;;; gastown-spec-test.el ends here
