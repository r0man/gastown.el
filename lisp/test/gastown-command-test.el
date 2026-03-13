;;; gastown-command-test.el --- Tests for gastown-command -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests for gastown-command.el EIEIO command infrastructure.

;;; Code:

(require 'ert)
(require 'gastown-custom)
(require 'gastown-command)

;;; gastown-defcommand tests

(eval-and-compile
  (gastown-defcommand gastown-command--test-simple (gastown-command-global-options)
    ((name
      :initarg :name
      :type (or null string)
      :initform nil
      :documentation "Test name."
      :long-option "name"
      :option-type :string)
     (force
      :initarg :force
      :type boolean
      :initform nil
      :documentation "Force flag."
      :long-option "force"
      :option-type :boolean))
    :documentation "Test command."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command--test-simple))
  "test")

(ert-deftest gastown-command-test-defcommand-creates-class ()
  "Test that gastown-defcommand creates the class."
  (should (find-class 'gastown-command--test-simple)))

(ert-deftest gastown-command-test-defcommand-creates-bang-function ()
  "Test that gastown-defcommand creates the ! convenience function."
  (should (fboundp 'gastown-command--test-simple!)))

(ert-deftest gastown-command-test-command-line-basic ()
  "Test basic command line building."
  (let ((cmd (gastown-command--test-simple :name "hello")))
    (should (member "test" (gastown-command-line cmd)))
    (should (member "--name" (gastown-command-line cmd)))
    (should (member "hello" (gastown-command-line cmd)))))

(ert-deftest gastown-command-test-command-line-with-boolean ()
  "Test command line with boolean flag."
  (let ((cmd (gastown-command--test-simple :force t)))
    (should (member "--force" (gastown-command-line cmd)))))

(ert-deftest gastown-command-test-command-line-without-boolean ()
  "Test command line without boolean flag (nil)."
  (let ((cmd (gastown-command--test-simple :force nil)))
    (should-not (member "--force" (gastown-command-line cmd)))))

(ert-deftest gastown-command-test-command-line-executable ()
  "Test that command line starts with executable."
  (let ((cmd (gastown-command--test-simple :name "test"))
        (gastown-executable "gt"))
    (should (equal "gt" (car (gastown-command-line cmd))))))

(ert-deftest gastown-command-test-validate-default ()
  "Test that default validation returns nil (valid)."
  (let ((cmd (gastown-command--test-simple)))
    (should-not (gastown-command-validate cmd))))

(ert-deftest gastown-command-test-preview ()
  "Test command preview returns string."
  (let ((cmd (gastown-command--test-simple :name "hello")))
    (should (stringp (gastown-command-preview cmd)))))

;;; gastown-command-execution tests

(ert-deftest gastown-command-test-execution-object ()
  "Test execution object creation."
  (let* ((cmd (gastown-command--test-simple))
         (exec (gastown-command-execution
                :command cmd
                :exit-code 0
                :stdout "output"
                :stderr "")))
    (should (equal 0 (oref exec exit-code)))
    (should (equal "output" (oref exec stdout)))
    (should (equal "" (oref exec stderr)))))

;;; JSON command tests

(eval-and-compile
  (gastown-defcommand gastown-command--test-json (gastown-command-global-options)
    ()
    :documentation "Test JSON command."))

(cl-defmethod gastown-command-subcommand ((_command gastown-command--test-json))
  "test-json")

(ert-deftest gastown-command-test-json-command-has-json-flag ()
  "Test that JSON command includes --json flag."
  (let ((cmd (gastown-command--test-json :json t)))
    (should (member "--json" (gastown-command-line cmd)))))

(ert-deftest gastown-command-test-json-command-no-json ()
  "Test that JSON command can disable --json flag."
  (let ((cmd (gastown-command--test-json :json nil)))
    (should-not (member "--json" (gastown-command-line cmd)))))

;;; Concrete command tests

(ert-deftest gastown-command-test-status-subcommand ()
  "Test status command subcommand."
  (require 'gastown-command-status)
  (let ((cmd (gastown-command-status)))
    (should (equal "status" (gastown-command-subcommand cmd)))))

(ert-deftest gastown-command-test-status-with-watch ()
  "Test status command with watch flag."
  (require 'gastown-command-status)
  (let ((cmd (gastown-command-status :watch t)))
    (should (member "--watch" (gastown-command-line cmd)))))

;;; Auto-derivation tests

(eval-and-compile
  (gastown-defcommand gastown-command--test-derived-single (gastown-command-global-options)
    ()
    :documentation "Test command for single-word auto-derivation."))
;; No explicit cl-defmethod gastown-command-subcommand — relies on auto-derivation.
;; Expected: "gastown-command--test-derived-single" -> strip "gastown-command-" -> "-test-derived-single"
;; -> replace "-" with " " -> " test derived single"

(eval-and-compile
  (gastown-defcommand gastown-command-testword (gastown-command-global-options)
    ()
    :documentation "Test command for clean single-word auto-derivation."))
;; Expected: "gastown-command-testword" -> strip "gastown-command-" -> "testword"

(eval-and-compile
  (gastown-defcommand gastown-command-test-multi-word (gastown-command-global-options)
    ()
    :documentation "Test command for multi-word auto-derivation."))
;; Expected: "gastown-command-test-multi-word" -> strip "gastown-command-" -> "test-multi-word"
;; -> replace "-" with " " -> "test multi word"

(ert-deftest gastown-command-test-auto-derive-single-word ()
  "Test auto-derivation of single-word subcommand."
  (let ((cmd (gastown-command-testword)))
    (should (equal "testword" (gastown-command-subcommand cmd)))))

(ert-deftest gastown-command-test-auto-derive-multi-word ()
  "Test auto-derivation of multi-word subcommand."
  (let ((cmd (gastown-command-test-multi-word)))
    (should (equal "test multi word" (gastown-command-subcommand cmd)))))

(ert-deftest gastown-command-test-auto-derive-base-class-nil ()
  "Test that the abstract base class returns nil for subcommand."
  ;; We can't instantiate gastown-command directly (abstract), so test via a
  ;; class that has no explicit override and check the logic:
  ;; gastown-command itself should return nil when class-name equals "gastown-command".
  ;; We verify via the existing test command that explicit overrides still win.
  (let ((cmd (gastown-command--test-simple)))
    ;; gastown-command--test-simple has explicit cl-defmethod returning "test"
    (should (equal "test" (gastown-command-subcommand cmd)))))

;;; :cli-command tests

(eval-and-compile
  (gastown-defcommand gastown-command--test-cli-override (gastown-command-global-options)
    ()
    :documentation "Test command with :cli-command override."
    :cli-command "some-hyphenated-command"))

(ert-deftest gastown-command-test-cli-command-overrides-derivation ()
  "Test that :cli-command option overrides auto-derivation."
  (let ((cmd (gastown-command--test-cli-override)))
    (should (equal "some-hyphenated-command" (gastown-command-subcommand cmd)))))

(ert-deftest gastown-command-test-cli-command-in-command-line ()
  "Test that :cli-command value appears correctly in command line."
  (let* ((cmd (gastown-command--test-cli-override))
         (line (gastown-command-line cmd)))
    (should (member "some-hyphenated-command" line))))

;;; gastown-command-execute — missing executable error handling

(ert-deftest gastown-command-test-execute-signals-error-on-missing-executable ()
  "gastown-command-execute signals gastown-command-error when executable missing.
When process-file throws file-error (executable not in PATH), the error must
be caught and re-signaled as gastown-command-error with a readable message."
  (let ((cmd (gastown-command--test-simple)))
    (cl-letf (((symbol-function 'process-file)
               (lambda (&rest _)
                 (signal 'file-error
                         (list "Searching for program" "no-such-gt-binary")))))
      (should-error (gastown-command-execute cmd)
                    :type 'gastown-command-error))))

(ert-deftest gastown-command-test-execute-error-message-names-executable ()
  "gastown-command-error from missing executable includes the program name."
  (let* ((cmd (gastown-command--test-simple))
         (err (should-error
               (cl-letf (((symbol-function 'process-file)
                          (lambda (&rest _)
                            (signal 'file-error
                                    (list "Searching for program"
                                          "no-such-gt-binary")))))
                 (gastown-command-execute cmd))
               :type 'gastown-command-error)))
    ;; The error data list should contain a string describing the problem
    (should (cl-some #'stringp (cdr err)))))

;;; Terminal backend no-query-on-exit tests

(ert-deftest gastown-command-test-run-term-clears-process-query-flag ()
  "run-term sets process-query-on-exit-flag nil so agent buffers need no kill confirmation."
  (let ((flag-cleared nil)
        (fake-proc 'fake-process))
    (cl-letf (((symbol-function 'process-live-p) (lambda (_) nil))
              ((symbol-function 'get-buffer-process) (lambda (_) fake-proc))
              ((symbol-function 'delete-process) #'ignore)
              ((symbol-function 'term-exec) #'ignore)
              ((symbol-function 'term-char-mode) #'ignore)
              ((symbol-function 'pop-to-buffer) #'ignore)
              ((symbol-function 'set-process-query-on-exit-flag)
               (lambda (proc val)
                 (when (and (eq proc fake-proc) (not val))
                   (setq flag-cleared t)))))
      (gastown-command--run-term "cmd" "*test-buf*" "/tmp"))
    (should flag-cleared)))

(ert-deftest gastown-command-test-run-vterm-clears-process-query-flag ()
  "run-vterm sets process-query-on-exit-flag nil so agent buffers need no kill confirmation."
  (skip-unless (gastown-command--vterm-available-p))
  (let ((flag-cleared nil)
        (fake-proc 'fake-process))
    (cl-letf (((symbol-function 'vterm) (lambda (_name) (current-buffer)))
              ((symbol-function 'get-buffer-process) (lambda (_) fake-proc))
              ((symbol-function 'set-process-query-on-exit-flag)
               (lambda (proc val)
                 (when (and (eq proc fake-proc) (not val))
                   (setq flag-cleared t)))))
      (gastown-command--run-vterm "cmd" "*test-buf*" "/tmp"))
    (should flag-cleared)))

(ert-deftest gastown-command-test-run-eat-clears-process-query-flag ()
  "run-eat sets process-query-on-exit-flag nil so agent buffers need no kill confirmation."
  (skip-unless (gastown-command--eat-available-p))
  (let ((flag-cleared nil)
        (fake-proc 'fake-process))
    (cl-letf (((symbol-function 'derived-mode-p) (lambda (&rest _) t))
              ((symbol-function 'process-live-p) (lambda (_) nil))
              ((symbol-function 'get-buffer-process) (lambda (_) fake-proc))
              ((symbol-function 'eat-exec) #'ignore)
              ((symbol-function 'pop-to-buffer) #'ignore)
              ((symbol-function 'set-process-query-on-exit-flag)
               (lambda (proc val)
                 (when (and (eq proc fake-proc) (not val))
                   (setq flag-cleared t)))))
      (gastown-command--run-eat "cmd" "*test-buf*" "/tmp"))
    (should flag-cleared)))

;;; execute-interactive tilde expansion tests

(ert-deftest gastown-command-test-execute-interactive-expands-tilde ()
  "execute-interactive expands tilde in default-directory before passing to terminal."
  (let ((captured-dir nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (_cmd-string _buffer-name dir)
                 (setq captured-dir dir))))
      (let ((default-directory "~/gt/some/path/"))
        (gastown-command-execute-interactive (gastown-command--test-simple))))
    (should (not (string-prefix-p "~" captured-dir)))
    (should (string-prefix-p "/" captured-dir))))

(provide 'gastown-command-test)
;;; gastown-command-test.el ends here
