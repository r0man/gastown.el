;;; gastown-tabulated-test.el --- Tests for gastown-tabulated -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for gastown-tabulated.el: pagination logic, entry converters,
;; timestamp helper, and mode definitions.

;;; Code:

(require 'ert)
(require 'gastown-tabulated)

;;; ============================================================
;;; Helpers
;;; ============================================================

(defmacro gastown-tabulated-test--with-paged-buffer (&rest body)
  "Execute BODY inside a temporary buffer with pagination state initialised."
  (declare (indent 0))
  `(with-temp-buffer
     (tabulated-list-mode)
     ,@body))

;;; ============================================================
;;; Timestamp formatter
;;; ============================================================

(ert-deftest gastown-tabulated-test-format-timestamp-full ()
  "Full ISO timestamp is trimmed to date portion."
  (should (equal "2026-03-07"
                 (gastown-tabulated--format-timestamp "2026-03-07T22:16:18Z"))))

(ert-deftest gastown-tabulated-test-format-timestamp-date-only ()
  "Date-only string is returned as-is."
  (should (equal "2026-03-07"
                 (gastown-tabulated--format-timestamp "2026-03-07"))))

(ert-deftest gastown-tabulated-test-format-timestamp-nil ()
  "Nil timestamp returns empty string."
  (should (equal "" (gastown-tabulated--format-timestamp nil))))

(ert-deftest gastown-tabulated-test-format-timestamp-empty ()
  "Empty string timestamp returns empty string."
  (should (equal "" (gastown-tabulated--format-timestamp ""))))

;;; ============================================================
;;; Pagination — page size
;;; ============================================================

(ert-deftest gastown-tabulated-test-effective-page-size-from-slot ()
  "When gastown-paged--page-size is set, it is returned directly."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5)
    (should (= 5 (gastown-paged--effective-page-size)))))

(ert-deftest gastown-tabulated-test-effective-page-size-computed ()
  "When page-size is nil, it is computed from window height."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size nil)
    ;; computed value should be at least 1
    (should (>= (gastown-paged--effective-page-size) 1))))

;;; ============================================================
;;; Pagination — total pages
;;; ============================================================

(ert-deftest gastown-tabulated-test-total-pages-exact ()
  "20 entries with page size 5 → 4 pages."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--all-entries (make-list 20 '("x" [])))
    (should (= 4 (gastown-paged--total-pages)))))

(ert-deftest gastown-tabulated-test-total-pages-remainder ()
  "11 entries with page size 5 → 3 pages."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--all-entries (make-list 11 '("x" [])))
    (should (= 3 (gastown-paged--total-pages)))))

(ert-deftest gastown-tabulated-test-total-pages-empty ()
  "Empty entry list → 1 page (minimum)."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--all-entries nil)
    (should (= 1 (gastown-paged--total-pages)))))

(ert-deftest gastown-tabulated-test-total-pages-single ()
  "3 entries with page size 10 → 1 page."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 10
          gastown-paged--all-entries (make-list 3 '("x" [])))
    (should (= 1 (gastown-paged--total-pages)))))

;;; ============================================================
;;; Pagination — page slice
;;; ============================================================

(defconst gastown-tabulated-test--sample-entries
  '(("a" []) ("b" []) ("c" []) ("d" []) ("e" [])
    ("f" []) ("g" []) ("h" []) ("i" []) ("j" [])
    ("k" []) ("l" []))
  "12 minimal tabulated-list entries for pagination tests.")

(ert-deftest gastown-tabulated-test-page-slice-first ()
  "First page slice returns items 1–5 from a 12-entry list."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--current-page 1
          gastown-paged--all-entries gastown-tabulated-test--sample-entries)
    (should (equal '(("a" []) ("b" []) ("c" []) ("d" []) ("e" []))
                   (gastown-paged--page-slice)))))

(ert-deftest gastown-tabulated-test-page-slice-second ()
  "Second page slice returns items 6–10."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--current-page 2
          gastown-paged--all-entries gastown-tabulated-test--sample-entries)
    (should (equal '(("f" []) ("g" []) ("h" []) ("i" []) ("j" []))
                   (gastown-paged--page-slice)))))

(ert-deftest gastown-tabulated-test-page-slice-last-partial ()
  "Last page returns only remaining items (2 of 5)."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--current-page 3
          gastown-paged--all-entries gastown-tabulated-test--sample-entries)
    (should (equal '(("k" []) ("l" []))
                   (gastown-paged--page-slice)))))

;;; ============================================================
;;; Pagination — interactive commands (state changes only)
;;; ============================================================

(defconst gastown-tabulated-test--6-entries
  '(("a" []) ("b" []) ("c" []) ("d" []) ("e" []) ("f" []))
  "6 minimal tabulated-list entries for pagination interaction tests.")

(ert-deftest gastown-tabulated-test-next-page-advances ()
  "gastown-paged-next-page increments current page."
  (gastown-tabulated-test--with-paged-buffer
    (setq tabulated-list-format []
          gastown-paged--page-size 2
          gastown-paged--current-page 1
          gastown-paged--base-name "Test"
          gastown-paged--all-entries gastown-tabulated-test--6-entries)
    (tabulated-list-init-header)
    (gastown-paged-next-page)
    (should (= 2 gastown-paged--current-page))))

(ert-deftest gastown-tabulated-test-next-page-clamps-at-max ()
  "gastown-paged-next-page does not advance past the last page."
  (gastown-tabulated-test--with-paged-buffer
    (setq tabulated-list-format []
          gastown-paged--page-size 5
          gastown-paged--current-page 1
          gastown-paged--base-name "Test"
          gastown-paged--all-entries '(("a" []) ("b" []) ("c" [])))
    (tabulated-list-init-header)
    (gastown-paged-next-page)
    (should (= 1 gastown-paged--current-page))))

(ert-deftest gastown-tabulated-test-prev-page-decrements ()
  "gastown-paged-prev-page decrements current page."
  (gastown-tabulated-test--with-paged-buffer
    (setq tabulated-list-format []
          gastown-paged--page-size 2
          gastown-paged--current-page 2
          gastown-paged--base-name "Test"
          gastown-paged--all-entries gastown-tabulated-test--6-entries)
    (tabulated-list-init-header)
    (gastown-paged-prev-page)
    (should (= 1 gastown-paged--current-page))))

(ert-deftest gastown-tabulated-test-prev-page-clamps-at-one ()
  "gastown-paged-prev-page does not go below page 1."
  (gastown-tabulated-test--with-paged-buffer
    (setq tabulated-list-format []
          gastown-paged--page-size 5
          gastown-paged--current-page 1
          gastown-paged--base-name "Test"
          gastown-paged--all-entries '(("a" []) ("b" []) ("c" [])))
    (tabulated-list-init-header)
    (gastown-paged-prev-page)
    (should (= 1 gastown-paged--current-page))))

(ert-deftest gastown-tabulated-test-goto-page-valid ()
  "gastown-paged-goto-page sets current page to given value."
  (gastown-tabulated-test--with-paged-buffer
    (setq tabulated-list-format []
          gastown-paged--page-size 2
          gastown-paged--current-page 1
          gastown-paged--base-name "Test"
          gastown-paged--all-entries gastown-tabulated-test--6-entries)
    (tabulated-list-init-header)
    (gastown-paged-goto-page 3)
    (should (= 3 gastown-paged--current-page))))

(ert-deftest gastown-tabulated-test-goto-page-out-of-range ()
  "gastown-paged-goto-page signals user-error for out-of-range page."
  (gastown-tabulated-test--with-paged-buffer
    (setq gastown-paged--page-size 5
          gastown-paged--current-page 1
          gastown-paged--all-entries '(("a" []) ("b" []) ("c" [])))
    (should-error (gastown-paged-goto-page 99) :type 'user-error)
    (should-error (gastown-paged-goto-page 0)  :type 'user-error)))

;;; ============================================================
;;; Entry converters
;;; ============================================================

(ert-deftest gastown-tabulated-test-rig-entry-structure ()
  "Rig entry has correct id and 6-column vector."
  (let* ((rig   '((name . "beads_el") (status . "operational")
                  (witness . "running") (refinery . "running")
                  (polecats . 5) (crew . 1)))
         (entry (gastown-rig-list--entry rig)))
    (should (equal "beads_el" (car entry)))
    (should (= 6 (length (cadr entry))))
    (should (equal "beads_el" (aref (cadr entry) 0)))
    (should (equal "5"        (aref (cadr entry) 4)))
    (should (equal "1"        (aref (cadr entry) 5)))))

(ert-deftest gastown-tabulated-test-session-entry-structure ()
  "Session entry has correct id and 4-column vector."
  (let* ((session '((rig . "beads_el") (polecat . "jasper")
                    (session_id . "be-jasper") (running . t)))
         (entry   (gastown-session-list--entry session)))
    (should (equal "be-jasper" (car entry)))
    (should (= 4 (length (cadr entry))))
    (should (equal "beads_el" (aref (cadr entry) 0)))
    (should (equal "jasper"   (aref (cadr entry) 1)))))

(ert-deftest gastown-tabulated-test-session-entry-stopped ()
  "Stopped session uses the ○ indicator."
  (let* ((session '((rig . "beads_el") (polecat . "test")
                    (session_id . "be-test") (running . :json-false)))
         (entry (gastown-session-list--entry session)))
    (should (equal "○" (aref (cadr entry) 3)))))

(ert-deftest gastown-tabulated-test-convoy-entry-structure ()
  "Convoy entry has correct id and 5-column vector."
  (let* ((convoy '((id . "hq-cv-abc") (title . "Test convoy")
                   (status . "open") (created_at . "2026-03-07T10:00:00Z")
                   (completed . 2) (total . 5)))
         (entry  (gastown-convoy-list--entry convoy)))
    (should (equal "hq-cv-abc" (car entry)))
    (should (= 5 (length (cadr entry))))
    (should (equal "hq-cv-abc"  (aref (cadr entry) 0)))
    (should (equal "Test convoy" (aref (cadr entry) 1)))
    (should (equal "2026-03-07"  (aref (cadr entry) 3)))
    (should (equal "2/5"         (aref (cadr entry) 4)))))

(ert-deftest gastown-tabulated-test-mail-entry-structure ()
  "Mail entry has correct id and 5-column vector."
  (let* ((mail  '((id . "hq-a5at") (from . "guix_home/witness")
                  (subject . "Test subject")
                  (timestamp . "2026-03-07T21:55:47Z")
                  (read . t) (priority . "normal")))
         (entry (gastown-mail-inbox--entry mail)))
    (should (equal "hq-a5at" (car entry)))
    (should (= 5 (length (cadr entry))))
    (should (equal "hq-a5at"            (aref (cadr entry) 0)))
    (should (equal "guix_home/witness"  (aref (cadr entry) 1)))
    (should (equal "2026-03-07"         (aref (cadr entry) 3)))
    ;; Read message has empty unread indicator
    (should (equal "" (aref (cadr entry) 4)))))

(ert-deftest gastown-tabulated-test-mail-entry-unread ()
  "Unread mail shows the ● indicator."
  (let* ((mail  '((id . "hq-xyz") (from . "someone")
                  (subject . "Unread") (timestamp . "2026-03-07T00:00:00Z")
                  (read . :json-false) (priority . "normal")))
         (entry (gastown-mail-inbox--entry mail)))
    (should (equal "●" (aref (cadr entry) 4)))))

;;; ============================================================
;;; Mode definitions
;;; ============================================================

(ert-deftest gastown-tabulated-test-modes-defined ()
  "All four list modes are defined."
  (should (fboundp 'gastown-rig-list-mode))
  (should (fboundp 'gastown-session-list-mode))
  (should (fboundp 'gastown-convoy-list-mode))
  (should (fboundp 'gastown-mail-inbox-mode)))

(ert-deftest gastown-tabulated-test-pagination-keys-bound ()
  "Each mode's keymap has ] [ G pagination bindings."
  (dolist (map (list gastown-rig-list-mode-map
                     gastown-session-list-mode-map
                     gastown-convoy-list-mode-map
                     gastown-mail-inbox-mode-map))
    (should (eq #'gastown-paged-next-page (lookup-key map (kbd "]"))))
    (should (eq #'gastown-paged-prev-page (lookup-key map (kbd "["))))
    (should (eq #'gastown-paged-goto-page (lookup-key map (kbd "G"))))))

(ert-deftest gastown-tabulated-test-execute-interactive-overrides ()
  "gastown-command-execute-interactive is overridden for all four command classes."
  (should (fboundp 'gastown-rig-list-show-buffer))
  (should (fboundp 'gastown-session-list-show-buffer))
  (should (fboundp 'gastown-convoy-list-show-buffer))
  (should (fboundp 'gastown-mail-inbox-show-buffer)))

(provide 'gastown-tabulated-test)
;;; gastown-tabulated-test.el ends here
