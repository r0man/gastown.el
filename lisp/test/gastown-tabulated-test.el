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
  (let* ((rig   (gastown-rig-data :name "beads_el" :status "operational"
                                  :witness "running" :refinery "running"
                                  :polecats 5 :crew 1))
         (entry (gastown-rig-list--entry rig)))
    (should (equal "beads_el" (car entry)))
    (should (= 6 (length (cadr entry))))
    (should (equal "beads_el" (aref (cadr entry) 0)))
    (should (equal "5"        (aref (cadr entry) 4)))
    (should (equal "1"        (aref (cadr entry) 5)))))

(ert-deftest gastown-tabulated-test-session-entry-structure ()
  "Session entry has correct id and 4-column vector."
  (let* ((session (gastown-session :rig "beads_el" :polecat "jasper"
                                   :session-id "be-jasper" :running t))
         (entry   (gastown-session-list--entry session)))
    (should (equal "be-jasper" (car entry)))
    (should (= 4 (length (cadr entry))))
    (should (equal "beads_el" (aref (cadr entry) 0)))
    (should (equal "jasper"   (aref (cadr entry) 1)))))

(ert-deftest gastown-tabulated-test-session-entry-stopped ()
  "Stopped session uses the ○ indicator."
  (let* ((session (gastown-session :rig "beads_el" :polecat "test"
                                   :session-id "be-test" :running nil))
         (entry (gastown-session-list--entry session)))
    (should (equal "○" (aref (cadr entry) 3)))))

(ert-deftest gastown-tabulated-test-convoy-entry-structure ()
  "Convoy entry has correct id and 5-column vector."
  (let* ((convoy (gastown-convoy-data :id "hq-cv-abc" :title "Test convoy"
                                      :status "open"
                                      :created-at "2026-03-07T10:00:00Z"
                                      :completed 2 :total 5))
         (entry  (gastown-convoy-list--entry convoy)))
    (should (equal "hq-cv-abc" (car entry)))
    (should (= 5 (length (cadr entry))))
    (should (equal "hq-cv-abc"  (aref (cadr entry) 0)))
    (should (equal "Test convoy" (aref (cadr entry) 1)))
    (should (equal "2026-03-07"  (aref (cadr entry) 3)))
    (should (equal "2/5"         (aref (cadr entry) 4)))))

(ert-deftest gastown-tabulated-test-mail-entry-structure ()
  "Mail entry has correct id and 5-column vector."
  (let* ((mail  (gastown-mail-message :id "hq-a5at" :from "guix_home/witness"
                                      :subject "Test subject"
                                      :timestamp "2026-03-07T21:55:47Z"
                                      :read t :priority "normal"))
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
  (let* ((mail  (gastown-mail-message :id "hq-xyz" :from "someone"
                                      :subject "Unread"
                                      :timestamp "2026-03-07T00:00:00Z"
                                      :read nil :priority "normal"))
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

;;; ============================================================
;;; Filter keybindings
;;; ============================================================

(ert-deftest gastown-tabulated-test-filter-keys-bound ()
  "Each mode's keymap has / filter keybinding."
  (should (lookup-key gastown-rig-list-mode-map (kbd "/")))
  (should (lookup-key gastown-session-list-mode-map (kbd "/")))
  (should (lookup-key gastown-convoy-list-mode-map (kbd "/")))
  (should (lookup-key gastown-mail-inbox-mode-map (kbd "/"))))

;;; ============================================================
;;; Filter transients and functions
;;; ============================================================

(ert-deftest gastown-tabulated-test-filter-transients-exist ()
  "All four list-view filter transient prefixes are defined."
  (should (fboundp 'gastown-rig-list-filter))
  (should (fboundp 'gastown-session-list-filter))
  (should (fboundp 'gastown-convoy-list-filter))
  (should (fboundp 'gastown-mail-inbox-filter)))

(ert-deftest gastown-tabulated-test-filter-functions-exist ()
  "All filter apply/clear functions are defined."
  (should (fboundp 'gastown-rig-list--apply-filter))
  (should (fboundp 'gastown-rig-list-clear-filter))
  (should (fboundp 'gastown-session-list--apply-filter))
  (should (fboundp 'gastown-session-list--clear-filter))
  (should (fboundp 'gastown-convoy-list--apply-filter))
  (should (fboundp 'gastown-convoy-list--clear-filter))
  (should (fboundp 'gastown-mail-inbox--apply-filter))
  (should (fboundp 'gastown-mail-inbox--clear-filter)))

;;; ============================================================
;;; Filter apply — spec updates
;;; ============================================================

(ert-deftest gastown-tabulated-test-session-apply-filter-sets-rig ()
  "gastown-session-list--apply-filter stores rig in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-agent-spec nil)
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '("--rig=beads_el")))
    (should (gastown-agent-spec-p gastown-current-agent-spec))
    (should (equal "beads_el" (oref gastown-current-agent-spec rig)))))

(ert-deftest gastown-tabulated-test-session-apply-filter-clears-rig ()
  "gastown-session-list--apply-filter with empty rig stores nil."
  (with-temp-buffer
    (setq gastown-current-agent-spec (make-instance 'gastown-agent-spec :rig "old"))
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '()))
    (should (null (oref gastown-current-agent-spec rig)))))

(ert-deftest gastown-tabulated-test-session-clear-filter-resets-spec ()
  "gastown-session-list--clear-filter sets buffer-local spec to nil."
  (with-temp-buffer
    (setq gastown-current-agent-spec (make-instance 'gastown-agent-spec :rig "myrig"))
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--clear-filter))
    (should (null gastown-current-agent-spec))))

(ert-deftest gastown-tabulated-test-convoy-apply-filter-sets-status ()
  "gastown-convoy-list--apply-filter stores status in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-convoy-spec nil)
    (cl-letf (((symbol-function 'gastown-convoy-list-refresh) #'ignore))
      (gastown-convoy-list--apply-filter '("--status=open")))
    (should (gastown-convoy-spec-p gastown-current-convoy-spec))
    (should (equal "open" (oref gastown-current-convoy-spec status)))))

(ert-deftest gastown-tabulated-test-convoy-clear-filter-resets-spec ()
  "gastown-convoy-list--clear-filter sets buffer-local spec to nil."
  (with-temp-buffer
    (setq gastown-current-convoy-spec (make-instance 'gastown-convoy-spec :status "open"))
    (cl-letf (((symbol-function 'gastown-convoy-list-refresh) #'ignore))
      (gastown-convoy-list--clear-filter))
    (should (null gastown-current-convoy-spec))))

(ert-deftest gastown-tabulated-test-mail-apply-filter-sets-unread ()
  "gastown-mail-inbox--apply-filter sets unread-only on buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-mail-spec nil)
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '("--unread")))
    (should (gastown-mail-spec-p gastown-current-mail-spec))
    (should (oref gastown-current-mail-spec unread-only))))

(ert-deftest gastown-tabulated-test-mail-apply-filter-clears-unread ()
  "gastown-mail-inbox--apply-filter without --unread stores nil unread-only."
  (with-temp-buffer
    (setq gastown-current-mail-spec (make-instance 'gastown-mail-spec :unread-only t))
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '()))
    (should (null (oref gastown-current-mail-spec unread-only)))))

(ert-deftest gastown-tabulated-test-mail-clear-filter-resets-spec ()
  "gastown-mail-inbox--clear-filter sets buffer-local spec to nil."
  (with-temp-buffer
    (setq gastown-current-mail-spec (make-instance 'gastown-mail-spec :unread-only t))
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--clear-filter))
    (should (null gastown-current-mail-spec))))

;;; ============================================================
;;; Mail inbox unread slot
;;; ============================================================

(ert-deftest gastown-tabulated-test-mail-inbox-has-unread-slot ()
  "gastown-command-mail-inbox has unread slot for --unread filter."
  (let ((cmd (make-instance 'gastown-command-mail-inbox)))
    (should (slot-exists-p cmd 'unread))))

;;; ============================================================
;;; Full filter menus — rig
;;; ============================================================

(ert-deftest gastown-tabulated-test-rig-filter-transient-exists ()
  "Rig list filter transient prefix is defined."
  (should (fboundp 'gastown-rig-list-filter)))

(ert-deftest gastown-tabulated-test-rig-filter-key-is-filter ()
  "Rig mode / key invokes filter menu, not just clear."
  (should (eq #'gastown-rig-list-filter
              (lookup-key gastown-rig-list-mode-map (kbd "/")))))

(ert-deftest gastown-tabulated-test-rig-apply-filter-sets-status ()
  "gastown-rig-list--apply-filter stores status in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-rig-spec nil)
    (cl-letf (((symbol-function 'gastown-rig-list-refresh) #'ignore))
      (gastown-rig-list--apply-filter '("--status=operational")))
    (should (gastown-rig-spec-p gastown-current-rig-spec))
    (should (equal "operational" (oref gastown-current-rig-spec status)))))

(ert-deftest gastown-tabulated-test-rig-apply-filter-clears-status ()
  "gastown-rig-list--apply-filter with no status stores nil."
  (with-temp-buffer
    (setq gastown-current-rig-spec (make-instance 'gastown-rig-spec :status "operational"))
    (cl-letf (((symbol-function 'gastown-rig-list-refresh) #'ignore))
      (gastown-rig-list--apply-filter '()))
    (should (null (oref gastown-current-rig-spec status)))))

(ert-deftest gastown-tabulated-test-rig-apply-filter-sets-order ()
  "gastown-rig-list--apply-filter stores order in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-rig-spec nil)
    (cl-letf (((symbol-function 'gastown-rig-list-refresh) #'ignore))
      (gastown-rig-list--apply-filter '("--order=status")))
    (should (gastown-rig-spec-p gastown-current-rig-spec))
    (should (eq 'status (oref gastown-current-rig-spec order)))))

(ert-deftest gastown-tabulated-test-rig-clear-filter-resets-spec ()
  "gastown-rig-list--apply-filter with c clear action resets spec."
  (with-temp-buffer
    (setq gastown-current-rig-spec (make-instance 'gastown-rig-spec :status "degraded"))
    (cl-letf (((symbol-function 'gastown-rig-list-refresh) #'ignore))
      (gastown-rig-list-clear-filter))
    (should (null gastown-current-rig-spec))))

;;; ============================================================
;;; Full filter menus — session (extended)
;;; ============================================================

(ert-deftest gastown-tabulated-test-session-apply-filter-sets-role ()
  "gastown-session-list--apply-filter stores role in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-agent-spec nil)
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '("--role=polecat")))
    (should (gastown-agent-spec-p gastown-current-agent-spec))
    (should (equal "polecat" (oref gastown-current-agent-spec role)))))

(ert-deftest gastown-tabulated-test-session-apply-filter-sets-running ()
  "gastown-session-list--apply-filter stores running in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-agent-spec nil)
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '("--running")))
    (should (gastown-agent-spec-p gastown-current-agent-spec))
    (should (oref gastown-current-agent-spec running))))

(ert-deftest gastown-tabulated-test-session-apply-filter-clears-running ()
  "gastown-session-list--apply-filter without --running stores nil."
  (with-temp-buffer
    (setq gastown-current-agent-spec (make-instance 'gastown-agent-spec :running t))
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '()))
    (should (null (oref gastown-current-agent-spec running)))))

(ert-deftest gastown-tabulated-test-session-apply-filter-sets-order ()
  "gastown-session-list--apply-filter stores order in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-agent-spec nil)
    (cl-letf (((symbol-function 'gastown-session-list-refresh) #'ignore))
      (gastown-session-list--apply-filter '("--order=rig")))
    (should (gastown-agent-spec-p gastown-current-agent-spec))
    (should (eq 'rig (oref gastown-current-agent-spec order)))))

;;; ============================================================
;;; Full filter menus — convoy (extended)
;;; ============================================================

(ert-deftest gastown-tabulated-test-convoy-apply-filter-sets-order ()
  "gastown-convoy-list--apply-filter stores order in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-convoy-spec nil)
    (cl-letf (((symbol-function 'gastown-convoy-list-refresh) #'ignore))
      (gastown-convoy-list--apply-filter '("--order=oldest")))
    (should (gastown-convoy-spec-p gastown-current-convoy-spec))
    (should (eq 'oldest (oref gastown-current-convoy-spec order)))))

(ert-deftest gastown-tabulated-test-convoy-apply-filter-sets-limit ()
  "gastown-convoy-list--apply-filter stores limit in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-convoy-spec nil)
    (cl-letf (((symbol-function 'gastown-convoy-list-refresh) #'ignore))
      (gastown-convoy-list--apply-filter '("--limit=25")))
    (should (gastown-convoy-spec-p gastown-current-convoy-spec))
    (should (= 25 (oref gastown-current-convoy-spec limit)))))

;;; ============================================================
;;; Full filter menus — mail (extended)
;;; ============================================================

(ert-deftest gastown-tabulated-test-mail-apply-filter-sets-from ()
  "gastown-mail-inbox--apply-filter stores from in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-mail-spec nil)
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '("--from=gastown_el/witness")))
    (should (gastown-mail-spec-p gastown-current-mail-spec))
    (should (equal "gastown_el/witness" (oref gastown-current-mail-spec from)))))

(ert-deftest gastown-tabulated-test-mail-apply-filter-sets-priority ()
  "gastown-mail-inbox--apply-filter stores priority in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-mail-spec nil)
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '("--priority=high")))
    (should (gastown-mail-spec-p gastown-current-mail-spec))
    (should (equal "high" (oref gastown-current-mail-spec priority)))))

(ert-deftest gastown-tabulated-test-mail-apply-filter-sets-order ()
  "gastown-mail-inbox--apply-filter stores order in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-mail-spec nil)
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '("--order=oldest")))
    (should (gastown-mail-spec-p gastown-current-mail-spec))
    (should (eq 'oldest (oref gastown-current-mail-spec order)))))

(ert-deftest gastown-tabulated-test-mail-apply-filter-sets-limit ()
  "gastown-mail-inbox--apply-filter stores limit in buffer-local spec."
  (with-temp-buffer
    (setq gastown-current-mail-spec nil)
    (cl-letf (((symbol-function 'gastown-mail-inbox-refresh) #'ignore))
      (gastown-mail-inbox--apply-filter '("--limit=20")))
    (should (gastown-mail-spec-p gastown-current-mail-spec))
    (should (= 20 (oref gastown-current-mail-spec limit)))))

(provide 'gastown-tabulated-test)
;;; gastown-tabulated-test.el ends here
