;;; gastown-terminal-test.el --- Tests for gastown-terminal -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Tests for gastown-terminal.el mouse wheel forwarding.

;;; Code:

(require 'ert)
(require 'gastown-terminal)

(defvar vterm-copy-mode)

;;; Minor mode tests

(ert-deftest gastown-terminal-test-mode-defines-keymap ()
  "The minor mode keymap binds wheel events."
  (should (lookup-key gastown-terminal-mouse-mode-map [wheel-up]))
  (should (lookup-key gastown-terminal-mouse-mode-map [wheel-down])))

(ert-deftest gastown-terminal-test-mode-binds-double-wheel ()
  "The minor mode keymap binds double-wheel events."
  (should (lookup-key gastown-terminal-mouse-mode-map [double-wheel-up]))
  (should (lookup-key gastown-terminal-mouse-mode-map [double-wheel-down])))

(ert-deftest gastown-terminal-test-mode-binds-triple-wheel ()
  "The minor mode keymap binds triple-wheel events."
  (should (lookup-key gastown-terminal-mouse-mode-map [triple-wheel-up]))
  (should (lookup-key gastown-terminal-mouse-mode-map [triple-wheel-down])))

(ert-deftest gastown-terminal-test-mode-toggle ()
  "The minor mode can be toggled on and off."
  (with-temp-buffer
    (gastown-terminal-mouse-mode 1)
    (should gastown-terminal-mouse-mode)
    (gastown-terminal-mouse-mode -1)
    (should-not gastown-terminal-mouse-mode)))

(ert-deftest gastown-terminal-test-mode-lighter ()
  "The minor mode shows TM lighter."
  (with-temp-buffer
    (gastown-terminal-mouse-mode 1)
    (should (member '(gastown-terminal-mouse-mode " TM") minor-mode-alist))
    (gastown-terminal-mouse-mode -1)))

;;; SGR escape sequence tests

(ert-deftest gastown-terminal-test-send-wheel-up-sends-sgr ()
  "Wheel up sends SGR button 64 to the process."
  (skip-unless (require 'vterm nil t))
  (let ((sent nil))
    (cl-letf (((symbol-function 'derived-mode-p) (lambda (&rest _) t))
              ((symbol-function 'get-buffer-process) (lambda (_) 'fake-proc))
              ((symbol-function 'process-live-p) (lambda (_) t))
              ((symbol-function 'process-send-string)
               (lambda (_proc str) (setq sent str)))
              ((symbol-function 'gastown-terminal--posn-col-row)
               (lambda (_) '(4 . 9)))
              ((symbol-function 'gastown-terminal--event-start) #'identity)
              ((symbol-function 'gastown-terminal--posn-window)
               (lambda (_) (selected-window)))
              ((symbol-function 'window-buffer)
               (lambda (_) (current-buffer))))
      (with-temp-buffer
        (gastown-terminal--send-mouse-wheel 'fake-event 64))
      (should (equal sent "\e[<64;5;10M")))))

(ert-deftest gastown-terminal-test-send-wheel-down-sends-sgr ()
  "Wheel down sends SGR button 65 to the process."
  (skip-unless (require 'vterm nil t))
  (let ((sent nil))
    (cl-letf (((symbol-function 'derived-mode-p) (lambda (&rest _) t))
              ((symbol-function 'get-buffer-process) (lambda (_) 'fake-proc))
              ((symbol-function 'process-live-p) (lambda (_) t))
              ((symbol-function 'process-send-string)
               (lambda (_proc str) (setq sent str)))
              ((symbol-function 'gastown-terminal--posn-col-row)
               (lambda (_) '(0 . 0)))
              ((symbol-function 'gastown-terminal--event-start) #'identity)
              ((symbol-function 'gastown-terminal--posn-window)
               (lambda (_) (selected-window)))
              ((symbol-function 'window-buffer)
               (lambda (_) (current-buffer))))
      (with-temp-buffer
        (gastown-terminal--send-mouse-wheel 'fake-event 65))
      (should (equal sent "\e[<65;1;1M")))))

(ert-deftest gastown-terminal-test-fallback-when-not-vterm ()
  "Falls back to `mwheel-scroll' when not in vterm-mode."
  (let ((fell-back nil))
    (cl-letf (((symbol-function 'derived-mode-p) (lambda (&rest _) nil))
              ((symbol-function 'get-buffer-process) (lambda (_) nil))
              ((symbol-function 'mwheel-scroll)
               (lambda (_event) (setq fell-back t)))
              ((symbol-function 'gastown-terminal--posn-col-row)
               (lambda (_) '(0 . 0)))
              ((symbol-function 'gastown-terminal--event-start) #'identity)
              ((symbol-function 'gastown-terminal--posn-window)
               (lambda (_) (selected-window)))
              ((symbol-function 'window-buffer)
               (lambda (_) (current-buffer))))
      (with-temp-buffer
        (gastown-terminal--send-mouse-wheel 'fake-event 64))
      (should fell-back))))

(ert-deftest gastown-terminal-test-no-send-when-process-dead ()
  "Does not send when the process is not live."
  (let ((sent nil))
    (cl-letf (((symbol-function 'derived-mode-p) (lambda (&rest _) t))
              ((symbol-function 'get-buffer-process) (lambda (_) 'fake-proc))
              ((symbol-function 'process-live-p) (lambda (_) nil))
              ((symbol-function 'process-send-string)
               (lambda (_proc str) (setq sent str)))
              ((symbol-function 'gastown-terminal--posn-col-row)
               (lambda (_) '(0 . 0)))
              ((symbol-function 'gastown-terminal--event-start) #'identity)
              ((symbol-function 'gastown-terminal--posn-window)
               (lambda (_) (selected-window)))
              ((symbol-function 'window-buffer)
               (lambda (_) (current-buffer))))
      (with-temp-buffer
        (gastown-terminal--send-mouse-wheel 'fake-event 64))
      (should-not sent))))

;;; Hook registration tests

(ert-deftest gastown-terminal-test-vterm-mode-hook-registered ()
  "gastown-terminal--vterm-setup is registered in vterm-mode-hook."
  (should (memq #'gastown-terminal--vterm-setup vterm-mode-hook)))

(ert-deftest gastown-terminal-test-vterm-copy-mode-hook-registered ()
  "gastown-terminal--vterm-copy-mode-setup is registered in vterm-copy-mode-hook."
  (should (memq #'gastown-terminal--vterm-copy-mode-setup vterm-copy-mode-hook)))

(ert-deftest gastown-terminal-test-vterm-setup-enables-mouse-mode ()
  "gastown-terminal--vterm-setup enables gastown-terminal-mouse-mode."
  (with-temp-buffer
    (gastown-terminal--vterm-setup)
    (should gastown-terminal-mouse-mode)
    (gastown-terminal-mouse-mode -1)))

(ert-deftest gastown-terminal-test-copy-mode-setup-disables-mouse-mode ()
  "gastown-terminal--vterm-copy-mode-setup disables mouse mode when copy mode is on."
  (with-temp-buffer
    (gastown-terminal-mouse-mode 1)
    (let ((vterm-copy-mode t))
      (gastown-terminal--vterm-copy-mode-setup))
    (should-not gastown-terminal-mouse-mode)))

(ert-deftest gastown-terminal-test-copy-mode-setup-reenables-mouse-mode ()
  "gastown-terminal--vterm-copy-mode-setup re-enables mouse mode when copy mode exits."
  (with-temp-buffer
    (let ((vterm-copy-mode nil))
      (gastown-terminal--vterm-copy-mode-setup))
    (should gastown-terminal-mouse-mode)
    (gastown-terminal-mouse-mode -1)))

(provide 'gastown-terminal-test)
;;; gastown-terminal-test.el ends here
