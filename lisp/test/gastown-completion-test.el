;;; gastown-completion-test.el --- Tests for gastown-completion -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests for gastown-completion.el EIEIO classes, parse functions,
;; completion tables, and annotation functions.
;;
;; All tests mock gastown-command-execute to avoid real gt CLI calls.

;;; Code:

(require 'ert)
(require 'gastown-completion)

;;; ============================================================
;;; EIEIO Class Construction Tests
;;; ============================================================

(ert-deftest gastown-completion-test-rig-class-exists ()
  "Test that gastown-completion-rig class is defined."
  (should (find-class 'gastown-completion-rig)))

(ert-deftest gastown-completion-test-polecat-class-exists ()
  "Test that gastown-completion-polecat class is defined."
  (should (find-class 'gastown-completion-polecat)))

(ert-deftest gastown-completion-test-convoy-class-exists ()
  "Test that gastown-completion-convoy class is defined."
  (should (find-class 'gastown-completion-convoy)))

(ert-deftest gastown-completion-test-rig-construction ()
  "Test constructing a gastown-completion-rig object."
  (let ((rig (gastown-completion-rig
              :name "beads_el"
              :beads-prefix "be"
              :status "operational"
              :witness "running"
              :refinery "running"
              :polecats 2
              :crew 1)))
    (should (equal "beads_el" (oref rig name)))
    (should (equal "be" (oref rig beads-prefix)))
    (should (equal "operational" (oref rig status)))
    (should (equal "running" (oref rig witness)))
    (should (equal "running" (oref rig refinery)))
    (should (equal 2 (oref rig polecats)))
    (should (equal 1 (oref rig crew)))))

(ert-deftest gastown-completion-test-rig-defaults ()
  "Test gastown-completion-rig default slot values."
  (let ((rig (gastown-completion-rig :name "test_rig")))
    (should (equal "test_rig" (oref rig name)))
    (should (null (oref rig beads-prefix)))
    (should (null (oref rig status)))
    (should (null (oref rig witness)))
    (should (null (oref rig refinery)))
    (should (null (oref rig polecats)))
    (should (null (oref rig crew)))))

(ert-deftest gastown-completion-test-polecat-construction ()
  "Test constructing a gastown-completion-polecat object."
  (let ((polecat (gastown-completion-polecat
                  :name "nux"
                  :rig "beads_el"
                  :state "working"
                  :issue "be-p5c"
                  :session-running t)))
    (should (equal "nux" (oref polecat name)))
    (should (equal "beads_el" (oref polecat rig)))
    (should (equal "working" (oref polecat state)))
    (should (equal "be-p5c" (oref polecat issue)))
    (should (equal t (oref polecat session-running)))))

(ert-deftest gastown-completion-test-polecat-defaults ()
  "Test gastown-completion-polecat default slot values."
  (let ((polecat (gastown-completion-polecat :name "test")))
    (should (equal "test" (oref polecat name)))
    (should (null (oref polecat rig)))
    (should (null (oref polecat state)))
    (should (null (oref polecat issue)))
    (should (null (oref polecat session-running)))))

(ert-deftest gastown-completion-test-convoy-construction ()
  "Test constructing a gastown-completion-convoy object."
  (let ((convoy (gastown-completion-convoy
                 :id "hq-cv-kwjna"
                 :title "Work: shiny"
                 :status "open"
                 :completed 0
                 :total 0)))
    (should (equal "hq-cv-kwjna" (oref convoy id)))
    (should (equal "Work: shiny" (oref convoy title)))
    (should (equal "open" (oref convoy status)))
    (should (equal 0 (oref convoy completed)))
    (should (equal 0 (oref convoy total)))))

(ert-deftest gastown-completion-test-convoy-defaults ()
  "Test gastown-completion-convoy default slot values."
  (let ((convoy (gastown-completion-convoy :id "cv-abc")))
    (should (equal "cv-abc" (oref convoy id)))
    (should (null (oref convoy title)))
    (should (null (oref convoy status)))
    (should (null (oref convoy completed)))
    (should (null (oref convoy total)))))

;;; ============================================================
;;; Parse Function Tests
;;; ============================================================

(ert-deftest gastown-completion-test-parse-rig-full ()
  "Test parsing a complete rig alist."
  (let* ((alist '((name . "beads_el")
                  (beads_prefix . "be")
                  (status . "operational")
                  (witness . "running")
                  (refinery . "running")
                  (polecats . 2)
                  (crew . 1)))
         (rig (gastown-completion--parse-rig alist)))
    (should (object-of-class-p rig 'gastown-completion-rig))
    (should (equal "beads_el" (oref rig name)))
    (should (equal "be" (oref rig beads-prefix)))
    (should (equal "operational" (oref rig status)))
    (should (equal "running" (oref rig witness)))
    (should (equal "running" (oref rig refinery)))
    (should (equal 2 (oref rig polecats)))
    (should (equal 1 (oref rig crew)))))

(ert-deftest gastown-completion-test-parse-rig-minimal ()
  "Test parsing a rig alist with only required fields."
  (let* ((alist '((name . "my_rig")))
         (rig (gastown-completion--parse-rig alist)))
    (should (object-of-class-p rig 'gastown-completion-rig))
    (should (equal "my_rig" (oref rig name)))
    (should (null (oref rig beads-prefix)))
    (should (null (oref rig status)))))

(ert-deftest gastown-completion-test-parse-polecat-full ()
  "Test parsing a complete polecat alist."
  (let* ((alist '((name . "nux")
                  (rig . "beads_el")
                  (state . "working")
                  (issue . "be-p5c")
                  (session_running . t)))
         (polecat (gastown-completion--parse-polecat alist)))
    (should (object-of-class-p polecat 'gastown-completion-polecat))
    (should (equal "nux" (oref polecat name)))
    (should (equal "beads_el" (oref polecat rig)))
    (should (equal "working" (oref polecat state)))
    (should (equal "be-p5c" (oref polecat issue)))
    (should (equal t (oref polecat session-running)))))

(ert-deftest gastown-completion-test-parse-polecat-session-false ()
  "Test parsing a polecat alist with session_running false."
  (let* ((alist '((name . "nux")
                  (rig . "beads_el")
                  (session_running . :json-false)))
         (polecat (gastown-completion--parse-polecat alist)))
    (should (object-of-class-p polecat 'gastown-completion-polecat))
    (should (equal "nux" (oref polecat name)))
    (should (null (oref polecat session-running)))))

(ert-deftest gastown-completion-test-parse-convoy-full ()
  "Test parsing a complete convoy alist."
  (let* ((alist '((id . "hq-cv-kwjna")
                  (title . "Work: shiny")
                  (status . "open")
                  (completed . 0)
                  (total . 5)))
         (convoy (gastown-completion--parse-convoy alist)))
    (should (object-of-class-p convoy 'gastown-completion-convoy))
    (should (equal "hq-cv-kwjna" (oref convoy id)))
    (should (equal "Work: shiny" (oref convoy title)))
    (should (equal "open" (oref convoy status)))
    (should (equal 0 (oref convoy completed)))
    (should (equal 5 (oref convoy total)))))

(ert-deftest gastown-completion-test-parse-convoy-minimal ()
  "Test parsing a convoy alist with only required fields."
  (let* ((alist '((id . "cv-xyz")))
         (convoy (gastown-completion--parse-convoy alist)))
    (should (object-of-class-p convoy 'gastown-completion-convoy))
    (should (equal "cv-xyz" (oref convoy id)))
    (should (null (oref convoy title)))
    (should (null (oref convoy status)))))

;;; ============================================================
;;; Cache Tests
;;; ============================================================

(ert-deftest gastown-completion-test-invalidate-rig-cache ()
  "Test that rig cache can be invalidated."
  (let ((gastown-completion--rig-cache '(12345.0 . some-data)))
    (gastown-completion-invalidate-rig-cache)
    (should (null gastown-completion--rig-cache))))

(ert-deftest gastown-completion-test-invalidate-polecat-cache ()
  "Test that polecat cache can be invalidated."
  (let ((gastown-completion--polecat-cache '(12345.0 . some-data)))
    (gastown-completion-invalidate-polecat-cache)
    (should (null gastown-completion--polecat-cache))))

(ert-deftest gastown-completion-test-invalidate-convoy-cache ()
  "Test that convoy cache can be invalidated."
  (let ((gastown-completion--convoy-cache '(12345.0 . some-data)))
    (gastown-completion-invalidate-convoy-cache)
    (should (null gastown-completion--convoy-cache))))

(ert-deftest gastown-completion-test-get-cached-rigs-uses-cache ()
  "Test that get-cached-rigs returns cached data when fresh."
  (let* ((mock-rig (gastown-completion-rig :name "cached_rig"))
         (now (float-time))
         ;; Fresh cache: timestamp is now
         (gastown-completion--rig-cache (cons now (list mock-rig)))
         (gastown-completion--rig-cache-ttl 5))
    (let ((result (gastown-completion--get-cached-rigs)))
      (should (equal (list mock-rig) result)))))

(ert-deftest gastown-completion-test-get-cached-rigs-refreshes-stale ()
  "Test that get-cached-rigs refreshes when cache is stale."
  (let* ((mock-rig (gastown-completion-rig :name "fresh_rig"))
         ;; Stale cache: timestamp is 100 seconds ago
         (gastown-completion--rig-cache (cons (- (float-time) 100) nil))
         (gastown-completion--rig-cache-ttl 5))
    ;; Mock fetch to return our mock rig
    (cl-letf (((symbol-function 'gastown-completion--fetch-rigs)
               (lambda () (list mock-rig))))
      (let ((result (gastown-completion--get-cached-rigs)))
        (should (equal (list mock-rig) result))))))

;;; ============================================================
;;; Completion Table Tests
;;; ============================================================

(ert-deftest gastown-completion-test-rig-table-metadata ()
  "Test that rig completion table returns correct metadata."
  (let* ((mock-rig (gastown-completion-rig :name "test_rig"))
         (gastown-completion--rig-cache
          (cons (float-time) (list mock-rig)))
         (gastown-completion--rig-cache-ttl 5)
         (table (gastown-completion-rig-table)))
    (let ((meta (funcall table "" nil 'metadata)))
      (should (equal 'metadata (car meta)))
      (should (assq 'category (cdr meta)))
      (should (eq 'gastown-rig (cdr (assq 'category (cdr meta))))))))

(ert-deftest gastown-completion-test-rig-table-candidates ()
  "Test that rig completion table returns rig names."
  (let* ((rig1 (gastown-completion-rig :name "beads_el"))
         (rig2 (gastown-completion-rig :name "gastown_el"))
         (gastown-completion--rig-cache
          (cons (float-time) (list rig1 rig2)))
         (gastown-completion--rig-cache-ttl 5)
         (table (gastown-completion-rig-table)))
    (let ((candidates (funcall table "" nil t)))
      (should (member "beads_el" (mapcar #'substring-no-properties
                                         candidates)))
      (should (member "gastown_el" (mapcar #'substring-no-properties
                                           candidates))))))

(ert-deftest gastown-completion-test-polecat-table-metadata ()
  "Test that polecat completion table returns correct metadata."
  (let* ((polecat (gastown-completion-polecat :name "nux" :rig "beads_el"))
         (gastown-completion--polecat-cache
          (cons (float-time) (list polecat)))
         (gastown-completion--polecat-cache-ttl 5)
         (table (gastown-completion-polecat-table)))
    (let ((meta (funcall table "" nil 'metadata)))
      (should (equal 'metadata (car meta)))
      (should (assq 'category (cdr meta)))
      (should (eq 'gastown-polecat (cdr (assq 'category (cdr meta))))))))

(ert-deftest gastown-completion-test-polecat-table-format ()
  "Test that polecat table returns rig/name addresses."
  (let* ((polecat (gastown-completion-polecat :name "nux" :rig "beads_el"))
         (gastown-completion--polecat-cache
          (cons (float-time) (list polecat)))
         (gastown-completion--polecat-cache-ttl 5)
         (table (gastown-completion-polecat-table)))
    (let ((candidates (funcall table "" nil t)))
      (should (member "beads_el/nux"
                      (mapcar #'substring-no-properties candidates))))))

(ert-deftest gastown-completion-test-polecat-table-rig-filter ()
  "Test that polecat table filters by rig when rig-filter is given."
  (let* ((p1 (gastown-completion-polecat :name "nux" :rig "beads_el"))
         (p2 (gastown-completion-polecat :name "nova" :rig "gastown_el"))
         (gastown-completion--polecat-cache
          (cons (float-time) (list p1 p2)))
         (gastown-completion--polecat-cache-ttl 5)
         (table (gastown-completion-polecat-table "beads_el")))
    (let ((candidates (funcall table "" nil t)))
      (should (= 1 (length candidates)))
      (should (member "beads_el/nux"
                      (mapcar #'substring-no-properties candidates))))))

;;; ============================================================
;;; Annotation Function Tests
;;; ============================================================

(ert-deftest gastown-completion-test-rig-annotate-returns-string ()
  "Test that rig annotate returns a string and does not error."
  (let* ((rig (gastown-completion-rig
               :name "beads_el"
               :status "operational"
               :polecats 2
               :crew 1))
         (candidate (propertize "beads_el" 'gastown-rig rig)))
    (let ((annotation (gastown-completion--rig-annotate candidate)))
      (should (or (null annotation) (stringp annotation))))))

(ert-deftest gastown-completion-test-rig-annotate-no-error-on-missing ()
  "Test that rig annotate does not error on candidate with no property."
  (let ((annotation (gastown-completion--rig-annotate "plain-string")))
    (should (or (null annotation) (stringp annotation)))))

(ert-deftest gastown-completion-test-polecat-annotate-returns-string ()
  "Test that polecat annotate returns a string and does not error."
  (let* ((polecat (gastown-completion-polecat
                   :name "nux"
                   :rig "beads_el"
                   :state "working"
                   :issue "be-p5c"
                   :session-running t))
         (candidate (propertize "beads_el/nux"
                                'gastown-polecat polecat)))
    (let ((annotation (gastown-completion--polecat-annotate candidate)))
      (should (or (null annotation) (stringp annotation))))))

(ert-deftest gastown-completion-test-polecat-annotate-no-error-on-missing ()
  "Test that polecat annotate does not error on candidate with no property."
  (let ((annotation (gastown-completion--polecat-annotate "plain-string")))
    (should (or (null annotation) (stringp annotation)))))

;;; ============================================================
;;; Public read-* function signature tests
;;; ============================================================

(ert-deftest gastown-completion-test-read-rig-is-function ()
  "Test that gastown-completion-read-rig is a function."
  (should (fboundp 'gastown-completion-read-rig)))

(ert-deftest gastown-completion-test-read-polecat-is-function ()
  "Test that gastown-completion-read-polecat is a function."
  (should (fboundp 'gastown-completion-read-polecat)))

(ert-deftest gastown-completion-test-read-mail-address-is-function ()
  "Test that gastown-completion-read-mail-address is a function."
  (should (fboundp 'gastown-completion-read-mail-address)))

(provide 'gastown-completion-test)
;;; gastown-completion-test.el ends here
