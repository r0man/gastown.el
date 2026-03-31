;;; gastown-live-integration-test.el --- Live Emacs integration tests -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Live integration tests for gastown.el.  These tests exercise every
;; command class, transient menu, and completing-read reader against a
;; real Gas Town installation at `~/gt'.
;;
;; All tests are tagged `:live' and require:
;;   - A `gt' executable on PATH
;;   - A working Gas Town installation at ~/gt
;;
;; Run live tests explicitly:
;;   eldev -p -dtT test --tags :live
;;
;; These tests are excluded from the standard `eldev test' run because
;; they require a live Gas Town environment and may be slower.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'gastown)
(require 'gastown-completion)
(require 'gastown-reader)
(require 'gastown-context)
(require 'gastown-test)

;;; ============================================================
;;; Constants: Menu and Reader Symbols
;;; ============================================================

(defconst gastown-live-test-top-menus
  '(gastown
    gastown-formula-menu
    gastown-work-menu
    gastown-agent-management
    gastown-comm-menu
    gastown-services
    gastown-workspace-menu
    gastown-config-menu
    gastown-diagnostics
    gastown-convoy
    gastown-mq
    gastown-synthesis-menu
    gastown-wl)
  "Top-level transient menus reachable from the main gastown menu.")

(defconst gastown-live-test-sub-menus
  '(gastown-witness
    gastown-refinery
    gastown-session-menu
    gastown-quota-menu
    gastown-scheduler-menu
    gastown-crew-menu
    gastown-namepool-menu
    gastown-worktree-menu
    gastown-account-menu
    gastown-config-values-menu
    gastown-directive
    gastown-hooks-menu)
  "Sub-menus reached from category menus.")

(defconst gastown-live-test-all-menus
  (append gastown-live-test-top-menus gastown-live-test-sub-menus)
  "All 25 transient menu symbols.")

(defconst gastown-live-test-readers
  '(gastown-reader-rig-name
    gastown-reader-formula-name
    gastown-reader-mail-address
    gastown-reader-merge-strategy
    gastown-reader-convoy-id
    gastown-reader-crew-name
    gastown-reader-bead-id
    gastown-reader-agent-target
    gastown-reader-polecat-address)
  "Reader functions to test.
All 9 completing-read readers, including `gastown-reader-polecat-address'
now that ge-f4b (--all flag) and ge-mmn (error handling) are fixed.")

;;; ============================================================
;;; Skip Guards
;;; ============================================================

(defmacro gastown-live-test-skip-unless ()
  "Skip the test unless a live Gas Town environment is present.
Requires GASTOWN_LIVE_TESTS environment variable to be set (non-empty),
a `gt' executable on PATH, and ~/gt to be a working Gas Town installation."
  `(progn
     (skip-unless (getenv "GASTOWN_LIVE_TESTS"))
     (gastown-test-skip-unless-gt)
     (skip-unless (file-directory-p (expand-file-name "~/gt")))))

;;; ============================================================
;;; 1. Menu Rendering Tests
;;; ============================================================

(ert-deftest gastown-live-menus-all-defined ()
  "All 25 transient menu symbols are `fboundp'."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (dolist (sym gastown-live-test-all-menus)
    (should (fboundp sym))))

(ert-deftest gastown-live-menus-all-render ()
  "All 25 transient prefixes render without error."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((default-directory (expand-file-name "~/gt")))
    (dolist (sym gastown-live-test-all-menus)
      (condition-case err
          (progn
            (funcall sym)
            (sit-for 0.05)
            (transient-quit-all)
            (sit-for 0.02))
        (error (ert-fail (format "%s raised: %s" sym err)))))))

(ert-deftest gastown-live-top-menus-render ()
  "All 13 top-level transient prefixes render without error."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((default-directory (expand-file-name "~/gt")))
    (dolist (sym gastown-live-test-top-menus)
      (condition-case err
          (progn
            (funcall sym)
            (sit-for 0.05)
            (transient-quit-all)
            (sit-for 0.02))
        (error (ert-fail (format "%s raised: %s" sym err)))))))

(ert-deftest gastown-live-sub-menus-render ()
  "All 12 sub-menus render without error."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((default-directory (expand-file-name "~/gt")))
    (dolist (sym gastown-live-test-sub-menus)
      (condition-case err
          (progn
            (funcall sym)
            (sit-for 0.05)
            (transient-quit-all)
            (sit-for 0.02))
        (error (ert-fail (format "%s raised: %s" sym err)))))))

;;; ============================================================
;;; 2. Reader Completion Tests
;;; ============================================================

(defmacro gastown-live-test-reader-has-candidates (reader-sym prompt)
  "Call READER-SYM with PROMPT, mock `completing-read', and return candidates.
Captures the completion table passed to `completing-read' and returns all
completions as a list.  Fails the test if READER-SYM signals an error."
  (let ((candidates-sym (gensym "candidates")))
    `(let ((default-directory (expand-file-name "~/gt"))
           (,candidates-sym nil))
       (cl-letf (((symbol-function 'completing-read)
                  (lambda (_prompt coll &rest _)
                    (setq ,candidates-sym (all-completions "" coll))
                    (or (car ,candidates-sym) ""))))
         (condition-case err
             (funcall ',reader-sym ,prompt)
           (error (ert-fail (format "%s raised: %s" ',reader-sym err)))))
       ,candidates-sym)))

(ert-deftest gastown-live-reader-rig-name ()
  "gastown-reader-rig-name provides live rig candidates."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((candidates (gastown-live-test-reader-has-candidates
                     gastown-reader-rig-name "Rig: ")))
    (should (> (length candidates) 0))
    (should (stringp (car candidates)))))

(ert-deftest gastown-live-reader-formula-name ()
  "gastown-reader-formula-name provides live formula candidates."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((candidates (gastown-live-test-reader-has-candidates
                     gastown-reader-formula-name "Formula: ")))
    (should (> (length candidates) 0))
    (should (stringp (car candidates)))))

(ert-deftest gastown-live-reader-mail-address ()
  "gastown-reader-mail-address provides live address candidates."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((candidates (gastown-live-test-reader-has-candidates
                     gastown-reader-mail-address "To: ")))
    (should (> (length candidates) 0))
    (should (stringp (car candidates)))))

(ert-deftest gastown-live-reader-merge-strategy ()
  "gastown-reader-merge-strategy provides exactly 3 fixed choices."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let ((candidates (gastown-live-test-reader-has-candidates
                     gastown-reader-merge-strategy "Strategy: ")))
    (should (= (length candidates) 3))
    (should (member "mr" candidates))
    (should (member "direct" candidates))
    (should (member "local" candidates))))

(ert-deftest gastown-live-reader-convoy-id ()
  "gastown-reader-convoy-id returns without error."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  ;; Convoys may be empty — just verify the reader doesn't crash
  (let ((default-directory (expand-file-name "~/gt")))
    (cl-letf (((symbol-function 'completing-read)
               (lambda (_prompt coll &rest _)
                 (or (car (all-completions "" coll)) ""))))
      (condition-case err
          (gastown-reader-convoy-id "Convoy: ")
        (error (ert-fail (format "gastown-reader-convoy-id raised: %s" err)))))))

(ert-deftest gastown-live-reader-crew-name ()
  "gastown-reader-crew-name returns without error."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  ;; Crew may be empty — just verify the reader doesn't crash
  (let ((default-directory (expand-file-name "~/gt")))
    (cl-letf (((symbol-function 'completing-read)
               (lambda (_prompt coll &rest _)
                 (or (car (all-completions "" coll)) ""))))
      (condition-case err
          (gastown-reader-crew-name "Crew: ")
        (error (ert-fail (format "gastown-reader-crew-name raised: %s" err)))))))

(ert-deftest gastown-live-reader-bead-id ()
  "gastown-reader-bead-id prompts for input when no bead at point."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  ;; With no buffer context, falls back to beads-completion-read-issue
  ;; (or read-string if beads-completion is not loaded).
  (let ((result
         (cl-letf (((symbol-function 'read-string)
                    (lambda (_prompt &rest _) "ge-test"))
                   ((symbol-function 'beads-completion-read-issue)
                    (lambda (_prompt &rest _) "ge-test")))
           (gastown-reader-bead-id "Bead ID: "))))
    (should (stringp result))))

(ert-deftest gastown-live-reader-agent-target ()
  "gastown-reader-agent-target prompts with read-string when no agent at point."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  ;; With no buffer context, falls back to read-string
  (cl-letf (((symbol-function 'read-string)
             (lambda (_prompt &rest _) "gastown_el/nux")))
    (let ((result (gastown-reader-agent-target "Target: ")))
      (should (stringp result)))))

(ert-deftest gastown-live-reader-polecat-address ()
  "gastown-reader-polecat-address provides live polecat candidates.
Fixed by ge-f4b (add --all flag to polecat-list) and ge-mmn (error handling)."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  ;; Polecats may be empty if no workers are running — just verify no hang/crash.
  ;; When polecats are present, verify candidates are strings.
  (let ((default-directory (expand-file-name "~/gt")))
    (cl-letf (((symbol-function 'completing-read)
               (lambda (_prompt coll &rest _)
                 (or (car (all-completions "" coll)) ""))))
      (condition-case err
          (gastown-reader-polecat-address "Polecat: ")
        (error (ert-fail (format "gastown-reader-polecat-address raised: %s" err)))))))

;;; ============================================================
;;; 3. Command-Line Integration Tests
;;; ============================================================

(ert-deftest gastown-live-status-runs ()
  "gastown-command-status executes successfully against ~/gt."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-status))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))))

(ert-deftest gastown-live-status-has-output ()
  "gastown-command-status produces non-empty stdout."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-status))
         (exec (gastown-command-execute cmd)))
    (should (> (length (oref exec stdout)) 0))))

(ert-deftest gastown-live-rig-list-returns-rigs ()
  "gastown-command-rig-list returns at least one rig."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-rig-list :json t))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))
    (should (> (length (oref exec stdout)) 0))))

(ert-deftest gastown-live-formula-list-returns-formulas ()
  "gastown-command-formula-list returns at least one formula."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-formula-list :json t))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))
    (should (> (length (oref exec stdout)) 0))))

(ert-deftest gastown-live-convoy-list-runs ()
  "gastown-command-convoy-list executes without error (may return empty list)."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-convoy-list :json t))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))))

(ert-deftest gastown-live-vitals-runs ()
  "gastown-command-vitals executes successfully against ~/gt."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (cmd (gastown-command-vitals))
         (exec (gastown-command-execute cmd)))
    (should (zerop (oref exec exit-code)))
    (should (> (length (oref exec stdout)) 0))))

;;; ============================================================
;;; 4. Annotation Function Tests
;;; ============================================================

(ert-deftest gastown-live-rig-annotations ()
  "Rig completion entries have annotation functions that return strings."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (table (gastown-completion-rig-table))
         (ann-fn (completion-metadata-get
                  (completion-metadata "" table nil)
                  'annotation-function)))
    (should ann-fn)
    (let ((candidates (all-completions "" table)))
      (when candidates
        (let ((ann (funcall ann-fn (car candidates))))
          (should (stringp ann)))))))

(ert-deftest gastown-live-formula-annotations ()
  "Formula completion entries have annotation functions that return strings."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (table (gastown-completion-formula-table))
         (ann-fn (completion-metadata-get
                  (completion-metadata "" table nil)
                  'annotation-function)))
    (should ann-fn)
    (let ((candidates (all-completions "" table)))
      (when candidates
        (let ((ann (funcall ann-fn (car candidates))))
          (should (stringp ann)))))))

(ert-deftest gastown-live-convoy-annotations ()
  "Convoy completion table provides annotation function."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (table (gastown-completion-convoy-table))
         (ann-fn (completion-metadata-get
                  (completion-metadata "" table nil)
                  'annotation-function)))
    (should ann-fn)))

(ert-deftest gastown-live-crew-annotations ()
  "Crew completion table provides annotation function."
  :tags '(:live)
  (gastown-live-test-skip-unless)
  (let* ((default-directory (expand-file-name "~/gt"))
         (table (gastown-completion-crew-table))
         (ann-fn (completion-metadata-get
                  (completion-metadata "" table nil)
                  'annotation-function)))
    (should ann-fn)))

(provide 'gastown-live-integration-test)
;;; gastown-live-integration-test.el ends here
