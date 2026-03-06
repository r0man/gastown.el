;;; gastown-command-ready-test.el --- Tests for gastown-command-ready -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests for gastown-command-ready.el: ready buffer rendering and
;; the execute-interactive override.

;;; Code:

(require 'ert)
(require 'gastown-custom)
(require 'gastown-command-ready)

;;; Priority formatting tests

(ert-deftest gastown-ready-test-format-priority-critical ()
  "Format priority 0 as P0 with critical face."
  (let ((result (gastown-ready--format-priority 0)))
    (should (string= "P0" result))
    (should (eq 'gastown-ready-priority-critical
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-high ()
  "Format priority 1 as P1 with high face."
  (let ((result (gastown-ready--format-priority 1)))
    (should (string= "P1" result))
    (should (eq 'gastown-ready-priority-high
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-medium ()
  "Format priority 2 as P2 with medium face."
  (let ((result (gastown-ready--format-priority 2)))
    (should (string= "P2" result))
    (should (eq 'gastown-ready-priority-medium
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-low ()
  "Format priority 3 as P3 with low face."
  (let ((result (gastown-ready--format-priority 3)))
    (should (string= "P3" result))
    (should (eq 'gastown-ready-priority-low
                (get-text-property 0 'face result)))))

(ert-deftest gastown-ready-test-format-priority-nil ()
  "Format nil priority as empty string."
  (let ((result (gastown-ready--format-priority nil)))
    (should (string= "" result))))

;;; Truncation tests

(ert-deftest gastown-ready-test-truncate-short ()
  "Short strings pass through unchanged."
  (should (string= "hello" (gastown-ready--truncate "hello" 10))))

(ert-deftest gastown-ready-test-truncate-long ()
  "Long strings are truncated with ellipsis."
  (let ((result (gastown-ready--truncate "abcdefghij" 5)))
    (should (= 5 (length result)))
    (should (string-suffix-p "…" result))))

(ert-deftest gastown-ready-test-truncate-nil ()
  "Nil returns empty string."
  (should (string= "" (gastown-ready--truncate nil 10))))

;;; Section entry tests

(ert-deftest gastown-ready-test-section-entry-id ()
  "Section entry ID has 'section:' prefix."
  (let ((entry (gastown-ready--section-entry "town")))
    (should (string= "section:town" (car entry)))))

(ert-deftest gastown-ready-test-section-entry-vector-length ()
  "Section entry vector has 5 columns."
  (let ((entry (gastown-ready--section-entry "gastown_el")))
    (should (= 5 (length (cadr entry))))))

(ert-deftest gastown-ready-test-section-entry-face ()
  "Section entry first column has section-header face."
  (let* ((entry (gastown-ready--section-entry "town"))
         (vec   (cadr entry))
         (header (aref vec 0)))
    (should (eq 'gastown-ready-section-header
                (get-text-property 0 'face header)))))

;;; Issue entry tests

(ert-deftest gastown-ready-test-issue-entry-id ()
  "Issue entry ID matches issue id field."
  (let* ((issue '((id . "ge-abc") (title . "Fix bug") (issue_type . "bug")
                  (priority . 1) (assignee . "chrome")))
         (entry (gastown-ready--issue-entry issue)))
    (should (string= "ge-abc" (car entry)))))

(ert-deftest gastown-ready-test-issue-entry-vector ()
  "Issue entry vector has 5 columns."
  (let* ((issue '((id . "ge-abc") (title . "Fix bug") (issue_type . "bug")
                  (priority . 1) (assignee . "chrome")))
         (entry (gastown-ready--issue-entry issue))
         (vec   (cadr entry)))
    (should (= 5 (length vec)))
    (should (string= "ge-abc" (aref vec 1)))
    (should (string= "bug"    (aref vec 2)))))

;;; Build entries tests

(ert-deftest gastown-ready-test-build-entries-empty ()
  "Empty sources vector produces no entries."
  (should (null (gastown-ready--build-entries []))))

(ert-deftest gastown-ready-test-build-entries-sections ()
  "Each source produces a section header plus issue rows."
  (let* ((sources
          (vector
           `((name . "town")
             (issues . ,(vector '((id . "hq-1") (title . "A") (issue_type . "task")
                                  (priority . 1) (assignee . "mayor/")))))
           `((name . "gastown_el")
             (issues . ,(vector '((id . "ge-2") (title . "B") (issue_type . "bug")
                                  (priority . 2) (assignee . "chrome")))))))
         (entries (gastown-ready--build-entries sources)))
    ;; Two sources × (1 header + 1 issue) = 4 entries
    (should (= 4 (length entries)))
    (should (string= "section:town" (car (nth 0 entries))))
    (should (string= "hq-1"         (car (nth 1 entries))))
    (should (string= "section:gastown_el" (car (nth 2 entries))))
    (should (string= "ge-2"         (car (nth 3 entries))))))

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

(provide 'gastown-command-ready-test)
;;; gastown-command-ready-test.el ends here
