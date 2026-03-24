;;; gastown-command.el --- EIEIO command classes for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for Gas Town CLI commands,
;; providing an object-oriented interface to gt command execution.
;;
;; The architecture reuses beads.el's EIEIO command class infrastructure
;; (beads-meta) for slot metadata, command-line building, and transient
;; generation.
;;
;; Class hierarchy:
;;   gastown-command (abstract base)
;;     └─ gastown-command-global-options (global CLI flags: verbose, json)
;;         ├─ gastown-command-status
;;         ├─ gastown-command-rig-list
;;         ├─ gastown-command-polecat-list
;;         └─ ...
;;
;; Usage:
;;
;;   (let ((cmd (gastown-command-status :json t)))
;;     (gastown-command-execute cmd))
;;
;;   (gastown-command-line cmd)
;;   ;; => ("gt" "status" "--json" "--verbose")

;;; Code:

(require 'eieio)
(require 'beads-meta)    ; Reuse beads.el slot metadata infrastructure
(require 'beads-command) ; For generic method bridge
(require 'gastown-error)
(require 'cl-lib)
(require 'json)

;; Forward declarations
(defvar gastown-executable)
(declare-function gastown--log "gastown")

;; Forward declarations for optional terminal packages
(defvar vterm-shell)
(defvar vterm-buffer-name)
(declare-function vterm "vterm")
(declare-function eat-mode "eat")
(declare-function eat-exec "eat")
(declare-function term-mode "term")
(declare-function term-exec "term")
(declare-function term-char-mode "term")
(defvar compilation-filter-start)
(declare-function ansi-color-apply-on-region "ansi-color")

;;; ============================================================
;;; Command Definition Macro
;;; ============================================================

(defmacro gastown-defcommand (name superclasses slots &rest options)
  "Define a gastown command class with auto-generated ! convenience function.

NAME is the class name (a symbol like `gastown-command-foo').
SUPERCLASSES is the list of parent classes.
SLOTS is the list of slot definitions.
OPTIONS are additional class options like :documentation.

This macro:
1. Defines the class using `defclass'
2. Generates a NAME! convenience function that executes the command
   and returns the result from the execution object

Custom keyword options (stripped before passing to defclass):
  :cli-command STR    - Explicit CLI subcommand string.  When not
                        specified, the subcommand is auto-derived
                        from the class name by the default method
                        on `gastown-command'.
  :global-section SYM - Generate a transient menu and include SYM
                        as a global options section.  The transient
                        name is derived by stripping \"-command-\"
                        from NAME.  The docstring uses the first
                        sentence of :documentation.

Example:
  (gastown-defcommand gastown-command-foo (gastown-command-global-options)
    ((name :initarg :name)
     (force :initarg :force :type boolean))
    :documentation \"Foo command.\")

This generates:
  (defclass gastown-command-foo ...)
  (defun gastown-command-foo! (&rest args) ...)"
  (declare (indent 2))
  (let* ((result-1 (beads--extract-option :global-section options))
         (global-section (car result-1))
         (options-2 (cdr result-1))
         (result-2 (beads--extract-option :cli-command options-2))
         (cli-command (car result-2))
         (defclass-options (cdr result-2))
         (final-slots (if cli-command
                          (append slots
                                  `((cli-command
                                     :initform ,cli-command
                                     :allocation :class
                                     :documentation "CLI subcommand name.")))
                        slots))
         (bang-fn (intern (concat (symbol-name name) "!")))
         (transient-name (when global-section
                           (beads--derive-transient-name name)))
         (transient-prefix (when transient-name
                             (symbol-name transient-name)))
         (doc-pos (cl-position :documentation defclass-options))
         (docstring (when doc-pos (nth (1+ doc-pos) defclass-options)))
         (short-doc (when global-section
                      (beads--extract-first-sentence docstring)))
         (autoload-file (when transient-name
                          (beads--current-feature-name))))
    `(progn
       ,@(when (and transient-name autoload-file)
           `((autoload ',transient-name ,autoload-file nil t)))
       (eval-and-compile
         (defclass ,name ,superclasses ,final-slots ,@defclass-options))
       (defun ,bang-fn (&rest args)
         ,(format "Execute %s and return result.\n\nARGS are passed to the constructor." name)
         (oref (gastown-command-execute (apply #',name args)) result))
       ,@(when global-section
           `((beads-meta-define-transient ,name ,transient-prefix
               ,short-doc
               ,global-section))))))

;;; Terminal Backend Customization

(defgroup gastown-terminal nil
  "Terminal settings for gastown command execution."
  :group 'gastown
  :prefix "gastown-terminal-")

(defcustom gastown-terminal-backend nil
  "Backend to use for interactive command execution.

When nil (auto-detect), tries backends in order: vterm, eat, term.
The first available backend is used.

Available backends:
- nil: Auto-detect best available backend (vterm > eat > term).
- `vterm': Use vterm (libvterm-based terminal).
- `eat': Use Eat (Emulate A Terminal).
- `term': Use built-in `term-mode' terminal emulator."
  :type '(choice (const :tag "Auto-detect (vterm > eat > term)" nil)
                 (const :tag "Vterm (requires vterm package)" vterm)
                 (const :tag "Eat (requires eat package)" eat)
                 (const :tag "Term mode (built-in)" term))
  :group 'gastown-terminal)

;;; Terminal Backend Implementations

(defun gastown-command--run-term (cmd-string buffer-name default-dir)
  "Run CMD-STRING in term buffer BUFFER-NAME from DEFAULT-DIR."
  (require 'term)
  (let* ((default-directory default-dir)
         (process-environment (cons "CLICOLOR_FORCE=1" process-environment))
         (buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (setq-local default-directory default-dir)
      (unless (derived-mode-p 'term-mode)
        (term-mode))
      (let ((proc (get-buffer-process buf)))
        (when (and proc (process-live-p proc))
          (delete-process proc)))
      (erase-buffer)
      (term-exec buf buffer-name shell-file-name nil
                 (list "-c" (concat "cd " (shell-quote-argument default-dir)
                                    " && " cmd-string "; exit")))
      (term-char-mode)
      (setq-local kill-buffer-query-functions
                  (remq 'process-kill-buffer-query-function
                        kill-buffer-query-functions))
      (when-let ((proc (get-buffer-process buf)))
        (set-process-query-on-exit-flag proc nil)))
    (pop-to-buffer buf)))

(defun gastown-command--vterm-available-p ()
  "Return non-nil if vterm is available."
  (require 'vterm nil t))

(defun gastown-command--run-vterm (cmd-string buffer-name default-dir)
  "Run CMD-STRING in vterm buffer BUFFER-NAME from DEFAULT-DIR."
  (unless (gastown-command--vterm-available-p)
    (user-error "Vterm package not installed.  Install it or change `gastown-terminal-backend'"))
  (let* ((default-directory default-dir)
         (process-environment (cons "CLICOLOR_FORCE=1" process-environment))
         (vterm-shell (format "%s -c %s"
                              shell-file-name
                              (shell-quote-argument
                               (concat "cd " (shell-quote-argument default-dir)
                                       " && " cmd-string))))
         (vterm-buffer-name buffer-name)
         (buf (vterm buffer-name)))
    (with-current-buffer buf
      (setq-local default-directory default-dir)
      (setq-local vterm-kill-buffer-on-exit nil)
      (setq-local kill-buffer-query-functions
                  (remq 'process-kill-buffer-query-function
                        kill-buffer-query-functions))
      (when-let ((proc (get-buffer-process buf)))
        (set-process-query-on-exit-flag proc nil)))
    buf))

(defun gastown-command--eat-available-p ()
  "Return non-nil if eat is available."
  (require 'eat nil t))

(defun gastown-command--run-eat (cmd-string buffer-name default-dir)
  "Run CMD-STRING in eat buffer BUFFER-NAME from DEFAULT-DIR."
  (unless (gastown-command--eat-available-p)
    (user-error "Eat package not installed.  Install it or change `gastown-terminal-backend'"))
  (let* ((default-directory default-dir)
         (process-environment (cons "CLICOLOR_FORCE=1" process-environment))
         (buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (setq-local default-directory default-dir)
      (unless (derived-mode-p 'eat-mode)
        (eat-mode))
      (let ((proc (get-buffer-process buf)))
        (when (and proc (process-live-p proc))
          (delete-process proc)))
      (eat-exec buf buffer-name shell-file-name nil
                (list "-c" (concat "cd " (shell-quote-argument default-dir)
                                   " && " cmd-string "; exit")))
      (setq-local kill-buffer-query-functions
                  (remq 'process-kill-buffer-query-function
                        kill-buffer-query-functions))
      (when-let ((proc (get-buffer-process buf)))
        (set-process-query-on-exit-flag proc nil)))
    (pop-to-buffer buf)))

(defun gastown-command--detect-best-backend ()
  "Detect the best available terminal backend.
Tries in order: vterm, eat, term.  Falls back to term (built-in)."
  (cond
   ((gastown-command--vterm-available-p) 'vterm)
   ((gastown-command--eat-available-p) 'eat)
   (t 'term)))

(defun gastown-command--run-in-terminal (cmd-string buffer-name default-dir)
  "Run CMD-STRING in terminal buffer BUFFER-NAME from DEFAULT-DIR.
Uses the backend specified by `gastown-terminal-backend'.
When nil, auto-detects best available backend."
  (let ((backend (or gastown-terminal-backend
                     (gastown-command--detect-best-backend))))
    (pcase backend
      ('vterm (gastown-command--run-vterm cmd-string buffer-name default-dir))
      ('eat (gastown-command--run-eat cmd-string buffer-name default-dir))
      ('term (gastown-command--run-term cmd-string buffer-name default-dir))
      (_ (gastown-command--run-term cmd-string buffer-name default-dir)))))

;;; Base Command Class

(defclass gastown-command ()
  ()
  :abstract t
  :documentation "Abstract base class for all gt commands.
Concrete commands inherit from `gastown-command-global-options'.
Execution results are returned in `gastown-command-execution' objects.")

;;; Global Options Class

(defclass gastown-command-global-options (gastown-command)
  ((verbose
    :initarg :verbose
    :type boolean
    :initform nil
    :documentation "Enable verbose output"
    :long-option "verbose"
    :short-option "v"
    :option-type :boolean)
   (json
    :initarg :json
    :type boolean
    :initform nil
    :documentation "Output in JSON format"
    :long-option "json"
    :option-type :boolean))
  :documentation "Global gt CLI options; all concrete commands inherit from this.
These flags apply to all gt commands.")

;;; Command Execution Result

(defclass gastown-command-execution ()
  ((command
    :initarg :command
    :type gastown-command
    :documentation "The command that was executed.")
   (exit-code
    :initarg :exit-code
    :type (or null integer)
    :initform nil
    :documentation "Exit code from command execution.
0 indicates success, non-zero indicates failure.")
   (stdout
    :initarg :stdout
    :type (or null string)
    :initform nil
    :documentation "Standard output from command execution.")
   (stderr
    :initarg :stderr
    :type (or null string)
    :initform nil
    :documentation "Standard error from command execution.")
   (result
    :initarg :result
    :initform nil
    :documentation "Parsed/processed result data after command execution."))
  :documentation "Result of executing a gastown-command.")

;;; Generic Methods

(cl-defgeneric gastown-command-execute (command)
  "Execute COMMAND by building arguments and running gt CLI.
Returns a `gastown-command-execution' object.")

(cl-defgeneric gastown-command-line (command)
  "Build full command line from COMMAND object.
Returns a list of strings starting with the executable.")

(cl-defgeneric gastown-command-validate (command)
  "Validate COMMAND and return error string or nil if valid.")

(cl-defgeneric gastown-command-subcommand (command)
  "Return the CLI subcommand name for COMMAND.")

(cl-defgeneric gastown-command-execute-interactive (command)
  "Execute COMMAND interactively, showing output to user.")

(cl-defgeneric gastown-command-preview (command)
  "Preview what COMMAND would execute without running it.")

(cl-defgeneric gastown-command-parse (command execution)
  "Parse EXECUTION output for COMMAND and return the parsed result.")

;;; Bridge Methods for beads-meta Compatibility
;;
;; beads-meta-define-transient generates suffixes that call
;; beads-command-validate, beads-command-execute-interactive, and
;; beads-command-preview.  These bridge methods delegate from the
;; beads-command generics to the gastown-command generics.

(declare-function beads-command-validate "beads-command")
(declare-function beads-command-execute-interactive "beads-command")
(declare-function beads-command-preview "beads-command")

(cl-defmethod beads-command-validate ((command gastown-command))
  "Bridge COMMAND: delegate to `gastown-command-validate'."
  (gastown-command-validate command))

(cl-defmethod beads-command-execute-interactive ((command gastown-command))
  "Bridge COMMAND: delegate to `gastown-command-execute-interactive'."
  (gastown-command-execute-interactive command))

(cl-defmethod beads-command-preview ((command gastown-command))
  "Bridge COMMAND: delegate to `gastown-command-preview'."
  (gastown-command-preview command))

;;; Base Implementations

(cl-defmethod gastown-command-line :around ((_command gastown-command))
  "Prepend executable to command line built by primary method."
  (cons gastown-executable (cl-call-next-method)))

(cl-defmethod gastown-command-line ((command gastown-command))
  "Build command arguments from COMMAND using slot metadata."
  (let ((global-args (gastown-command--build-global-options command))
        (subcommand (gastown-command-subcommand command)))
    (if subcommand
        (append (split-string subcommand)
                global-args
                (beads-meta-build-command-line command))
      global-args)))

(cl-defmethod gastown-command-validate ((_command gastown-command))
  "Default validation: return nil (valid)."
  nil)

(cl-defmethod gastown-command-subcommand ((command gastown-command))
  "Auto-derive subcommand name from COMMAND class name.
Strips \"gastown-command-\" prefix and replaces hyphens with spaces.
For the abstract `gastown-command' class itself, returns nil.
Checks for a class-allocated cli-command slot first (set via :cli-command
in `gastown-defcommand')."
  (let ((class-name (symbol-name (eieio-object-class command))))
    (unless (equal class-name "gastown-command")
      (let ((cli-cmd (and (slot-exists-p command 'cli-command)
                          (slot-boundp command 'cli-command)
                          (oref command cli-command))))
        (or cli-cmd
            (when (string-match "\\`gastown-command-\\(.+\\)\\'" class-name)
              (replace-regexp-in-string
               "-" " " (match-string 1 class-name))))))))

(cl-defmethod gastown-command-execute-interactive ((command gastown-command))
  "Default: run COMMAND in terminal buffer."
  (let* ((cmd-line (gastown-command-line command))
         (cmd-string (mapconcat #'shell-quote-argument cmd-line " "))
         (buffer-name (format "*gt %s*" (or (nth 1 cmd-line) "command")))
         (default-dir (expand-file-name default-directory)))
    (gastown-command--run-in-terminal cmd-string buffer-name default-dir)))

(cl-defmethod gastown-command-preview ((command gastown-command))
  "Default: return formatted command line for COMMAND."
  (let* ((cmd-line (gastown-command-line command))
         (cmd-string (mapconcat #'shell-quote-argument cmd-line " ")))
    (message "Command: %s" cmd-string)
    cmd-string))

(cl-defmethod gastown-command-parse ((command gastown-command) execution)
  "Parse output from COMMAND using EXECUTION data.
When :json is t, parses stdout as JSON and returns an alist.
When :json is nil (default), returns stdout string."
  (if (not (oref command json))
      (oref execution stdout)
    (let ((stdout (oref execution stdout)))
      (condition-case err
          (let* ((json-object-type 'alist)
                 (json-array-type 'vector)
                 (json-key-type 'symbol))
            (json-read-from-string stdout))
        (error
         (signal 'gastown-json-parse-error
                 (list (format "Failed to parse JSON: %s"
                               (error-message-string err))
                       :exit-code (oref execution exit-code)
                       :stdout stdout
                       :stderr (oref execution stderr)
                       :parse-error err)))))))

;;; Base Command Execution

(cl-defmethod gastown-command-execute ((command gastown-command))
  "Execute COMMAND and return a `gastown-command-execution' object."
  ;; Validate first
  (when-let ((error-msg (gastown-command-validate command)))
    (signal 'gastown-validation-error
            (list (format "Command validation failed: %s" error-msg)
                  :command command
                  :error error-msg)))

  ;; Build full command line
  (let* ((cmd (gastown-command-line command))
         (cmd-string (mapconcat #'shell-quote-argument cmd " "))
         (stderr-file (make-temp-file "gastown-stderr-")))

    (when (fboundp 'gastown--log)
      (gastown--log 'info "Running: %s" cmd-string))

    (unwind-protect
        (with-temp-buffer
          (let* ((proc-exit-code
                  (condition-case err
                      (apply #'process-file
                             (car cmd) nil
                             (list (current-buffer) stderr-file)
                             nil (cdr cmd))
                    (file-error
                     (signal 'gastown-command-error
                             (list (format "Executable not found: %s (%s)"
                                           (car cmd)
                                           (error-message-string err))
                                   :command cmd-string
                                   :exit-code nil
                                   :stdout ""
                                   :stderr "")))))
                 (proc-stdout (buffer-string))
                 (proc-stderr (with-temp-buffer
                                (insert-file-contents stderr-file)
                                (buffer-string)))
                 (execution (gastown-command-execution
                             :command command
                             :exit-code proc-exit-code
                             :stdout proc-stdout
                             :stderr proc-stderr)))

            (when (fboundp 'gastown--log)
              (gastown--log 'info "Exit code: %d" proc-exit-code))

            (if (zerop proc-exit-code)
                ;; Success: parse output and set result
                (let ((parsed (gastown-command-parse command execution)))
                  (oset execution result parsed)
                  execution)
              ;; Signal error with complete information
              (signal 'gastown-command-error
                      (list (format "Command failed with exit code %d"
                                    proc-exit-code)
                            :command cmd-string
                            :exit-code proc-exit-code
                            :stdout proc-stdout
                            :stderr proc-stderr)))))

      ;; Cleanup temp file
      (when (file-exists-p stderr-file)
        (delete-file stderr-file)))))

;;; Global Options Helper

(defconst gastown-command--global-option-slots
  '(verbose)
  "List of slot names that are global gt CLI options.")

(defun gastown-command--build-global-options (command)
  "Build command-line arguments for global options in COMMAND."
  (let ((result nil)
        (class-name (eieio-object-class command)))
    (dolist (slot-name gastown-command--global-option-slots)
      (when (and (slot-exists-p command slot-name)
                 (slot-boundp command slot-name))
        (let* ((value (eieio-oref command slot-name))
               (long-opt (beads-meta-slot-property class-name slot-name
                                                   :long-option))
               (option-type (or (beads-meta-slot-property class-name slot-name
                                                          :option-type)
                                :string)))
          (when (and value long-opt)
            (pcase option-type
              (:boolean
               (push (concat "--" long-opt) result))
              (_
               (push (concat "--" long-opt) result)
               (push (if (stringp value) value (format "%s" value)) result)))))))
    (nreverse result)))

(provide 'gastown-command)
;;; gastown-command.el ends here
