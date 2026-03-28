;;; gastown-command-ready-test.el --- Tests for gastown-command-ready -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests for gastown-command-ready.el: ready buffer rendering and
;; the execute-interactive override.

;;; Code:

(require 'ert)
(require 'gastown-custom)
(require 'gastown-command-ready)

;;; Priority face tests

(ert-deftest gastown-ready-test-priority-face-critical ()
  "Priority 0 maps to critical face."
  (should (eq 'gastown-ready-priority-critical
              (gastown-ready--priority-face 0))))

(ert-deftest gastown-ready-test-priority-face-high ()
  "Priority 1 maps to high face."
  (should (eq 'gastown-ready-priority-high
              (gastown-ready--priority-face 1))))

(ert-deftest gastown-ready-test-priority-face-medium ()
  "Priority 2 maps to medium face."
  (should (eq 'gastown-ready-priority-medium
              (gastown-ready--priority-face 2))))

(ert-deftest gastown-ready-test-priority-face-low ()
  "Priority 3 maps to low face."
  (should (eq 'gastown-ready-priority-low
              (gastown-ready--priority-face 3))))

;;; Priority tag formatting tests

(ert-deftest gastown-ready-test-format-priority-tag-zero ()
  "Priority 0 formats as [P0] with critical face."
  (let ((result (gastown-ready--format-priority-tag 0)))
    (should (string= "[P0]" result))
    (should (eq 'gastown-ready-priority-critical
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-tag-one ()
  "Priority 1 formats as [P1] with high face."
  (let ((result (gastown-ready--format-priority-tag 1)))
    (should (string= "[P1]" result))
    (should (eq 'gastown-ready-priority-high
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-tag-two ()
  "Priority 2 formats as [P2] with medium face."
  (let ((result (gastown-ready--format-priority-tag 2)))
    (should (string= "[P2]" result))
    (should (eq 'gastown-ready-priority-medium
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-tag-nil ()
  "Nil priority formats as [P?]."
  (let ((result (gastown-ready--format-priority-tag nil)))
    (should (string= "[P?]" result))))

;;; Count issues tests

(ert-deftest gastown-ready-test-count-issues-empty ()
  "Empty sources returns zeros."
  (cl-destructuring-bind (total p1 p2)
      (gastown-ready--count-issues nil)
    (should (= 0 total))
    (should (= 0 p1))
    (should (= 0 p2))))

(ert-deftest gastown-ready-test-count-issues-mixed ()
  "Mixed priorities are counted correctly."
  (let ((sources
         (list
          (gastown-ready-source
           :name "town"
           :issues (list (gastown-ready-issue :id "hq-1" :priority 1)
                         (gastown-ready-issue :id "hq-2" :priority 1)
                         (gastown-ready-issue :id "hq-3" :priority 2))))))
    (cl-destructuring-bind (total p1 p2)
        (gastown-ready--count-issues sources)
      (should (= 3 total))
      (should (= 2 p1))
      (should (= 1 p2)))))

;;; Render tests

(ert-deftest gastown-ready-test-render-header ()
  "Render inserts the '📋 Ready work' header."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render '((sources . [])))
    (goto-char (point-min))
    (should (search-forward "Ready work across town" nil t))))

(ert-deftest gastown-ready-test-render-section-with-items ()
  "Render inserts section header with item count."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render
     `((sources . ,(vector
                    `((name . "town")
                      (issues . ,(vector '((id . "hq-1") (title . "Fix it")
                                           (priority . 1)))))))))
    (goto-char (point-min))
    (should (search-forward "town/ (1 item)" nil t))))

(ert-deftest gastown-ready-test-render-section-none ()
  "Render inserts '(none)' for empty source."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render
     `((sources . ,(vector '((name . "sooper_whisper") (issues . []))))))
    (goto-char (point-min))
    (should (search-forward "sooper_whisper/ (none)" nil t))))

(ert-deftest gastown-ready-test-render-issue-line ()
  "Render inserts issue line with priority tag and ID."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render
     `((sources . ,(vector
                    `((name . "gastown_el")
                      (issues . ,(vector '((id . "ge-abc") (title . "Fix bug")
                                           (priority . 2)))))))))
    (goto-char (point-min))
    (should (search-forward "[P2]" nil t))
    (should (search-forward "ge-abc" nil t))
    (should (search-forward "Fix bug" nil t))))

(ert-deftest gastown-ready-test-render-footer ()
  "Render inserts total footer when items exist."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render
     `((sources . ,(vector
                    `((name . "town")
                      (issues . ,(vector '((id . "hq-1") (priority . 1)))))))))
    (goto-char (point-min))
    (should (search-forward "Total: 1 item ready" nil t))))

(ert-deftest gastown-ready-test-render-issue-has-text-property ()
  "Issue ID in rendered buffer has gastown-ready-issue-id property."
  (with-temp-buffer
    (gastown-ready-mode)
    (gastown-ready--render
     `((sources . ,(vector
                    `((name . "gastown_el")
                      (issues . ,(vector '((id . "ge-xyz") (title . "Test")
                                           (priority . 2)))))))))
    (goto-char (point-min))
    (search-forward "ge-xyz")
    (backward-char 1)
    (should (equal "ge-xyz"
                   (get-text-property (point) 'gastown-ready-issue-id)))))

;;; gastown-ready-do-refresh tests

(defun gastown-ready-test--mount-with-mock (buf)
  "Mount gastown-ready-app in BUF with a mock fetch that never resolves.
Returns the buffer so the caller can call gastown-ready-do-refresh on it."
  (with-current-buffer buf
    (gastown-ready-mode)
    (cl-letf (((symbol-function 'gastown-ready--async-fetch)
               (lambda (_resolve _reject) nil)))
      (vui-mount (vui-component 'gastown-ready-app) (buffer-name))))
  buf)

(ert-deftest gastown-ready-test-do-refresh-defined ()
  "gastown-ready-do-refresh is a defined function."
  (should (fboundp 'gastown-ready-do-refresh)))

(ert-deftest gastown-ready-test-do-refresh-returns-nil-for-dead-buffer ()
  "gastown-ready-do-refresh returns nil for a non-live buffer."
  (should-not (gastown-ready-do-refresh (get-buffer-create " *dead*")))
  (kill-buffer " *dead*"))

(ert-deftest gastown-ready-test-do-refresh-returns-nil-without-instance ()
  "gastown-ready-do-refresh returns nil when no vui root instance exists."
  (with-temp-buffer
    (should-not (gastown-ready-do-refresh (current-buffer)))))

(ert-deftest gastown-ready-test-do-refresh-increments-tick ()
  "gastown-ready-do-refresh increments :refresh-tick on the live root instance."
  (with-temp-buffer
    (let ((buf (gastown-ready-test--mount-with-mock (current-buffer))))
      (let ((tick-before (plist-get (vui-instance-state vui--root-instance)
                                    :refresh-tick)))
        (cl-letf (((symbol-function 'gastown-ready--async-fetch)
                   (lambda (_resolve _reject) nil)))
          (gastown-ready-do-refresh buf))
        (let ((tick-after (plist-get (vui-instance-state vui--root-instance)
                                     :refresh-tick)))
          (should (= (1+ tick-before) tick-after)))))))

(ert-deftest gastown-ready-test-do-refresh-returns-t-with-instance ()
  "gastown-ready-do-refresh returns t when a live vui root instance exists."
  (with-temp-buffer
    (let ((buf (gastown-ready-test--mount-with-mock (current-buffer))))
      (cl-letf (((symbol-function 'gastown-ready--async-fetch)
                 (lambda (_resolve _reject) nil)))
        (should (gastown-ready-do-refresh buf))))))

;;; Mode and method existence tests

(ert-deftest gastown-ready-test-mode-defined ()
  "gastown-ready-mode is a defined function."
  (should (fboundp 'gastown-ready-mode)))

(ert-deftest gastown-ready-test-refresh-defined ()
  "gastown-ready-refresh is a defined function."
  (should (fboundp 'gastown-ready-refresh)))

(ert-deftest gastown-ready-test-show-issue-defined ()
  "gastown-ready-show-issue is a defined function."
  (should (fboundp 'gastown-ready-show-issue)))

(ert-deftest gastown-ready-test-execute-interactive-method ()
  "execute-interactive method is defined for gastown-command-ready."
  (should (fboundp 'gastown-command-execute-interactive)))

(ert-deftest gastown-ready-test-entry-point-defined ()
  "gastown-ready entry point is defined as autoload."
  (should (fboundp 'gastown-ready)))

(ert-deftest gastown-ready-test-mode-sets-header-line ()
  "gastown-ready-mode sets header-line-format with key hint hints."
  (with-temp-buffer
    (gastown-ready-mode)
    (should (stringp header-line-format))
    (should (string-match-p "g=refresh" header-line-format))
    (should (string-match-p "q=quit" header-line-format))))

(ert-deftest gastown-ready-test-mode-navigation-keys-bound ()
  "gastown-ready-mode binds n and p for navigation."
  (with-temp-buffer
    (gastown-ready-mode)
    (should (eq (key-binding "n") #'next-line))
    (should (eq (key-binding "p") #'previous-line))))

(provide 'gastown-command-ready-test)
;;; gastown-command-ready-test.el ends here
