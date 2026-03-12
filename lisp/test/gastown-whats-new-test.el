;;; gastown-whats-new-test.el --- Tests for gastown-whats-new -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for gastown-whats-new.el.
;;
;; Tests cover:
;;   - Function and variable existence
;;   - Line vnode rendering (heading, section header, bullet, plain)
;;   - Mode derivation
;;   - execute-interactive override

;;; Code:

(require 'ert)
(require 'gastown-whats-new)

;;; Existence tests

(ert-deftest gastown-whats-new-test-fetch-defined ()
  "gastown-whats-new--async-fetch is defined."
  (should (fboundp 'gastown-whats-new--async-fetch)))

(ert-deftest gastown-whats-new-test-line-vnode-defined ()
  "gastown-whats-new--line-vnode is defined."
  (should (fboundp 'gastown-whats-new--line-vnode)))

(ert-deftest gastown-whats-new-test-app-registered ()
  "gastown-whats-new-app is registered as a vui component."
  (should (gethash 'gastown-whats-new-app vui--component-registry)))

(ert-deftest gastown-whats-new-test-entry-point-defined ()
  "gastown-whats-new interactive entry point is defined."
  (should (fboundp 'gastown-whats-new)))

(ert-deftest gastown-whats-new-test-buffer-name-defined ()
  "gastown-whats-new-buffer-name constant is defined."
  (should (boundp 'gastown-whats-new-buffer-name))
  (should (stringp gastown-whats-new-buffer-name)))

;;; Line vnode rendering tests

(ert-deftest gastown-whats-new-test-line-vnode-returns-vnode ()
  "line-vnode returns a non-nil result for any string."
  (should (gastown-whats-new--line-vnode "some text")))

(ert-deftest gastown-whats-new-test-line-vnode-heading ()
  "Title line (starts with 'What's New') renders with bold face."
  (let* ((line "What's New in Gas Town (Current: v0.12.0)")
         (node (gastown-whats-new--line-vnode line))
         (content (vui-vnode-text-content node)))
    (should (stringp content))
    (should (eq 'gastown-whats-new-title (get-text-property 0 'face content)))))

(ert-deftest gastown-whats-new-test-line-vnode-section-header ()
  "Version header line (## v...) renders with gastown-whats-new-version face."
  (let* ((line "## v0.12.0 (2026-03-11) <- current")
         (node (gastown-whats-new--line-vnode line))
         (content (vui-vnode-text-content node)))
    (should (stringp content))
    (should (eq 'gastown-whats-new-version (get-text-property 0 'face content)))))

(ert-deftest gastown-whats-new-test-line-vnode-new-bullet ()
  "NEW bullet renders with gastown-whats-new-new face on the tag."
  (let* ((line "  * NEW: Some new feature")
         (node (gastown-whats-new--line-vnode line))
         (content (vui-vnode-text-content node)))
    (should (stringp content))
    (let ((tag-pos (string-match "NEW:" content)))
      (should tag-pos)
      (should (eq 'gastown-whats-new-new
                  (get-text-property tag-pos 'face content))))))

(ert-deftest gastown-whats-new-test-line-vnode-fix-bullet ()
  "FIX bullet renders with gastown-whats-new-fix face on the tag."
  (let* ((line "  * FIX: Some fix")
         (node (gastown-whats-new--line-vnode line))
         (content (vui-vnode-text-content node)))
    (should (stringp content))
    (let ((tag-pos (string-match "FIX:" content)))
      (should tag-pos)
      (should (eq 'gastown-whats-new-fix
                  (get-text-property tag-pos 'face content))))))

(ert-deftest gastown-whats-new-test-line-vnode-plain-line ()
  "Plain text line renders without error."
  (let ((node (gastown-whats-new--line-vnode "  Some plain text")))
    (should node)))

(ert-deftest gastown-whats-new-test-line-vnode-empty-string ()
  "Empty string renders without error."
  (should (gastown-whats-new--line-vnode "")))

;;; Mode tests

(ert-deftest gastown-whats-new-test-mode-derived-from-vui ()
  "gastown-whats-new-mode is derived from vui-mode."
  (with-temp-buffer
    (gastown-whats-new-mode)
    (should (derived-mode-p 'vui-mode))))

;;; execute-interactive override test

(ert-deftest gastown-whats-new-test-execute-interactive-override ()
  "gastown-command-info execute-interactive calls gastown-whats-new."
  (let ((called nil))
    (cl-letf (((symbol-function 'gastown-whats-new)
               (lambda () (setq called t))))
      (gastown-command-execute-interactive (gastown-command-info)))
    (should called)))

(provide 'gastown-whats-new-test)
;;; gastown-whats-new-test.el ends here
