;;; gastown-command-formula-test.el --- Tests for gastown-command-formula -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for gastown-command-formula.el — formula lifecycle integration:
;; output buffers, dynamic var transient, run/status commands.

;;; Code:

(require 'ert)
(require 'gastown-command-formula)

;;; ============================================================
;;; Output Buffer Tests
;;; ============================================================

(ert-deftest gastown-formula-test-output-buffer-name ()
  "Test that output buffer name uses the correct format."
  (should (equal "*gastown-formula: test-formula*"
                 (gastown-formula--output-buffer-name "test-formula"))))

(ert-deftest gastown-formula-test-output-buffer-creates-buffer ()
  "Test that gastown-formula-output-buffer creates a buffer."
  (let ((buf (gastown-formula-output-buffer "test-formula")))
    (unwind-protect
        (progn
          (should (bufferp buf))
          (should (buffer-live-p buf))
          (should (equal "*gastown-formula: test-formula*" (buffer-name buf))))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-buffer-has-header ()
  "Test that output buffer contains formula name header."
  (let ((buf (gastown-formula-output-buffer "my-formula")))
    (unwind-protect
        (with-current-buffer buf
          (let ((content (buffer-substring-no-properties (point-min) (point-max))))
            (should (string-match-p "my-formula" content))
            (should (string-match-p "--- Output ---" content))))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-buffer-with-target ()
  "Test that output buffer includes target when provided."
  (let ((buf (gastown-formula-output-buffer "my-formula" "gastown_el")))
    (unwind-protect
        (with-current-buffer buf
          (let ((content (buffer-substring-no-properties (point-min) (point-max))))
            (should (string-match-p "gastown_el" content))))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-buffer-is-special-mode ()
  "Test that output buffer uses special-mode."
  (let ((buf (gastown-formula-output-buffer "test-formula")))
    (unwind-protect
        (with-current-buffer buf
          (should (derived-mode-p 'special-mode)))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-buffer-is-read-only ()
  "Test that output buffer is read-only after creation."
  (let ((buf (gastown-formula-output-buffer "test-formula")))
    (unwind-protect
        (with-current-buffer buf
          (should buffer-read-only))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-append-adds-text ()
  "Test that gastown-formula-output-append adds text to buffer."
  (let ((buf (gastown-formula-output-buffer "test-formula")))
    (unwind-protect
        (progn
          (gastown-formula-output-append "test-formula" "hello output\n")
          (with-current-buffer buf
            (let ((content (buffer-substring-no-properties (point-min) (point-max))))
              (should (string-match-p "hello output" content)))))
      (kill-buffer buf))))

(ert-deftest gastown-formula-test-output-append-noop-for-missing-buffer ()
  "Test that gastown-formula-output-append is a no-op when buffer does not exist."
  ;; Should not signal an error
  (should-not (gastown-formula-output-append "nonexistent-formula-xyz" "text")))

(ert-deftest gastown-formula-test-output-show-defined ()
  "Test that gastown-formula-output-show is defined."
  (should (fboundp 'gastown-formula-output-show)))


;;; ============================================================
;;; Var Transient Infrastructure Tests
;;; ============================================================

(ert-deftest gastown-formula-test-pending-action-vars-defined ()
  "Test that pending state variables are defined."
  (should (boundp 'gastown-formula--pending-action))
  (should (boundp 'gastown-formula--pending-formula-name)))

(ert-deftest gastown-formula-test-vars-history-is-hash ()
  "Test that formula vars history is a hash table."
  (should (hash-table-p gastown-formula--vars-history)))

(ert-deftest gastown-formula-test-pick-key-returns-string ()
  "Test that gastown-formula--pick-key returns a string."
  (let ((key (gastown-formula--pick-key "problem" nil)))
    (should (or (stringp key) (characterp key)))))

(ert-deftest gastown-formula-test-pick-key-avoids-used ()
  "Test that gastown-formula--pick-key avoids already-used keys."
  (let* ((used '("p" "r" "o"))
         (key (gastown-formula--pick-key "problem" used))
         (key-str (if (characterp key) (string key) key)))
    (should (not (member key-str used)))))

(ert-deftest gastown-formula-test-build-var-groups-empty ()
  "Test that gastown-formula--build-var-groups returns nil for empty vars."
  (should (null (gastown-formula--build-var-groups nil nil))))

(ert-deftest gastown-formula-test-build-var-groups-required-first ()
  "Test that required vars appear in the Required group."
  (let* ((required-var (gastown-formula-var :name "issue"
                                            :description "The issue ID"
                                            :required t))
         (optional-var (gastown-formula-var :name "context"
                                            :description "Extra context"
                                            :required nil
                                            :default ""))
         (groups (gastown-formula--build-var-groups
                  (list required-var optional-var) nil)))
    ;; Should have at least one group
    (should (> (length groups) 0))
    ;; Required group should exist
    (should (cl-find-if (lambda (g) (equal (car g) "Required")) groups))
    ;; Optional group should exist
    (should (cl-find-if (lambda (g) (equal (car g) "Optional")) groups))))

(ert-deftest gastown-formula-test-build-var-groups-only-required ()
  "Test build-var-groups with only required vars."
  (let* ((var (gastown-formula-var :name "problem" :required t))
         (groups (gastown-formula--build-var-groups (list var) nil)))
    (should (= 1 (length groups)))
    (should (equal "Required" (caar groups)))))

(ert-deftest gastown-formula-test-build-var-groups-history-hint ()
  "Test that history values appear as hints in var group descriptions."
  (let* ((var (gastown-formula-var :name "problem"
                                   :description "Problem statement"
                                   :required t))
         (history '(("problem" . "previous value")))
         (groups (gastown-formula--build-var-groups (list var) history)))
    ;; The spec for the var should contain the history hint
    (when groups
      (let* ((group (car groups))
             (specs (cdr group))
             (spec (car specs))
             (desc (cadr spec)))
        (should (string-match-p "previous value" desc))))))


;;; ============================================================
;;; gastown-formula-var-transient Behavior Tests
;;; ============================================================

(ert-deftest gastown-formula-test-var-transient-defined ()
  "Test that gastown-formula-var-transient is defined."
  (should (fboundp 'gastown-formula-var-transient)))

(ert-deftest gastown-formula-test-var-transient-zero-vars-calls-action ()
  "Test that var-transient with zero vars calls action immediately."
  (let ((was-called nil)
        (called-with 'not-set))
    ;; Mock get-cached-formula-vars to return nil
    (cl-letf (((symbol-function 'gastown-completion--get-cached-formula-vars)
               (lambda (_name) nil)))
      (gastown-formula-var-transient
       "test-formula"
       (lambda (vars)
         (setq was-called t)
         (setq called-with vars))))
    ;; Action should have been called immediately
    (should was-called)
    ;; Action should have been called with nil (no vars)
    (should (null called-with))))

(ert-deftest gastown-formula-test-prompt-vars-sequentially-defined ()
  "Test that gastown-formula--prompt-vars-sequentially is defined."
  (should (fboundp 'gastown-formula--prompt-vars-sequentially)))

(ert-deftest gastown-formula-test-prompt-vars-sequentially-returns-alist ()
  "Test sequential prompting returns an alist."
  (let* ((var (gastown-formula-var :name "foo" :description "Foo" :required t)))
    (cl-letf (((symbol-function 'read-string)
               (lambda (prompt &rest _) "bar")))
      (let ((result (gastown-formula--prompt-vars-sequentially
                     (list var) "test-formula")))
        (should (listp result))
        (should (= 1 (length result)))
        (should (equal "foo" (caar result)))
        (should (equal "bar" (cdar result)))))))


;;; ============================================================
;;; gastown-formula-run-interactive Tests
;;; ============================================================

(ert-deftest gastown-formula-test-run-interactive-defined ()
  "Test that gastown-formula-run-interactive is defined."
  (should (fboundp 'gastown-formula-run-interactive)))

(ert-deftest gastown-formula-test-run-with-vars-defined ()
  "Test that gastown-formula--run-with-vars is defined."
  (should (fboundp 'gastown-formula--run-with-vars)))


;;; ============================================================
;;; gastown-formula-status Tests
;;; ============================================================

(ert-deftest gastown-formula-test-status-defined ()
  "Test that gastown-formula-status is defined."
  (should (fboundp 'gastown-formula-status)))

(ert-deftest gastown-formula-test-record-convoy-defined ()
  "Test that gastown-formula--record-convoy is defined."
  (should (fboundp 'gastown-formula--record-convoy)))

(ert-deftest gastown-formula-test-record-convoy-adds-to-list ()
  "Test that recording a convoy adds it to the recent list."
  (let ((gastown-formula--recent-convoy-ids nil))
    (gastown-formula--record-convoy "hq-cv-test123")
    (should (member "hq-cv-test123" gastown-formula--recent-convoy-ids))))

(ert-deftest gastown-formula-test-record-convoy-deduplicates ()
  "Test that convoy list deduplicates entries."
  (let ((gastown-formula--recent-convoy-ids nil))
    (gastown-formula--record-convoy "hq-cv-abc")
    (gastown-formula--record-convoy "hq-cv-abc")
    (should (= 1 (length gastown-formula--recent-convoy-ids)))))


;;; ============================================================
;;; Formula Menu Tests
;;; ============================================================

(ert-deftest gastown-formula-test-menu-defined ()
  "Test that gastown-formula-menu is defined."
  (should (fboundp 'gastown-formula-menu)))

(provide 'gastown-command-formula-test)
;;; gastown-command-formula-test.el ends here
