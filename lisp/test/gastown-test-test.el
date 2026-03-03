;;; gastown-test-test.el --- Tests for gastown-test infrastructure -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests that verify the test infrastructure itself works correctly.
;; These tests ensure Dolt server isolation prevents production pollution.

;;; Code:

(require 'ert)
(require 'gastown-test)

;;; ============================================================
;;; Port allocation tests
;;; ============================================================

(ert-deftest gastown-test-find-free-port ()
  "Test that find-free-port returns a valid port number."
  (let ((port (gastown-test--find-free-port)))
    (should (integerp port))
    (should (> port 0))
    (should (<= port 65535))))

(ert-deftest gastown-test-find-free-port-unique ()
  "Test that successive calls return different ports."
  (let ((port1 (gastown-test--find-free-port))
        (port2 (gastown-test--find-free-port)))
    (should (integerp port1))
    (should (integerp port2))
    ;; Ports should generally be different (not 100% guaranteed but
    ;; extremely unlikely to collide with ephemeral port allocation)
    (should (not (equal port1 port2)))))

;;; ============================================================
;;; Prefix generation tests
;;; ============================================================

(ert-deftest gastown-test-generate-prefix ()
  "Test that prefix generation returns valid format."
  (let ((prefix (gastown-test--generate-prefix)))
    (should (stringp prefix))
    (should (string-prefix-p "gastownTest" prefix))
    (should (= (length prefix) (+ (length "gastownTest") 6)))))

(ert-deftest gastown-test-generate-prefix-unique ()
  "Test that successive prefix calls return different values."
  (let ((p1 (gastown-test--generate-prefix))
        (p2 (gastown-test--generate-prefix)))
    (should-not (equal p1 p2))))

;;; ============================================================
;;; Skip helper tests
;;; ============================================================

(ert-deftest gastown-test-skip-unless-gt-available ()
  "Test that skip-unless-gt works when gt is available."
  (if (executable-find "gt")
      (should-not (gastown-test-skip-unless-gt))
    (should-error (gastown-test-skip-unless-gt))))

;;; ============================================================
;;; Dolt server isolation tests
;;; ============================================================

(ert-deftest gastown-test-dolt-server-lifecycle ()
  "Test that the Dolt server starts and stops cleanly."
  :tags '(:integration)
  (gastown-test-skip-unless-dolt)
  (let ((gastown-test--dolt-server-process nil)
        (gastown-test--dolt-server-port nil)
        (gastown-test--dolt-server-tmpdir nil)
        (gastown-test--dolt-server-pidfile nil))
    (unwind-protect
        (let ((port (gastown-test-start-dolt-server)))
          (should (integerp port))
          (should (> port 0))
          (should (/= port 3307))  ; MUST NOT be production port
          (should (process-live-p gastown-test--dolt-server-process))
          (should (file-directory-p gastown-test--dolt-server-tmpdir)))
      (gastown-test-stop-dolt-server))))

(ert-deftest gastown-test-dolt-server-not-production-port ()
  "Test that the test server never uses production port 3307."
  :tags '(:integration)
  (gastown-test-skip-unless-dolt)
  (gastown-test-with-dolt-server ()
    (should gastown-test--dolt-server-port)
    (should (/= gastown-test--dolt-server-port 3307))
    ;; Verify BEADS_DOLT_PORT is set to test port
    (should (equal (getenv "BEADS_DOLT_PORT")
                   (number-to-string gastown-test--dolt-server-port)))
    ;; Verify GT_ROOT is unset
    (should-not (getenv "GT_ROOT"))))

(ert-deftest gastown-test-dolt-server-accepts-connections ()
  "Test that the isolated Dolt server accepts MySQL connections."
  :tags '(:integration)
  (gastown-test-skip-unless-dolt)
  (gastown-test-with-dolt-server ()
    ;; Server should accept TCP connections
    (let ((proc (make-network-process
                 :name "gastown-test-verify"
                 :host "127.0.0.1"
                 :service gastown-test--dolt-server-port
                 :noquery t)))
      (should (processp proc))
      (delete-process proc))))

(ert-deftest gastown-test-dolt-server-cleanup-on-error ()
  "Test that server is cleaned up even when test body signals an error."
  :tags '(:integration)
  (gastown-test-skip-unless-dolt)
  (let ((saved-port nil)
        (saved-tmpdir nil))
    (ignore-errors
      (gastown-test-with-dolt-server ()
        (setq saved-port gastown-test--dolt-server-port)
        (setq saved-tmpdir gastown-test--dolt-server-tmpdir)
        (error "Simulated test failure")))
    ;; Server should be cleaned up
    (should-not gastown-test--dolt-server-process)
    (should-not gastown-test--dolt-server-port)
    ;; Temp dir should be removed
    (when saved-tmpdir
      (should-not (file-directory-p saved-tmpdir)))))

(provide 'gastown-test-test)
;;; gastown-test-test.el ends here
