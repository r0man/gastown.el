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
  (gastown-defcommand gastown-command--test-simple (gastown-command)
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
  (gastown-defcommand gastown-command--test-json (gastown-command-json)
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

(provide 'gastown-command-test)
;;; gastown-command-test.el ends here
