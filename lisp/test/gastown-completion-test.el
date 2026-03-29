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
;;; Async Prefetch Tests
;;; ============================================================

(ert-deftest gastown-completion-test-async-warm-rigs-defined ()
  "Test that gastown-completion--async-warm-rigs is defined."
  (should (fboundp 'gastown-completion--async-warm-rigs)))

(ert-deftest gastown-completion-test-async-warm-polecats-defined ()
  "Test that gastown-completion--async-warm-polecats is defined."
  (should (fboundp 'gastown-completion--async-warm-polecats)))

(ert-deftest gastown-completion-test-async-warm-convoys-defined ()
  "Test that gastown-completion--async-warm-convoys is defined."
  (should (fboundp 'gastown-completion--async-warm-convoys)))

(ert-deftest gastown-completion-test-prefetch-defined ()
  "Test that gastown-completion-prefetch is defined."
  (should (fboundp 'gastown-completion-prefetch)))

(ert-deftest gastown-completion-test-warm-if-stale-skips-fresh-cache ()
  "Test that warm-if-stale does not invoke warm-fn when cache is fresh."
  (let* ((mock-rig (gastown-completion-rig :name "cached_rig"))
         (gastown-completion--rig-cache (cons (float-time) (list mock-rig)))
         (warm-called nil))
    (gastown-completion--warm-if-stale
     'gastown-completion--rig-cache
     5
     (lambda () (setq warm-called t) nil)
     1.0)
    (should-not warm-called)))

(ert-deftest gastown-completion-test-warm-if-stale-warms-nil-cache ()
  "Test that warm-if-stale invokes warm-fn when cache is nil."
  (let* ((gastown-completion--rig-cache nil)
         (warm-called nil))
    (gastown-completion--warm-if-stale
     'gastown-completion--rig-cache
     5
     (lambda () (setq warm-called t) nil)
     0.001)
    (should warm-called)))

(ert-deftest gastown-completion-test-warm-if-stale-warms-stale-cache ()
  "Test that warm-if-stale invokes warm-fn when cache timestamp is expired."
  (let* ((gastown-completion--rig-cache (cons (- (float-time) 100) nil))
         (warm-called nil))
    (gastown-completion--warm-if-stale
     'gastown-completion--rig-cache
     5
     (lambda () (setq warm-called t) nil)
     0.001)
    (should warm-called)))

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

(ert-deftest gastown-completion-test-read-convoy-is-function ()
  "Test that gastown-completion-read-convoy is a function."
  (should (fboundp 'gastown-completion-read-convoy)))

(ert-deftest gastown-completion-test-read-formula-is-function ()
  "Test that gastown-completion-read-formula is a function."
  (should (fboundp 'gastown-completion-read-formula)))

(ert-deftest gastown-completion-test-read-crew-is-function ()
  "Test that gastown-completion-read-crew is a function."
  (should (fboundp 'gastown-completion-read-crew)))

;;; ============================================================
;;; Formula class tests
;;; ============================================================

(ert-deftest gastown-completion-test-formula-class-exists ()
  "Test that gastown-completion-formula class is defined."
  (should (find-class 'gastown-completion-formula)))

(ert-deftest gastown-completion-test-formula-construction ()
  "Test constructing a gastown-completion-formula object."
  (let ((formula (gastown-completion-formula
                  :name "shiny-enterprise"
                  :type "workflow"
                  :description "A standard enterprise workflow."
                  :vars 3)))
    (should (equal "shiny-enterprise" (oref formula name)))
    (should (equal "workflow" (oref formula type)))
    (should (equal "A standard enterprise workflow." (oref formula description)))
    (should (equal 3 (oref formula vars)))))

(ert-deftest gastown-completion-test-parse-formula ()
  "Test parsing a formula alist into a gastown-completion-formula object."
  (let* ((alist '((name . "shiny-enterprise")
                  (type . "workflow")
                  (description . "An enterprise workflow.")
                  (vars . 5)))
         (formula (gastown-completion--parse-formula alist)))
    (should (equal "shiny-enterprise" (oref formula name)))
    (should (equal "workflow" (oref formula type)))
    (should (equal "An enterprise workflow." (oref formula description)))
    (should (equal 5 (oref formula vars)))))

(ert-deftest gastown-completion-test-formula-annotate-returns-string ()
  "Test that formula annotation function returns a string."
  (let* ((formula (gastown-completion-formula
                   :name "test-formula"
                   :type "workflow"
                   :description "Test description."
                   :vars 2))
         (candidate (propertize "test-formula" 'gastown-formula formula))
         (result (gastown-completion--formula-annotate candidate)))
    (should (stringp result))
    (should (string-match-p "workflow" result))
    (should (string-match-p "2 vars" result))))

(ert-deftest gastown-completion-test-formula-annotate-no-property ()
  "Test formula annotation returns empty string when no text property."
  (should (string= "" (gastown-completion--formula-annotate "no-property"))))

(ert-deftest gastown-completion-test-formula-table-returns-function ()
  "Test that gastown-completion-formula-table returns a function."
  (should (functionp (gastown-completion-formula-table))))

(ert-deftest gastown-completion-test-formula-table-metadata ()
  "Test that formula completion table returns correct metadata."
  (let* ((gastown-completion--formula-cache
          (cons (float-time)
                (list (gastown-completion-formula
                       :name "test-formula"
                       :type "workflow"
                       :description "A test."
                       :vars 1))))
         (table (gastown-completion-formula-table))
         (metadata (funcall table "" nil 'metadata)))
    (should (equal 'gastown-formula
                   (cdr (assq 'category (cdr metadata)))))
    (should (assq 'annotation-function (cdr metadata)))))

;;; ============================================================
;;; Crew class tests
;;; ============================================================

(ert-deftest gastown-completion-test-crew-class-exists ()
  "Test that gastown-completion-crew class is defined."
  (should (find-class 'gastown-completion-crew)))

(ert-deftest gastown-completion-test-crew-construction ()
  "Test constructing a gastown-completion-crew object."
  (let ((crew (gastown-completion-crew
               :name "roman"
               :rig "gastown_el"
               :branch "main"
               :has-session t)))
    (should (equal "roman" (oref crew name)))
    (should (equal "gastown_el" (oref crew rig)))
    (should (equal "main" (oref crew branch)))
    (should (eq t (oref crew has-session)))))

(ert-deftest gastown-completion-test-parse-crew ()
  "Test parsing a crew alist into a gastown-completion-crew object."
  (let* ((alist '((name . "roman")
                  (rig . "gastown_el")
                  (branch . "main")
                  (has_session . t)))
         (crew (gastown-completion--parse-crew alist)))
    (should (equal "roman" (oref crew name)))
    (should (equal "gastown_el" (oref crew rig)))
    (should (equal "main" (oref crew branch)))
    (should (eq t (oref crew has-session)))))

(ert-deftest gastown-completion-test-crew-annotate-returns-string ()
  "Test that crew annotation function returns a string."
  (let* ((crew (gastown-completion-crew
                :name "roman"
                :rig "gastown_el"
                :branch "main"
                :has-session t))
         (candidate (propertize "roman" 'gastown-crew crew))
         (result (gastown-completion--crew-annotate candidate)))
    (should (stringp result))
    (should (string-match-p "gastown_el" result))
    (should (string-match-p "main" result))
    (should (string-match-p "active" result))))

(ert-deftest gastown-completion-test-crew-annotate-no-property ()
  "Test crew annotation returns empty string when no text property."
  (should (string= "" (gastown-completion--crew-annotate "no-property"))))

(ert-deftest gastown-completion-test-crew-table-returns-function ()
  "Test that gastown-completion-crew-table returns a function."
  (should (functionp (gastown-completion-crew-table))))

(ert-deftest gastown-completion-test-crew-table-metadata ()
  "Test that crew completion table returns correct metadata."
  (let* ((gastown-completion--crew-cache
          (cons (float-time)
                (list (gastown-completion-crew
                       :name "roman"
                       :rig "gastown_el"
                       :branch "main"
                       :has-session nil))))
         (table (gastown-completion-crew-table))
         (metadata (funcall table "" nil 'metadata)))
    (should (equal 'gastown-crew
                   (cdr (assq 'category (cdr metadata)))))
    (should (assq 'annotation-function (cdr metadata)))))

;;; ============================================================
;;; Cache invalidation tests
;;; ============================================================

(ert-deftest gastown-completion-test-invalidate-formula-cache ()
  "Test that invalidate-formula-cache clears the formula cache."
  (let ((gastown-completion--formula-cache '(1234567 . nil)))
    (gastown-completion-invalidate-formula-cache)
    (should (null gastown-completion--formula-cache))))

(ert-deftest gastown-completion-test-invalidate-crew-cache ()
  "Test that invalidate-crew-cache clears the crew cache."
  (let ((gastown-completion--crew-cache '(1234567 . nil)))
    (gastown-completion-invalidate-crew-cache)
    (should (null gastown-completion--crew-cache))))

;;; ============================================================
;;; gastown-formula-var Class Tests
;;; ============================================================

(ert-deftest gastown-completion-test-formula-var-class-exists ()
  "Test that gastown-formula-var class is defined."
  (should (find-class 'gastown-formula-var)))

(ert-deftest gastown-completion-test-formula-var-construction ()
  "Test constructing a gastown-formula-var object."
  (let ((var (gastown-formula-var
              :name "problem"
              :description "The problem statement"
              :default "none"
              :required t)))
    (should (equal "problem" (oref var name)))
    (should (equal "The problem statement" (oref var description)))
    (should (equal "none" (oref var default)))
    (should (eq t (oref var required)))))

(ert-deftest gastown-completion-test-formula-var-defaults ()
  "Test gastown-formula-var default slot values."
  (let ((var (gastown-formula-var :name "context")))
    (should (equal "context" (oref var name)))
    (should (null (oref var description)))
    (should (null (oref var default)))
    (should (null (oref var required)))))

(ert-deftest gastown-completion-test-formula-var-from-json-required ()
  "Test parsing a required formula var from JSON alist."
  (let* ((alist '((description . "The issue ID to work on")
                  (required . t)))
         (var (gastown-formula-var-from-json "issue" alist)))
    (should (object-of-class-p var 'gastown-formula-var))
    (should (equal "issue" (oref var name)))
    (should (equal "The issue ID to work on" (oref var description)))
    (should (null (oref var default)))
    (should (eq t (oref var required)))))

(ert-deftest gastown-completion-test-formula-var-from-json-optional ()
  "Test parsing an optional formula var (with default) from JSON alist."
  (let* ((alist '((description . "Base branch to rebase on")
                  (default . "main")))
         (var (gastown-formula-var-from-json "base_branch" alist)))
    (should (object-of-class-p var 'gastown-formula-var))
    (should (equal "base_branch" (oref var name)))
    (should (equal "main" (oref var default)))
    (should (null (oref var required)))))

(ert-deftest gastown-completion-test-formula-var-from-json-json-false ()
  "Test that :json-false in required field is treated as nil."
  (let* ((alist '((description . "Some var")
                  (required . :json-false)))
         (var (gastown-formula-var-from-json "myvar" alist)))
    (should (null (oref var required)))))

;;; ============================================================
;;; gastown-completion--parse-formula-vars Tests
;;; ============================================================

(ert-deftest gastown-completion-test-parse-formula-vars-empty ()
  "Test parsing nil vars returns nil."
  (should (null (gastown-completion--parse-formula-vars nil))))

(ert-deftest gastown-completion-test-parse-formula-vars-one-var ()
  "Test parsing a single var alist."
  (let* ((vars-alist '((issue (description . "The issue ID") (required . t))))
         (result (gastown-completion--parse-formula-vars vars-alist)))
    (should (= 1 (length result)))
    (let ((var (car result)))
      (should (object-of-class-p var 'gastown-formula-var))
      (should (equal "issue" (oref var name)))
      (should (eq t (oref var required))))))

(ert-deftest gastown-completion-test-parse-formula-vars-multiple ()
  "Test parsing multiple vars from a vars alist."
  (let* ((vars-alist
          '((issue (description . "Issue ID") (required . t))
            (base_branch (description . "Base branch") (default . "main"))))
         (result (gastown-completion--parse-formula-vars vars-alist)))
    (should (= 2 (length result)))
    (let ((names (mapcar (lambda (v) (oref v name)) result)))
      (should (member "issue" names))
      (should (member "base_branch" names)))))

;;; ============================================================
;;; Formula Vars Cache Tests
;;; ============================================================

(ert-deftest gastown-completion-test-formula-vars-cache-is-hash ()
  "Test that formula vars cache is a hash table."
  (should (hash-table-p gastown-completion--formula-vars-cache)))

(ert-deftest gastown-completion-test-formula-vars-cache-ttl-positive ()
  "Test that formula vars cache TTL is positive."
  (should (> gastown-completion--formula-vars-cache-ttl 0)))

(ert-deftest gastown-completion-test-invalidate-formula-vars-specific ()
  "Test invalidating a specific formula vars cache entry."
  (let ((gastown-completion--formula-vars-cache (make-hash-table :test 'equal)))
    (puthash "test-formula" (cons (float-time) nil) gastown-completion--formula-vars-cache)
    (gastown-completion-invalidate-formula-vars-cache "test-formula")
    (should (null (gethash "test-formula" gastown-completion--formula-vars-cache)))))

(ert-deftest gastown-completion-test-invalidate-formula-vars-all ()
  "Test invalidating the entire formula vars cache."
  (let ((gastown-completion--formula-vars-cache (make-hash-table :test 'equal)))
    (puthash "formula-a" (cons (float-time) nil) gastown-completion--formula-vars-cache)
    (puthash "formula-b" (cons (float-time) nil) gastown-completion--formula-vars-cache)
    (gastown-completion-invalidate-formula-vars-cache)
    (should (= 0 (hash-table-count gastown-completion--formula-vars-cache)))))

(ert-deftest gastown-completion-test-get-cached-formula-vars-uses-cache ()
  "Test that get-cached-formula-vars returns cached data when fresh."
  (let* ((mock-var (gastown-formula-var :name "issue" :required t))
         (cache (make-hash-table :test 'equal))
         (gastown-completion--formula-vars-cache cache)
         (gastown-completion--formula-vars-cache-ttl 60))
    (puthash "test-formula" (cons (float-time) (list mock-var)) cache)
    (let ((result (gastown-completion--get-cached-formula-vars "test-formula")))
      (should (equal (list mock-var) result)))))

(ert-deftest gastown-completion-test-get-cached-formula-vars-refreshes-stale ()
  "Test that get-cached-formula-vars refreshes stale cache."
  (let* ((mock-var (gastown-formula-var :name "fresh-var" :required t))
         (cache (make-hash-table :test 'equal))
         (gastown-completion--formula-vars-cache cache)
         (gastown-completion--formula-vars-cache-ttl 5))
    ;; Put stale data (100 seconds old)
    (puthash "test-formula" (cons (- (float-time) 100) nil) cache)
    (cl-letf (((symbol-function 'gastown-completion--fetch-formula-vars)
               (lambda (_name) (list mock-var))))
      (let ((result (gastown-completion--get-cached-formula-vars "test-formula")))
        (should (equal (list mock-var) result))))))

(ert-deftest gastown-completion-test-fetch-formula-vars-defined ()
  "Test that gastown-completion--fetch-formula-vars is defined."
  (should (fboundp 'gastown-completion--fetch-formula-vars)))

(provide 'gastown-completion-test)
;;; gastown-completion-test.el ends here
