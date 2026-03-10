;;; gastown-test.el --- Test infrastructure with Dolt isolation -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Test infrastructure for gastown.el that provides isolated Dolt server
;; lifecycle management.  Tests that invoke `gt' or `bd' CLI commands must
;; NEVER connect to the production Dolt server on port 3307.  This module
;; ensures test isolation by:
;;
;;   1. Starting a dedicated Dolt server on a dynamic port with a temp
;;      data directory.
;;   2. Setting BEADS_DOLT_PORT so all bd/gt commands route to the test
;;      server.
;;   3. Unsetting GT_ROOT to prevent Gas Town auto-detection (which
;;      forces port 3307).
;;   4. Cleaning up reliably even on test failure or interruption.
;;
;; Usage:
;;
;;   ;; Per-test isolation (starts/stops server per test):
;;   (ert-deftest my-integration-test ()
;;     :tags '(:integration)
;;     (gastown-test-skip-unless-gt)
;;     (gastown-test-with-dolt-server ()
;;       ;; test code here — gt/bd commands use isolated server
;;       ))
;;
;;   ;; Suite-level isolation (faster — shared server across tests):
;;   ;; Configure in Eldev via gastown-test-suite-setup / gastown-test-suite-teardown

;;; Code:

(require 'cl-lib)

(defvar gastown-executable)

;;; ============================================================
;;; Daemon isolation
;;; ============================================================

(defvar gastown-test-no-daemon t
  "When non-nil, tests use BD_NO_DAEMON=1 for file-backed bd storage.
This prevents tests from connecting to the production Dolt server
on port 3307.  Defaults to t for safety.

Integration tests that explicitly need a real Dolt server use
`gastown-test-with-dolt-server', which removes BD_NO_DAEMON from
the subprocess environment so bd can connect to the isolated
test server.")

;;; ============================================================
;;; Server State
;;; ============================================================

(defvar gastown-test--dolt-server-process nil
  "Process object for the running test Dolt server, or nil.")

(defvar gastown-test--dolt-server-port nil
  "Port number of the running test Dolt server, or nil.")

(defvar gastown-test--dolt-server-tmpdir nil
  "Temporary directory for the test Dolt server data, or nil.")

(defvar gastown-test--dolt-server-pidfile nil
  "PID file path for the test Dolt server, or nil.")

(defvar gastown-test--saved-env nil
  "Saved environment variables to restore after test cleanup.")

;;; ============================================================
;;; Skip Helpers
;;; ============================================================

(defun gastown-test-skip-unless-gt ()
  "Skip test if gt executable is not available."
  (unless (executable-find (if (boundp 'gastown-executable)
                               gastown-executable
                             "gt"))
    (ert-skip "gt executable not found")))

(defun gastown-test-skip-unless-dolt ()
  "Skip test if dolt executable is not available."
  (unless (executable-find "dolt")
    (ert-skip "dolt executable not found")))

(defun gastown-test-skip-unless-dolt-server ()
  "Skip test if the test Dolt server is not running."
  (unless gastown-test--dolt-server-port
    (ert-skip "test Dolt server not available")))

;;; ============================================================
;;; Port Allocation
;;; ============================================================

(defun gastown-test--find-free-port ()
  "Find an available TCP port by binding to port 0.
Returns the port number."
  (let* ((proc (make-network-process
                :name "gastown-test-port-probe"
                :host "127.0.0.1"
                :service 0
                :server t
                :noquery t))
         (port (cadr (process-contact proc))))
    (delete-process proc)
    port))

;;; ============================================================
;;; Dolt Server Lifecycle
;;; ============================================================

(defun gastown-test-start-dolt-server ()
  "Start an isolated Dolt server on a dynamic port with temp data dir.
Sets `gastown-test--dolt-server-port' and related state variables.
Returns the port number, or nil if dolt is not installed."
  ;; Don't start if already running
  (when gastown-test--dolt-server-process
    (error "Test Dolt server already running on port %d"
           gastown-test--dolt-server-port))

  (unless (executable-find "dolt")
    (message "WARN: dolt not found in PATH, skipping test server")
    (cl-return-from gastown-test-start-dolt-server nil))

  ;; Clean up any stale test servers from previous runs
  (gastown-test--clean-stale-servers)

  (let* ((tmpdir (make-temp-file "gastown-test-dolt-" t))
         (dbdir (expand-file-name "data" tmpdir))
         (dolt-env (append `(,(concat "DOLT_ROOT_PATH=" tmpdir))
                           process-environment)))
    ;; Create data directory
    (make-directory dbdir t)

    ;; Configure dolt user identity
    (let ((process-environment dolt-env))
      (call-process "dolt" nil nil nil
                    "config" "--global" "--add" "user.name" "gastown-test")
      (call-process "dolt" nil nil nil
                    "config" "--global" "--add" "user.email" "test@gastown.local"))

    ;; Initialize dolt database
    (let ((default-directory dbdir)
          (process-environment dolt-env))
      (unless (zerop (call-process "dolt" nil nil nil "init"))
        (delete-directory tmpdir t)
        (error "Failed to initialize dolt database for test server")))

    ;; Find a free port (retry up to 3 times)
    (let ((port nil)
          (proc nil)
          (pidfile nil)
          (attempts 0)
          (max-attempts 3))
      (while (and (null proc) (< attempts max-attempts))
        (setq port (gastown-test--find-free-port))
        (setq attempts (1+ attempts))

        ;; Start dolt sql-server
        (condition-case err
            (let ((process-environment dolt-env)
                  (default-directory dbdir))
              (setq proc (start-process
                          "gastown-test-dolt"
                          " *gastown-test-dolt*"
                          "dolt" "sql-server"
                          "-H" "127.0.0.1"
                          "-P" (number-to-string port)
                          "--no-auto-commit"))
              (set-process-query-on-exit-flag proc nil)

              ;; Write PID file for stale cleanup
              (setq pidfile (expand-file-name
                             (format "gastown-test-dolt-%d.pid" port)
                             temporary-file-directory))
              (with-temp-buffer
                (insert (number-to-string (process-id proc)))
                (write-region (point-min) (point-max) pidfile))

              ;; Wait for server to become ready
              (unless (gastown-test--wait-for-server port 30)
                (delete-process proc)
                (ignore-errors (delete-file pidfile))
                (setq proc nil)
                (message "WARN: test dolt server did not become ready on port %d (attempt %d/%d)"
                         port attempts max-attempts)))
          (error
           (message "WARN: failed to start test dolt server (attempt %d/%d): %s"
                    attempts max-attempts (error-message-string err))
           (setq proc nil))))

      (unless proc
        (delete-directory tmpdir t)
        (error "Test dolt server failed to start after %d attempts" max-attempts))

      ;; Store state
      (setq gastown-test--dolt-server-process proc
            gastown-test--dolt-server-port port
            gastown-test--dolt-server-tmpdir tmpdir
            gastown-test--dolt-server-pidfile pidfile)

      port)))

(defun gastown-test-stop-dolt-server ()
  "Stop the test Dolt server and clean up all state."
  (when gastown-test--dolt-server-process
    ;; Kill the server process
    (when (process-live-p gastown-test--dolt-server-process)
      (kill-process gastown-test--dolt-server-process)
      ;; Wait briefly for clean shutdown
      (accept-process-output gastown-test--dolt-server-process 2))
    (ignore-errors
      (delete-process gastown-test--dolt-server-process))
    (setq gastown-test--dolt-server-process nil))

  ;; Remove PID file
  (when gastown-test--dolt-server-pidfile
    (ignore-errors (delete-file gastown-test--dolt-server-pidfile))
    (setq gastown-test--dolt-server-pidfile nil))

  ;; Remove temp directory
  (when gastown-test--dolt-server-tmpdir
    (ignore-errors (delete-directory gastown-test--dolt-server-tmpdir t))
    (setq gastown-test--dolt-server-tmpdir nil))

  ;; Clear port
  (setq gastown-test--dolt-server-port nil)

  ;; Kill the process buffer
  (when-let ((buf (get-buffer " *gastown-test-dolt*")))
    (kill-buffer buf)))

(defun gastown-test--wait-for-server (port timeout-secs)
  "Wait up to TIMEOUT-SECS for server to accept connections on PORT.
Returns non-nil if server is ready, nil if timeout."
  (let ((deadline (+ (float-time) timeout-secs)))
    (catch 'ready
      (while (< (float-time) deadline)
        (condition-case nil
            (let ((proc (make-network-process
                         :name "gastown-test-probe"
                         :host "127.0.0.1"
                         :service port
                         :noquery t)))
              (delete-process proc)
              (throw 'ready t))
          (error nil))
        (sleep-for 0.5))
      nil)))

;;; ============================================================
;;; Stale Server Cleanup
;;; ============================================================

(defun gastown-test--clean-stale-servers ()
  "Kill orphaned test Dolt servers from previous interrupted runs."
  (let ((pattern (expand-file-name "gastown-test-dolt-*.pid"
                                   temporary-file-directory)))
    (dolist (pidfile (file-expand-wildcards pattern))
      (condition-case nil
          (let* ((pid-str (with-temp-buffer
                            (insert-file-contents pidfile)
                            (string-trim (buffer-string))))
                 (pid (string-to-number pid-str)))
            (when (> pid 0)
              ;; Check if process is alive
              (when (zerop (call-process "kill" nil nil nil "-0"
                                         (number-to-string pid)))
                ;; Kill it
                (call-process "kill" nil nil nil "-9"
                              (number-to-string pid))
                (sleep-for 0.1)))
            (delete-file pidfile))
        (error (ignore-errors (delete-file pidfile)))))))

;;; ============================================================
;;; Test Macros
;;; ============================================================

(defmacro gastown-test-with-dolt-server (_args &rest body)
  "Execute BODY with an isolated Dolt server running.

Starts a dedicated Dolt server on a dynamic port, sets environment
variables so gt/bd commands route to it, and cleans up afterward.
The production Dolt server on port 3307 is never contacted.

ARGS is reserved for future keyword arguments (currently unused).

Example:
  (gastown-test-with-dolt-server ()
    (let ((output (shell-command-to-string \"gt status --json\")))
      (should (stringp output))))"
  (declare (indent 1) (debug (form body)))
  `(let ((gastown-test--dolt-server-process nil)
         (gastown-test--dolt-server-port nil)
         (gastown-test--dolt-server-tmpdir nil)
         (gastown-test--dolt-server-pidfile nil))
     (gastown-test-skip-unless-dolt)
     (let ((port (gastown-test-start-dolt-server)))
       (unwind-protect
           (let ((process-environment
                  (append
                   (list (format "BEADS_DOLT_PORT=%d" port)
                         (format "BEADS_DOLT_SERVER_PORT=%d" port)
                         "BEADS_TEST_MODE=1")
                   ;; Remove GT_ROOT to prevent Gas Town auto-detection
                   ;; (which forces port 3307).
                   ;; Remove BD_NO_DAEMON so bd can connect to the
                   ;; isolated test server on BEADS_DOLT_PORT.
                   (cl-remove-if
                    (lambda (e)
                      (or (string-prefix-p "GT_ROOT=" e)
                          (string-prefix-p "BD_NO_DAEMON=" e)))
                    process-environment))))
             ,@body)
         (gastown-test-stop-dolt-server)))))

(defmacro gastown-test-with-temp-project (args &rest body)
  "Execute BODY in a temporary directory with an isolated Dolt server.

ARGS is a plist with optional keys:
  :init-beads - If non-nil, initialize beads in the temp project
  :prefix     - Custom beads prefix

Creates a temporary git repository, optionally initializes beads,
and runs BODY with the temp dir as `default-directory'.  The Dolt
server is isolated from production.

Example:
  (gastown-test-with-temp-project (:init-beads t)
    (should (file-directory-p \".beads\")))"
  (declare (indent 1) (debug (form body)))
  (let ((temp-dir (make-symbol "temp-dir"))
        (init-beads (plist-get args :init-beads))
        (prefix (plist-get args :prefix)))
    `(gastown-test-with-dolt-server ()
       (let ((,temp-dir (make-temp-file "gastown-test-project-" t)))
         (unwind-protect
             (let ((default-directory ,temp-dir))
               ;; Initialize git
               (call-process "git" nil nil nil "init" "-q")
               (call-process "git" nil nil nil
                             "config" "user.email" "test@gastown.local")
               (call-process "git" nil nil nil
                             "config" "user.name" "Gastown Test")
               ,@(when init-beads
                   `((call-process "bd" nil nil nil
                                   "init"
                                   "--prefix"
                                   ,(or prefix
                                        '(gastown-test--generate-prefix))
                                   "--quiet"
                                   "--skip-hooks")))
               ,@body)
           (delete-directory ,temp-dir t))))))

;;; ============================================================
;;; Suite-Level Lifecycle (for Eldev integration)
;;; ============================================================

(defun gastown-test-suite-setup ()
  "Start the isolated Dolt server for the test suite.
Call from Eldev configuration before running tests.
Sets environment variables globally for all test processes."
  (when (executable-find "dolt")
    (let ((port (gastown-test-start-dolt-server)))
      (when port
        ;; Save current env for restoration
        (setq gastown-test--saved-env
              (list (cons "BEADS_DOLT_PORT" (getenv "BEADS_DOLT_PORT"))
                    (cons "BEADS_DOLT_SERVER_PORT" (getenv "BEADS_DOLT_SERVER_PORT"))
                    (cons "BEADS_TEST_MODE" (getenv "BEADS_TEST_MODE"))
                    (cons "GT_ROOT" (getenv "GT_ROOT"))))
        ;; Set test environment
        (setenv "BEADS_DOLT_PORT" (number-to-string port))
        (setenv "BEADS_DOLT_SERVER_PORT" (number-to-string port))
        (setenv "BEADS_TEST_MODE" "1")
        ;; Unset GT_ROOT to prevent Gas Town detection
        (setenv "GT_ROOT" nil)
        (message "gastown-test: Dolt server started on port %d" port)))))

(defun gastown-test-suite-teardown ()
  "Stop the isolated Dolt server and restore environment.
Call from Eldev configuration after running tests."
  (gastown-test-stop-dolt-server)
  ;; Restore saved environment
  (dolist (entry gastown-test--saved-env)
    (setenv (car entry) (cdr entry)))
  (setq gastown-test--saved-env nil)
  (message "gastown-test: Dolt server stopped"))

;;; ============================================================
;;; Utility Functions
;;; ============================================================

(defun gastown-test--generate-prefix ()
  "Generate a unique test prefix for beads initialization.
Uses format `gastownTestXXXXXX' where XXXXXX is random."
  (let ((chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        (suffix ""))
    (dotimes (_ 6)
      (setq suffix (concat suffix (string (aref chars (random (length chars)))))))
    (concat "gastownTest" suffix)))

(provide 'gastown-test)
;;; gastown-test.el ends here
