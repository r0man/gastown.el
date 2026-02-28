;;; guix.scm --- Guix package definition for emacs-gastown

;; This file defines the emacs-gastown package for GNU Guix.
;; Use with: guix shell -D -f guix.scm
;; This provides a development environment with emacs-eldev and
;; other dependencies.

(use-modules
 (guix packages)
 (guix gexp)
 (guix git-download)
 (guix build-system emacs)
 ((guix licenses) #:prefix license:)
 (gnu packages emacs)
 (gnu packages emacs-xyz)
 (gnu packages emacs-build)
 (guix git))

(define %source-dir (dirname (current-filename)))

(define emacs-gastown
  (package
    (name "emacs-gastown")
    (version "0.1.0")
    (source (local-file %source-dir
                        "emacs-gastown-checkout"
                        #:recursive? #t
                        #:select? (git-predicate %source-dir)))
    (build-system emacs-build-system)
    (arguments
     (list
      #:emacs emacs  ; Use full Emacs with GnuTLS support
      #:tests? #f    ; Tests require gt CLI and mock setup
      #:lisp-directory "lisp"
      #:exclude #~(cons ".*-test\\.el$" %default-exclude)))
    (propagated-inputs
     (list emacs-transient))
    (native-inputs
     (list emacs-eldev emacs-package-lint emacs-undercover
           emacs-claude-code-ide))
    (home-page "https://github.com/r0man/gastown.el")
    (synopsis "Magit-like Emacs interface for Gas Town workspace manager")
    (description
     "This package provides a comprehensive Emacs interface for the Gas Town
multi-agent workspace manager, inspired by Magit.  It offers keyboard-driven,
transient-based UI for managing workspaces without leaving Emacs.

Features:
@itemize
@item Transient menus for all gt CLI commands
@item Agent management (polecats, witnesses, refineries)
@item Work dispatch and tracking (sling, convoys, merge queue)
@item Communication (mail, nudge, broadcast)
@item Service management and diagnostics
@end itemize

Requires the gt CLI tool to be installed and available in PATH.")
    (license license:gpl3+)))

emacs-gastown
